---
name: fxplat-research-sprint-2026-10-19
description: 2026-10-19 research sprint proposed+approved (budget 20 variants) then REVERSED within the hour by Cristian - "dont stop infrastructure, we continue with the plan"; freeze reverted 7f0b516
metadata:
  type: project
---

Cristian, 2026-10-19 ~13:30 CST, after seeing the simulator trade a "take all" DON20 stub: building infrastructure
for 3 weeks to run what a short script could do makes no sense. Agreed: the bottleneck is finding an edge that beats
costs, not code. He chose "Research sprint" over trimming the protocol first / keeping the plan.

- Finish in-flight (3.128 v4 sim book, 3.136 retry, my v4 config flip), then FREEZE new infrastructure: held 4.19,
  9.6-9.9, 9.11, 3.137, 3.138 (hold text "research sprint"); queue_low_water 6 -> 0 pauses the spec-writer refill.
- Sprint = fast strategy experiments on DEV 2010-2018 with honest costs (engine already ~10 min per pair-run after
  the 3.91-3.94 speedups); candidates: other timeframes, turbulence filter, cheaper broker cost profile (IC Raw
  ~half of IB), longer holds. Every variant registered in experiments/registro.csv; protocol line 1033 says new
  variants need approval and count toward N (DSR) - get Cristian's trial budget.
- Stop rule: if nothing beats costs on DEV in the window, say so plainly and decide whether to continue.
**Why:** 4 DEV runs (O1-O4) were NO_EDGE; costs ~0.27 R/trade on IB at US$5k dominate.
**How to apply:** don't propose new plumbing/UI during the sprint; resume held tasks only after the sprint review.
Related: [[fxplat-o2-speed-2026-10-13]], [[fxplat-broker-costs]], [[fxplat-turbulence-design]].

**REVERSED 2026-10-19 ~13:50 CST:** Cristian: "dont stop infrastructure, we continue with the plan". Freeze commit
c5682e7 reverted (7f0b516): holds removed, queue_low_water back to 6. The 20-variant trial budget he approved stands
only if research experiments are run later; do NOT re-propose freezing infrastructure. Plan = protocol path:
v4 config flip (mine, now unblocked by 3.128 b43f90f) -> F1 -> F2 -> G3.
