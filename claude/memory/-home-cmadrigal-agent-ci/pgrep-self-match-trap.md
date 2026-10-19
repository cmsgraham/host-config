---
name: pgrep-self-match-trap
description: "pgrep -f / pkill -f patterns match the waiting shell's own command line - wait loops never end and pkill kills my own shell; use ps|grep \"[x]yz\" or PIDs"
metadata:
  node_type: memory
  type: feedback
  originSessionId: 24bbbdc2-d19a-4e73-883e-d7ea2954387e
  modified: 2026-10-13T23:29:58.539Z
---

2026-10-13, three times in one session: `while pgrep -f "<cmd>"; do sleep; done` waited forever because the bash -c
running the loop contains the same string (the O3c launcher sat idle ~40 min after the pipeline halted), and
`pkill -f "<pattern>"` / `kill $(pgrep -f ...)` killed my own tool shell (exit 144).

**Why:** the harness runs every command as `bash -c '<whole command line>'`, so any -f pattern written in that
line matches that bash process too.
**How to apply:** wait on a PID captured when the target started (`kill -0 $pid`), or on a unit
(`systemctl --user is-active`), or match with the bracket trick `ps -eo pid,cmd | grep "[a]uto"`; never pgrep/pkill
-f with a pattern that appears in the same command. Related: [[runaway-background-search]].

**2026-10-17 repeat (cost ~45 min of loop downtime):** the "[D]ukascopy" bracket trick does NOT help when the
waiting script's own command line ALSO contains the plain text (here the restart command it was going to run:
`... --config /home/cmadrigal/Dukascopy/config.yaml auto`). The waiter matched itself forever, never restarted the
loop, and my heat watch (same pattern) never reported the loop down. Use an anchored pattern on the interpreter:
`pgrep -f "^[^ ]*python[^ ]* -m agent_ci.cli --config <cfg> auto"` (bash -c lines start with /bin/bash), or wait on
a PID / the supervisor.lock pid.
