---
name: latency-variants-and-node-drift-refill-2026-11-05
description: "Spec-writer refill 2026-11-05 ~09Z — lifted TASK-7.59 (third review OK) and opened a NEW spec source: the needs-build variants of config/variants.yaml. Chain 3.157 phase2 latency_s -> 3.158 symbol_stage -> 3.160 research_run (lands BEFORE) -> 3.159 variants status 'dataset' + V1-x0/V1-x5; plus 7.61 node_drift (clock probe). Measured 60/360/0 s label numbers; what is left (V1-g label grid needs barriers spec hook; 7.58/7.60 lift after 7.59 merges)"
metadata:
  node_type: memory
  type: project
  originSessionId: refill-20261105-085129
  modified: 2026-11-05T09:20:48.935Z
---

Refill 2026-11-05 08:51Z (runnable 7.50 / 7.53 / 7.55 / 7.56 / 7.57 < low water 6; drafts 7.58 OK-held, 7.59 BLOCK-unresolved,
7.60 OK-held). Generator /tmp/sw761/gen.py + specs.py, backups /tmp/sw761/backup, measurements /tmp/sw761/m_lat*.py,
7.59 scratch /tmp/sw759.
1. 7.59 node_host: third spec-review OK (medium: cap 280 -> 320; lows: spy case in its own test right after the start,
   dirty case writes no drift file) -> applied, --accept-amended, hold lifted, committed 950b283. Its reviewer's medium
   "re-measure case (g) once 7.49/7.50/7.53/7.55 merge" was NOT done (deps unmerged) - the deps chain protects it.
   7.58 / 7.60 stay HELD "lift only after TASK-7.59 is ... MERGED" -> next writer: once 7.59 merges, re-check the names
   (gate_hashes / HC / GC / write_g7c, node_start / node_poll) on main and delete their hold lines.
2. NEW SOURCE when the stubs are exhausted: `grep needs-build config/variants.yaml` - prompt.txt §9.5 says every one of
   the 53 configurations is reported, so building their plumbing is methodology, not an operator choice. Written:
   - 3.157 phase2.sample_events / build_dataset(latency_s=60) (deps []): validated FIRST, forwarded to
     assemble_events only; labeller grace stays 60 (§7.2 one-minute rule). *reading §3.4: T_exec = next minute's
     open = 60 s, so V1-x0 '+0 min' = 60 s (a control identical to V1) and V1-x5 = 360 s.
   - 3.158 run_symbol_stage(latency_s=60) LAST kw (deps 3.157): inputs key + build_dataset kw ONLY when != 60
     (3.137 noise_seed pattern keeps every pinned kwargs set / dataset_sha256 / cache key).
   - 3.160 research_run (deps 3.158, lands BEFORE 3.159 on purpose): build_datasets(latency_s=60) child kwargs only
     when != 60; _dataset_kwargs(options) = getattr(options, 'latency_s', 60) (RunOptions has no field yet) -> both
     dataset branches + the dataset_cache inputs mirror; owns test_research_helpers.py for the cap 950 -> 970
     (research_run is 945 lines).
   - 3.159 variants (deps 3.158 + 3.160): STATUSES + 'dataset' (RUNNABLE), DATASET_KEYS=<redacted>
     RunOptions.latency_s=60 LAST, dataset_kwargs; owns config/variants.yaml (V1-x0 {latency_s: 60}, V1-x5 {360}, header
     docs) + test_variants.py (Counter needs-build 34 -> 32 + dataset 2). If 3.159 merged before 3.160, `run
     --variant V1-x5` would walk V1's datasets under another name - hence the dependency direction.
   - 7.61 node_drift (deps []): the operator-side clock probe writing <out_dir>/clock_drift.json {ts_ms, drift_ms}
     (7.59's reader contract): parse `chronyc tracking` (System time fast/slow of NTP; Leap status Normal / Insert
     second / Delete second, else refuse) or --drift-ms; fail closed by writing NOTHING on error (stale file ages out).
MEASURED 2026-11-05 (sources.synthetic_symbol_data(weeks=66), test_phase2_sample_events' CAL / RISK_USD / TRAIN_END_MS /
_cost_v3, ~5 s per build): 1,662 events; latency 60 vs 360: events equal ex ts_order_submit, features EQUAL, 1,655
labels each, 1,654 common ids (only-60 '4548017bfd16fb27', only-360 'b9ad5c5ed561cb62'), ts_fill shift exactly 300 s,
entry_px differs on all, outcome_R on 1,642, first_touch on 47, sums 104.167932 / 105.16536; meta['d_star_d1_adf_p_values']
DIFFERS (don't pin meta ==). latency 0: 1,654 labels, censored 8 (vs 7), sum 129.35721. tests/pipeline IS a package
(import its helpers with `from tests.pipeline.x import ...`); tests/execution is not.
FINAL 09:20Z: all six committed hold-free - 7.59 950b283, 7.61 d60c57a, 3.158 76adf58, 3.157 00f9167, 3.160 e3e1087,
3.159 8f4b4db; queue 10 runnable. Review rounds: 7.61 / 3.158 OK first round; 3.157 (meta holds NaN -> never ==, compare
NaN-tolerantly like test_phase2._meta_eq), 3.159 (research_cli `variants` summary lists every STATUSES entry incl. 0 -> owns
test_research_cli_variant.py literal; CHARTER §12.5 is the cost model, don't cite it for variants.yaml), 3.160 (a SECOND
research_run cap pin lives in test_research_run_rulers.py::test_line_cap_and_all - own both when raising the cap) BLOCK
then OK. Reviewer trap: it called DESIGN line 214 "not under §9.6" - it is (header line 208).
LEFT in variants.yaml needs-build: V1-g label grid (12; needs label_events(barrier_spec=) hook in labeling/barriers -
spec_for(family, frame) is called inside label_events at two places), V3 (operator mapping), V-FFD etc., B1/B4 (deferred
by decision 2026-10-11), B6/B6x (policy rates data), B-D1 (daily pipeline). Next free ids: 3.161, 7.62, 8.15, 9.20.

**Why:** the next writer must not re-measure the latency numbers, must know the dependency direction 3.160 -> 3.159 and
that variants.yaml needs-build rows are a legitimate spec source.
**How to apply:** `git log --oneline -8 -- tasks/`; `agent-ci status` for 3.157-3.160 / 7.61 / 7.59. See
[[ib-node-sixth-refill-2026-11-05]], [[strict-lint-1000-line-cap]] (research_run cap), [[merge-gate-wipes-uncommitted-task-edits]].
