---
name: binance-theft-onchain
description: On-chain tracking of the 2026-10-26 Binance theft; the real destination address and its status
metadata:
  type: reference
---
The 2026-10-26 Binance withdrawal theft ([[binance-theft-2026-10-26]]) sent **0.00752778 BTC** to
destination **1H4hy3p38zJCkhU3ae2cnxTXUgw3FnCBuV** (BTC network). TxID
d98adb023c0b61cd3b5a7c7a368e1fb3681626eadef13199003a19a52e6b8a84, withdrawn 2026-10-26 14:23 UTC,
on-chain 14:25 UTC. A fresh single-use address (only this one tx).

STATUS 2026-10-28: still PARKED, total_sent=0, balance=0.00752778 BTC, n_tx=1 — the attacker has
NOT moved/converted/laundered it. Re-check: `curl -s https://blockchain.info/rawaddr/<addr>` (final_balance,
total_sent) or mempool.space/address/<addr>. If it ever moves, the next-hop address is the key artifact
for IC3/Binance (if it's an exchange deposit addr it may be freezable).

TRAP I fell into 2026-10-28: the FORENSIC_SCAN_REPORT.md "13 attacker BTC reserve addresses (IOCs)"
(16KYa…, 1CrMWn…, bc1qqxn…, etc.) are the malware module's GENERIC embedded decoys — NOT this victim's
destination (their activity all predates Oct 26; the per-victim address was served live from ngc246.com).
Do NOT confuse them with the real destination above.
