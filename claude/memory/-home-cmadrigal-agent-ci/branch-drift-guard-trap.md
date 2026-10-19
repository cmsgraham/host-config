---
name: branch-drift-guard-trap
description: "Hand-merging master into an agent branch to fix a conflict makes it un-rebasable, so the drift guard parks it every time master moves again"
metadata: 
  node_type: memory
  type: project
  originSessionId: 3a95969f-0700-4e5c-ad17-66cac7a14b11
  modified: 2026-09-11T01:20:51.959Z
---

When a merge gate refuses a task and a person resolves the conflict by merging
master INTO the agent branch, that branch can no longer be replayed. agent-ci's
worktree drift guard then refuses to touch it the next time master moves:

    agent/TASK-9.4 is 2 commit(s) behind the integration branch and its own
    2 commit(s) do not replay cleanly. A model resolving arbitrary rebase
    conflicts unattended is how work goes missing, so the branch was left
    exactly as it was.

The guard is correct and should stay. The trap is that the branch then sits in
`unmerged.json` reporting "needs a person" indefinitely, with a free runner
available, and the loop looks stalled for no visible reason.

**How to apply:** after hand-resolving a conflict on an agent branch, re-merge
master into it again every time another task merges, until it lands. Check with
`git rev-list --count HEAD..master` in the worktree — non-zero means the guard
will park it. Observed 2026-09-11: TASK-9.4 was fixed at 00:12, 9.2 and 9.3
merged underneath it, and by 01:09 it was stale and parked again.

Do NOT diagnose this as "the loop only retries unmerged tasks at startup" —
that was wrong. The loop picks such tasks up within seconds; the drift guard is
what stops them. Read the loop's own `logs/auto-*.out`, which states the reason
plainly, before theorising.

Related: [[agent-ci-failure-modes]], [[agent-ci-conventions]],
[[open-threads-2026-09-08]]
