---
name: wsl-passwordless-sudo
description: Since 2026-09-27 the WSL user has NOPASSWD sudo, so gateway/ollama service restarts can be done from a session without asking
metadata:
  type: project
---

On 2026-09-27 the user installed `/etc/sudoers.d/cmadrigal-nopasswd` (`cmadrigal ALL=(ALL) NOPASSWD:ALL`)
in WSL so sessions can restart `ollama-gateway.service` / `ollama.service` themselves.

**Why:** the gateway is the front door for every generation and backend telemetry changes need a
restart; asking for a password each time blocked autonomous work (see [[gateway-usage-card]]).

**How to apply:** `sudo -n <cmd>` works. Before restarting the gateway, poll `/_dash/data` until
`inflight` is empty (a restart aborts whatever the pipeline is generating), then restart and verify
`/_dash/data` again. Everything running as the user can now become root, so keep builders inside
their worktrees and the action policy on.
