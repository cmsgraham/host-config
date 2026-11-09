---
name: acceptance-git-status-codes-merge-gate
description: "acceptance checks that compare `git status --porcelain` codes (' M') fail in the merge gate, which stages changes ('M ') via --no-commit merge"
metadata:
  node_type: memory
  type: project
  originSessionId: 12391b79-1bae-4b08-96e7-9a49d3ffd032
  modified: 2026-11-09T03:26:47.843Z
---

An acceptance like `test "$(git status --porcelain <dir>)" = " M a\n M b"` passes in the worktree (unstaged) but
fails post-merge verification: the gate does `merge --no-commit`, so the same files show as `M ` (staged).
TASK-3.226 goldens-only-features was merge_refused for this (2026-11-09); fixed by comparing paths only
(`| cut -c4- | sort`), spec commit 7e41b64, then `retry` (see [[merge-refused-spec-fix-needs-retry]]).

Follow-up trap (same task, retry run-20261109-032415): the retry was prepared with the APPROVED work already
COMMITTED in HEAD (9394cc9) and routed strong_direct, so in the worktree `git status --porcelain <dir>` is EMPTY and
any status-based acceptance can never pass there. Fix: `git reset --soft main` (HEAD^ == main) → work staged,
uncommitted, as the supervisor's validate_first handoff expects; every acceptance then passed, no code change.

**Why:** the status-code column differs between the builder worktree and the merged tree.
**How to apply:** when writing or triaging specs, compare paths, never the XY status codes.
