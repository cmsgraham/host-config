---
name: one-suite-per-task
description: "2026-10-31 fxplat runs the full suite ONCE per task (merge gate); attempts mark suite checks DEFERRED; gate skips 'timing' tests; idle split by STOP; stop reminder ask"
metadata:
  node_type: memory
  type: project
  originSessionId: 1c4d5b2e-1683-4d80-96df-42f632213acd
  modified: 2026-11-01T01:19:33.337Z
---

Operator 2026-10-31 ("only improvements that buy quality or time, not because cool"), after
I compared agent-ci with a harness-engineering article and measured our own logs (10-15..31):
- Each task ran the full suite 3x (attempt suite-green 5,230 min, gate suite-green 3,760,
  gate full_suite_cmd 3,483). The attempt copy caught 19 extra failures, ~17 of them main's
  own breakage (Caleidoscopio 10-23 x14), load timeouts, or timing flakes. Now
  `validation.defer_suite_to_gate: true` (agent-ci d1ee4f3): suite checks read DEFERRED in
  attempts and in the gate's re-run of task checks; git.full_suite_cmd is the one run.
- Gate suite sets FXPLAT_SKIP_TIMING=1: 7 wall-clock tests carry @pytest.mark.timing
  (tests/conftest.py hook); they still run in their own tasks' module tests.
- `agent-ci stats` undercounted the gate (full_suite_cmd log ignored): idle 44 % -> 35 %.
  It now splits idle by operator stop (state/stop-history.jsonl; `agent-ci stop --reason`).
- Largest idle gap: a reasonless STOP 10-27 18:43 -> 10-30 09:59 (63 h, 4 ready). Now
  `ops.stop_reminder_hours` (4): phone ask "resume?" (safe = stay stopped), every 12 h
  (agent-ci 2862a4a). Set a --reason on every stop I request.

**Why:** time on the critical path and forgotten stops were the measured losses.
**How to apply:** re-measure with `agent-ci stats --since 2026-11-01` after ~2 weeks; if gate
failures rise sharply, revisit. Related: [[parallel-suite-gate-timeout]], [[main-lint-wedges-all-tasks]].
