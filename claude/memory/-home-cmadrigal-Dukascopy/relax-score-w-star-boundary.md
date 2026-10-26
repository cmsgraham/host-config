---
name: relax-score-w-star-boundary
description: "TASK-15.21 relax_score w* uses w in [0, 1) — boundary reading to satisfy requirement (c) 'never when delta[EDGE] <= 0.05'"
metadata:
  node_type: memory
  type: project
  originSessionId: dbd63131-63bf-4528-ab9c-e2bdd2c51eae
  modified: 2026-10-26T00:05:35.919Z
---

TASK-15.21 (relax_score.py, built 2026-10-25 as a strong_direct build, see [[strong-direct-escalations]]):
the registered w* equation has the solution w = 1 exactly when delta[EDGE] == 0.05, but requirement (c)
says w* is 'never' for every delta[EDGE] <= 0.05 with a negative null side. The module accepts w in
[0, 1) and documents it as a *reading in the w_star docstring; the test parametrizes d_edge = 0.05.

**Why:** a reviewer may flag "[0, 1] in the spec vs [0, 1) in code" — it is deliberate, the requirement
line outranks the measure-zero boundary of the equation.
**How to apply:** if 15.21 comes back from review on w*, point to requirement (c); don't widen to <= 1.0.
Other readings in the module docstring: open trades (r_net None) count 0 R; chained K3 = each entry into
dd >= 10 R from a 0 R start; a missing storm-day run fails KR4. See also [[relax-bench-knock-on-and-timing]].
