---
name: fxplat-contexto-del-dia
description: 2026-10-22 "Contexto del día" — daily point-in-time diagnosis + day score as ONE factor (never exclusive gate) + hot-days calendar + hot-day capture; design done, 16 drafts unqueued, decisions D1-D10 pending
metadata:
  type: project
---
Operator idea 2026-10-22: minimize losses, find the few opportunity days; day context is a FACTOR in the equation, not exclusive; "prepare better with more data on those days"; diagnosis from calendar/news/market on days before and after.

Design: ~/agent-ci/docs/research/2026-10-22-contexto-del-dia-design.md (55abb10). Drafts TASK-13.1..13.16 in ~/Dukascopy/state/proposals/contexto/ (gitignored), NOT queued — need operator approval.
Key points: score predicts MOVE SIZE not direction; size modifier capped ≤1.0; strategy version using it = 1 of 20 tries. No free source keeps pre-release consensus forecasts -> backtests use schedule only; our own forward snapshots from 2026-10 become the honest forecast record (why capture starts now). LLM diagnoses live-forward only, frozen in a hash-chained ledger, no backfill. Yahoo/Investing/Bloomberg excluded by ToS; GDELT (2015+), central-bank RSS, MT5 calendar, ALFRED usable.
Pending decisions D1-D10 (sec. 13 of the doc): CONTEXTO_DEV approval, sign target/features/pass bar, IB 2y warm-up overlapping holdout, model (local 27b vs Haiku), GDELT backfill, FF off, ALFRED key, forward realized facts, capture disk cap, MT5 calendar export 2016-2018.
Related: [[fxplat-observation-days-db]], [[fxplat-hallazgos-caleidoscopio]], [[fxplat-live-start-plan]].
