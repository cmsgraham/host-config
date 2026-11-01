---
name: escalation-pkill-gate
description: "Claude escalation's pkill -f killed the merge gate's suite (2026-11-01); guard in escalation.apply"
metadata:
  node_type: memory
  type: project
  originSessionId: 1c4d5b2e-1683-4d80-96df-42f632213acd
  modified: 2026-11-01T13:54:18.485Z
---

2026-11-01: a TASK-15.39 escalation cell ran `pkill -f "[p]ytest tests -q"` and killed the merge gate's full suite for TASK-11.53 at 99 % (exit -15, no test failed); merge refused, triage retried it.

Fix aea2561: `escalation.apply` always adds `--disallowedTools "Bash(pkill:*),Bash(killall:*)"` (verified live: the CLI denies the whole compound command) and appends a SHARED MACHINE system-prompt rule (never kill processes you did not start; whole suite only under `flock ~/.agent-ci/full-suite.lock`).

**Why:** Claude escalations bypass the gateway, so gateway action_policy can't veto them.
**How to apply:** a gate suite dying with exit -15 well under its timeout = look for another process killing it, not a test failure. Related: [[parallel-suite-gate-timeout]], [[one-suite-per-task]].
