---
name: windows-path-eacces-trap
description: Launching agent-ci from my shell inherits a Windows PATH entry (systemprofile WindowsApps) that is EACCES -> "missing program" raises PermissionError, failing test_pandoc_runner_file_not_found at the merge gate
metadata:
  type: feedback
---
2026-11-13: TASK-15.47 passed review but the merge gate failed on tests/pipeline/test_final_report_write.py::
test_pandoc_runner_file_not_found (expects FileNotFoundError; got PermissionError). Cause: my Bash/VS Code PATH carries
/mnt/c/WINDOWS/system32/config/systemprofile/AppData/Local/Microsoft/WindowsApps (WSL started by the S4U boot task since
the 11-11 reboot), which is EACCES; execvp then reports EACCES instead of ENOENT. systemd --user's PATH has no /mnt/c.

**Why:** I had started `agent-ci auto` with setsid nohup from my shell, so the loop and its merge gate inherited my PATH.
**How to apply:** start agent-ci loops / runs with `systemd-run --user --collect -p WorkingDirectory=... python -m
agent_ci.cli ...` (or let the watchdog start them), never from my shell. Related: [[boot-without-logon-credentials]].
