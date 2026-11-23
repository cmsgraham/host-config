---
name: crypto-micro-edge-screen
description: "Crypto micro-trading on BTC/ETH spot loses at the current 10bp/side fee tier (20bp round-trip wall); keyless screen tool fxplat.crypto.micro_shadow proves it; fees are the only lever"
metadata:
  node_type: memory
  type: project
  originSessionId: 65592fdb-22b6-4529-9491-76c88746cc4c
  modified: 2026-11-23T04:18:27.718Z
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

2026-11-22 (independent mode): did the fee-tier sweep (new `--tier`/`--maker-bps`/`--taker-bps`
overrides + FEE_TIERS presets; commit d720fab on branch `claude/crypto-fee-tier`, NOT on main —
merge-to-main is hold-for-human). Finding: NO tier flips a naive momentum baseline positive, but
fees change WHICH WALL binds. As round-trip falls 20bp -> ~3bp (futures-vip9), P(|move|>=cost)@60s
rises ~3-6% -> ~65-70%: the cost wall falls away and the binding constraint becomes a real
directional edge (~3bp gross/trade), not fees. So micro is possible ONLY on a low-fee venue
(USDⓈ-M futures, or spot VIP9) AND with a validated few-bp edge — which we don't have. The honest
next step is edge research on a low-fee venue (DEV window + held-out confirm, like the FX work),
NOT more cost modelling. Futures is the unlock (cheaper + shorting) but is the deferred Binance
track behind CRYPTO_LIVE + key hardening.

Don't re-litigate "micro spot crypto": at retail fees it's NO, and the fee sweep is done — the
open question is now a directional edge on a low-fee venue, not the fee level. Execution plumbing is ready ([[fxplat-ib-connector-server]] analog:
binance-trader testnet, recorder, sim, safety gate), but live is hard-gated behind CRYPTO_LIVE +
[[binance-theft-2026-10-26]] key hardening. Related: [[fxplat-crypto-future]] [[binance-live-prep]]
[[scan-only-not-no-edge]] (this is a clear cost-wall result, not an underpowered scan).
