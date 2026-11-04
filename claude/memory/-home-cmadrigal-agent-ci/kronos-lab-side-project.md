---
name: kronos-lab-side-project
description: ~/kronos-lab (2026-11-03) - Kronos candlestick foundation model tried on our data as a side project; not strategy basis; KRONOS-001 in registry and descartadas
metadata:
  node_type: memory
  type: project
  originSessionId: 1c4d5b2e-1683-4d80-96df-42f632213acd
  modified: 2026-11-04T03:44:50.040Z
---

Cristian 2026-11-03: "don't want to discard it and don't want to base our strategy on this", try it on our data for
angles, and track it in the discarded-ideas book ([[fxplat-discarded-strategies-book]]).
- ~/kronos-lab (own git + uv venv, upstream pinned 67b630e, weights local). CPU only, nice 19 (GPUs belong to Ollama);
  Kronos-small ~2 s/forecast, base ~7 s.
- Runs: idx-h1 (S&P/DAX/Nikkei 2025-09..2026-10, after Kronos' publication = clean), syn (known-answer worlds: nulls,
  planted momentum/reversion/time-of-day/garch, real vs mirrored EURUSD = finder-or-rememberer test), fx-d1/fx-h1
  (7 majors DEV 2010-2015 only, contaminated by its pretraining). Score: lab/score.py out/<run>.jsonl.
- Registered: registro.csv KRONOS-001 (exploratory, cuenta_para_N=0, 410e8aa); descartadas.yaml KRONOS-001 "EN PRUEBA"
  (2a753f4) - fill in numbers/verdict when runs finish (INCONCLUSIVE vs NO_EDGE per [[scan-only-not-no-edge]]).
