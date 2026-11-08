---
name: v5v6-v15v16-registry-refill-2026-11-08
description: "Spec-writer refill 2026-11-08 ~06Z: lifted 3.214/3.215/3.216 (V5/V6 wiring), wrote 3.223 V5/V6 variants flip, 3.224 V15/V16 research wiring, 3.225 V15/V16 variants flip; variants chain COMPLETE (needs-build left B1, B4, B6, B6x, B-D1); next free 3.226"
metadata:
  node_type: memory
  type: project
  originSessionId: 2ba7f509-e36e-4f0a-9096-1f7fe8b3903e
  modified: 2026-11-08T05:54:40.612Z
---

Refill 2026-11-08 05:36-06:20Z (runnable 3.218-3.222). Six committed (50be3ea..98e699d), all review OK.

- 3.214 phase2 exit_rule: re-measured on main 7ab23d6 after 3.213 merged - every number identical. Added `phase2._check_exit_rule(exit_rule, barrier_spec)` helper (public to 3.215). Round-1 BLOCK: meta has NaN in d_star_*_adf_p_values -> use _meta_eq/_dict_eq from test_phase2_cusum_decay, never plain ==.
- 3.215 symbol_stage: TRAP found - `_run_symbol_stage` is at C901 15 = the strict limit on main; the old spec's two `if`s made it 17. Now one-liners: `exit_rule = phase2._check_exit_rule(...)` and `extra.update({} if exit_rule is None else {...})` (IfExp does not count for C901/PLR0912). 3.219/3.222 depend on the same 15.
- 3.216 lifted unchanged (research_run 979 after it).
- 3.223 variants exit_rule (RunOptions field 19, DATASET_KEYS, local EXIT_RULES copy - test_variants import allow-list forbids fxplat.labeling); yaml V5/V6 status dataset. Pins moved: Counters (needs-build 7 / dataset 19), ("V5") -> ("B6x"), DATASET_KEYS exact, test_variants_major `_fields[-1]` -> `_fields[17]`.
- 3.224 research info_bars: build_datasets(info_bars) placed BEFORE exit_rule (3.216's test pins exit_rule last); _DS_DEFAULTS six pairs; caps 980 -> 985 (research_run 982).
- 3.225 variants info_bars (field 20, local INFO_BARS copy, no combination refusal); Counters needs-build 5 / dataset 21; owns test_variants_exits.py to move its `[-1] == 'exit_rule'` pins to [18] / DATASET_KEYS[4].

Prototypes: /tmp/sw3214 (phase2+symbol_stage), /tmp/sw3223 (+3.216, variants), /tmp/sw3224, /tmp/sw3225. Reviewer flagged `_opts` unused import in mandated import lists (F401) - don't mandate helpers no case uses.

**Why:** the next writer must not re-survey the variants chain; it is fully specified. **How to apply:** remaining variants needs-build (B1, B4, B-D1 wiring into variants; B6/B6x pending data) - check PHASE3_PLAN / decisions next. See [[vmaj-v15-v16-wiring-refill-2026-11-07]], [[protected-sibling-test-pins-exact-all]].
