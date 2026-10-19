---
name: snapshot-filemode-trap
description: "agent-ci snapshots built from an empty temp index dropped +x under core.fileMode=false, failing protected-paths on every task; fixed 2026-09-11 in write_tree"
metadata: 
  node_type: memory
  type: project
  originSessionId: 3a95969f-0700-4e5c-ad17-66cac7a14b11
  modified: 2026-09-11T17:50:18.538Z
---

On 2026-09-11 every snoopy_frog task failed `protected-paths` on
`deploy/linode/deploy.sh`, a file no task touched. Cause: `Repo.write_tree`
(agent_ci/git/repository.py) built the attempt snapshot through an EMPTY
temporary index. Repos on /mnt/c run with core.fileMode=false, and git gives a
new index entry mode 100644 whatever is on disk, so the repo's only executable
(deploy.sh, +x since v3 commit 65e8c17) showed as a mode change in every
snapshot. It cost TASK-11.1 its last attempt and both strong-tier escalations.
Fix: seed the temp index with `read-tree HEAD` before `add -A` (unborn branch
skips it); regression test in tests/test_snapshot.py.

I first blamed base drift (a commit to master mid-run). That was wrong: `git
diff --stat` saying "1 file changed, 0 insertions, 0 deletions" is a MODE-only
change, not "identical". Use `git diff --summary` to see mode changes.

**Why:** a check that fails on something the task never touched looks like a
builder fault and burns attempts and escalations.

**How to apply:** when protected-paths names a file the diff's content doesn't
touch, run `git diff --summary <base> <snapshot>` first. Any new executable in
a project repo would have hit this before the fix. Related:
[[branch-drift-guard-trap]], [[agent-ci-verification-stack]]
