---
name: fxplat-replay-whatif
description: 2026-10-14 Repetición got trade ledgers + Qué pasaría sliders (R9); live sliders = exploration, only "Registrar escenario" counts; sizing default = run's fixed US$50
metadata:
  type: project
---
Built 2026-10-14 in ~/Dukascopy (ui/src/replay/whatif.ts, WhatIfPanel.tsx, ui/scripts/replay_day.py `_alt`):
- Per-trade ledger (gross R/US$/pips, spread, commission, odd lot, slippage, financing, net).
- What-if sliders: family on/off + τ per family, min p, commission rate/min, odd lot, spread/slippage/financing ×,
  sizing fixed US$ or % balance, opening balance. Reproduces the run exactly with run params (tests on 3 real days).
  Cannot change p, stop/target, or R2/R4/R5 (other pairs); R1 re-applied, highest EV first per minute.
- Cristian's decisions: live sliders + register on save (POST /app/api/whatif-registrations, mirrored to
  ~/fxdata/whatif-registrations.jsonl); sizing default = run's fixed US$50 (O3c balance goes negative 2017-11-02).
- Folding registered scenarios into experiments/registro.csv is an operator commit (tracked file; research run
  refuses a dirty tree) - not automated yet.
- Production deploys are blocked for me by the classifier: the user runs deploy/server/redeploy-ui.sh and
  redeploy-requests.sh.

**Why:** the user wants to understand decisions and costs per trade and test scenarios without breaking trial accounting.
**How to apply:** any new replay field goes through replay_day.py + the identity test; never let the what-if
diverge from the run at default params. Related: [[fxplat-run-analysis]], [[fxplat-dashboard-publisher]], [[fxplat-broker-costs]].
