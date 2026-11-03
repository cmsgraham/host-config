---
name: attribution-report-chain-refill-2026-11-02
description: "2026-11-02 22:12Z refill: 3.153 rerun_attribution (run dir -> AttributionRun + 14-key provenance) / 3.154 attribution_report (Spanish md + json writer) / 3.155 attribution_cli (deps 3.153+3.154) committed as HELD DRAFTS ec49b57 / e85875f / 7b6d8b0 because spec-review is SKIPPED by the usage gate (weekly 70 % cap, resets Tue 03:00 UTC); e2e synthetic datasets LACK the 4 attribution context columns -> tests need the registered _augment recipe; prototypes /tmp/p3153; next free 3.156 / 7.29 / 9.19 / 11.64 / 15.43 / 16.82"
metadata:
  type: project
  originSessionId: refill-20261102-221222
  modified: 2026-11-03T07:20:56.231Z
---

2026-11-02 22:12Z refill (runnable 3.151 / 7.27 / 7.28 / 9.18; low water 6). No drafts, no new RESOLVED decision,
every phone ask expired 'wait'; UI-A / UI-E / R rows / PHASE3 §3 exhausted; the unqueued state/proposals files
(contexto 13.10-13.16, multi-account 16.1-16.19, participantes 14.7, synthetic 15.22 / 15.35 / 15.38) are the
operator's own held-back proposals (untracked, no decision) - do not queue them. Source used = TASK-3.152's
deferred wiring ("a later task, with the run's c14_subperiods"; 3.152 merged 2026-11-02):
- 3.153 fxplat.pipeline.rerun_attribution (deps []): run_dir_attribution(run_dir, symbols, *, oos_start_ms,
  oos_end_ms, counterparty_path=None, n_boot=10_000) = read_manifest (seed, role) -> run_c14_subperiods ->
  load_counterparty -> read_pooled + read_predictions + read_windows -> run_attribution(global_seed=manifest seed);
  no config read / hash check (nothing from config enters); 14-key provenance.
- 3.154 fxplat.pipeline.attribution_report (deps []): check_payload, render_attribution_markdown (items 1/2/3/6
  tables with verdict.fmt, items 4/5 'pendiente', provenance block), attribution_report_json (kind
  'attribution_report'/1), write_attribution_report (rerun_report contract: stem regex, FileExistsError, md then
  json, unlink md on json failure).
- 3.155 fxplat.pipeline.attribution_cli (deps 3.153, 3.154): rerun_cli pattern, stem F3_<role>_<run_id>_ATRIBUCION
  (no timestamp), exit codes 0/2/3/1, three stdout lines.
- KEY TRAP: the e2e synthetic datasets (test_research_run_end_to_end._dataset) have only x0..x3 + FFD columns;
  fxplat.validation.attribution requires b27_vol_regime / d37_session / mtf_agreement / d44_carry -> the 3.153 /
  3.155 tests build their own run with the registered `_augment` recipe (rng 'attribution.context.<sym>' seed
  20_261_003; draws b27 uniform, mtf integers 0..4 int8, carry sign then magnitude; session via
  fxplat.sampling.sessions.session_of). Measured: run 137 s under load, n_test 1032, n_taken 172, stable both
  False (default subperiods: only (2013, 2015) holds trades), 32 cells / 26 reportable, both 'no evidence'.
- Spec review: `spec-review` returns "SKIPPED (0 findings, route local)" when agent_ci.usage.allow refuses
  (weekly 70 % >= cap); no report is written. All three committed WITH hold "draft, under review: spec-review
  SKIPPED ..." so the next writer (step 1 of SPEC_WRITER.md) reviews and lifts; nothing runnable was added.

**Why:** the next writer must not redo the prototyping, must know why the holds exist, and must not fall into the
missing-context-columns trap or queue the operator's held-back proposals.

**UPDATE 2026-11-03 07:15-07:3xZ (writer refill-20261103):** usage cap raised to 0.8 by the operator; the three
spec-reviews ran in parallel (detached nohup, ~5 min, route local, OK x3, 8 low/medium findings, all applied):
3.153 spelled-out fixture (t0 2010-01-01..2013-03-01, run_dir mkdir before writing) + re-verified on 85935b8
(recheck script /tmp/p3153/recheck.py: payload equal field for field on the old and the reviewer's /tmp/rv3153
rebuilt run); 3.154 section-5 heading literal 90 chars -> implicit concatenation note, _check_records helper for
mccabe 15, PROVENANCE_ORDER NOT in __all__; 3.155 refusals (d) call the REAL collaborators (only the RuntimeError
case patches), --reports-dir a fresh tmp_path subdir (env.reports holds the run's own F3 report), `from __future__
import annotations` allowed. Holds deleted, all valid (3.153/3.154 ELIGIBLE, 3.155 BLOCKED on them); committed by
/tmp/p3153/commit_final.sh once the 4.31 merge gate cleared (log /tmp/p3153/commit_final.log). Chain COMPLETE;
nothing left to write for §10.15 except the research_run wiring the operator keeps.

**How to apply (historical):** after Tue 03:00 UTC run `spec-review TASK-3.154`, `TASK-3.153`, `TASK-3.155`,
apply findings, delete the hold lines, validate, commit one file at a time (`git add -f`, no MERGING.json).
Prototypes: /tmp/p3153/proto/{rerun_attribution,attribution_report,attribution_cli}.py, measurement scripts
proto_run2.py (augmented run) / proto_attr.py / proto_cli.py, run dir /tmp/p3153/work2. Related:
[[control-settings-wiring-and-attribution-runner-refill]], [[k13-marks-wiring-refill-2026-11-02]],
[[real-run-task-ids]], [[merge-gate-wipes-uncommitted-task-edits]].
