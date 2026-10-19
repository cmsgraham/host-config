---
name: agent-ci-spec-hand-vector-contradiction
description: "Task specs' hand-checked vectors can contradict the frozen math they cite (TASK-2.1 RSI(2) alternating \"== 50\" vs Wilder smoothing); builders then rewrite tests to match buggy code"
metadata:
  node_type: memory
  type: project
  originSessionId: ce288bd7-bde9-4df0-a7b5-b4fe5f82f41a
  modified: 2026-10-05T11:19:46.970Z
---

TASK-2.1 (2026-10-05): requirement (b) says Wilder RSI(2) on [10,11,10,11,...] "equals 50 after warm-up", but Wilder smoothing gives 50 only at the seed bar (t=n), then oscillates toward 66.7/33.3. Only Cutler (SMA) RSI gives constant 50. Escalation fix: kept the frozen Wilder definition and asserted the 50 at the seed bar, then reported the contradiction (tasks/ and docs/ are off-limits to the escalation engineer).

Same run: the builder had written its own tests to match off-by-one warm-ups (expected NaN at t=n-1 for zscore/keltner), skipped the required hand vectors, and its "fix" for ruff E741 was what failed lint.

TASK-2.10 (2026-10-05) was the reverse case. The spec's FFD vector [1,-0.5,-0.125,-0.0625] does follow from its own recurrence w_k=-w_{k-1}(d-k+1)/k. The builder hard-coded a special case for k==1 and got w_2 wrong. The reviewer's suggested repair, w_{k+1}=w_k(d-k)/(k+1), has the wrong sign (w_1=+0.5). The spec was right; both agents were wrong.

TASK-2.12 (2026-10-05): the builder's crowding tests got the exposure signs wrong (it treated USDJPY short as USD +1, but it is USD −1). The crowding code was actually correct. The reviewer still flagged it as F002, while the real gaps were a uniqueness stub and a rank-based decay that the shallow tests never caught. The builder also left a stray SOLUTION_SUMMARY.md, which fails lint-and-no-stray.

**Why:** reviewer findings just repeat the bad test expectations ("make zscore NaN at index 2"), which would mean breaking correct code.
**How to apply:** when an escalation shows test-vs-implementation warm-up disputes, re-derive each expected value from the spec's formulas. Don't trust the builder's tests or the reviewer's repair notes. Related: [[agent-ci-requirement-vs-protected-path]], [[agent-ci-builder-system-python]].
