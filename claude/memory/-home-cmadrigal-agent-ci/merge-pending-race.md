---
name: merge-pending-race
description: "With 2 runners a dependent task started while its dependency was still in the merge gate; fixed 31a5516 by marking passes \"merge pending\""
metadata: 
  node_type: memory
  type: project
  originSessionId: 3a95969f-0700-4e5c-ad17-66cac7a14b11
  modified: 2026-09-11T21:33:57.649Z
---

On 2026-09-11 (max_parallel_tasks: 2 in snoopy_frog v3), the free runner started
tasks whose dependency had PASSED but was still in its ~10-minute merge gate:

| Task | Depends on | Dep passed | Dep merged | Task started |
|---|---|---|---|---|
| 11.3 | 11.2 | 19:02Z | 19:12Z | 19:04Z |
| 11.5 | 11.4 | 20:28Z | 20:39Z | 20:30Z |

Both built on a tree without the code they depend on, failed ("code" class),
and spent an escalation. The escalation's summary named the cause ("the branch
was cut before its dependency merged").

Cause: `passed_task_ids()` = history PASSED minus `unmerged` (REFUSED merges
only), so a merge still in progress counted as done. The fix, 31a5516 on
pipeline-revision: when auto_merge is on, the supervisor records the pass as
"merge pending" in the existing unmerged record before archiving it, and
`_integrate` clears it when the merge lands. Both early exits (already on
master, auto_merge off) clear it too. The loop's busy-set already stops the
same task being picked twice.

Second bug, same cause (the merge gate stages its merge in the ROOT for ~10
minutes while the other runner's attempt is running). The containment check
diffs the root's dirt before and after each attempt. It blamed TASK-11.3's
builder for TASK-11.5's four staged merge files, "restored" them, and failed
11.3's attempt on workspace-containment, which cost it its LAST escalation.
The restore only did no harm because `git checkout -- p` restores from the
index. Fixed 1f267cb: `_root_dirt` skips staged-only entries (worktree column
blank). Untracked files and unstaged edits still count.

**Why:** it looks like a builder failing on a missing endpoint or module, so
nobody suspects the scheduler.

**How to apply:** when a task fails on something its dependency adds, compare
its first run's start time with its dependency's merge commit time. Committing
to agent-ci makes the watchdog restart the loop ("running older code"), and that
STOP also cuts a post-escalation re-validation, although the work survives as
unvalidated. Related: [[enomem-classifier-trap]], [[snapshot-filemode-trap]],
[[branch-drift-guard-trap]]
