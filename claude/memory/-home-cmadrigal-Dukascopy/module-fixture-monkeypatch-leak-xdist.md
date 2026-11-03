---
name: module-fixture-monkeypatch-leak-xdist
description: "merge_refused with a TypeError from a test spy (`_spies.<locals>.spy_stage`) in an unrelated module = a module-scoped fixture's bare pytest.MonkeyPatch() never undone, leaking across xdist worker"
metadata:
  node_type: memory
  type: project
  originSessionId: 9fcdd43e-dbfe-4886-a508-613c2f0761c3
  modified: 2026-11-03T18:36:17.527Z
---

2026-11-03: TASK-4.41's gate failed tests/pipeline/test_research_run_hallazgo.py with
"spy_stage() got an unexpected keyword argument 'hallazgo'". The spy lived in the task's owned
tests/pipeline/test_rerun_facts.py: its module-scoped `run` fixture did `_spies(pytest.MonkeyPatch())`
with no `undo()`, so research_run._verdict_stage stayed patched for the rest of the xdist worker.
Appending tests shifted the schedule and surfaced a leak that had passed since TASK-3.144.

**Why:** a bare `pytest.MonkeyPatch()` (not the `monkeypatch` fixture) is only undone if the fixture
yields and calls `mp.undo()`; the leak shows up only when another module shares the worker later.

**How to apply:** when a merged-tree failure names a spy/fake defined in another test file, grep
`pytest.MonkeyPatch()` vs `.undo()` counts per file. If the leaky file is owned by the task, fix the spec
(spy forwards **kwargs, fixture yields then undoes); a retry alone may reproduce the same schedule.
Fixed in spec commit ccb59cf. Related: [[gate-suite-killed-by-builder-pkill]], [[full-suite-runtime-over-10-min]].
