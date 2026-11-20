---
name: cost-rescore-3-and-re7-promote-refill-2026-11-20
description: "2026-11-20 12Z refill: both asks RESOLVED (a) -> 11.77 promote RE7 like POOL7; cost-rescore 3/3 split 3.246 hz / 3.247 paper_recost / 3.248 report / 3.249 CLI (new package fxplat.research); next free 3.250 / 11.78 / 15.75 / 16.98"
metadata:
  type: project
---

Refill 2026-11-20 12:19Z (runnable 0). decision:re7-promote + decision:cost-rescore-variants both RESOLVED (a) on 11-20.
- 11.77 promote._universe maps scan.RE like POOL (promoted.rule_symbols inherits) + RE_SENTENCE appended to claim; cap 465.
- 3.246 fxplat/research/__init__ + cost_rescore_hz (hz_shift over cells.parquet: IB base, IC_RAW = judged mean_net/q_by,
  DUKASCOPY not stored); 3.247 paper_recost (close/1 + enter units + open positions; commission/odd-lot recomputed,
  slippage/financing held; v4 identity exact 0.0 on sim-v4 24 closes); 3.248 cost_rescore_report (study_rows,
  render_markdown, write_report exclusive-create); 3.249 cost_rescore CLI (--v1-run --v1-model --paper-dir --scan-dir).
- Operator run needs the v3 model: `git show b035028:config/cost_model.yaml` hashes to bf001191 = O3c run
  artifacts/real/20261013-232943-F3-V1-8deeee7. Prototype run of the whole tool on real data: /tmp/p1177 (11 s).
- All four reviews OK with low findings applied (--accept-amended). Spec gotcha: CostModel.pair(sym), not pairs(sym).

**Why:** next writer skips re-deriving. **How to apply:** chain complete once 3.249 lands; operator runs the CLI. See [[refill-log]], [[cost-rescore-refill-2026-11-20]].
