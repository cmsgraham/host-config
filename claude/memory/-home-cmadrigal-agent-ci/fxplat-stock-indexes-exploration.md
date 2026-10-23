---
name: fxplat-stock-indexes-exploration
description: 2026-10-20 Cristian "just for fun" asked to add stock indexes to look for FX connections; downloading S&P500/Nikkei/DAX 2012+ into separate ~/fxdata-idx (exploration only)
metadata:
  type: project
---

Cristian 2026-10-20: "just for fun, can we add stock market indexes? maybe we find a connection".
- Dukascopy index CFDs already in fxplat.data.instruments (USA500IDXUSD, USA30IDXUSD, USATECHIDXUSD, DEUIDXEUR,
  GBRIDXGBP, JPNIDXJPY). Downloading USA500 / JPN / DEU 2012-01-01..2026-10-19 into ~/fxdata-idx (README there),
  3 parallel nice'd `python -m dukascopy backfill` started 2026-10-20 ~07:20 CST; measured ~3 min + ~1.8 MB per
  index-week. 2026-10-20 evening: only DAX had run (one writer per data dir!), ~1 year per 13 h; restarted as 9 dirs <SYMBOL>-<year> (2012/2017/2022 ranges), original dir = DAX 2012-2016 (stop that process after 2016). Kept OUT of the governed ~/fxdata store and the hourly updater on purpose.
- Use: Hallazgos condition-catalogue entries (risk-on/off state, prior-session index move, Nikkei->JPY at Tokyo
  open, DAX->EUR, US close->AUD/NZD in Asia) - exploratory; promotion = new variable -> protocol approval + counts N.
- Expectation: equity/FX links are mostly contemporaneous (risk sentiment), lead-lag weak; say so plainly.
Related: [[fxplat-hallazgos-caleidoscopio]].

**2026-10-23:** index downloads COMPLETE (USA500/JPN/DEU 2012..2026-10-19). Commodities added at operator request: ~/fxdata-cmd (README), XAUUSD / BRENTCMDUSD / LIGHTCMDUSD 2010..2026-10-22, 9 nice'd backfill writers (one per symbol x period dir), started 07:48 CST; throttles are handled by the client's pauses. Copper not in fxplat.data.instruments. Participants design (2026-10-23) is folding commodity COT + price primitives in.
