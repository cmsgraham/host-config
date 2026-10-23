---
name: reviewer-misreads-error-path-tests
description: "Local reviewer/test-audit flags a test of a REQUIRED error path (e.g. \"second call -> FileExistsError\") as contradicting the happy-path requirement; its repair is wrong"
metadata:
  node_type: memory
  type: project
  originSessionId: 8c2ad71f-c226-4eee-bb4c-2fac2af9c479
  modified: 2026-10-23T16:48:50.632Z
---

TASK-14.1 (run-20261023-151014-3ef6c1, 2026-10-23): the test audit and the reviewer marked `test_snapshot_is_immutable_and_needs_aware_now` as a "contradiction" (FIX, F001, confidence 1.0). They said the snapshot "should succeed", but the requirement says verbatim "a second call -> FileExistsError". The suggested repair (drop the FileExistsError assert) would have broken the spec. The same audit called constant-table and empty-input tests "vacuous" and listed the `__init__` docstring and "no imports" requirement as uncovered.

**Why:** the local review model reads a combined test as only the happy-path clause of the requirement.

**How to apply:** never apply such a repair. Split error-path tests into one test per clause, each with a docstring quoting the requirement ("Requirement: 'a second call -> FileExistsError'"). Add an `ast` test for "docstring, no imports" `__init__` requirements. Related: [[stale-reviewer-lint-findings]], [[counterfactual-venv-symlink]].
