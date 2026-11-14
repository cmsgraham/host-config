---
name: merge-gate-wipes-uncommitted-task-edits
description: Uncommitted edits to tasks/<id>.yaml on main are discarded when a merge gate (state/MERGING.json) finishes; edit only once the gate is clear and commit immediately
metadata:
  node_type: memory
  type: project
  originSessionId: 7998a828-ef82-4771-873c-6c7e1ac4adbb
  modified: 2026-10-27T16:32:53.880Z
---

Triage on 2026-10-27 (TASK-14.21 spec_blocked): I edited `tasks/TASK-14.21.yaml` while
`state/MERGING.json` existed (TASK-14.19's gate), waited 30 min for the gate to clear, and found the
file reverted to its original sha (git status clean, no commit of mine). The gate's merge of
TASK-14.19 landed (02544e6) in between and its checkout of main threw away the working-tree edit.

**Why:** the merge gate operates on the main worktree and restores a clean tree; anything
uncommitted under `tasks/` (or anywhere) is lost, silently.

**How to apply:** in triage, do the analysis while a gate runs but do NOT edit the spec yet. When
`MERGING.json` disappears, apply the edits and commit in the same minute. Alternatively run a single
background shell that waits for the file to vanish, re-applies, and commits atomically. Always
`git status --short tasks/` plus `sha256sum tasks/<id>.yaml` after any wait to confirm the edit is
still there. Related: [[real-run-task-ids]] (untracked drafts under tasks/ found 3x).

2026-11-14: `git add -f tasks/<new>.yaml` while MERGING.json exists stages the file INTO the gate's in-progress
merge index (commit fails "cannot do a partial commit during a merge"); unstage with `git rm --cached` immediately
or it lands in the merge commit. Use a wait-then-commit script (/tmp/commit_specs.sh pattern).
