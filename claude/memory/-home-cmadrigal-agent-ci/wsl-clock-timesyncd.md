---
name: wsl-clock-timesyncd
description: "2026-10-05 WSL clock steps (\"Time jumped backwards\") came from systemd-timesyncd fighting Hyper-V implicit time sync; timesyncd is now disabled; the watchdog's stale-code rule compares commit hashes (supervisor.code), never clocks"
metadata:
  node_type: memory
  type: project
  originSessionId: e2e1e562-e852-469b-98e4-f8f9b218520e
  modified: 2026-10-05T12:49:35.763Z
---

**Symptom:** 50 "systemd-journald: Time jumped backwards, rotating" entries between 05:00 and 06:30 on
2026-10-05; the same process showed a start time 27 minutes earlier than the night before. The agent-ci
watchdog's `stale_code` rule (commit time vs process start time from /proc) misfired and restarted a
loop that was already current; the pipeline lost ~12 minutes, no work.

**Cause (microsoft/WSL issue 11790):** WSL's kernel runs `hv_utils.timesync_implicit=1`, which slews the
guest clock toward the host continuously; systemd-timesyncd was ALSO enabled and steps the clock in
discontinuous jumps whenever it disagrees. Two steerers, one clock. The host clock itself is accurate
(w32tm stripchart: 7 ms off NTP). Users there report changing the clocksource
(`clocksource=hyperv_clocksource_tsc_page`, processors=, etc.) does NOT help; disabling timesyncd does.

**Fixes applied 2026-10-05:**
1. `sudo systemctl disable --now systemd-timesyncd.service` (reversible; Hyper-V sync remains).
2. agent-ci c9c37c1: the loop writes the commit hash of its code to `state/supervisor.code` beside the
   lock; the watchdog compares hashes and uses the time rule only when no hash was recorded.

**How to apply:** if "Time jumped backwards" returns, check `systemctl is-active systemd-timesyncd`
first (something may have re-enabled it) and compare `date` with the host (`powershell Get-Date`).
Do not propose a kernelCommandLine clocksource change; it was tested upstream and did nothing.
Any commit to agent-ci that touches `agent_ci/` or `pyproject.toml` still restarts a running loop at
its next task boundary by design ([[watchdog-role]]). See [[focus-fxplat-2026-10]].
