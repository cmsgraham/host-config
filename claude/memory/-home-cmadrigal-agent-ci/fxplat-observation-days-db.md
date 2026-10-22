---
name: fxplat-observation-days-db
description: Reusable event DB of market days (experiments/observations/observations.sqlite, 2a309fb) - days + tagged events (MT5 calendar, Haiku recall, web) + observation sets; first set = 113 TURBULENT-USD days; query.py; Haiku rows are leads (70% web agreement; conf>=0.8 6/7)
metadata:
  type: reference
---

Cristian 2026-10-22: "create a db of observation days with tags/identifiers to cross-match future findings; ask what
happened on the turbulence days (cheaper model)". Built ~/Dukascopy/experiments/observations/ (committed 2a309fb):
observations.sqlite (days = all 1,565 DEV D1 bars 2010-2015 with turbulence + USD-index/major moves in ATR units;
events with source_kind economic_calendar | llm_recall | web_source, confidence, model; event_tags restricted to a
45-tag vocabulary; observation_sets/set_days; views v_set_day_events, v_day_tags), README (method, quality rules),
query.py (sets, tags, days-with-tag, cross, enrichment, day), llm_recall.py --set <id> (new dates only).
First set TURB-USD-D1-HZS-20261022: 113 days (n=111 cells + 2012-12-31/2013-01-01), 2012-2015. Calendar snapshot
~/fxdata/calendar/mt5-2009-2015/ (855 events, 4,122 high-importance values; no forecasts -> no surprise flags).
Enrichment vs all DEV days: rate_change 2.45x, NFP 1.9x, CB speeches 1.8x, CB decisions 1.7x. Haiku cost US$0.11.
**How to apply:** add every future finding as a new set and cross-match; treat llm_recall rows as leads (use
conf >= 0.8 or calendar/web-confirmed days); errors were real events on wrong dates. Related:
[[fxplat-hallazgos-caleidoscopio]], [[fxplat-discarded-strategies-book]].
