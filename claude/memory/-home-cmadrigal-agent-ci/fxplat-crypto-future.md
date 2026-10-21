---
name: fxplat-crypto-future
description: "2026-10-11 Cristian floated crypto/Binance as a FUTURE second market for fxplat; explicitly not now, FX first"
metadata:
  node_type: memory
  type: project
  originSessionId: cc48b68a-726f-4a75-82ee-bb627b7e7f1c
  modified: 2026-10-12T04:00:51.430Z
---

2026-10-11: Cristian asked how much of fxplat could run on crypto (Binance). Explicitly "future, not now — we are still in the middle of FX". Do not queue crypto tasks or raise it unprompted.

Assessment given (for when it comes back):
- Carries over: NautilusTrader ships Binance spot+futures adapters (also bybit, okx, kraken, hyperliquid, tardis; verified in ~/Dukascopy/.venv); research machinery (walk-forward, C1-C18, cards, cross-engine, replay, gates, agent-ci, UI); generic signal families.
- Must be rebuilt: data (Binance public history only ~2017+, new period split/holdout), 24x7 calendar (K13, sessions, bar boundaries), cost model (maker/taker, funding, no swap), BTC-beta exposure instead of per-currency K14, leverage/liquidation + exchange counterparty risk, a crypto charter with Rodrigo (prompt.txt is FX-only).
- Recommended shape: a second market inside fxplat, not a fork, after FX O1-O4 prove the method; cheap first step = BTC/ETH one-off study through the existing pipeline.

**Why:** he's thinking ahead; the FX evidence machine is the asset.
**How to apply:** only when he raises it again or after FX real runs land; reuse this list. See [[fxplat-real-run-plan]].

**2026-10-21:** Cristian raised it again ("once we are set with FX, effort to add crypto? same model? another build
process? start gathering data?"). Answered: ~2/3 carries over, 40-60 pipeline tasks (~1-2 weeks), second market
inside fxplat, start AFTER the first FX verdict, model must be re-tested. Started data gathering: ~/cryptodata/
fetch_binance.sh (Binance public data, BTCUSDT+ETHUSDT 1m spot klines 2017-2026-09 + USD-M funding rates 2019+,
checksummed, resumable; log fetch.log). Dukascopy also has BTCUSD ticks from 2017 (fxplat.data.instruments).
**Decisions 2026-10-21 (Cristian):** evaluate 3-4 crypto exchanges the same way as the FX brokers (live recorded
costs, fees, API, Costa Rica access) and pick the cheapest/most convenient; SPOT first, futures only once learned.
