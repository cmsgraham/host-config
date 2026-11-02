---
name: reviewer-misreads-error-path-tests
description: "Local reviewer/test-audit flags a test of a REQUIRED error path (e.g. \"second call -> FileExistsError\") as contradicting the happy-path requirement; its repair is wrong"
metadata:
  node_type: memory
  type: project
  originSessionId: 8c2ad71f-c226-4eee-bb4c-2fac2af9c479
  modified: 2026-11-02T09:37:05.335Z
---

TASK-14.1 (run-20261023-151014-3ef6c1, 2026-10-23): the test audit and the reviewer marked `test_snapshot_is_immutable_and_needs_aware_now` as a "contradiction" (FIX, F001, confidence 1.0). They said the snapshot "should succeed", but the requirement says verbatim "a second call -> FileExistsError". The suggested repair (drop the FileExistsError assert) would have broken the spec. The same audit called constant-table and empty-input tests "vacuous" and listed the `__init__` docstring and "no imports" requirement as uncovered.

TASK-11.59 (run-20261102-085900-404d54, 2026-11-02): the same pattern. The reviewer read the title's "False where a currency's series does not cover the day" as also covering an absent series, then blocked `rate_bp` raising ValueError for a ccy not in rates.series. The spec registers that ValueError verbatim, and test (h) requires it ('USDCHF' -> 'CHF'). Fix: quote the contract in a test comment. Also make malformed input (not-ascending) raise before the coverage -> None check.

**Why:** the local review model reads a combined test as only the happy-path clause of the requirement.

**How to apply:** never apply such a repair. Split error-path tests into one test per clause, each with a docstring quoting the requirement ("Requirement: 'a second call -> FileExistsError'"). Add an `ast` test for "docstring, no imports" `__init__` requirements. Related: [[stale-reviewer-lint-findings]], [[counterfactual-venv-symlink]].
