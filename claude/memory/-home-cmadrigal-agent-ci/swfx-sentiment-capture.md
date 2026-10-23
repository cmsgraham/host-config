---
name: swfx-sentiment-capture
description: 2026-10-23 SWFX sentiment LIVE via the official embed in headless Chromium every 10 min (swfx-sentiment.timer); consent email drafted; direct API needs the widget Origin (never faked)
metadata:
  node_type: memory
  type: project
  originSessionId: 1e7b6d6f-c956-4bad-a107-730b720d1dcd
  modified: 2026-10-23T15:00:31.019Z
---

Operator 2026-10-23: "we definitely need the sentiment data"; chose "ask Dukascopy + capture now". Email asking written consent drafted (private, no redistribution, 10-min rate) — operator sends it.

Findings: widget = widgets.dukascopy.com/en/sentiment; API `https://jetta.dukascopy.com/v1/` (from widgets.dukascopy.com/config.json JETTA_SERVER_URL): GET `instruments`, POST `sentiments/instruments` {instrumentCodes:["EUR-USD",...]} (widget groups FX_MAJOR/FX_CROSS/FX_METAL/FX_RSRV), POST `sentiments/currencies` {currencyCodes: 13 incl XAU}. Returns long/short % at LAST/SIX_HOURS/ONE_DAY/FIVE_DAYS. Without the widget Origin header it answers 202 empty: spoofing Origin was refused (auto-mode classifier blocked it; I will not fake it).

LIVE since 2026-10-23 15:40 UTC: ~/fxdata-sentiment/capture_embed.py (own .venv, playwright 1.64.1) hosts the published embed on a routed http://localhost:8799/ page, opens Historical (all FX, ~93 pairs with data) then clicks the visible 2nd view toggle (labelled 'Providers' = currencies, 13). Raw responses -> swfx/YYYY-MM-DD.jsonl; user unit swfx-sentiment.timer (*:00/10), log capture.log. API answers in 30-120 s. Delete the store if Dukascopy refuses.

Also 2026-10-23: commodity backfill moved to one writer 1 req/s, unit fxdata-cmd-backfill (+15-min timer), yields to fxplat-update via drop-in yield-cmd-backfill.conf; touches ~/fxdata-cmd/.done when both passes finish.
Related: [[fxplat-participantes-design]], [[handoff-2026-10-23]].
