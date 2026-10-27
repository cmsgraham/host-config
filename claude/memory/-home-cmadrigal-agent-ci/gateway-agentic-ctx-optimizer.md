---
name: gateway-agentic-ctx-optimizer
description: gateway grows the agentic num_ctx with the conversation, sized from the CALIBRATED token count
metadata:
  type: project
---

2026-10-26: replaced the fixed agentic num_ctx pin with a growing optimizer in
`~/ollama-gateway/gateway.py`. `choose_agentic_ctx(model, prompt_tokens)` picks from a
ladder [32768..262144] capped per model by `AGENTIC_CTX_BY_MODEL` (uncensored ceiling =
262144): small fast window for short threads, steps UP one bucket as the prompt climbs
(25% grow headroom), holds through wobble (hysteresis via `_agentic_ctx_last`), drops back
only when a clearly smaller conversation starts (`AGENTIC_SHRINK_BELOW=0.45`). Each step up
costs one Ollama reload — unavoidable when num_ctx changes.

**Critical:** size the window from the CALIBRATED token count, NOT the raw char estimate.
The char estimate undercounts agentic (tools/reasoning) traffic ~1.8-1.9x. Passing raw
`ptok` picked a window too small -> Ollama `refused the prompt (N tokens > window)` -> the
request fell back to the base model at full 262144 -> 4-min prefill timeouts (the symptom
the user hit with Cline, 18:49-19:01). Fix: `choose_agentic_ctx(model, calibrated_tokens(ptok,
_src, "typical"))` at the main site and `ptok_fit` at the fallback site. The per-source
ratios (`_est_ratios`, e.g. 'agent (tools)': 1.87) persist across restart via the prefill log.

See [[cold-prefill-loop]] for the related keep-the-model-warm behavior.
