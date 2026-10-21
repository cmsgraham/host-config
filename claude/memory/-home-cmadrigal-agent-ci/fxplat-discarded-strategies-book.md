---
name: fxplat-discarded-strategies-book
description: The "book of shame" (Cristian 2026-10-21) - ~/Dukascopy/experiments/descartadas.yaml lists every rejected strategy with numbers, why it failed, lesson; add an entry whenever a study/run ends NO_EDGE
metadata:
  type: project
---

Cristian 2026-10-21: "mark them on the strategy book of shame". File: ~/Dukascopy/experiments/descartadas.yaml
(3bcfcef): FX-V1-001 (DON20 H1, -0.12R/trade), carry 3x3 / 2x2, momentum 3M / 12M (all NO_EDGE). Panel
"Estrategias descartadas" on the Investigación view (agent building 2026-10-21) shows it with the 20-try budget
counter (4 of 20 used as of 2026-10-21).
**How to apply:** every time a study, scan promotion or run ends NO_EDGE, append an entry (id, name, family, frame,
tested, date, verdict, numbers after costs, why_failed, lesson, evidence, registry ids, tries_used) and commit with a
pathspec outside a merge gate. Never delete entries. Related: [[fxplat-hallazgos-caleidoscopio]].
