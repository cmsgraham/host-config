---
name: vffd-vaux-runner-refill-2026-11-06
description: "Spec-writer refill 2026-11-06 ~13Z — 7.58/7.60 lifted; V-FFD / V-AUX runner chain 3.180-3.183 (research_run split-prep, variants options, runner wiring, yaml flip)"
metadata:
  node_type: memory
  type: project
  originSessionId: 96fdc0d2-fb5f-4471-a37b-c81ce1fb8cec
  modified: 2026-11-06T13:32:51.126Z
---

Refill 2026-11-06 13:07Z (runnable 3.176-3.179 / 7.61). Scratch /tmp/sw761 (gen/ t318x.py + common.py; s/ = git prototype of the whole chain).
- 7.58 / 7.60 holds lifted (7.59 merged; gate_hashes / HC / GC / write_g7c / build_run / NodeMixin verified on fe1c505).
- 3.180 split-prep: _DS_DEFAULTS / _dataset_kwargs / _child_kwargs moved research_run -> research_helpers (991 -> 973; cap 995 in test_research_helpers::test_line_caps).
- 3.181 variants: WF_KEYS gains 'no_ffd' BEFORE 'monotone' (test_variants_monotone pins WF_KEYS[-1]=='monotone'); RUN_KEYS=<redacted> never in wf_kwargs; no_ffd only valid with drop_features ⊇ FFD_COLUMNS -> V-FFD is a FILTER entry.
- 3.182 research_run wiring (ffd_series None + NO_FFD_NOTE check; mae_target = -labels['mae_R']). The e2e fixture labels have NO mae_R (real labels do).
- 3.183 yaml flip + counters 13/10/10 in test_variants.py AND test_variants_cusum_decay.py; ('V-FFD','needs-build') example -> V-MAJ.
Left: V7 (M3) runnable needs a C11-for-NaN-p_cal reading (operator ask?); rerun_criteria (C15/C17) ignore no_ffd. Next free ids: 3.184, 7.62, 8.15, 9.20.

**Why:** the next writer must not redo this chain; adding RunOptions fields changes every variant's checkpoint key (accepted, same as monotone).
**How to apply:** `git log --oneline -8 -- tasks/`. See [[m3-vaux-vffd-refill-2026-11-06]], [[strict-lint-1000-line-cap]].
