---
name: commit-during-merge-gate
description: "In a supervised root: pathspec commits only; create+commit a file in ONE command (gate no-stray, strict-lint-new on working-tree diffs, and build-time containment that reverts new files to escaped-files)"
metadata:
  node_type: memory
  type: feedback
  originSessionId: 1e08dd12-044d-459f-8438-708c6962279f
  modified: 2026-10-07T13:51:36.992Z
---

2026-10-07 07:12: I committed a task YAML in ~/Dukascopy with a plain `git commit` while the gate had
TASK-3.5's merge staged (--no-commit, full suite running). My commit swallowed the merge ("commit (merge)" in
the reflog); the gate's own commit then failed and 3.5 was left "unmerged" although its code was on main.
Same failure as the 2026-09-09 human incident. Repaired by `StateStore.clear_unmerged('TASK-3.5')` after
confirming the gate's checks + full suite had passed on that tree.

**Why:** a staged merge lives in the shared index; any commit without a pathspec takes it.
**How to apply:** in a supervised project root always `git commit -m ... -- <paths>` (git refuses a partial
commit during a merge, so it fails safe), and check `state/MERGING.json` / `.git/MERGE_HEAD` first. See
[[merge-pending-race]], [[queue-refill-autostash]].

**Also untracked files (2026-10-10):** task acceptance checks include `lint-and-no-stray` = no untracked file
in the root except the task's own. My new docs (UI_DESIGN.md, the original UI brief), left uncommitted while
TASK-8.7's merge gate ran, made the MERGED tree fail and 8.7 was refused (state/unmerged.json). Create a file
in a supervised root and commit it in the same step (or draft it in the scratchpad first); never leave it
untracked across a merge gate. A refused task re-runs by judging its existing tree, not by rebuilding.
Same day the spec writer's drafts under tasks/ refused 8.7 a second time; agent-ci a2e2208 now hides
untracked files that predate the merge (and the tasks dir) from the merged-tree checks via a temporary
.git/info/exclude block. Pathspec commits are still required (the staged-merge race is separate).
Third time (2026-10-11 night): UI sample-data files I generated under ui/ DURING TASK-3.74's gate refused it.
agent-ci 691d6e3 adds git.merge_gate_ignore (fxplat: [ui]) - dirs no pipeline task writes are hidden even for
files created mid-gate. Anything else generated in the supervised root still must be committed in the same step.

2026-10-12: the attempt-end CONTAINMENT guard (supervisor._quarantine_escapes) also reverted 15 uncommitted ui/ files as a "builder escape" (recovered from logs/<run>/escaped-files/). Fixed in agent-ci 0d6db49: git.merge_gate_ignore dirs count as operator paths. If root edits ever vanish mid-run, look in logs/<run>/escaped-files first. Still: commit UI work in small batches.

**2026-10-14, three more (fxplat):** (1) my uncommitted edits to tracked ui/scripts/*.py failed TASK-3.98's gate
on strict-lint-new (it lints the root's working-tree diff vs main) and my untracked deploy script failed
lint-and-no-stray; (2) a failed `git add` (ignored-path error) still STAGED my tracked files into the index during
a gate - unstage with `git restore --staged <mine>`; (3) BUILD-TIME containment, not just the gate: a new untracked
file I created in the root (config/variants.yaml) while TASK-9.10 was building was moved to
logs/<run>/escaped-files/ and reverted as a "builder escape". Rule now: write the file and commit it in the SAME
command, any time a run is active; restore from escaped-files if it happens. TS under ui/ is ignored by ruff/stray.

**Trap 2026-10-22:** a supervisor restore runs `git clean -fd` in the MAIN tree (agent_ci/git/repository.py:156) - an agent's untracked experiments/observations/ was wiped mid-task. Agents must work outside ~/Dukascopy (or in a worktree) and copy in only at commit time.
