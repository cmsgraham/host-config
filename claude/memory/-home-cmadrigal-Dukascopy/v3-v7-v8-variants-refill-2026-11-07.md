---
name: v3-v7-v8-variants-refill-2026-11-07
description: "Spec-writer refill 2026-11-07 ~10Z after all six phone asks were RESOLVED: 3.203 V3 keep_features / 3.204 V8 trend_aligned / 3.205-3.208 V7 (M3) chain; left V-MAJ, V5/V6 wiring, V15/V16 wiring"
metadata:
  node_type: memory
  type: project
  originSessionId: e6b7d1b2-d066-4623-8455-4c60996689aa
  modified: 2026-11-07T16:40:52.796Z
---

All six 2026-11-07 asks came back RESOLVED with the recommended option (decisions-pending.md lines ~1094-1180):
v5-v6-exits (b) pure exit, v15-v16-scope (a) triggers only, v7-c11 (a) reported, v-maj (a) test on 7, v3 (a) literal, v8 (a) model filtered.

Written this refill (proto = scratchpad sw/proto, a full copy of src+config; tests symlinked; PYTHONPATH=proto/src):
- 3.203 V3: variants FILTER_KEYS + keep_features (RunOptions field 15, X order kept, FFD rule: keep without both FFD needs no_ffd; no_ffd with an FFD kept refused). V3 filter {keep_features: 13 cols, no_ffd: true}.
- 3.204 V8 (deps 3.203): trend_aligned (field 16), BREAKOUT_FAMILIES on WFInput.family, b23_trend200 == 1 — b23 is ALREADY direction x trend200 (groups_ab), the ask text said "direction == b23" which was a misreading.
- 3.205 decision_log / 3.206 run_events: p_hat no longer required on 'enter' — an M3 run through research_run otherwise dies at the first entered event (measured).
- 3.207 run_criteria: RunCriteria.c11_no_probability (last field) -> run_results C11 = Manual(None, 'no aplica (M3 no da probabilidad)'); rc.c11 stays None (publish.verdict reads attributes).
- 3.208 (deps 3.204-3.207): variants accepts M3 (+ kelly refused at load), V7 runner-ready, e2e run ~40 s.
GOTCHA: the research_run e2e seed datasets have only x0.. + FFD columns, so V3/V8 cannot be proven end to end there (unit WFInput only).
GOTCHA: proto outside git -> test_research_cli_variant fails with "git rev-parse" (artifact, not a real failure).

QUEUED + committed 0682297..ea7acef (all review OK; 3.204 BLOCK round 1 = 3.203's exact FILTER_KEYS pin -> 3.204 now owns test_variants_keep.py and moves it to [:5]). Runnable now: 3.203, 3.205, 3.206, 3.207.

Left for the next writer: V-MAJ (walkforward train_symbols, walkforward.py 849 lines), V5/V6 labeller wiring (barriers.py 927 lines -> new module), V15/V16 S-A triggers on info bars + symbol_stage wiring. Next free ids: 3.209, 7.62, 8.15, 9.20.

**Why:** the next writer should go straight to these three remaining answered decisions.
**How to apply:** check `git log --oneline -- tasks/` for 3.203-3.208 landing; specify V-MAJ / V5-V6 / V15-V16 pieces. See [[vmaj-v3-v8-asks-2026-11-07]], [[real-run-task-ids]].
