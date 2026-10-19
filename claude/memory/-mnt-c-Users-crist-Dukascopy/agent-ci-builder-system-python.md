---
name: agent-ci-builder-system-python
description: "local builder runs bare `python` (system), hits import errors, never runs its tests and ships untested stubs; check builder-activity.log first"
metadata:
  node_type: memory
  type: project
  originSessionId: 9e2fbeba-f72e-4b7a-8d29-2105d2691e9b
  modified: 2026-10-05T12:55:07.083Z
---

In agent-ci escalations, check `logs/<run>/builder-activity.log` for `python -m pytest` / `pip install` calls. The local builder (OpenHands) sometimes uses system `python` instead of `.venv/bin/python`. fxplat isn't importable there, `pip install` is blocked, and the builder gives up on running tests and reports "finish" with code it never ran. Seen on TASK-1.6 (2026-10-04): `pa.table(list_of_dicts)` crashed, `derive_bars` was a stub, and the D1 session logic was wrong. Seen again on TASK-1.8 (2026-10-05): the builder ran `pip install -e . --break-system-packages` into system python and shipped an `async` placeholder `ingest_update`. Its `cli.py` re-declared `--data-dir` on a subparser that already inherits it from the shared `dd` parent. That raises argparse ArgumentError for every CLI call, so unrelated `tests/quality/test_cli_datadir.py` / `test_verify.py` failures in suite-green came from the builder's diff, not a pre-existing break. Seen a third time on TASK-1.9 (2026-10-05): the builder wrote only import-smoke tests, so `-k exit` / `-k <named test>` acceptance checks failed with pytest **exit=5 (no tests collected)**. Exit 5 on a `-k` check means the named test was never written; it is not a logic bug. The builder had also put its new CLI branch after `store = Store(data_dir)`, which would create a manifest at a partitioned root, so read-only subcommands must dispatch before that line. Seen a fourth time on TASK-2.4 (2026-10-05): system python resolved `fxplat` from **another worktree** (`../TASK-1.12/src`), left there by an earlier `--break-system-packages` editable install. The builder then wrote tests that passed naive datetimes plus `cal=None` and wrapped the calls in try/except. The reviewer's "fix the tests" repair was only half the story: the session table and the emission rules were wrong too, so both files needed a rewrite on `session_bounds` / `is_market_open`.

**Why:** the environment is actually fine (`.venv` works), so the failure looks like a "code / value_error" when the real cause is that the builder never got a test loop.
**How to apply:** for these stalls, expect to finish the implementation rather than hunt for an env or spec contradiction. Related: [[agent-ci-real-failure-records]], [[agent-ci-strong-direct-on-built-task]].
