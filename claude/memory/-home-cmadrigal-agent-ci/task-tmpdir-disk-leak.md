---
name: task-tmpdir-disk-leak
description: 2026-10-26 /tmp/agent-ci task temp dirs held 492 GB -> disk-guard stopped Ollama 3 h; fixed 1fae66a (drop on merge, watchdog 12 h sweep, no nesting) + fxplat-health 750 GiB alert
metadata:
  type: project
---
"Ollama not running" alert = disk-guard (/usr/local/bin/disk-guard.sh, 850 GiB on the WSL ext4) stopping it, not a crash.
Cause was isolation TMPDIR dirs never removed (and nested via inherited TMPDIR). Fixed in agent-ci 1fae66a; the sweep runs
in watchdog run_once only with fix=True. fxplat-health now alerts at 750 GiB. When sizing the disk: a parallel `du` with
`timeout` silently drops slow dirs (I missed /tmp that way); bind-mount / and du -x -d1 for a true total.
Related: [[wsl-disk-exhaustion-crash]], [[docker-pool-slot-leak]].
