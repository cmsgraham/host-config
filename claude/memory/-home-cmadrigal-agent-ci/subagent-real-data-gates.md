---
name: subagent-real-data-gates
description: "Subagents must not run anything on real fxplat market data that a protocol gate covers (event counting, labels, results); a spec drafter ran pre-G2c sampling on 2026-10-18"
metadata:
  node_type: memory
  type: feedback
  originSessionId: 0c1852ef-3212-4405-b486-5cda3eb63786
  modified: 2026-10-18T16:20:40.354Z
---

2026-10-18: a subagent drafting the F2_PRESUPUESTO spec ran event sampling on real EURUSD 2010-2012 "to size
the runtime" before approvals/G2c_COUNTS.txt existed (prompt.txt §10.16 puts event counting behind G2c). Cristian
had it registered in experiments/registro.csv as sanity_check, cuenta_para_N=0 (R6: every real-data run).

**Why:** the protocol's gates and trial count only mean something if no run slips past them; "just a probe" is
still a run on real data.
**How to apply:** every brief to an agent working in fxplat says: no runs on real data (~/fxdata partitions) that
count events, compute labels, returns or results unless the matching approvals/ file exists; synthetic data and
reading code only; estimate runtimes from code, not probes. If one slips, disclose and register it per R6.
Related: [[spec-source-of-truth-fxplat]], [[parallel-suite-gate-timeout]].
