---
name: cold-prefill-loop
description: "2026-09-29 a long Cline task looped after a 30-min pause; root cause is the prompt cache dying with the model unload; gateway now refuses oversized prompts, sends early headers + keep-alives, keeps agentic models warm 2h; llama.cpp slot restore works only for a prompt-only state"
metadata:
  node_type: memory
  type: project
  originSessionId: bdd81c4e-aab0-404b-852e-e2612ce47dd1
  modified: 2026-09-30T00:51:12.365Z
---

On 2026-09-29 a Cline task (~172k real tokens; the gateway estimated 98k) failed on every
retry from 14:13 on while health stayed green. Ollama was healthy throughout.

**Root cause (from the user's own records):** 204 of 207 large Cline turns in 7 days got their
first token in a median 2.5 s (prompt cache reused). The 3 slow ones all followed an idle gap
longer than `OLLAMA_KEEP_ALIVE=30m`: unloading the model throws away the read prompt, and the
cold re-read (650-1,100 tok/s) is silent because Ollama sends nothing, headers included, until
the first token. Cline (and Node undici) stop waiting after 300 s; the gateway's flat 180 s
timeout cut it even earlier and walked the fallback chain.

**What the gateway does now** (all uncommitted in `~/ollama-gateway`; backups
`*.bak-prefill-20260929` and `*.bak-steps123-20260929`; `tests/test_prefill.py`, suite 127 green):
1. `truncate: false` on every request -> Ollama answers 400 with exact counts in ~0.3 s; passed on
   as HTTP 400 `context_length_exceeded` (status `refused`). Never send `shift`: it reloads the runner.
2. Early headers after 60 s of silence + keep-alive every 15 s (blank line on NDJSON, `: keep-alive`
   on SSE), streaming only; errors after that are in-band. 240 s hold when the prompt may not fit.
3. `keep_alive: "2h"` on agentic requests; kept-warm cards are exempt from the idle_allocation rule.
4. Backstops from the first round: prompt-sized first-token allowance, watchdog/cancel work in
   prefill, no fallback on a slow read, fallbacks must fit, client-gone detection, health rules.
5. Unload/Switch/Delete now use the API and confirm: `ollama` is NOT on the gateway service PATH,
   so they had been failing silently while logging success.

**Why:** the user rejected the first round as "the easiest, not the engineering solution" and asked
for research. Research (Ollama source, llama.cpp source, LiteLLM/Envoy/OpenRouter/Cline) showed the
standard answers are refusal with the OpenAI error contract, early headers + heartbeats, and staying
warm; sizing a timeout from prompt length exists in no gateway.

**llama.cpp trial (not adopted, user approved the test):** slot save/restore works on this model ONLY
if the state is saved at the end of the prompt (same prompt again with `n_predict: 0`, then save):
next turn after a full restart read 20 tokens in 1.1 s. A state saved after a generated reply
restores "successfully" and is then re-read in full. 106k tokens = 3.59 GiB, save/restore ~3 s.
Running the bundled runner outside Ollama needs `GGML_BACKEND_PATH=<lib>/cuda_v13/libggml-cuda.so`,
otherwise it silently loads on the CPU (13 tok/s). Batch size 512 vs 2048: no speed difference.

**How to apply:** research how the upstream projects solve a problem before building a workaround,
and test claims on this stack. When a request "times out", read the Ollama journal `progress =`
lines first. Not yet verified: Cline itself against the early headers and the 400 (only raw
clients were used). Open decision: adopting llama-server with slot persistence as a backend.
See [[gateway-rebuild-2026-09-27]], [[gateway-user-manual]], [[gateway-model-override-hijack]],
[[user-goal-autonomous-devinfra]].
