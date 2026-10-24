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
  (EURUSD long -5.5 USD/lot/night; gold -516.5 POINTS = -51.65 USD/lot/night, digits 3 - I misreported 516 once), affiliate-driven marketing.
- Tick history via MCP get_chart_ticks_history (available from 2026-01-01) - no waiting needed for past events.
- Public-record research: docs/research/2026-10-19-exness-public-record.md (agent, 2026-10-19). Earlier:
  docs/research/2026-10-18-exness.md. Related [[fxplat-broker-costs]].

**Role (Cristian 2026-10-21):** Exness is kept ONLY as a reference / evidence of why not to use it (many Costa Rican influencers/scammers use it) - never a trading venue; keep its CostRecorder data for that purpose.

**Verdict 2026-10-19 (public-record report, agent-ci docs/research/2026-10-19-exness-public-record.md):**
spreads HONEST (Exness itself says EURUSD/gold spreads are "stable... usually fixed ~90% of the time"; its public
real-server tick files show the same 0.6). MISLEADING: (1) "regulated / protected" - FCA/CySEC entities serve no
retail; Costa Ricans get an offshore entity (Seychelles FSA SD025 / Curaçao / BVI / Belize), "no government-backed
Compensation Fund", Seychelles courts, final complaint answer in English/French/Creole only; (2) "swap-free" is
conditional on an undisclosed "mostly intraday" algorithm, else admin fees 25 USD/lot/night EURUSD, 250 XAUUSD
(~5x swap), applied even to open orders; (3) influencer content: up to 40% lifetime revenue share or CPA up to
US$960/client in LATAM, 2025 LATAM campaign aimed at influencers/academies. Market maker by its own words; contract
lets it cancel profits on vague triggers (e.g. "excessive leverage" while advertising 1:Unlimited). SUGEVAL: forex
is outside its regulation (notice 2018-11-22); Exness not on its alert list. Abroad: CVM Brazil stop order 2022,
RBI India alert list. Open: which entity onboards CR (needs signup), live fills, actual CR ad wording.

**Video evidence #1 (2026-10-23, file DeqUk2kRyu1.mp4 - deleted after analysis at the operator's request, 43 s, caption "Que harían ustedes? Cierran?"):** MT5 mobile, XAUUSDm (Exness Standard naming). Deposit US$5,000 2026-10-14 18:18 comment "D-BINANCEU-USD-1699057885190"; buy 3 lots 4091.787->4106.956 closed 22:58 (+4,550.70); buy 5 lots 4113.996, ~4181 at filming (+33,615). Checked vs Dukascopy ticks: every price/time REAL (close 22:58 bid 4106.08-4107.72; entry right after 15 Oct 00:00 UTC rollover; 4181 at 03:37 UTC 19 Oct = 9:37 PM Sun 18 Oct UTC-6 -> filmed by someone on Central American time). Server name never shown -> demo vs real UNPROVEN. SL 4111.22 could not have existed at entry (bid hit 4111.10 minutes after). ~1:1000 leverage; fxplat replay: refused pre-entry (not a major, 120-200x size, K14, K16); if forced, K1/K2/K17 at entry (spread alone 2.5R/5.6R) and K3 shutdown 4 min into trade 1. Open test: compare the deposit comment with a demo top-up on our demo 480425693. Cristian 2026-10-23: wants MORE evidence before writing a public/family explainer (Spanish one-pager offered, deferred).
