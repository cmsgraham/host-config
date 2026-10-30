---
name: watchdog-frozen-tasks-kills-escalation
description: "the watchdog's frozen_tasks rule (60m) kills a legitimately-running long strong-tier escalation, looping it; notify dedups open cases so they never re-alert"
metadata:
  node_type: memory
  type: feedback
  originSessionId: 1c4d5b2e-1683-4d80-96df-42f632213acd
  modified: 2026-10-30T22:05:26.171Z
---

The agent-ci watchdog's `frozen_tasks` rule judged TASK-16.43 "stalled 60m with
no retry in sight" and STOPped the loop ("a fresh one would pick them up") while
the strong-tier escalation was ACTIVELY progressing (full suite 9,895 tests
passing, near done, 2026-10-30). It killed the near-complete escalation at the
safe boundary; the task reverted to "strong_direct / not built" and re-queued —
an infinite near-complete-then-killed loop. A large task routed straight to the
strong model (contour too large for local) runs a ~22m+ full suite that, under
S2/memory contention, exceeds the 60m window.

**Why:** frozen_tasks can't tell a long-running legitimate escalation from a
genuine freeze; its 60m threshold is shorter than a big strong-tier build+suite.

**How to apply:** before resuming such a task, raise the frozen-tasks window (or
use `agent-ci resume` to validate the interrupted run's existing worktree work —
16.43's module + tests were already built and passing, preserved in
.agent-worktrees/TASK-16.43, WIP commit 2304b92) so the escalation isn't killed
again. Also: the phone notifier (`state/notify.json`) dedups per case id —
an already-`open` case is pushed ONCE and never re-alerts; only a NEW run_id
(new case) pushes again. So a stable stopped task does NOT spam the phone.
Related: [[main-lint-wedges-all-tasks]], [[agent-ci-ops-triage]], [[watchdog-role]].
