---
name: merge-gate-exclude-hides-ui-snapshot
description: "tree-drift on UI tasks (16.x) = merge gate's /ui/** in shared .git/info/exclude hid new ui files from the attempt snapshot"
metadata:
  node_type: memory
  type: project
  originSessionId: cd07da22-ad09-4f43-8aed-2862e1d3ad2e
  modified: 2026-11-05T04:09:01.300Z
---

TASK-16.28 (run-20261025-154404-3202c3) failed `tree-drift` naming new ui/ files whose mtimes PRE-date the run.
Cause: config.yaml `git.merge_gate_ignore: [ui]` makes every merge gate write `/ui/**` into `.git/info/exclude`
(agent_ci/cli.py `_hide_foreign_untracked`), and that file is the COMMON git dir, shared by all task worktrees.
A 16.x snapshot taken while another task's gate runs (here 14.2's gate, 15:32-15:46Z) omits new untracked ui files;
validation still passes on disk, then the drift check sees them.

**Why:** the config comment assumes "ui/ is never built by a pipeline task", false since the 16.x UI tasks.
**How to apply:** check `git check-ignore -v <file>` in the worktree and merge-gate timing vs the snapshot event;
not a builder late write. Retry after `state/MERGING.json` clears; the real fix (agent-ci/config) is the operator's.
Follow-up run-20261025-183521 (strong-direct again): the supervisor had committed the work as a "work in progress
before refresh" commit (6360bd7), so the files are tracked and exclude can no longer hide them. Nothing to fix;
all 4 checks re-run green on the unchanged tree. Next time: if HEAD is a WIP commit holding the owned files, just verify.
Also (TASK-4.54, run-20261105-011713): the exclude hid the builder's NEW ui test file from the diff, so the reviewer
filed a false "missing required test file" (F002). The real failure was one TS2531 error. Check builder-activity.log
for a `create` of the file before you rewrite it.
**`git add -f` does NOT help** (run-20261105-025055, 2026-11-05 triage): `Repo.write_tree` builds the snapshot in a
TEMP index seeded from HEAD + `git add -A`, so a staged-but-uncommitted ui file is still dropped while any gate runs;
the handoff run lost both attempts to a false "missing test file" (identical trees -> no_progress). Only a COMMIT on the
task branch survives. The loop's `WorktreeManager.refresh` makes that commit itself ("work in progress before
refresh", real index, so the staged file is included) whenever main has drifted -> as triage, just `retry` and say so;
as the strong-direct engineer, verify and hand off (you may not commit). The agent-ci fix (snapshot `add -A -f` for
owned paths, or dropping ui from merge_gate_ignore) is the operator's.
Related: [[containment-false-positive-operator-ui]], [[vitest-css-raw-blank]].
