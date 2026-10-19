---
name: orphaned-builder-tmux
description: "An OpenHands builder survives HUMAN_REQUIRED and keeps editing the task worktree while the escalation works in it -- two writers, one tree; the builder's shells live in a detached tmux server the supervisor never reaps"
metadata: 
  node_type: memory
  type: project
  originSessionId: 3a95969f-0700-4e5c-ad17-66cac7a14b11
  modified: 2026-09-12T14:59:04.574Z
---

Proven on snoopy_frog TASK-12.5, 2026-09-12 04:25-04:50Z. The run was moved to
HUMAN_REQUIRED at 22:23 CST and the escalation (headless Claude, pid 800061)
started at 22:25:37 in `.agent-worktrees/TASK-12.5`. The qwen BUILDER for that
same run never died: its `builder-activity.log` kept being written throughout,
and it ran `git stash` / `git stash pop` / `git checkout --` cycles in the
escalation's cwd (stashes at 22:26:40, 22:39:53, 22:45:48 -- "broke something,
let me revert to a clean state"). The escalation reported its files reset at
22:39:56 and restored at 22:41:14, and its untracked test file deleted. Those
timestamps match the builder's commands within 3 seconds.

**Why the supervisor does not reap it:** the builder's shells are children of
`/usr/bin/tmux -Lopenhands new-session` (pid 595618 that night), whose parent is
`/init` -- NOT the supervisor. `ps --ppid <supervisor>` lists only the escalation.
So nothing in the HUMAN_REQUIRED -> escalation transition stops the builder.

Ruled out as causes: agent-ci's own `worktrees.refresh` (it COMMITS uncommitted
work to the task branch, never stashes) and any stash/clean in the codebase --
the only one is `counterfactual.py:117`, and it runs in a scratch dir. The
escalation's own log contained no stash/reset commands, only read-only
`git stash list` inspections.

**The fix that worked, with no privileged action:** have the escalation COMMIT to
its own branch. A commit survives `git stash` and `reset --hard`; working-tree
edits and untracked files do not. It costs nothing downstream because the
supervisor commits the escalation's tree itself anyway (`supervisor.py:527`
-> `add_all_and_commit`). TASK-12.5 committed 9827df0 and the tree went clean.
Do NOT drop the leftover `WIP on agent/TASK-<id>` stashes -- they can hold a
duplicate of the escalation's work (stash@{0} held 5 files with 12 matching
lines), and dropping one while the builder still expects it makes things worse.

**Why:** two writers in one worktree can waste a whole escalation (~$6.50 and
40-80 min) and can produce a tree that passes review while missing work.

**A second gap in the same transition, found 2026-09-12 05:30Z:** the supervisor
releases the runner slot and starts the re-run only when the escalation PROCESS
EXITS. The escalation prompt (snoopy_frog `config.yaml`, `escalation.command`)
says "run those acceptance commands yourself and only finish when they pass",
which TASK-12.6's escalation reasonably read as finish-and-REPORT. It sat idle
with every check green while both parallel slots showed busy and two tasks sat
ELIGIBLE. Symptom to recognise: `active_run` is None, tasks are ELIGIBLE, and
`pgrep -af "escalation engineer"` still lists a pid. Fix is one line in that
prompt -- tell it to exit when the checks pass.

**IT RECURRED ON TASK-12.15 (2026-09-12 ~14:55Z), and there is a mitigation
that needs no config change.** The escalation announced completion to me in a
cross-session message -- all five checks green, 2555-test suite, tree clean --
while its own session was still sitting at a prompt (`ListAgents` showed it
`busy`, the message carried `from-mode="prompting"`). So the gap is systematic,
not a one-off: an escalation that finishes and REPORTS is still holding the
runner slot. I asked it directly to exit, explaining that the supervisor
releases the slot only on process exit and that its committed work would be
judged by `validate_first` either way; about a minute later the process was
gone, `ESCALATING.json` was deleted and the run had moved to PREPARING.
CAUSATION IS NOT PROVEN -- it may have been exiting anyway -- but asking costs
nothing and is the only lever available until the prompt is fixed.
**How to apply:** when a peer escalation session messages you that its task is
green, check whether it is still alive (`pgrep -f '[e]scalation engineer'`) and
if so tell it to exit. Do NOT kill it: its work may be uncommitted, and the
supervisor commits the escalation's tree itself (`supervisor.py:527`).

**ESCALATING.json IS BOOKKEEPING, NOT A LOCK — and I misread it as one
(2026-09-12 13:40Z).** With `max_parallel_tasks: 2`, TWO escalations run at the
same time: measured pid 1160798 on TASK-12.14 (age 19:41) and pid 1171631 on
TASK-12.13 (age 02:14), each with its cwd in its own worktree. `state/
ESCALATING.json` holds only the MOST RECENTLY LAUNCHED one and is overwritten
each time — it named 12.14, then 12.13 three minutes later.
WORSE, AND MEASURED AT 13:43:36Z: the file is DELETED when ANY escalation exits,
not just rewritten. It was absent at 13:43 while pid 1171631 was still
escalating TASK-12.13 at age 05:53, and the phase monitor correspondingly showed
NO "ESCALATING" line for a live escalation. So its ABSENCE proves nothing
either: never read an empty or missing marker as "nothing is escalating". Reading it as a
mutex produced a wrong throughput conclusion ("the single escalation slot is the
ceiling"), which I reported before checking. To count escalations, count
processes: `pgrep -f '[e]scalation engineer' | wc -l`, and read each one's task
from `/proc/<pid>/cwd`. Note also that `active_run` is None while every runner's
task sits in escalation; that is expected, not a stall. Two concurrent
escalations also SHARE the git stash stack and the machine, so tell each not to
drop stash entries.

**How to apply:** when an escalation reports files being reset underneath it,
check `builder-activity.log` freshness for that run FIRST -- a write in the last
minute on a run that is already HUMAN_REQUIRED proves the builder is still alive.
The real fix is for the supervisor to kill the tmux builder session before
launching the escalation. Related: [[agent-ci-failure-modes]],
[[merge-pending-race]], [[docker-wedge-issue]]
