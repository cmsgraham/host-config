---
name: exness-investigation
description: 2026-10-19 Cristian suspects Exness (heavily advertised in Costa Rica) is misleading; measured evidence so far + where data lives; public-record research running
metadata:
  type: project
---

Cristian, 2026-10-19: "this exness trader is advertised a lot in Costa Rica but I'm afraid it is misinformation,
grab as much information as possible and confirm". Be fair: confirm OR refute with evidence.

Measured (demo "Pro", login 480425693, Exness-MT5Trial11, MT5 MCP read-only + CostRecorder service):
- Symbol spec: spread_float=true, trade_execution_mode=instant (dealer model, requotes possible), hedging.
- Liquid hours: spread PINNED at a floor (EURUSD exactly 0.6 all hour, incl. London open + 12:30 UTC news slot);
  widens only at Sunday open (to 14.5) and some rollovers (Thu to 6.0). Gold 1.68-2.38. => broker-set minimum,
  not raw market. CostRecorder CSV (MQL5/Files/cost_recorder_480425693.csv, ANSI) min=max most hours.
- Yardstick, same hour 16:00 UTC: IC Markets Raw (cTrader recorder on fxplat-server, mirrored home by
  fxplat-ctrader-mirror since 2026-10-19 to ~/.cache/fxplat/brokers/ctrader/) 0.06-0.21 pips + $3/lot/side
  => ~0.66-0.81 all-in vs Exness Pro 0.6-1.0 no commission. So the SPREAD claim is not obviously false in liquid
  hours; the real questions are demo-vs-real, offshore entity for CR clients, execution/requotes, swaps
  (EURUSD long -5.5 USD/lot/night, gold long -516.5), affiliate-driven marketing.
- Tick history via MCP get_chart_ticks_history (available from 2026-01-01) - no waiting needed for past events.
- Public-record research: docs/research/2026-10-19-exness-public-record.md (agent, 2026-10-19). Earlier:
  docs/research/2026-10-18-exness.md. Related [[fxplat-broker-costs]].
