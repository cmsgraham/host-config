---
name: cusum-decay-vmon-refill-2026-11-05
description: "Spec-writer refill 2026-11-05 ~23Z — variants.yaml needs-build source continued: 3.161 phase2 cusum_k / time_decay, 3.162 symbol_stage same, 3.163 metalabel monotone= (V-MON); measured numbers; what is left (research_run + variants halves wait for 3.159/3.160; V-MON walk-forward wiring needs a walkforward helper split, 987/1000 lines); B5 variants row is stale"
metadata:
  node_type: memory
  type: project
  originSessionId: 12dd4000-92f7-40d3-b7a7-abf86aec84fb
  modified: 2026-11-05T22:54:19.886Z
---

Refill 2026-11-05 22:46Z (runnable 3.159 / 3.160 / 7.57 / 7.59 / 7.61; 3.160 building; 7.58 / 7.60 still held until
7.59 MERGES). Scratch /tmp/sw3161 (m1.py phase2 measurements, m_mon.py V-MON, review-3.16x.log).
- 3.161 phase2: sample_events(cusum_k=2.0), build_dataset(cusum_k=2.0, time_decay=True); *reading: g76_cusum_state
  follows the sampler's k (both cusum calls); meta 'cusum_k' / 'time_decay' keys only off-default.
- 3.162 symbol_stage (deps 3.161): inputs keys + build_dataset kwargs only off-default (3.158 pattern); acceptance runs
  only ONE other store module (3.158 load-stall triage).
- 3.163 metalabel fit_m2 / fit_window(monotone=None) (deps []): extra constraints on top of cost -1; refused for
  M0/M1; no V-MON column names in the module.
MEASURED (synthetic_symbol_data(weeks=66), test_phase2_sample_events constants): k1.5 -> 1,986 events {H 450, C 775,
B 761}, 1,974 labels, warmup 4478, censored 12, sumR 71.186384; k3.0 -> 1,403 {858,192,353}, 1,398 labels, warmup 1295,
sumR 127.131821; non-CUSUM-family ids identical (1,211); g76 differs on 1,239 / 1,225 common rows; also d46_crowding and
h77_origin differ. time_decay False: only weights change, sum 1655, (V1 w / nodecay w) max/min == 2.0.
V-MON planted frame (5 seeds): unconstrained against-theory carry range -0.70..-0.84; constrained flat; along theory
+0.76..+0.83.
LEFT: research_run + variants halves of CUSUM-k / V-TD (write after 3.159 / 3.160 merge: generalise DATASET_KEYS);
V-MON walk-forward wiring (walkforward.py 987 lines, lint-new cap 1000 -> split a helper first) + variants options key;
variants.yaml B5 says needs-build but run_criteria already calls cell_hit_rate (status should be in-run - fold into
the next variants task). Next free ids: 3.164, 7.62, 8.15, 9.20.

**Why:** next writer must not re-measure and must know the chain direction.
**How to apply:** `git log --oneline -8 -- tasks/`; status of 3.159-3.163. See [[latency-variants-and-node-drift-refill-2026-11-05]].
