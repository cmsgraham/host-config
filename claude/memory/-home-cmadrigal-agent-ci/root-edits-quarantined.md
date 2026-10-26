---
name: root-edits-quarantined
description: agent-ci containment quarantines ANY root-tree change made while a builder attempt runs - do session work in ~/Dukascopy-claude worktree, never in ~/Dukascopy
metadata:
  type: feedback
---
2026-10-25 20:23: TASK-16.30's builder ended and the supervisor's workspace_escape check moved my uncommitted root
edits (IB watchdog files, compose.fun.yml fix) to logs/<run>/escaped-files/, blaming the builder; the operator then
ran a deploy script that was "not found". Same day the merge gate's autostash had also parked my UI edits.

**Why:** the supervised root is a shared workspace; containment cannot tell my edits from a builder's.
**How to apply:** for fxplat session work, use the worktree ~/Dukascopy-claude (branch claude/<topic>), commit
there, merge into main when no merge gate runs (check .git/MERGE_HEAD / state/MERGING.json). Deploy scripts can be
run from the worktree path. If files vanish from the root, look in logs/run-*/escaped-files first.
Related: [[commit-during-merge-gate]], [[merge-gate-stashes-registry]].
