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
- MINE in session: finish 11.12 spec after 11.11 merges; finish TASK-12.7 spec after 11.7 merges; HALLAZGOS_DEV approval when 11.7 lands. (11.6 done 2026-10-21: studentised RW, FWER 0.0498.)
  after 11.11 merges; Cristian signs approvals/HALLAZGOS_DEV.txt when the scanner (11.7) is built.
- Prior art: Gençay 2026 arXiv:2608.27734 (LLM strategies all rejected under DSR/PBO).
Related: [[fxplat-research-sprint-2026-10-19]], [[fxplat-broker-costs]], [[spec-source-of-truth-fxplat]].
- 2026-10-21: TASK-12.1..12.16 queued (4809564): weekly frame + fxplat.xsec portfolio engine; 12.6 + 12.16 held for his sign-off, 12.7 for my spec finish.
