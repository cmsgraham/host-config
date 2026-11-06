---
name: b1-rerun-chain-refill-2026-11-06
description: "Spec-writer refill 2026-11-06 ~18Z — B1 random-entries re-run chain 3.184-3.188 (baseline_label, rerun_b1, rerun_b1_stage, rerun_run b1=, rerun_cli --b1) so C4 can finally PASS; new source = needs-build baselines"
metadata:
  node_type: memory
  type: project
  originSessionId: 04400a5d-4c48-4bf3-9f34-ee8ee25b1988
  modified: 2026-11-06T18:31:30.101Z
---

Refill 2026-11-06 18:14Z (runnable 3.178/3.179/3.182/3.183/7.61; IB node composition still deferred, ibapi not installed). NEW SOURCE: the needs-build rows of config/variants.yaml **baselines** — run_criteria's C4 is only the B3 half ('B1 pendiente'), so no DEV verdict could ever be EDGE. Scratch /tmp/sw3184 (gen/ t318x.py generators reuse /tmp/sw761/gen/common.py; s/ = prototype tree with config symlink, run with PYTHONPATH=s/src:s).
- 3.184 fxplat.pipeline.baseline_label (deps []): strategy_valid_hours = sample_events' emission gate (sum 1622 on synthetic weeks=66), label_baseline = build_dataset's labeller call (equal to built.labels exactly).
- 3.185 fxplat.pipeline.rerun_b1 (deps []): b1_counts (taken trades per symbol × UTC month of t0_ms), pool_b1 (per-seed null pooled over symbols; empty seed refused), c4_with_b1.
- 3.186 rerun_b1_stage (deps 3.184/3.185): rerun_b1(run_dir, symbols, *, data_dir, cost_model, cal) → B1Run(counts, b3, b1, c4); per-symbol spawned child reads the store with the dataset's stored inputs; refuses variant inputs / other cost model.
- 3.187 rerun_run(b1=None) merges b1.c4 into a PENDING C4 (deps 3.186). 3.188 rerun_cli --b1 [--data-dir] (deps 3.187); rerun_b1 runs after the preflight, `**extra` so test_rerun_cli's exact kwargs pin holds.
Left: B4 (can only FAIL C5 while B-D1 is pending), B-D1 daily pipeline (PHASE3_PLAN 3.20, big), V5 chandelier / V6 native exits (labeller needs bar-driven exits; barriers.py 927 lines), V7 C11-for-M3. Next free ids: 3.189, 7.62, 8.15, 9.20.

**Why:** the next writer must not redo the B1 chain and should know which needs-build rows are still open.
**How to apply:** `git log --oneline -8 -- tasks/`; check /tmp/sw3184/commit_a.log for the waiter. See [[vffd-vaux-runner-refill-2026-11-06]], [[real-run-task-ids]].
