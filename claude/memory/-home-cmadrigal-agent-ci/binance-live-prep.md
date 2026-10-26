---
name: binance-live-prep
description: 2026-10-26 operator plans to trade crypto with his Binance account soon: Mi cuenta read-only panel, holdings watch, sub-account fxplat-bot + trading key ([binance_sub], unused until CRYPTO_LIVE approval), testnet hardening queued
metadata:
  type: project
---
Operator 2026-10-26: "we will be trading with this [Binance] in the near future, test and retest". His main account
holds ~0.0075 BTC in Simple Earn (~US$600); it is NEVER traded by fxplat. Built: Mi cuenta Binance panel (operator-only
via request service /app/api/me/binance, read-only [binance] key), holdings-change phone alert, staleness check.
Sub-account "fxplat-bot" created; its key is [binance_sub] in ~/.config/fxplat-brokers.ini (verified: spot trading on,
withdrawals/transfers/margin/futures off, IP 143.255.29.93 = home WAN for PC and docker1). Unfunded. NOTHING uses it
until testnet hardening (decisions 2026-10-26: shadow exec, OCO exits, exchange filters, failure drills, restart
reconciliation, daily regression) is done AND approvals/CRYPTO_LIVE.txt is signed. Binance signed calls need server
time (WSL clock ~2 s off -> -1021). Related: [[fxplat-crypto-future]], [[docker1-binance-node]].
