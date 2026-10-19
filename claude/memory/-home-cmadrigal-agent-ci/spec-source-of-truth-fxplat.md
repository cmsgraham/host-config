---
name: spec-source-of-truth-fxplat
description: fxplat task specs must be grounded in prompt.txt (Rodrigo's methodology) section by section, not only in TASKS/CHARTER/DESIGN
metadata:
  type: feedback
---

For fxplat (Dukascopy repo) the methodology of record is `prompt.txt` (Rodrigo, Spanish, 1139 lines). TASKS.md,
CHARTER and DESIGN are summaries; PHASE2_DESIGN was explicitly derived from prompt.txt §3.4-§7.6. On 2026-10-05 I
wrote all of Phase 3 from the summaries without reading prompt.txt §8-§10 and got the official validation scheme,
model parameters, calibration, decision rule and baselines wrong; caught the next morning only because the user asked
about a simulator and I grepped prompt.txt (10 specs written, 4 held, 0 built thanks to the queue order).

**Why:** a spec that is internally consistent and numerically verified can still implement the wrong method; no
audit of my own claims catches a source I never read.
**How to apply:** before writing any fxplat phase's specs, read the prompt.txt sections that phase covers end to end
(P3 = §8-§10, P4 = §9.4 portfolio + §11+), list every registered parameter, and cite the section in each spec.
Related: [[spec-given-claims-trap]], [[fxplat-phase3-specs-2026-10-05]].
