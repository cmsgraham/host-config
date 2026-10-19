---
name: runaway-background-search
description: never run find/bfs over / here; a timed-out search kept running 15 h, ate 3.8 GB swap and stalled TASK-3.79 five times (2026-10-12)
metadata:
  type: feedback
---
2026-10-11 21:54 I ran `find / -path /proc -prune -o -type d -name playwright-core` (find is bfs here) to locate a browser; it timed out, the harness moved it to the background, my `pkill` attempt killed my own shell, and the bfs lived on for 15 h walking /mnt/c and /mnt/d. It held 3.8 GB of swap; the host went memory-starved (PSI full ~20%) and TASK-3.79's suite-green stalled 5 times at test_discovery_motif_search until triage escalated to Cristian ("NEEDS YOU").

**Why:** a whole-filesystem walk in WSL crosses the Windows drives (hundreds of GB); anything I start that times out keeps running unless I stop it.
**How to apply:** search known roots only (`~/.cache`, `~/Dukascopy/ui/node_modules`, a project dir), with `-maxdepth`; never `/`. After any command times out or goes to the background, check `pgrep -af <its command>` and stop it by PID found from its PORT (`ss -ltnpH "sport = :N"`) or `pgrep -af` read by eye; never `pkill -f` and never `kill $(pgrep -f ...)` in one command: both match my own shell (exit 144, three times by 2026-10-12). When a task stalls in validation, check `free -h` / `/proc/pressure/memory` and look for my own leftovers first. Related: [[agent-ci-conventions]].
