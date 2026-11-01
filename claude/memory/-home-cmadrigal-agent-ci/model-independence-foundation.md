---
name: model-independence-foundation
description: "Operator foundation 2026-11-01 - builder and every checker (reviewer, test auditor, phase reviewer) must be different model families"
metadata:
  node_type: memory
  type: feedback
  originSessionId: 1c4d5b2e-1683-4d80-96df-42f632213acd
  modified: 2026-11-01T22:50:25.481Z
---

Cristian, 2026-11-01: "add to the foundations of this setup: we don't want builder and auditor on the same family; if Qwen builds, another family audits."

Enforced in agent-ci c14a1c6 (`agent_ci/families.py`, load_config refuses; `models.allow_same_family` waiver; dashboard switch refuses). fxplat switched (5d20cf8): reviewer qwen3-coder-next:80b -> devstral-small-2:24b (Mistral), test_audit gemma3:27b -> gemma4:31b (Google). Builder stays qwen3.8:27b.

**Why:** a same-family checker shares the builder's blind spots and approves what it would have written itself.
**How to apply:** when recommending or switching ANY model, check the family against the builder first; never suggest a Qwen reviewer for a Qwen builder (I had suggested qwen3.8 as reviewer before this rule). Other projects (malware-lab, x-scraping, snoopy-demo, Dukascopy-* clones) still fail the rule and won't start until fixed. Watch the first ~10 devstral reviews (verdict mix, FAILED rate) vs the 80b's 216 APPROVE / 68 FIX / 15 FAILED since 10-20.
