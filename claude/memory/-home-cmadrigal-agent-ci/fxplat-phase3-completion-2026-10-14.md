---
name: fxplat-phase3-completion-2026-10-14
description: Gate 1 after O3 NO_EDGE - finish Phase 3 on 2010-2021 (53 variants), cost-model-v4, M2 bug fix, Phase 7A SIMULATED plumbing; what is queued, held and still to spec
metadata:
  type: project
---
Cristian's decisions 2026-10-14 (full text: ~/Dukascopy/state/decisions-pending.md, last sections):
- Finish Phase 3 per prompt.txt §12 on Desarrollo 2010-2021 (all 53 §9.5 variants) + a registered cost/CUSUM
  hypothesis for approval later. Holdout untouched (§0.8). Dropping CUSUM post hoc = rescue; V-CUSUM-k / V1-HEU are
  the legitimate route.
- cost-model-v4 per §7.5 (0.5 pip/order + 0.5 pip stop extra + IB financing from BIS policy rates).
- M2 drops categorical cols (d37-d42, h77): fix + re-run V1; O3 verdict was on the defective V1.
- Phase 7A paper = SIMULATED plumbing, stub B2 DON20 take-all, auto-flatten K1/K2/K11, K10 vs stub's own backtest,
  no G7, IB read-only quotes.
- Risky specs routed straight to Claude via new agent-ci `builder: {tier: strong}` (ff69296).
Queued (d504c32): 3.99-3.101b cost v4, 3.102a-e DEV_FULL role (strong); 7.1, 7.3, 7.18-7.23 paper (local).
Held: 3.103 (N rule - Rodrigo, §14.2 item 5), 3.104/3.105a-b (variants.yaml + protocol freeze by Cristian).
Still to spec: M2 fix; v4 consumers (4.12 FillModel, D45 features.context, signal_card_costs, daily_diagnostic,
ui/scripts/replay_day.py `_alt` upu recovery assumes fixed_bps - MINE); test migrations before the config flip
(172 tests fail on a raw flip); dsr_trial_count wiring; build_dataset knobs for 34 needs-build variants; CPCV runner;
B1 seeds; PBO/DSR/SPA drivers; F3_DESARROLLO report.
Operator steps: BIS WS_CBPOL download (needs Cristian's OK - data download rule); validation/ has ticks but no
bars (derive + seam 2018/2019); stub backtest for K10; G3_DEV approval file (Cristian only); paper systemd unit.
Facts: local 27b builder lands ~70% unaided (143 tasks since 10-06); escalation 6.6 min vs build 43 min.

**Why:** a multi-week program; next sessions must not re-derive it.
**How to apply:** check `agent-ci tasks` for these ids, then continue the "still to spec" list. Related:
[[fxplat-real-run-plan]], [[fxplat-broker-costs]], [[fxplat-replay-whatif]], [[spec-source-of-truth-fxplat]].
