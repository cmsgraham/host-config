---
name: agent-ci-workspace-escape-false-positive
description: "agent-ci \"workspace-containment\" failures can be the operator's own concurrent edits in the main checkout, not builder escapes"
metadata:
  node_type: memory
  type: project
  originSessionId: 63acafa2-758a-403e-baef-4f3cdb4f317a
  modified: 2026-10-05T01:58:01.306Z
---

In run-20261005-013818-a7ccaa (TASK-1.2, 2026-10-04) the supervisor's `workspace_escape` check flagged and quarantined six root src/fxplat/data/*.py files. They were byte-identical (modulo CRLF) to the operator's in-progress lint fix, later committed as e511f8b on `lint/legacy-data`. The builder's activity log showed only edits inside the worktree.

**Why:** the escape detector diffs the main checkout during the build window and can't tell operator edits from builder writes.

**How to apply:** when escalating a containment failure, compare `logs/<run>/escaped-files/` with the main repo's branches/commits (`tr -d '\r'` before cmp) and check the builder-activity.log paths before blaming the builder. Related: [[agent-ci-real-failure-records]].
