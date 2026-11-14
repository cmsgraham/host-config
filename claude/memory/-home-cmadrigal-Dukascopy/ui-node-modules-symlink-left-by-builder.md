---
name: ui-node-modules-symlink-left-by-builder
description: "UI task protected-paths + tree-drift on ui/node_modules + ui/tsconfig.tsbuildinfo = builder ran the acceptance's `ln -sfn .../ui/node_modules` + typecheck by hand and returned before its cleanup; work itself usually complete"
metadata:
  node_type: memory
  type: project
  originSessionId: 2cb6e1e8-596b-4e67-a66d-3b6acdc12fef
  modified: 2026-11-14T12:24:43.474Z
---

TASK-16.97 (2026-11-14): HUMAN_REQUIRED with failing checks protected-paths + tree-drift naming
`ui/node_modules, ui/tsconfig.tsbuildinfo`. The builder had run the module-tests-green steps by hand
(symlink main's node_modules, `npm run typecheck`) without the acceptance's trailing
`rm -f ui/node_modules; git checkout -- ui/tsconfig.tsbuildinfo`. By escalation time the two strays were already gone
from the worktree and the owned diff matched the spec exactly; reviewer F001 ("remove from the index") is just this.

**Why:** the artifacts are a side effect of the builder's own checks, not a code or spec problem.

**How to apply:** `git status --short` + `ls ui/node_modules`; if strays remain, `rm -f ui/node_modules; git checkout -- ui/tsconfig.tsbuildinfo`.
Verify the owned diff against the spec, run the acceptance (it cleans up after itself), then retry. No code change is needed.
Related: [[sibling-worktree-contamination]] (this builder also tried to edit TASK-15.59, but every attempt was vetoed).
