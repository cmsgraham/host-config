---
name: write-run-dir-not-reentrant
description: tests/pipeline/test_replay_run.write_run_dir can only be called once per run_dir — a second call fails with OSError Errno 39 (os.replace onto a non-empty dir)
metadata:
  node_type: memory
  type: project
  originSessionId: 711faef0-707e-426d-9c92-8ed1b7bcbb07
  modified: 2026-11-03T23:05:26.500Z
---

`write_run_dir(run_dir, data, records)` (tests/pipeline/test_replay_run.py, TASK-4.45) writes `.SYM.tmp` and then `os.replace`s it onto `run_dir/SYM`. If you call it a second time on the same dir (for example: write with `[]` records, then rewrite with the real records), you get `OSError: [Errno 39] Directory not empty`. Every fixture that uses it errors out.

TASK-4.46 builder hit this (2026-11-03): 25 ERRORs in test_replay_report.py were reported as an "assertion_error / code" failure class, but the module itself was fine. The fix was to collect the records first and call write_run_dir once per `tmp_path_factory.mktemp` dir.

**Why:** the failure class misleads builders into changing the implementation.
**How to apply:** for TASK-4.47 (replay_cli) and any later user of these helpers, check the fixtures for repeated write_run_dir calls first. The same builder also matched `"'run'"` against messages formatted as `run: ...`. Use `r"^run: "` instead (the sibling rerun_report uses that convention).
