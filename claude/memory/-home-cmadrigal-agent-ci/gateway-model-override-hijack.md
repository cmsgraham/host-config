---
name: gateway-model-override-hijack
description: "The gateway's dashboard model override silently reroutes agent-ci's ARCHITECT role, because alias tags are what the override matches"
metadata: 
  node_type: memory
  type: project
  originSessionId: 3a95969f-0700-4e5c-ad17-66cac7a14b11
  modified: 2026-09-09T06:26:40.911Z
---

The Ollama gateway has a dashboard "switch model" control that writes
`{"override": "<model>"}` to `~/ollama-gateway/control.json`. The override is
applied in `gateway.py` at the request path as:

    ov = get_override()
    if ov and requested.strip() in MODEL_ALIASES:
        model = ov

**It matches only requests whose model name is an ALIAS TAG**, i.e. the keys of
`MODEL_ALIASES`: `qwen3.8:27b-64k`, `qwen3.8:27b-32k`, `qwen3:8b-32k`. It was
built for Cline, which always sends its alias tag unchanged.

**The trap:** agent-ci's ARCHITECT role is configured as `qwen3.8:27b-64k` —
an alias tag. So any override set for a chat experiment silently becomes the
model doing every phase review. Found 2026-09-09 with the override left on
`qwen3.8:27b-uncensored` (set 2026-09-08 20:43); the architect had been
running on the uncensored 27b instead of `qwen3.8:27b`.

Builder (`qwen3-coder:30b`), reviewer (`qwen3-coder-next:80b-iq4xs`) and
test_audit (`gemma3:27b`) are NOT alias tags, so they are never hijacked. Only
the architect is exposed, and nothing in agent-ci reports it — `doctor` checks
the builder and reviewer only.

**How to apply:** check `cat ~/ollama-gateway/control.json` when phase reviews
read oddly. Clear it properly through the API, not by editing the file, so the
in-memory state updates too:

    curl -s -X POST http://127.0.0.1:11434/_dash/action \
      -H 'Content-Type: application/json' -d '{"action":"use_default"}'

Verify by asking for the alias and reading back the served model:

    curl -s http://127.0.0.1:11434/v1/chat/completions -d \
      '{"model":"qwen3.8:27b-64k","messages":[{"role":"user","content":"hi"}],"max_tokens":5}' \
    | python3 -c "import json,sys; print(json.load(sys.stdin)['model'])"   # -> qwen3.8:27b

Startup logs it too: `model override active: <name>` at every gateway boot.
See [[agent-ci-conventions]], [[unified-dashboard-preference]].
