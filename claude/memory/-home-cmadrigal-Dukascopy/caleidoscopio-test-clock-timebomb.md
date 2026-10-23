---
name: caleidoscopio-test-clock-timebomb
description: "tests/publish/test_caleidoscopio_service.py red on main since 2026-10-23 12:00Z (fixed NOW vs real-clock 24 h expiry, 6 failures); the fix must be an operator commit on main, never carried in a task branch"
metadata:
  node_type: memory
  type: project
  originSessionId: 738f264e-af0c-4d38-87a0-5260ccd5ff4c
  modified: 2026-10-23T14:25:19.276Z
---

From 2026-10-23 12:00Z, 6 tests in tests/publish/test_caleidoscopio_service.py (no_approval..., new_batch_detection...,
ideate_failure..., scan_failure..., second_request_same_tick..., tick_waits_when_agent_ci_is_busy) fail
everywhere: requests are stamped with the test's fixed NOW, but ui/scripts/caleidoscopio_service.py
`new_record`/`tick` call `datetime.now(UTC)` directly (only `now_iso` was patched), so every request is >24 h old.
There is no env/config hook; the fix has to touch tests/publish/ or ui/.

**Why:** a time bomb in the TASK-11.21 test, not the builder's fault; suite-green fails for every task.

**How to apply:** the patch (autouse fixture swapping `svc.datetime` for a `_FrozenDatetime` with a metaclass
`__instancecheck__`) lives at ref `refs/agent-ci/escalations/TASK-13.1/run-20261023-130658-206107/1/after`.
Do NOT put it in a task branch: tests/publish/ and ui/ are in most specs' protected_paths, protected-paths diffs
against merge-base(main, HEAD), and TASK-13.1 burned escalation 1 + a local attempt that way (2026-10-23). Also
never commit-then-revert it on the branch: the re-run refresh rebases, and the revert commit would undo the
operator's fix on main. Check `git log main -- tests/publish/test_caleidoscopio_service.py`; if unfixed, leave the
branch with only owned files and hand the operator the one-file patch for main. Related:
[[operator-commit-red-lint-on-main]], [[registry-commit-breaks-main-suite]].
