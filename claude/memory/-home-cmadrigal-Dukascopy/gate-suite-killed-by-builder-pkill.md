---
name: gate-suite-killed-by-builder-pkill
description: "merge_refused with suite exit -15 well under the 3600 s gate timeout = another task's escalation builder ran `pkill -f \"[p]ytest tests -q\"` and SIGTERMed the gate's suite; retry"
metadata:
  node_type: memory
  type: project
  originSessionId: 9bd3c66f-9a37-4c2d-bc77-1e08047ed552
  modified: 2026-11-01T12:34:29.340Z
---

2026-11-01 12:15Z: TASK-11.53's merge gate suite died at 99% after 1047 s with `exit=-15`
(git.full_suite_timeout_seconds is 3600, validation.json shows `timed_out: false`, so agent-ci did
not kill it). The TASK-15.39 strong-tier escalation builder (Claude Code, transcript under
`~/.claude/projects/-home-cmadrigal-Dukascopy--agent-worktrees-TASK-15-39/`) ran
`pkill -f "[p]ytest tests -q" ; timeout 3500 .venv/bin/python -m pytest tests -q -p no:cacheprovider`
at 12:15:24Z to clear "its" stale suite, and the pattern matched the gate's `pytest tests -q`.

**Why:** strong escalation builders run full suites in their worktrees without taking agent-ci's
suite flock, and clear stale ones with pkill patterns broad enough to hit the gate's run; the gate
log then ends in dots plus a `PluggyTeardownRaisedWarning ... OSError: cannot send (already closed?)`
from the SIGTERMed xdist controller.

**How to apply:** for merge_refused with exit -15 and duration < timeout, do not hunt for a failing
test. Check `logs/run-*-merge-full-suite.log` mtime, then `ps -o lstart` of running `pytest tests`
processes (cwd via /proc/<pid>/cwd) and grep the sibling worktree's Claude transcript for
`"command":"pkill`. Cause 2 (environmental) -> `agent-ci retry`. Systemic fix belongs to the operator
(agent-ci action_policy veto on `pkill`/`kill` of pytest from builders). Related:
[[suite-green-timeout-diagnosis]], [[full-suite-runtime-over-10-min]].
