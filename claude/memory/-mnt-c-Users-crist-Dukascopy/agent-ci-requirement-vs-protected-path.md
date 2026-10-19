---
name: agent-ci-requirement-vs-protected-path
description: Task specs can require edits to a file they also list in protected_paths; grep both lists before blaming the builder
metadata:
  node_type: memory
  type: project
  originSessionId: 61fbf5e2-8727-4b04-842e-e6d0dfb4f794
  modified: 2026-10-05T06:25:41.919Z
---

TASK-1.12 (2026-10-05) required "PartitionedStore passes `readonly` through" while listing
`src/fxplat/data/partition.py` in its own `protected_paths`, so the supervisor's
protected-paths gate could never pass. Escalation can't edit `tasks/`; I reverted the protected
file so the gates pass and reported the conflict as DISPUTED for the operator.

Same task: the spec's `file:<path>?mode=ro` URI cannot read a WAL-mode manifest in a read-only
directory (SQLITE_READONLY_DIRECTORY). It needs an `immutable=1` fallback. Archive manifests
are WAL because the hourly job creates them that way.

**Why:** both are spec defects, not builder failures, and a re-run alone would never break them.
**How to apply:** on any protected-paths failure, check whether a requirement names a protected
file. On sqlite read-only work, test with WAL-mode DBs in a chmod 0555 directory.
Related: [[agent-ci-real-failure-records]]
