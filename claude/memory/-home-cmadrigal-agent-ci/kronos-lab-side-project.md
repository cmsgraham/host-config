---
name: kronos-lab-side-project
description: ~/kronos-lab (2026-11-03) - Kronos candlestick foundation model tried on our data as a side project; not strategy basis; KRONOS-001 in registry and descartadas
metadata:
  node_type: memory
  type: project
  originSessionId: 1c4d5b2e-1683-4d80-96df-42f632213acd
  modified: 2026-11-04T11:39:54.170Z
---

Cristian 2026-11-03: "don't want to discard it and don't want to base our strategy on this", try it on our data for
angles, and track it in the discarded-ideas book ([[fxplat-discarded-strategies-book]]).
- ~/kronos-lab (own git + uv venv, upstream pinned 67b630e, weights local). CPU only, nice 19 (GPUs belong to Ollama);
  Kronos-small ~2 s/forecast, base ~7 s.
- Runs: idx-h1 (S&P/DAX/Nikkei 2025-09..2026-10, after Kronos' publication = clean), syn (known-answer worlds: nulls,
  planted momentum/reversion/time-of-day/garch, real vs mirrored EURUSD = finder-or-rememberer test), fx-d1/fx-h1
  (7 majors DEV 2010-2015 only, contaminated by its pretraining). Score: lab/score.py out/<run>.jsonl.
- Registered: registro.csv KRONOS-001 (exploratory, cuenta_para_N=0, 410e8aa).
- DONE 2026-11-04: descartadas KRONOS-001 = NO_EDGE (dca8510). Kronos-small is a fixed reversal prior: finds planted
  reversal (IC +0.19), blind to planted momentum/time-of-day, real == mirrored (no memorization); loses to momentum on
  indexes, FX H1 reversal doesn't pay the spread, ranges worse than persistence. Base/fine-tune only with a concrete thesis.
