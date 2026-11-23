---
name: crypto-micro-edge-screen
description: "Crypto micro-trading on BTC/ETH spot loses at the current 10bp/side fee tier (20bp round-trip wall); keyless screen tool fxplat.crypto.micro_shadow proves it; fees are the only lever"
metadata:
  node_type: memory
  type: project
  originSessionId: 65592fdb-22b6-4529-9491-76c88746cc4c
  modified: 2026-11-23T01:06:32.365Z
---

2026-11-22: operator asked how ready we are for crypto MICRO-trading (many small-gain
trades that add up). Built `src/fxplat/crypto/micro_shadow.py` (commit 967b481) — a KEYLESS,
order-less feasibility screen that scores real public 1s klines (data.binance.vision, cached
~/.cache/fxplat/micro/data) against the account's REAL costs (recorder fee snapshot
~/.cache/fxplat/brokers/binance/fees/*.json + hourly spread). Write-up:
docs/research/2026-11-22-crypto-micro-edge-screen.md. 8 unit tests (tests/test_micro_shadow.py).

**Verdict (BTCUSDT+ETHUSDT, 2026-11-14..11-20): micro small-gain on SPOT loses structurally.**
- Round-trip cost ~20 bp, ALMOST ALL FEES: 10 bps/side maker AND taker, no rebate at this tier.
- Spread is ~a $0.01 tick (BTC 0.0013 bp), so maker spread-capture is DEAD (−20 bp).
- A typical short move is a few bp (median 60 s ~4–5 bp) << 20 bp cost. Every taker momentum
  baseline netted −17 to −20 bp/trade.
- **The only lever is cutting the round-trip cost:** BNB (−25% → 15 bp), Binance VIP volume
  tiers (maker → ~0/rebate), or FUTURES (~2–5 bp/side + shorting). A 5-min+ edge is ordinary
  systematic trading, not "micro". Sub-second market-making is unreachable from home CR (latency).

Don't re-litigate "micro spot crypto": at retail fees it's NO. If pursued, FIRST re-run the
screen with reduced cost tiers to find the fee level that even makes a micro edge possible, THEN
look for a directional edge. Execution plumbing is ready ([[fxplat-ib-connector-server]] analog:
binance-trader testnet, recorder, sim, safety gate), but live is hard-gated behind CRYPTO_LIVE +
[[binance-theft-2026-10-26]] key hardening. Related: [[fxplat-crypto-future]] [[binance-live-prep]]
[[scan-only-not-no-edge]] (this is a clear cost-wall result, not an underpowered scan).
