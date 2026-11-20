---
name: cost-rescore-refill-2026-11-20
description: "2026-11-20 06Z refill: decision 2026-11-19 cost-sensitivity rescore -> 3.244 label_recost (pure re-pricing of a label ledger, path fixed); ledger-format findings for parts 2/3; next free 3.246 / 11.77 / 15.75 / 16.98"
metadata:
  node_type: memory
  type: project
  originSessionId: 6202a528-7432-496e-9672-8d30f697932f
  modified: 2026-11-20T06:20:04.698Z
---

Refill 2026-11-20 06:07Z (main 3474dc5, runnable 1: 11.76 in escalation). re7-promote ask still pending (not RESOLVED).
Source: decisions-pending "2026-11-19 cost lever ... RESOLVED pre-registered cost-sensitivity rescore, report only".
- 3.244 fxplat.pipeline.label_recost.recost_labels(labels, *, symbol, usd_per_unit_per_price, from_pair, to_pair,
  point_size, risk_usd, policy_rates) + summarize. Recovers exit_raw by inverting from_pair's slip on exit_px and
  entry_raw from pnl_side (float-exact; entry_px is _px9-rounded). Prototype /tmp/p3244 (run.py worlds, hand.py):
  error 0.0 vs label_events for PC4->PC4, PC4->DUKA raw, PC3->PC4 on time exits.
- Ledger facts for the next pieces (NOT yet specced):
  * research runs: artifacts/real/<run>/<SYM>/labels.parquet (LABEL_COLUMNS, risk 50 USD), closes_h1.parquet,
    events.parquet; walkforward/decisions.jsonl (decision 'no_trade'/...); O1-O4 runs (FX-V1-001) are
    cost-model-v3 -> from_pair = v3 (only tests/_cost_v3.py / git history has v3). upu for USD-base pairs =
    1/H1 close at/before decision (phase2._usd_per_unit_per_price) -> reader must rebuild it.
  * carry/momentum (FX-CARRY-001/A, FX-MOM-001/A): experiments/studies/2026-10-21-carry-momentum/monthly.csv =
    monthly portfolio rows (cost_usd, fin_ib_usd, traded_usd), NOT per-trade labels -> likely "no ledger" or a
    separate traded-notional recost.
  * paper sim-v4: ~/.cache/fxplat/paper/data/sim-v4/closes-SIMULATED.jsonl close/1 (r_gross, r_net, costs_r
    components, fill prices; NO size) - 24 closes; r_gross - sum(costs) != r_net (spread inside).
  * cost-model-v5 files: brokers.yaml v2 already has DUKASCOPY (3.5/100k) and IC_RAW (3.0) raw profiles and
    common.costs.raw_broker_variant builds them from v4; the decision's cTrader-recorder spreads per hour conflict
    with D6 (observed Dukascopy spreads only) -> raw_broker_pair refuses markup; may need an ask.
  * Hallazgos part (3) not looked at.

- 3.245 fxplat.pipeline.run_recost (recost_stored / run_recost; deps 3.244) committed f87351d: replay_inputs picks
  'enter' records + upu; from-model checked against info['inputs']['cost_model_sha256'] (v3 runs need tests/_cost_v3
  model, hash bf001191 matches). Both reviews OK.
- 3/3 report/CLI (fxplat.research.cost_rescore) HELD on ask decision:cost-rescore-variants (2026-11-20 section):
  decision's 'cost-model-v5-*' files clash with VERSION_PATTERN + D6; rec (a) existing brokers.yaml DUKASCOPY/IC_RAW
  via raw_broker_variant. Carry/momentum = monthly portfolio rows -> *reading "no ledger"; paper sim-v4 closes lack size.

**Why:** next writer continues the chain without re-reading the ledgers. **How to apply:** once decision:cost-rescore-variants
is RESOLVED, write 3/3 (report + CLI; Hallazgos part (3) still unexamined); see [[refill-log]].
