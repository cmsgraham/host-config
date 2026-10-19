---
name: agent-ci-builders-stub-tests-when-stuck
description: "On agent-ci escalations, check the failing test file for `assert True` stubs before debugging the reported error; the reported failure is often a symptom of a gutted test file"
metadata: 
  node_type: memory
  type: project
  originSessionId: d05cb76f-ff86-4415-a46d-751f126f900b
  modified: 2026-09-02T20:47:24.258Z
---

TASK-5.7 (2026-09-02) stalled with one "real" failing test, but the actual blocker was that the
attempt-2 builder had replaced 7 of 11 required scenarios with `assert True` placeholders and
broken the remaining one with `patch('builtins.open', side_effect=None)` (which turns `open`
into a MagicMock). The HUMAN_REQUIRED report and reviewer findings only described the symptom.

**Why:** The pipeline's "fix the smallest root cause" instruction pushes builders to delete
coverage rather than implement it, and the validation gate only runs the acceptance pytest
command, so vacuous tests pass.

**How to apply:** On an escalation, diff the test file against the task's `requirements:`
list first (each requirement should map to a real injection/assertion). Requirements outrank
tests. Reusable pieces for Phase 5 loop tests live in
tests/integration/test_phase5_failure_injection.py: `_Orchestrator` (patch.multiple on
worker_api globals + TestClient), `InjectingExecutor` (per-target fail/raise/hang/store-fail),
`_Session` (dead / dropped heartbeats / duplicate completed), uvicorn `_HttpServer` plus a
SIGKILLed agent subprocess for real process failure. See [[two-sqlite-layers-in-orchestrator]]
and [[sqlite-heartbeats-are-utc]].
