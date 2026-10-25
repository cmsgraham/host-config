---
name: merge-gate-exclude-hides-ui-snapshot
description: "tree-drift on UI tasks (16.x) = merge gate's /ui/** in shared .git/info/exclude hid new ui files from the attempt snapshot"
metadata:
  node_type: memory
  type: project
  originSessionId: cd07da22-ad09-4f43-8aed-2862e1d3ad2e
  modified: 2026-10-25T17:13:50.555Z
---

TASK-16.28 (run-20261025-154404-3202c3) failed `tree-drift` naming new ui/ files whose mtimes PRE-date the run.
Cause: config.yaml `git.merge_gate_ignore: [ui]` makes every merge gate write `/ui/**` into `.git/info/exclude`
(agent_ci/cli.py `_hide_foreign_untracked`), and that file is the COMMON git dir, shared by all task worktrees.
A 16.x snapshot taken while another task's gate runs (here 14.2's gate, 15:32-15:46Z) omits new untracked ui files;
validation still passes on disk, then the drift check sees them.

**Why:** the config comment assumes "ui/ is never built by a pipeline task", false since the 16.x UI tasks.
**How to apply:** check `git check-ignore -v <file>` in the worktree and merge-gate timing vs the snapshot event;
not a builder late write. Retry after `state/MERGING.json` clears; the real fix (agent-ci/config) is the operator's.
Related: [[containment-false-positive-operator-ui]], [[vitest-css-raw-blank]].
