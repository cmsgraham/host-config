---
name: stale-reviewer-lint-findings
description: "Reviewer can re-raise strict-lint-new findings already fixed in a later attempt (validation green); check the snapshot before \"fixing\""
metadata:
  node_type: memory
  type: project
  originSessionId: 0308e2ab-729c-454a-9ed2-432cc7472af9
  modified: 2026-10-22T01:13:48.435Z
---

TASK-3.143 (run-20261021-152012-e6423d): attempt 2 had already fixed both strict-lint-new violations from attempt 1 (PLW0108 lambda, PLR0402 `as rr` alias). Validation was green, yet the attempt-2 reviewer re-raised them as F003/F004 by quoting attempt 1's stale strict-lint stdout. Max attempts ran out → HUMAN_REQUIRED with no real defect.

This happened again with TASK-12.10 (run-20261021-232125-e8edb6), this time with a test failure instead of lint output. Attempt 2 had already fixed R4 in xsec/legs.py. The reviewer's F001 quoted the cross-check failure from attempt 1's counterfactual log ({'EURUSD','USDCAD'} vs {'EURUSD'}). Its suggested repair (`s * direction * size_R`) is wrong because it applies the direction twice, and it fails that same cross-check.

**Why:** the review prompt still carries the earlier attempt's check output, and the certification event marked strict-lint-new "unresolved" even though the check passed.

**How to apply:** when HUMAN_REQUIRED says "every check passed, reviewer blocks" on lint findings, first diff the worktree against `refs/agent-ci/attempts/<task>/<run>/<n>`, then run the strict-lint-new command plus direct ruff on the files. If both are clean, the findings are stale. Check the tests against the requirements, then re-run.
