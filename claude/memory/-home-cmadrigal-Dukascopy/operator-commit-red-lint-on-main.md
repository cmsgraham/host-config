---
name: operator-commit-red-lint-on-main
description: "operator ui commits (e19cd49, 2026-10-22) left E501 in tests/publish/ on main; every task acceptance `ruff check src tests` fails regardless of the builder's work"
metadata:
  node_type: memory
  type: project
  originSessionId: fc147c98-d508-4486-941c-54473608583c
  modified: 2026-10-22T20:38:33.907Z
---

2026-10-22: operator commit e19cd49 (f1costs/observations exporters) put 16 E501 errors in
tests/publish/test_export_observations.py (15) and test_export_f1costs.py (1) on main. Any task whose
acceptance runs `ruff check src tests` fails lint-and-no-stray even with clean task files (TASK-11.13 burned
its attempt on it; the builder correctly saw "pre-exists on main" and quit). Reviewer findings then name
those non-owned files.

**Why:** operator commits to main skip the lint gate; tests/publish/ is protected in most hallazgos/ui specs,
so the protected-paths check (diff vs merge-base with main) flags a branch-side fix.

**How to apply:** first run `ruff check src tests` on main; if red, the real fix is a format-only commit on
main (operator pattern: state/lint_fix_main.sh / land_lint.sh) and then ff the task branch. Escalation in
TASK-11.13 applied the same format-only fix in the worktree. Still red on main at 70d0b2f;
TASK-11.17 (2026-10-22) applied the byte-identical patch (`git -C <11.13 worktree> diff -- tests/publish/`
| `git apply`) so the branches merge cleanly — reuse that patch until main gets the fix. TASK-9.7
(2026-10-22, strong-direct build) reused it too; its protected_paths list only named test_publish_*.py, so
the test_export_*.py edit is not a protected-path hit there — check each spec's list before applying.
TASK-9.8 (2026-10-22, strong-direct) reused it as well (same protected_paths shape; still red on main 70d0b2f).
RESOLVED on main 01d744f (2026-10-22): the patch landed via the TASK-9.7 merge (5ab89b2); `ruff check src
tests` is green on main, so do not re-apply it — a refreshed branch's diff vs main no longer shows tests/publish/. Related: [[containment-false-positive-operator-ui]],
[[registry-commit-breaks-main-suite]].
