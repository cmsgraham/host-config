---
name: merge-gate-stashes-registry
description: a run that appends to experiments/registro.csv in the supervised root while a merge gate runs gets its row autostashed (and popped back after); wait for the gate, then commit with a pathspec
metadata:
  type: feedback
---
2026-10-23: the F2 budget run appended its sanity_check row to ~/Dukascopy/experiments/registro.csv while the merge gate for TASK-13.9 was staging; the gate autostashed it (stash "agent-ci autostash before merging TASK-13.9") and popped it back after the merge. Its untracked reports were hidden via temporary .git/info/exclude lines.

**Why:** the gate keeps the root clean for the merge; anything I write there mid-merge moves temporarily and can look lost.
**How to apply:** before a real-data run in the root, check `agent-ci status`; if a row seems missing, look in `git stash list` / `git diff 'stash@{0}^' 'stash@{0}'` before re-running (a re-run = a second registry row). Wait until `git diff --cached` is empty, then commit reports + registry with a pathspec. Related: [[commit-during-merge-gate]].
