---
name: leakage-fixture-d1-warmup-limit
description: tests/leakage synthetic market has only 330 D1 / 1980 H4 bars; feature columns needing longer warm-up fail its non-vacuous check
metadata:
  node_type: memory
  type: project
  originSessionId: 1a63a1a9-0bad-440e-8c90-9f7df3123a52
  modified: 2026-10-06T14:33:54.295Z
---

The protected leakage gate (tests/leakage/test_truncation_all.py, `_market.build(weeks=66)`) yields 7920 H1, 1980 H4 and 330 D1 bars. Events are compared at D1 index ~269-295 (H4 ~1620-1775). `_assert_same` fails any feature column that is NaN for every compared event unless the column is listed in `allow_all_nan`. So a D1 feature whose warm-up exceeds ~270 bars cannot pass suite-green, whatever its task spec says (e.g. "percentile over 600 bars" on D1). A UTC hour-of-week seasonal key on H4 is split up by DST and stays NaN over the same span.

**Why:** TASK-2.7 (2026-10-06) stalled on this: `sd_SQZ` (600-bar rank) and `s4_NR7` (UTC-keyed R*) were all-NaN. The fix was rank over the available previous ≤600 ratios with a minimum of 252 (§1 warm-up), and raw range R = H - L for NR on H4/D1.

**How to apply:** when a Phase-2 feature task (2.8, 2.9, ...) fails suite-green with "NaN for every compared event (vacuous check)", check the column's warm-up against these bar counts before touching the formula. See [[escalation-common-blockers]].
