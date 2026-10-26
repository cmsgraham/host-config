---
name: fxplat-fondeo-prop-challenge
description: 2026-10-25 operator wants to learn prop-firm ("fondeo") accounts as a lab: simulated FTMO 2-step profile first, FTMO free trial on cTrader, maybe buy the smallest challenge later in the month
metadata:
  type: project
---
Operator framing: learning how the mechanism works, "no high expectations of big money; all this is a lab".
Plan agreed 2026-10-25: (1) 'fondeo_ftmo' profile in the SIMULATED fun ladder, queued via a RESOLVED entry in
state/decisions-pending.md, after the bench driver; (2) operator opens an FTMO free trial on cTrader (FTMO allows EAs,
~2000 order actions/day; daily loss counts floating P&L, resets midnight Prague); (3) read-only cTrader recorder on
the trial, then an order connector - each needs the operator's written approval; (4) buy the smallest challenge later
in the month only if 1-3 look sane, as lab tuition. Costa Rica is not restricted (operator checked).
My honest estimate given: ~16 % to pass phase 1 at -0.12 R/trade, ~80 % at +0.10 R; funded account with negative edge
= eventual ruin. Related: [[fxplat-multi-account]], [[fxplat-broker-costs]], [[fxplat-live-start-plan]].

2026-10-25 research (report https://claude.ai/artifact/3h4CdKki4oQNoJ22FaQsfW, verified on FTMO/Topstep pages): FTMO
funded accounts are SIMULATED (payouts real); no retail path to live capital at FTMO (Supreme -> Quantlane job);
Topstep 2025: 16.8 % pass, 33.3 % of funded paid, 0.71 % to live. Our fit = FTMO 2-Step SWING (weekend holds, no news
block); fixes: no entries 2 h before Friday close (gap rule), cap same-direction USD positions (overexposure), keep open
risk well under the 5 % equity daily limit (reset 00:00 CE(S)T = 17:00 CR winter / 16:00 summer). Withdraw each cycle
(static floor). $400k cap per trader OR strategy. Never log in / VPS from the US. Fondeo spec amended to Swing.
