---
name: flaky-pandoc-runner-eacces
description: "merge gate flake — test_pandoc_runner_file_not_found raises PermissionError (EACCES from a PATH dir) instead of FileNotFoundError; environmental, retry"
metadata:
  node_type: memory
  type: project
  originSessionId: b38420b2-b50d-4b5a-8779-e51d0030f461
  modified: 2026-11-10T00:52:31.029Z
---

2026-11-09 TASK-3.236 merge_refused: the only real failure was tests/pipeline/test_final_report_write.py::test_pandoc_runner_file_not_found.
It got `PermissionError: [Errno 13] ... 'definitely-not-a-program-fxplat-f6'`. execvp remembers EACCES from an inaccessible PATH dir (likely /mnt/c) in the gate env. The file passes on rerun and the task (carry_factor) did not touch it.
The case text listed tests/pipeline/test_research_run_variant. That came from the warnings tail, not from a failure (same pattern as [[flaky-test-ib-is-todays-call-second-boundary]]).

**Why:** This is environmental, not a task or spec defect.
**How to apply:** grep `^FAILED` at the bottom of the merge log. If this is the only failure, retry.
