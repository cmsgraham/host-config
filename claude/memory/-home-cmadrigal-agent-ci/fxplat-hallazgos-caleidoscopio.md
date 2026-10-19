---
name: fxplat-hallazgos-caleidoscopio
description: 2026-10-19 approved + queued: Hallazgos (honest DEV pattern scanner) + Caleidoscopio (LLM idea engine with temperature + calibrated P(success)); TASK-11.1..11.22; open in-session items
metadata:
  type: project
---

Cristian 2026-10-19: wants "something nobody or few have built... a kaleidoscope of ideas and options, with
temperature and probabilities of success". Design: ~/agent-ci/docs/research/2026-10-19-hallazgos-design.md (402793e).
Approved D1-D12 as recommended (log: Dukascopy state/decisions-pending.md). Queued 6c96bd2: TASK-11.1..11.22.
- Scanner DEV only: search 2010-2015, confirm 2016-2018 once (BY q<0.05 + 50% haircut); rank IB net R; Romano-Wolf
  (11.6). Expect "nothing survives at IB costs" - tell him plainly if so; IC/Exness profiles ranked too.
- Caleidoscopio: typed idea specs, temperature = LLM temp (0.3+0.9θ) + diversity rule; P0/P1/P2 from explicit
  Bayesian model (family priors, Sellke bound, LLM ±0.3 log-odds); Brier/reliability tracking; promotion = signed
  approvals/HALLAZGOS_PROMOCION_<HZ>.txt, 1 of 20 budget, N counts promotions only.
- MINE in session: measure the Romano-Wolf null-rejection bound (TO-MEASURE) then unhold 11.6; finish 11.12's spec
  after 11.11 merges; Cristian signs approvals/HALLAZGOS_DEV.txt when the scanner (11.7) is built.
- Prior art: Gençay 2026 arXiv:2608.27734 (LLM strategies all rejected under DSR/PBO).
Related: [[fxplat-research-sprint-2026-10-19]], [[fxplat-broker-costs]], [[spec-source-of-truth-fxplat]].
