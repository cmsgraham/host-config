---
name: bench-v4-scorer-and-forward-ui-refill-2026-11-14
description: "2026-11-14 ~08-09Z refill: 15.55 score skips RE7 (pooled_kind) cells in v3 criteria, 15.56 score_rare recall tables (POOL7-spillover credit!), 15.57 score reads baseline/ + reports 'rare', 15.58 bench-v4.yaml, 16.96/16.97 Forward UI (mirror lines, run history, K3 on row); ask decision:bench-v4-pass-rule; next free 3.244 / 11.74 / 15.59 / 16.98"
metadata:
  node_type: memory
  type: project
  originSessionId: 8ddba89a-8d3b-4dba-9da9-4dfe7a8746c3
  modified: 2026-11-14T08:16:12.362Z
---

Refill 2026-11-14 ~08Z (main caca593, 11.71 in the merge gate the whole session).

- 15.55 (deps 15.54): score._true_cells / _unpowered_cells skip `pooled_kind`; _load never pooled-pair-converts an RE7
  cell; H3 still counts them. Catalogue-bench-v4 has RE7 in the DEFAULT pairs -> RE7 true cells exist for E-S/E-R/E-A
  too, so without this H1 would be biased by the complete-pooling power.
- 15.56 (no deps): pure fxplat.synthetic.score_rare (imports nothing of fxplat: planted_world imports score -> cycle;
  E_H_PREFIX + GROUP_CELLS duplicated and pinned by test). TRAP caught after its first OK review: bench_hz calls POOL7
  'true' only for an all-7-pair edge, so the POOL7 cell of E-H / E-K is class 'spillover' (edge_id None) - counting
  only true cells would give the baseline ~0 and build the "rise" into the ruler. finds() also credits a found POOL7
  cell of the group's own (condition, D1, long, fixed_h) with class true|spillover.
- 15.57 (deps 15.55, 15.56): score._pool_pairs helper, _rare reads <bench_root>/baseline/<w>/result_hz.json only when
  yaml scan.baseline_catalogue, report['rare'] + MD section; reported only, no verdict.
- 15.58 (no deps): config/synthetic/bench-v4.yaml = v3 + 15-line header + 6 fixed-size ladders + scan block; parsed
  canonical_hash df6738fd...; proto /tmp/p1558.
- 16.96 / 16.97 (UI, chain): PaperForward per-mirror equity lines (legend, protocol series renamed 'FX simulado (IB)'),
  'Inicio de la corrida' column, 3-broker hint; then payload.run / history table / latched switches on the simulator
  row. Tests go in the EXISTING ui/src/views/paperMirrors.test.tsx (a new ui file trips the gate's /ui/** exclude).
  hints.test.ts fails if a new <h2> panel has no <Hint>. Proto copy /tmp/pui/ui (node_modules symlinked).

HELD on ask decision:bench-v4-pass-rule (sent ~08Z, held for quiet hours; rec (a) no group falls + total rises, null
confirmed 0/40): the criterion row in score (reads report 'rare') + its entry/gate in bench-v4.yaml. Then S2 v4 needs
approvals/SYNTHETIC_BENCH_S2_V4. Gotcha this session: `git add -f` while MERGING.json exists stages INTO the gate's
merge index ("cannot do a partial commit during a merge") - `git rm --cached` it at once; commit via /tmp/commit_specs.sh
(waits for the gate). See [[refill-log]], [[bench-v4-wiring-refill-2026-11-14]].
