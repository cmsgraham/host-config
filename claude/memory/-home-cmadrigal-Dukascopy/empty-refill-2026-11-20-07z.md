---
name: empty-refill-2026-11-20-07z
description: "2026-11-20 07:38Z refill queued nothing: asks cost-rescore-variants + re7-promote both pending; Hallazgos part (3) data located (HZS-20261104 cells.parquet per-profile mean_net); next free 3.246 / 11.77 / 15.75 / 16.98"
metadata:
  type: project
---

Refill 2026-11-20 07:38Z (runnable 2: 3.244 in merge gate, 3.245). Nothing queued: no draft holds, stubs 4.4/7.2/8.4 are
placeholders already split, no decision RESOLVED since the 06Z refill, both asks (decision:cost-rescore-variants,
decision:re7-promote) status pending.
Found for cost-rescore 3/3 part (3): artifacts/hallazgos/HZS-20261104-142040-4b040d6/cells.parquet (2,532 cells, judged
IC_RAW) has mean_gross, mean_net (IC_RAW), mean_net_IB, mean_net_EXNESS_PRO, cost_share; no DUKASCOPY column. NOTE
appended under the cost-rescore-variants ask in decisions-pending.

**Why:** next writer skips re-checking. **How to apply:** check ask status first; if still pending, it is EMPTY again. See [[refill-log]], [[cost-rescore-refill-2026-11-20]].
