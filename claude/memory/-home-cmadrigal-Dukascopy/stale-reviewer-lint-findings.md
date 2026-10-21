---
name: stale-reviewer-lint-findings
description: "Reviewer can re-raise strict-lint-new findings already fixed in a later attempt (validation green); check the snapshot before \"fixing\""
metadata:
  node_type: memory
  type: project
  originSessionId: 0308e2ab-729c-454a-9ed2-432cc7472af9
  modified: 2026-10-21T17:27:54.793Z
---

TASK-3.143 (run-20261021-152012-e6423d): attempt 2 had already fixed both strict-lint-new violations from attempt 1 (PLW0108 lambda, PLR0402 `as rr` alias). Validation was green, yet the attempt-2 reviewer re-raised them as F003/F004 by quoting attempt 1's stale strict-lint stdout. Max attempts ran out → HUMAN_REQUIRED with no real defect.

**Why:** the review prompt still carries the earlier attempt's check output, and the certification event marked strict-lint-new "unresolved" even though the check passed.

**How to apply:** when HUMAN_REQUIRED says "every check passed, reviewer blocks" on lint findings, first diff the worktree against `refs/agent-ci/attempts/<task>/<run>/<n>`, then run the strict-lint-new command plus direct ruff on the files. If both are clean, the findings are stale. Check the tests against the requirements, then re-run.
