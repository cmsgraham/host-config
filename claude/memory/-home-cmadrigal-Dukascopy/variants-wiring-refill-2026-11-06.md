---
name: variants-wiring-refill-2026-11-06
description: "Spec-writer refill 2026-11-06 ~05Z — research_run + variants halves of CUSUM-k / V-TD / V1-g / V-MON: 3.169-3.173; research_run cap 970 -> 995; variants.yaml needs-build source after this = 15 rows; field-order and pin-prefix conventions"
metadata:
  node_type: memory
  type: project
  originSessionId: 61e532a3-fecf-44f1-a7b4-2191ab9f0d42
  modified: 2026-11-06T04:59:20.789Z
---

Refill 2026-11-06 04:33Z (runnable 3.166/3.167/3.168/7.59/7.61). Scratch /tmp/sw3169 (git-archive prototype, gen/ generators t31xx.py + common.py, rr_3169.py / rr_3171.py / var_317x.py / yaml_317x.yaml prototypes).
All five reviewed OK in round 1 and committed hold-free (e674ef8, 84b0c80, 03e4845, 230940f, 0dfab1a):
- 3.169 research_run build_datasets(cusum_k, time_decay) + _DS_DEFAULTS/_dataset_kwargs (getattr defaults); raises the 970 cap to 995 in test_research_helpers / test_research_run_rulers / test_research_run_latency (owned). Measured 976.
- 3.170 variants DATASET_KEYS + cusum_k/time_decay; yaml V-CUSUM-k1.5/3.0, V-TD -> dataset; stale B5 -> in-run.
- 3.171 research_run barrier_spec: ds_kw stays JSON {m, limit_hours} (cache key), _child_kwargs -> BarrierSpec for the children. Measured 988-989 (budget 993, cap 995).
- 3.172 variants barrier_spec as an (m, limit_hours) pair (variants may NOT import fxplat.labeling); the twelve V1-g rows -> dataset.
- 3.173 variants WF_KEYS + monotone ((col, sign) pairs, M2 only, refuses d45_cost_r); V-MON -> runner-ready. No research_run change is needed: wf_kwargs feeds run_walk_forward.
Conventions: RunOptions fields are appended in this order: latency_s, cusum_k, time_decay, barrier_spec, monotone. New tests pin prefixes and indexes (_fields[8:11], DATASET_KEYS[:3]); ONLY test_variants.py pins the whole status Counter, so later variants tasks move one literal. Final Counter after 3.173: needs-build 15, dataset 17, runner-ready 9, filter 9, in-run 3.
Review traps found: an inline comment on the ds_kw line busts E501; once() in the cache-mirror test returns the shared list (copy it).
Left: research_run is at ~989/995, so the next research_run change needs a helper split first. Remaining needs-build rows in variants.yaml (V7, V16, V-FFD, B1, etc.). 7.58/7.60 still wait for 7.59 to merge. Next free ids: 3.174, 7.62, 8.15, 9.20.

**Why:** the next writer must not re-measure, and must respect the field order and pin conventions.
**How to apply:** `git log --oneline -8 -- tasks/`. See [[v1g-grid-and-vmon-wiring-refill-2026-11-06]], [[cusum-decay-vmon-refill-2026-11-05]].
