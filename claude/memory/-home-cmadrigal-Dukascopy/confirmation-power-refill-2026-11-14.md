---
name: confirmation-power-refill-2026-11-14
description: "2026-11-14 ~19Z refill: decision 'confirmation-term power' -> 15.63 plant n_events_by_period_symbol / 15.64 bench_hz conf_n + power(n_conf) / 15.65 repower confirm-JSON n; next free 3.244 / 11.74 / 15.66 / 16.98"
metadata:
  node_type: memory
  type: project
  originSessionId: 1e01dde9-3c36-4d5d-8b6f-2280738ef303
  modified: 2026-11-14T19:33:01.625Z
---

Refill 2026-11-14 19:20Z (main d81a5b7, runnable 0). The only new source was the decisions-pending entry "bench-v6 re-scored
after 15.61/15.62", RESOLVED 2026-11-14 (Claude, delegated): the confirmation term uses the confirmation-half count and is
0 below MIN_OCCURRENCES. The 12.6 NOTE is still unanswered. All three specs were review OK and committed 41f374e / fdfe740 / e296b0f:
- 15.63 plant.planted_json: new key `n_events_by_period_symbol` {period: {symbol: {direction: n}}} + PERIOD_NAMES. It owns
  test_plant.py because test_l pins A1 with a full-dict equality.
- 15.64 bench_hz: PLANTED_N_KEY, power(..., n_conf=None) (floor only for a COUNTED n; the n_ef/2 estimate stays
  bit-identical), conf_n (planted count > confirm row "n" > n_ef/2 estimated), and the cells gain n_conf / n_conf_estimated.
  It owns test_bench_hz.py because of the CELL_KEYS pin.
- 15.65 repower (dep 15.64): _confirm_n reads <world>/hz/<scan_id>/confirm-*.json by confirm_id. A missing JSON is a ValueError.
Real bench-v6 h-edge-01 copy: E-B POOL7 0.947 -> 0.998 (confirm n 214). Per-pair E-B already 0 (floor).

**Why:** the next writer must not re-spec this. **How to apply:** after 15.65 merges, the operator re-runs repower + score on
bench-v6 (not spec-writer work). See [[refill-log]], [[eb-power-fix-refill-2026-11-14]].
