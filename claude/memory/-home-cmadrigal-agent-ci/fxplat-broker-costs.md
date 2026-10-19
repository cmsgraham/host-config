---
name: fxplat-broker-costs
description: "2026-10-13 account stays US$5,000 (operator); IB's US$2 min + odd lot = 2/3 of costs; Dukascopy / cTrader raw brokers halve costs (O3c net -0.122 -> ~-0.017 R)"
metadata:
  node_type: memory
  type: project
  originSessionId: 24bbbdc2-d19a-4e73-883e-d7ea2954387e
  modified: 2026-10-14T02:17:16.507Z
---

Operator: the real account is US$5,000 (no bigger-account variant). Risk 1 % per prompt.txt (1R = US$50).
Research (docs/research/2026-10-13-broker-costs.md, calculator replays O3c trades): IB IDEALPRO 0.192 R/trade
(comm 0.080 + odd lot 0.052); Dukascopy Bank US$35/M no minimum ~0.087 R; Pepperstone/IC cTrader raw US$30/M
~0.083 R; floor (spread+slippage) 0.061 R vs gross +0.070 R. OANDA likely does not accept Costa Rica.
Trade-offs: Dukascopy = Swiss bank + same data source, but Java-only API (no Python, FIX >= US$100k);
cTrader = Python SDK but offshore CFD entities; IB = best regulation, already wired (paper read-only), costly.

**Why:** costs, not signals, are the biggest lever left at US$5k; the account size is fixed by the operator.
**How to apply:** a broker change = a new cost model version = a registered variant decided before looking;
eligibility, demo spreads and swap tables must be confirmed first. Related: [[fxplat-o2-speed-2026-10-13]].
