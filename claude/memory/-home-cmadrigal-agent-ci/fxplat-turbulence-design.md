---
name: fxplat-turbulence-design
description: "2026-10-13 market turbulence/noise indexes designed (not built) for fxplat - tier 0 describe + V-TURB-F filter, daily first, tasks M1-M5 written when O3 starts"
metadata:
  node_type: memory
  type: project
  originSessionId: 24bbbdc2-d19a-4e73-883e-d7ea2954387e
  modified: 2026-10-13T18:32:37.995Z
---

Design: ~/Dukascopy/docs/research/2026-10-13-market-turbulence-design.md (from Cristian's research summary
agent-ci/docs/"Market Turbulence & Noise Indicators — Research Summary.md").
Decided 2026-10-13: Tier 0 (market_state table, J2/J3 as regime variables in regimes.py/attribution, O2/O3
diagnostic, OFR FSI sanity check, UI panels; no trial) + register V-TURB-F filter now with literature
thresholds (J2 > 90th pct); feature group J (FX-V1-002, ablation V-TURB) ONLY if the diagnostic shows regime
dependence. Daily first (J1 turbulence, J2 percentile, J3 correlation surprise, J7 currency contribution).
Tasks M1-M5 written when O3 starts, built while it runs; O3 stays V1.

**Why:** each model feature costs a trial (prompt R8/§6.1) and raises DSR/PBO bars; O2 showed ~0 gross edge,
so spend trials only after the free diagnostic.
**How to apply:** basket measures cannot live in the per-symbol child - market_state table + as-of join at
the pooled stage; leakage needs a multi-symbol fixture (governance task); OFR FSI is revised, never an input.
Related: [[fxplat-o2-speed-2026-10-13]], [[fxplat-real-run-plan]].

2026-10-13 evening: TASK-3.95/3.96 merged; Tier 0 run on O3/O3c found NO regime dependence (V-TURB-F would
block the only positive band, O3c -0.014 R). Recommended: do not register V-TURB-F, no feature group J; operator
not yet asked. O3c (1 % risk) = -0.122 R/trade, 1050 trades, C3/C8/C11/C12 pass.
