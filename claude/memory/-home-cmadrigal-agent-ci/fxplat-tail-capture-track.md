---
name: fxplat-tail-capture-track
description: "Operator wants fxplat to CAPTURE big event-driven moves (convex tail-capture / trend-following), not just observe; crypto-first (equity gaps are out), design draft on branch claude/tail-capture"
metadata:
  node_type: memory
  type: project
  originSessionId: 65592fdb-22b6-4529-9491-76c88746cc4c
  modified: 2026-11-23T18:05:24.377Z
---

2026-11-23: NVDA jumped +33% on Jensen Huang's reinstatement; Cristian's point — "one of these a
year can make us shine; fxplat must be ready to capture and ACT, not just observe." Approved me to
draft a new strategy track.

**The direction (a standing goal, not a one-off):** build a **convex tail-capture / breakout-
continuation** capability — the trend-following / crisis-alpha payoff shape (many small controlled
losses funded by rare huge winners). We already OBSERVE shocks (turbulence indexes
[[fxplat-turbulence-design]], observation-days DB [[fxplat-observation-days-db]], Eventos panel);
we have no layer that ACTS on them. This track adds entry/exit/sizing + a real-time armed scanner.

**Key reframe (decides scope):** equity event-gaps are HOSTILE to continuation entries — the NVDA
move gapped open ~$160, no continuous path to ride. So **crypto first** (24/7, no gaps, continuous
fills), **FX second**, **equities out** for this track. This also means fxplat does NOT buy stocks
(and I cannot execute trades at all — no broker, no authority; live is `CRYPTO_LIVE`-gated).

**Design doc:** docs/research/2026-11-23-tail-capture-breakout-track.md on branch
`claude/tail-capture` (commit d29e793, NOT merged — merge-to-main is hold-for-human). Four blocks:
regime arm, confirmed-continuation entry (extend DON20), **convex exit = the crux** (trail +
scale-out + time-stop; REJECTS a fixed take-profit because it caps the fat tail — note this is the
opposite of Cristian's literal "exit at a profit level", flagged for his call), tail-aware
fixed-fractional sizing. Validated to the usual bar: known-answer synthetic worlds -> DEV ->
held-out -> paper (crypto-sim) -> testnet -> tiny live. Metrics fit a convex profile (profit
factor, tail ratio, MAR, drought length, single-best-trade dependence) — Sharpe is the wrong
headline. Trade count is a first-class cost ([[crypto-micro-edge-screen]] lesson: fees are decisive).

**Waiting on operator reaction to §8** (5 questions: scope order; accept trailing vs fixed TP;
timescale minutes-hours vs multi-day swing; max drought/drawdown tolerance -> drives sizing;
priority vs the v4->F1/F2->G3 sprint [[fxplat-research-sprint-2026-10-19]]). After he reacts, turn
build order T-cap.1-7 into queued task YAML grounded in prompt.txt ([[spec-source-of-truth-fxplat]]).
Related: [[fxplat-crypto-future]] [[fxplat-discarded-strategies-book]] [[scan-only-not-no-edge]].
