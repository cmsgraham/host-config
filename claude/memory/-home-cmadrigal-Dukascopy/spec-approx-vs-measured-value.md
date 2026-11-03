---
name: spec-approx-vs-measured-value
description: "Spec requirement approx(rounded, abs=1e-6) can contradict the spec's own measured value (16.83 995.659 vs 995.6589959999999); plus reviewer \"missing imports\" false positive"
metadata:
  node_type: memory
  type: feedback
  originSessionId: e440cb34-8eb4-4718-8f5e-242a3a869bb7
  modified: 2026-11-03T03:37:43.404Z
---

TASK-16.83: requirement (d) said `pytest.approx(995.659, abs=1e-6)` but the registered measured value
is 995.6589959999999 (4e-6 off) — unpassable. Builder loosened to 1e-4; escalation pinned the measured
value at the spec tolerance (`approx(995.658996, abs=1e-6)`). The run actually stalled on a reviewer false
positive: F001 "test file missing imports Fun/with_h1_row/..." while lines 16-17 imported them all.

**Why:** spec writers round measured floats when drafting requirement phrases; the reviewer
hallucinates missing imports on sibling-module imports (`from test_fun_sim import ...`).
**How to apply:** when a spec approx fails, compare to the spec's own "measured" numbers before changing
code; for "missing imports" findings, grep the file first. See [[reviewer-misreads-error-path-tests]],
[[stale-reviewer-lint-findings]].
