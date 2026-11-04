---
name: flaky-test-ib-is-todays-call-second-boundary
description: "merge gate flake - tests/pipeline/test_research_cli_cost_profile.py::test_ib_is_todays_call compares two wall-clock run ids; fails when the two calls straddle a second boundary; retry, not the task's fault"
metadata:
  node_type: memory
  type: project
  originSessionId: 1c196856-a858-45ce-bb73-51e952389b9c
  modified: 2026-11-04T16:18:28.511Z
---

`tests/pipeline/test_research_cli_cost_profile.py::test_ib_is_todays_call` (TASK-4.26, on main) runs
`research run` twice and asserts `(args_ib, kwargs_ib) == (args, kwargs)`; `args[0]` is the run id
`YYYYMMDD-HHMMSS-F3-V1-<sha7>`, so the assertion fails whenever the second call lands in the next
wall-clock second (seen 2026-11-03 gate run-20261103-220039 and 2026-11-04 TASK-7.42 gate
run-20261104-145401: `154935` vs `154936`).

**Why:** the merge_refused case text quotes the warnings tail of the log (a test_research_run_variant
line), which looks like a different failure; the real FAILED line is at the bottom of
`logs/<run>-merge-full-suite.log`.

**How to apply:** when a merge_refused names that test and the task's diff is outside tests/pipeline,
it is transient -> `agent-ci retry <task>` (accepted under STOP). A real fix needs a task or operator
commit on that test (freeze the clock / strip the seconds). See [[gate-suite-killed-by-builder-pkill]]
for the other common non-task gate failure.
