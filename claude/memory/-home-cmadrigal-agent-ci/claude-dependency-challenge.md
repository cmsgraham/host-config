---
name: claude-dependency-challenge
description: "Operator's current main challenge (2026-11-02): lower agent-ci's reliance on Claude escalation; baseline numbers"
metadata:
  node_type: memory
  type: project
  originSessionId: 1c4d5b2e-1683-4d80-96df-42f632213acd
  modified: 2026-11-03T05:26:43.341Z
---

2026-11-02 (night): operator said "we need to lower the dependency on Claude, that's the challenge now". Planned to look at it together on 2026-11-03.

Baseline from `agent-ci stats` on fxplat:
- Since 11-01: 77 passed tasks; 34 needed escalation (44 %), of which 16 were strong_direct (hard specs routed straight to Claude) and the rest were local stalls (missing_owned_test 7, builder_error 7, review_fix 7). All 34 escalations succeeded.
- 10-27..10-31: about 27 % needed escalation.
- pass@1 about 65 %, unchanged after the 11-01 model-independence switch (reviewer devstral-small-2:24b, test_audit gemma4:31b).
- Throughput rose from ~20 to 32-39 merges/day after defer_suite_to_gate (validate went from 7.2 to 1.1 min average).

**Why:** Claude usage hits the weekly cap ([[claude-usage-50pct-rule]], now 80 %), which stops refill and escalations. See [[local-builder-gap-research]] and [[model-independence-foundation]].

**How to apply:** start from the levers: missing_owned_test (the builder doesn't write its required tests), review_fix loops, and which specs get routed strong_direct and why. Measure with `agent-ci stats --since`.
