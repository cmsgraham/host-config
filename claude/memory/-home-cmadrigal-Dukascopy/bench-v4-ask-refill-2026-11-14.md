---
name: bench-v4-ask-refill-2026-11-14
description: "2026-11-14 ~02Z refill - nothing queued; ask decision:rare-edge-bench-v4 sent (E-H/E-K conditions + pair sizes); rare-edge-rw still pending; next free 3.244 / 11.70 / 15.50 / 16.96"
metadata:
  type: project
---

Refill 2026-11-14 ~02Z (main 1ecbf0c, gate on 16.92). Queued nothing: decision:rare-edge-rw (RE7 in Romano-Wolf) still
pending, catalogue v2 unsigned (no approvals/CATALOGUE_V2_DEV.txt), 4.4/7.2/8.4 stubs fully split. Sent ask
decision:rare-edge-bench-v4 (decisions-pending 2026-11-14 section): rec (a) E-H = C-MONTH-END-LAST D1 long fixed_h on
EURUSD .3 / GBPUSD .4 / AUDUSD .5 / NZDUSD .6 / USDCAD .7 R (0 JPY/CHF), E-K = C-INSIDE-AGAINST D1 long +0.5 R on
AUD/NZD/CAD, fixed sizes like E-B; E-H planted as five single-pair labels so per-label calibration works.
MEASURED per-pair D1 fixed_h n on ~/fxsynth/bench-v6/h-null-00/hz/*/cells.parquet: MONTH-END-LAST 68-71,
INSIDE-AGAINST 55-79, DON55-BRK 30-57, RSI2-WITH 34-51, TURBULENT-USD 86-103.

**Why:** next writer must not re-survey. **How to apply:** on RESOLVED rare-edge-rw -> 11.70 scan wiring; on RESOLVED
bench-v4 -> planted_world LIBRARY labels + bench-v4.yaml (oracle.py is 1217 lines: no growth there). See [[refill-log]].
