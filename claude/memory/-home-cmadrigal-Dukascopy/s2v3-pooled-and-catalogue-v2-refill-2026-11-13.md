---
name: s2v3-pooled-and-catalogue-v2-refill-2026-11-13
description: "2026-11-13 ~12Z refill - TASK-15.47 (score.py pooled label -> per-pair true cells become H4 spillover; bench-v3 pooled [E-A]) queued; catalogue v2 52-condition PROPOSAL drafted in state/proposals/catalogue-v2/ awaiting operator signature; next free 3.243 / 11.68 / 15.48 / 16.90"
metadata:
  node_type: memory
  type: project
  originSessionId: 350e3526-b067-49c5-bf2f-4d38c3c4cf3e
  modified: 2026-11-13T12:32:28.489Z
---

Refill 2026-11-13 (main 27f2483 -> a3ff4b4). Two decisions RESOLVED 2026-11-13 (chat) were the only new sources.

- **15.47** (review OK round 1, low applied, accept-amended): score.py `_load` reclassifies at READ time (result_hz.json
  never rewritten); optional library E key `pooled`, validate_library checks it; H4_spillover gains `pooled_pair`.
  Owns score.py + config/synthetic/bench-v3.yaml (precedent 15.11 owned bench.yaml) + test_score.py. score.py 978 ->
  987 on the prototype (cap 1000 - next score.py change has ~13 lines left). E-B NOT pooled: bench-v3 sizes it per
  pair ("0.60 R = power 0.90 per pair"). Measured re-score of a bench-v6 copy: gate STILL FAIL on H1 (0.95 level 11/48,
  mean power 0.472) - also FAIL with E-B pooled (11/20 vs 0.794). Told the operator in decisions-pending NOTE.
- **Catalogue v2 proposal** (operator asked the WRITER to draft into state/proposals/, overriding the
  "only tasks/ + decisions-pending" rule for this one ask): catalogue-v2-conditions.yaml (21 + 10 + 21, parser-validated,
  every family combination parses; all three m 7,188, z 4.675), README.md, CATALOGUE_V2_DEV.txt, INDICES_DEV.txt drafts.
  GOTCHA hit again: `eq: on` parses as True ([[yaml11-key-gotchas]]) - quoted. Carry/risk evidence is
  pattern-identification §4 (not §3).
- NEXT: once approvals/CATALOGUE_V2_DEV.txt is signed, queue the catalogue.yaml version-2 append task (tests pinning
  m / catalogue_hash: tests/hallazgos/test_hz_catalogue*.py, test_hz_confirm, test_hz_idea_scan, test_hz_narrate).

**Why:** the next writer should not redo the survey or the 52-condition drafting.
**How to apply:** first check approvals/ for CATALOGUE_V2_DEV.txt / INDICES_DEV.txt and decisions-pending for a reply to
the 2026-11-13 NOTE. See [[refill-log]].
