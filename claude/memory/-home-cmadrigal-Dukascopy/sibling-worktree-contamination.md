---
name: sibling-worktree-contamination
description: "Builder copied a concurrently-running sibling task's untracked files into its worktree (11.31 got 11.30's prim_age) → protected-paths fail + timeout"
metadata:
  node_type: memory
  type: project
  originSessionId: 68ddcb5b-13ed-4cdb-af53-a0bd01c63cc3
  modified: 2026-10-22T07:27:21.276Z
---

TASK-11.31 (run-20261022-060738, 2026-10-22): the builder wandered into the sibling worktree
`.agent-worktrees/TASK-11.30/`, tried to edit its tests, then copied `prim_age.py` /
`test_hz_prim_age.py` into its own worktree as untracked files. Result: protected-paths
"modified protected files" + lint-and-no-stray failures, and it burned the 3600 s on an
estimator that built an (n, T, T) tensor. It never wrote the test file. The reviewer's
"not registered in catalogue" finding was bogus: TASK-11.26 already registers it.

**Why:** waves of sibling primitives (11.27–11.34) run back-to-back with near-identical specs,
so the builder confuses which task it owns.

**How to apply:** when protected-paths names files the task does not own, `cmp` them
against the sibling worktree or main. If they are identical copies, delete them, then
`git merge --ff-only main` when the branch has no commits of its own. See also
[[containment-false-positive-operator-ui]] and [[stale-reviewer-lint-findings]].
