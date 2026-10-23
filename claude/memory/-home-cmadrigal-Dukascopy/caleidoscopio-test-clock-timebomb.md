---
name: caleidoscopio-test-clock-timebomb
description: "tests/publish/test_caleidoscopio_service.py went red on main 2026-10-23 12:00Z: fixed NOW=2026-10-22T12Z vs the service's real datetime.now 24 h expiry ('caducada' != 'hecha'), 6 failures"
metadata:
  node_type: memory
  type: project
  originSessionId: 034bdd4c-a847-4a4e-9f31-d41bed37227c
  modified: 2026-10-23T13:38:21.482Z
---

From 2026-10-23 12:00Z, 6 tests in tests/publish/test_caleidoscopio_service.py (no_approval..., new_batch_detection...,
ideate_failure..., scan_failure..., second_request_same_tick..., tick_waits_when_agent_ci_is_busy) fail
everywhere: requests are stamped with the test's fixed NOW, but ui/scripts/caleidoscopio_service.py
`new_record`/`tick` call `datetime.now(UTC)` directly (only `now_iso` was patched), so every request is >24 h old.

**Why:** a time bomb in the TASK-11.21 test, not the builder's fault; suite-green fails for every task.

**How to apply:** TASK-13.1 escalation (2026-10-23) added an autouse fixture that swaps `svc.datetime` for a
`_FrozenDatetime` subclass (now() -> NOW) with a metaclass `__instancecheck__` so `is_expired`'s
`isinstance(x, datetime)` still accepts real datetimes. Reuse that exact patch (`git -C <13.1 worktree> diff --
tests/publish/test_caleidoscopio_service.py | git apply`) until it lands on main; check whether it has before you
apply it. tests/publish/ is in most specs' protected_paths. Related: [[operator-commit-red-lint-on-main]],
[[registry-commit-breaks-main-suite]].
