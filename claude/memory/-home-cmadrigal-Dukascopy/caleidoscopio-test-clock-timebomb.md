---
name: caleidoscopio-test-clock-timebomb
description: "tests/publish/test_caleidoscopio_service.py red on main since 2026-10-23 12:00Z (fixed NOW vs real-clock 24 h expiry, 6 failures); the fix must be an operator commit on main, never carried in a task branch"
metadata:
  node_type: memory
  type: project
  originSessionId: 738f264e-af0c-4d38-87a0-5260ccd5ff4c
  modified: 2026-10-23T17:29:35.556Z
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

Still unfixed on main at 2026-10-23 ~15:40Z (triage of TASK-13.1 run-143452: NEEDS YOU, not retried to save escalation; TASK-14.5 suite: exactly these 6 red; TASK-14.1 escalation later that day: same 6, patch verified green then reverted). `git diff <ref>^ <ref> -- tests/publish/test_caleidoscopio_service.py` applies cleanly to main.
Still unfixed ~16Z (TASK-14.4 escalation run-152524: same 6 + an owned-file E501; patch re-checked against main with `git apply --check`).
Still unfixed ~17Z: TASK-14.1 escalation 2 (run-163704) hit exactly these 6 again with main = 91e0d12. TASK-14.1 has now burned 3 runs on it, so retrying before the main fix wastes the escalation.
Still unfixed ~16:55Z: TASK-13.1 escalation 3 (run-163705, main 91e0d12). Branch left at f52043e with only its 3 owned files, and every own check is green (module tests, ruff, stray, strict-lint-new). The patch still applies cleanly and turns the file 38/38 green. TASK-13.1 has used all 3 escalations, and 13.2..13.9 are blocked behind it.
Still unfixed ~17:30Z: TASK-14.5 escalation 2 (run-170747, main 91e0d12). Branch left at 64ac03c with only its 2 owned files, and every own check is green. Its 5 reviewer findings (F001..F005: conflicts / missing_days / empty-frame sort) were all misreadings, so nothing was applied ([[stale-reviewer-lint-findings]]). A copy of the patch was saved to /tmp/caleido-clock-fix-14.5.patch.
Still unfixed ~17:35Z: TASK-14.4 escalation 2 (run-170210, main 91e0d12). The full suite has exactly these 6 red. Changes left uncommitted with only the 5 owned files, and every own check is green. To verify the patch without touching protected files even temporarily, use a scratch mirror: a /tmp dir with symlinks to `ui` and `tests/_plugins` (pyproject's `-p fxplat_parallel` needs it), copies of tests/conftest.py and pyproject.toml, and the patched test file. Run it with the worktree's .venv. Result: 38/38 green.
