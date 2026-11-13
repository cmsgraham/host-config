---
name: flaky-pandoc-runner-eacces
description: "merge gate flake — test_pandoc_runner_file_not_found raises PermissionError (EACCES from a PATH dir) instead of FileNotFoundError; environmental, retry"
metadata:
  node_type: memory
  type: project
  originSessionId: b38420b2-b50d-4b5a-8779-e51d0030f461
  modified: 2026-11-11T22:28:56.793Z
---

2026-11-09 TASK-3.236 merge_refused: the only real failure was tests/pipeline/test_final_report_write.py::test_pandoc_runner_file_not_found.
It got `PermissionError: [Errno 13] ... 'definitely-not-a-program-fxplat-f6'`. execvp remembers EACCES from an inaccessible PATH dir (likely /mnt/c) in the gate env. The file passes on rerun and the task (carry_factor) did not touch it.
The case text listed tests/pipeline/test_research_run_variant. That came from the warnings tail, not from a failure (same pattern as [[flaky-test-ib-is-todays-call-second-boundary]]).

**Why:** This is environmental, not a task or spec defect.
**How to apply:** grep `^FAILED` at the bottom of the merge log. If this is the only failure, retry.

Recurred 2026-11-11 on TASK-11.65 (family 1 levels grammar) with the same case-text pattern; retried.
Recurred 2026-11-13 on TASK-15.47 (S2 v3 bench); retried.

Root cause found 2026-11-11 (TASK-16.88 escalation): the PATH entry `/mnt/c/WINDOWS/system32/config/systemprofile/AppData/Local/Microsoft/WindowsApps` is unreadable (stat gives EACCES). In the escalation shell the test fails EVERY time, with or without the sandbox. It passes with that entry filtered out: `PATH=$(echo "$PATH" | tr ':' '\n' | grep -v systemprofile | paste -sd:)`. In escalation runs, treat it as environmental and do not edit the protected test.
