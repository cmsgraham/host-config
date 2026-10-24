---
name: real-run-task-ids
description: "REAL_RUN_PLAN R-row → TASK id map + spec-writer log; 12.7 merged, 12.18 / 12.19 lifted 2026-10-24; queue sources exhausted except operator-blocked items; next free 3.147 / 4.20 / 9.12 / 11.42 / 12.20"
metadata:
  node_type: memory
  type: project
  originSessionId: dde62561-890d-4445-b15e-f7deb60c6a16
  modified: 2026-10-22T23:11:24.383Z
---

REAL_RUN_PLAN §3 ids as of 2026-10-11: R1=TASK-3.60, R2=3.61, R3=3.62 (symbol_stage), R0=3.65, R4 driver=3.63
(RESERVED, not yet written), R5 CLI=3.64 (reserved). Pure pieces split out of R4: 3.66 R4a decision records,
3.67 R4b child runner, 3.68 R4c trade criteria C1/C2/C8/C12, 3.69/3.70/3.71 FFD early-stop + p_m0 + ffd_workers pool,
3.72 R4d single-run criteria (fxplat.pipeline.run_criteria: B2/B3/C3/C4-B3-half/C11/C14 partial, run_results,
no_edge_facts), 3.73 verdict.no_edge_statement says DATO NO DISPONIBLE for a NaN DSR, 3.74 decision_outputs fix
(predictions ⊂ inp raised StopIteration; quadratic lookup), 3.75 CUSUM zero-threshold fix (REAL_RUN §6), 3.76 R5a
period_split (custom exploration train/test split in splitters.py; runner/CLI wiring still to write). 3.77 bars drop
non-finite ticks (operator-written). Chunking RESOLVED 2026-10-11 as (b) "bars whole range, ticks per labelling
window"; queued 2026-10-12: 3.78 barriers TickSource/ArrayTicks/label_events_from_source, 3.79 sources.StoreTicks
(UTC-month blocks, LRU) + store_symbol_data(ticks=False), 3.80 build_dataset(ticks=TickSource) [deps 3.78].
3.81 (queued 2026-10-12) run_symbol_stage passes StoreTicks + store_symbol_data(ticks=False) (ingest rows =
sum(m1_n_ticks); dataset_sha256 pinned 2b500f61... = the old path). 3.82 (queued 2026-10-12) R4f
fxplat.pipeline.research_run.build_datasets (symbols in spawned children, parent emits 'dataset' events, fail-fast).
NEXT: the rest of R4 as tasks amending research_run.py (pooled walk-forward; then decisions / criteria / verdict /
report / registro), then 3.63 as the thin end-to-end composition. Next free id 3.86 (3.63/3.64 were superseded by 3.83-3.85 as R4g/R4h/R5). UI: 9.5 is the operator manual; UI-A5 signals=9.6, A6 backtests=9.7, A7 cross-engine=9.8 (queued 2026-10-12); next 9.9 = UI-A8 risk board, then A9 data coverage, A10 run events. R6 (dvc stages) unwritten, waits on 3.84/3.85.

**Why:** the next spec writer must not reuse 3.63/3.64, and must not re-specify the split-out pieces.

**How to apply:** write TASK-3.63 with depends_on [3.71, 3.72, 3.73, 3.74, 3.81]; it is too big for one task - split
(e.g. datasets in children + pooled walk-forward, then decisions / criteria / verdict / report / registro). Notes measured 2026-10-11:
- run_walk_forward has no min_train_years argument; the splitter's registered 3 years + ~1 year D1 feature warm-up
  mean an end-to-end store fixture needs ~4.5 years of ticks (200 weeks of 3 ticks/min took 106 s to write and
  ~75 s per symbol to build - too slow). A 66-week store (as tests/pipeline/test_symbol_stage.py) builds in ~9 s per
  symbol in a child; the e2e test would have to monkeypatch walkforward.walk_forward to min_train_years=0.
- daily_close for the §9.4 portfolio rules: build from StoredDataset d1 closes (mid, closing 17:00 NY), index =
  NY local date of the close instant (point-in-time with R5's "strictly before the session date").
- ffd_workers and capital/risk: config/experiment.yaml has seeds (global_, lightgbm, bootstrap) and risk
  (capital_usd, risk_pct) but no ffd_workers key; the driver takes it as an argument (R5 reads config).
- EventWriter cannot be shared with a spawned child: run run_symbol_stage in the child with writer=None and let the
  parent emit the 'dataset' StageStarted / StageFinished around run_in_child.
- symbol_stage refuses anything outside DEV, so the driver is DEV-only until symbol_stage changes.

2026-10-13 (spec writer): R1-R5 (3.60-3.85) all passed. R6 = TASK-3.87 HELD "needs operator decision" (conflicts with
tests/test_dvc_dag.py forbidding data_dir; question in state/decisions-pending.md 2026-10-13, recommended defer).
New package fxplat.replay: 3.86 R7a/R8a day_rules (day_rule / calendar_rules / model_window; creates
src/fxplat/replay/__init__.py), 3.88 R7b frames.build_frames (deps 3.86; frame order bar < decision < entry < exit).
Next R7 pieces still unwritten: the composer that computes a day (ticks -> ... -> fills), R8 service, R9 what-if.
UI: 9.9 = UI-A8 risk (fxplat.publish.risk) queued; next 9.10 = UI-A9 data coverage, then A10 run events.
Note: state/ is gitignored, so decisions-pending.md is never committed.

2026-10-14 (spec writer): 3.89-3.96 were used by other work (O1 fixes, O3 prep, turbulence). Queued 3.97 R7c
fxplat.replay.day_items (decision_log records + label timings -> build_frames inputs, frame refs, carried trades;
the run's out-of-sample records ARE "the model as it stood that morning" - walk-forward models are not persisted,
only model_sha256). Still unwritten for R7: bar closes for the day from the store, the file-reading composer
(decisions.jsonl + labels -> day_items -> build_frames), then R8 service and R9 what-if. Phase 4: 4.13
fxplat.backtest.nautilus_replay (one engine per trade; alert at t_limit_ns - 1 because Nautilus matches a quote
before an alert at the same timestamp); 4.4 stub now points at it. Next free ids: 3.98, 4.14, 9.11.

2026-10-14 (spec writer, later): queued 3.98 R7d fxplat.replay.day_bars (m1 bars -> n-minute chart bars stamped at
bucket close); 9.11 UI-A10 part 1 fxplat.publish.decisions (decision records -> codes, no prose); 4.14
fxplat.backtest.replay_reconcile (labeller vs replay_trades per field, tolerances passed in, no defaults).
Remaining: R7 file-reading composer (decisions.jsonl + labels + store m1 -> day_items/day_bars/build_frames), then
R8/R9. UI-A10: runs index (sketch ui/scripts/export_runs.py), P&L series (needs labels' exit time; sketch
ui/scripts/export_pnl.py); the 60 s push may be covered by state/ops-scripts/sync-run-events.sh. 4.4: V1 trade pick,
financing on replayed trades (backtest may not import labeling -> likely pipeline), P&L / Sharpe agreement,
tolerance VALUES (operator decision). Next free ids: 3.99, 4.15, 9.12.

2026-10-16 (spec writer): lifted 3.106's leftover draft hold (review OK, strong tier). Queued 4.16 cost-model-v4 in
nautilus_fills (order_fill_px; strong tier per 2026-10-14 routing), 3.108 R7f fxplat.replay.day_replay (replay_day:
day_rule refusal first, pairs = m1_bars keys covering run symbols, union clock - a clock from run.symbols breaks
truncation; m1_from_table mid prices; the store read stays with R8), 4.17 fxplat.pipeline.replay_costs (financing per
replayed trade for 4.15's replay_costs input; 'open' -> 0.0). 4.4 stub now points at 4.16/4.17. Left: R8 service needs
an HTTP/WebSocket dependency that is NOT installed (no fastapi/aiohttp/websockets) - operator question before speccing;
R9 what-if; importance MDA/SFI categorical follow-up after 3.106 passes. Next free ids: 3.109, 4.18, 9.12.

2026-10-16 (spec writer, 12:26 refill): queued 3.109 fxplat.validation.importance categorical follow-up of 3.106 (MDA
permute keeps Categorical dtype, sfi scores Categoricals, skips object/str; owns tests/validation/test_importance.py,
replaces test_sfi_skips_categorical_columns) and 4.18 fxplat.pipeline.replay_inputs (V1 trade pick: enter records ->
TRADE_COLUMNS re-derived from labeller rules, label rows, upu mapping; e2e replay_trades/reconcile measured exact on
times). 4.4 stub now points at 4.18; left: tolerance VALUES (open 2026-10-15) + the wiring composer (run dir + store
ticks -> replay_inputs -> replay_trades -> replay_costs -> reconcile/agree) - spec it after 4.17 passes (its givens
need replay_costs on main). R8 service / R9 what-if / UI-C: the operator already built them in ui/ and deploy/ - not
spec-writer work. Next free ids: 3.110, 4.19, 9.12.

2026-10-16 (spec writer, 17:05 refill): queued 3.110 run_criteria(cal=None) -> B5 (baselines.cell_hit_rate) + fail-only
partial C5 (Manual; RESULTS_WITH_C5 order; CRITERIA_COMPUTED unchanged because publish.verdict.run_measures iterates it)
and 3.111 research_run._verdict_stage n_trials = dsr_trial_count (was max(1, effective_trial_count) = 1 on the real
registry; §10.5 N = 17). FOLLOW-UP once 3.110 passes: research_run passes cal=load_quality_config().calendar to
run_criteria (+ publish.verdict C5 measure). C6 HELD as an operator question (decisions-pending 2026-10-16): the §10.5
floor V = 0.5*SR^2 on one run gives SR0 = 1.29*SR, so C6 can never pass. Do not spec C6 before that decision. Re-run
criteria (C9/C15/C17, B1/B4) are deferred by decision 2026-10-11 until C1/C2/C8 pass. Next free ids: 3.112, 4.19, 9.12.

2026-10-16 (spec writer, 21:04 refill): queued 3.112 publish.verdict run_measures adds a partial 'C5' Measure when
rc.c5 is set (also edits test_run_criteria_b5.py's run_measures test, which pinned the old keys - review caught it),
3.113 research_run passes its step-(1) cal to run_criteria (deps 3.111, same file; e2e: B5 n_taken 754 / 1032, C5
PENDING), 4.19 fxplat.pipeline.replay_check (per pair pick -> replay -> replay_costs -> reconcile, ONE pooled
agree_replay; refuses swap source 'broker_table' because replay_costs only does IB policy rates; config/cost_model.yaml
is still v3 = broker_table, so tests build V4 by editing the YAML into tmp_path). 4.4 stub now points at 4.19; left:
tolerance VALUES (open 2026-10-15) + the file-reading driver (needs config on v4). Next free ids: 3.114, 4.20, 9.12.

2026-10-18 (spec writer, 06:06 refill): queued 3.129 (lopo/loyo take ffd_series - LOYO d* cutoff = excluded year's
start), 3.130 (fxplat.validation.cpcv_run.run_cpcv: the missing CPCV runner for C17; tau start = largest s with
s-3..s-1 contiguous non-test years), 3.131 (research_run.run_c14_subperiods: DEV_FULL passes the registered C14
subperiods its OOS covers; DEV call unchanged - test_research_run_c5 pins its exact kwargs). All under decision
2026-10-14 Gate 1 item (2). NEXT: drivers that read a run dir and run LOPO/LOYO/C15 (after 3.129) and CPCV/C17
(after 3.130) into the report; C9 matrix/perturbation/noise drivers. Next free ids: 3.132, 4.20, 9.12.

2026-10-18 (spec writer, 20:17 CST refill): 3.132/3.133 were taken by F1_COSTOS / F2_PRESUPUESTO. Queued 3.134
fxplat.pipeline.rerun_criteria (read_pooled = run_pooled_walk_forward's inputs via research_run's private helpers;
rerun_c15 = lopo + c15 on entered rows; rerun_c17 = run_cpcv + c17, 2010-2021 only) and 3.135 fxplat.pipeline.rerun_matrix
(rerun_c9_matrix with the official walk-forward keywords; c9_partial -> Manual False on matrix fail, None = PENDING
otherwise, since robustness.c9 with None studies would FAIL). Measured: the 6-cell matrix WITH per-window FFD took ~460 s
on the 2009-2013 stored fixture (7 s without) - test FFD forwarding with spies. NEXT (after both merge): the composer that
reads a run dir's manifest (symbols, OOS window, role DEV_FULL) -> read_pooled -> rerun_c15/c17/c9_matrix -> files +
re-run report. Next free ids: 3.136, 4.20, 9.12.

2026-10-19 (spec writer, 04:33 CST refill): queued 3.136 fxplat.validation.decay_study (§10.11: dollar_trend = USD
index of the 7 majors = -cumsum(DOL), 252-row momentum; dollar_trend_at uses rows dated STRICTLY before the decision's
UTC date; decay_study composes regimes by_year / rolling / slope / terciles of b27_vol_regime and dollar trend / c14),
3.137 symbol_stage(noise_seed=None, noise_mode='atr') (§10.9: perturbation.noisy_symbol_data on the store bars inside
the dataset stage, real StoreTicks; inputs gain noise_seed/noise_mode only when given; measured seed 100 = 1,578 events
vs 1,552 unnoised, ~11 s/build on the 66-week fixture), 3.138 fxplat.pipeline.rerun_loyo (loyo + entered rows + year_ev,
report only). NEXT: noise driver (per seed: run_symbol_stage(noise_seed) per symbol -> read_pooled -> walk-forward ->
net EV -> perturbation.run_noise) after 3.134 + 3.137 merge; the run-dir composer (C15/C17/C9 matrix/LOYO/decay) after
3.134-3.138. §10.14 importance per fold needs an operator choice of "pliegues" (WF months / CPCV splits / LOYO years)
- not asked yet. §10.8 perturbation and §10.10 random entries need build_dataset hooks (family params, injected
events) - large. Next free ids: 3.139, 4.20, 9.12.

2026-10-19 (spec writer, 18:21 UTC refill): no new ids used. TASK-7.23 had passed, so per decision 2026-10-14 19:10 CST
lifted the holds on 9.6 / 9.7 / 9.8 / 9.9 / 9.11 after spec-review (all OK, low findings applied). 9.11 givens were
stale: run_events.ROLES gained DEV_FULL (3.102b) -> Role Literal now DEV / VALIDATION / DEV_FULL. Found: §10.15
attribution (validation.attribution.attribution(inp, predictions, stable)) is wired nowhere in pipeline; its item-6
'conditional power' needs `stable` from §10.14 stability, which waits on the operator's "pliegues" choice (not asked
yet). Next free ids still: 3.139, 4.20, 9.12.

2026-10-20 (spec writer, 01:12 UTC refill): queued 3.139 fxplat.pipeline.rerun_noise (§10.9 driver: stage_builder =
one run_in_child(run_symbol_stage, noise_seed) per symbol into <work_dir>/noise-<seed>; seed_ev = official walk-forward
keywords, taken-row EV by event_id, 0.0 if none; rerun_noise -> run_noise; c9_with_noise -> Manual False / None, never
True since §10.8 perturbation is unrun), 3.140 fxplat.pipeline.rerun_decay (predictions.parquet read back, taken rows in
inp row order, daily_close -> UTC-midnight closes with any-NaN sessions dropped -> decay_study; report only), 3.141
fxplat.pipeline.rerun_verdict (F3 JSON -> Verdict checked against its rows; merge_reruns fills ONLY PENDING rows via
verdict._check_results/_passed_of/_summary_of; oracle = evaluate(BASE+REST)). All review OK (low findings applied).
Run manifest has NO oos window (caller/CLI must supply it). NEXT: the re-run CLI composing read_pooled -> rerun_c15/c17/
c9_matrix/noise/loyo/decay -> rerun_verdict + files; §10.8 perturbation and §10.10 random entries still need build_dataset
hooks (11.11 extra_signals may serve §10.10). 4.4 driver blocked on design: PairData wants whole tick arrays (12 y x 7
pairs won't fit) + tolerance values still OPEN. Next free ids: 3.142, 4.20, 9.12.

2026-10-21 (spec writer, 11:01 UTC refill): queued 3.142 fxplat.pipeline.rerun_run (composer: read_manifest -> symbols
must equal manifest's, seed = manifest seeds['global'] for both model seed and bootstrap global_seed; read_verdict;
refuses non-PENDING C9/C15/C17 targets BEFORE read_pooled; read_pooled once; studies in order c15, c17, c9_matrix,
loyo, decay; optional precomputed NoiseVerdict -> c9_with_noise; merge_reruns) and 3.143 fxplat.pipeline.rerun_report
(study_summaries plain JSON, F3-layout JSON + 'studies' that read_verdict reads back, Markdown = render_report + one
table per study, never overwrites). render_report REQUIRES NoEdgeFacts on NO_EDGE: the original run's facts are not
persisted, so the re-run CLI needs them rebuilt - idea: run_criteria uses only result.predictions, so
WFResult(read_predictions(run_dir), empty windows, ()) + read_pooled labels -> run_criteria -> check evaluate(run_results)
== read_verdict(report) -> no_edge_facts (N = dsr_trial_count at re-run time). MEASURED 2026-10-21: run_criteria ALSO reads result.windows (ValueError "windows: missing column 'p_m0'" with an
empty frame) - the facts task must rebuild windows from walkforward/windows.jsonl (p_m0 round trip unverified). The e2e
synthetic run (tests/pipeline/test_research_run_end_to_end helpers) takes ~42 s; a measuring script needs an
if __name__ == '__main__' guard (spawned children re-import it, else it hangs). UI-A10 part 2 / R8 / pnl: the operator already has
ui/scripts/export_runs.py, export_pnl.py, replay_service.py - skip. Next free ids: 3.144, 4.20, 9.12.

2026-10-22 (spec writer, 21:27 UTC refill): finished operator-held drafts whose merge conditions had passed: 11.25
(Remix seeds + operator pool in ideate.py) and 11.34 (calendar_event + econ calendar in scan.py). No R ids used.
3.144 (NoEdgeFacts rebuild for the re-run CLI) scoped but NOT written: run_criteria reads result.windows ONLY via
walkforward.m0_probabilities (columns start_ms + p_m0; predictions need segment_start_ms); windows.jsonl lines =
_window_line (NaN -> null, d_star dict). Plan: read_windows(run_dir) + WFResult(read_predictions, windows, ()) +
read_pooled labels -> run_criteria(same seeds/n_boot/cal/c14_subperiods) -> check evaluate(run_results(rc)) rows ==
read_verdict(report) -> research_run._verdict_stage(rc, registry, role, variant)[1]. Needs a measured e2e round trip
(STORED fixture of test_rerun_criteria.py). 11.12 waits for 11.35 (promoted.load_promoted) to merge. Next free ids:
3.144, 4.20, 9.12.

2026-10-22 (spec writer, 22:58 UTC refill): wrote 3.144 fxplat.pipeline.rerun_facts (read_windows + rebuild_facts;
MEASURED on the e2e synthetic run: read_predictions (event_id index - the raw parquet is refused) + windows(start_ms,
p_m0) + read_pooled -> run_criteria -> rows == report rows and facts == the run's; n_boot 60 vs 50 caught by the C1
row) and 11.36 = part 2 of 11.12 (symbol_stage hallazgo=PromotedRule; StateInputs built from SymbolData = store_bars
oracle; W1-frame predicates refused - weekly_bars needs ts_open/bid/ask; cross-pair predicates fail without closes).
11.12 part 3 BLOCKED on design: research_run.py is 996/1000 lines, so passing hallazgo through build_datasets +
hypothesis_test row + report label needs a new wrapper module or a research_run split. 12.7 (W1 in scan) waits for
12.3 AND scan.py is 974 lines after 11.34 -> needs a helper-module split. Next free ids: 3.145, 4.20, 9.12, 11.37.

2026-10-23 (spec writer, 00:29 UTC refill): 3.144 merged (2a9af23). Gap found: rebuild_facts returns None when the
SINGLE run was INCOMPLETE, but the main re-run case is INCOMPLETE -> NO_EDGE via a failed C15/C17/C9 (render_report
then refuses). Queued 3.145 rerun_facts.merged_facts (merged rows may differ only on PENDING C9/C15/C17; facts via
no_edge_facts + MERGED_LIMITATIONS 'más las re-ejecuciones ... de: {reran}'). Drafted 3.146 rerun_cli (hold "draft,
under review" until 3.145 merges: re-verify merged_facts on main): manifest -> symbols/role/run_id, OOS default =
research_cli._PERIODS[role], merged_facts PREFLIGHT with report._replace(verdict='NO_EDGE') before studies,
rerun_run, merged_facts, write_rerun_report, exit 3 on refusals, no registry row, no noise. MEASURED on the e2e
synthetic run under load: c15 126 s, c17 540 s, c9_matrix 196 s, loyo 7-14 s; 'decay' FAILS on synthetic datasets
(inp.X missing 'b27_vol_regime') - tests run loyo only. spec-review can exceed the 600 s Bash background limit: run
it with run_in_background + explicit long timeout. Next free ids: 3.147, 4.20, 9.12, 11.37.

2026-10-23 (spec writer, 02:00 UTC refill): waited for the 3.145 merge gate (3569b27), re-verified merged_facts on main,
lifted 3.146's hold and committed (e55b16d) - the re-run chain 3.134-3.146 is now fully specified. No other spec-able
work found: 4.4 (tolerance values), 5.1-8.4 (wait on 4.4), 11.12 part 3 (research_run 996/1000 lines - needs a split
design), C6 / §10.14 pliegues all operator-blocked. Untracked tasks/TASK-11.35.yaml in the main tree is not the spec
writer's - left alone. Next free ids: 3.147, 4.20, 9.12, 11.37.

2026-10-23 (spec writer, 03:30 UTC refill): queued 11.39 (2ccd43f) = 11.12 part 3a: research_run.py split - twelve
pure helpers (_parallel_symbols, _tree_sample, _ResourceSampler, _session_dates, _daily_close, _pooled_labels,
_json_value, _window_line, _write_atomic, _write_lines, _segment_stats, _segment_events + _NY) verbatim into new
fxplat.pipeline.research_helpers, re-exported; research_run <= 820 lines (prototype 806; all research_run / cli /
rerun tests pass on it). Names tests PATCH on research_run (_build_symbol, _check_writer, build_datasets,
run_pooled_walk_forward, run_criteria, dsr_trial_count, load_cost_model, _verdict_stage, run_research) must stay
defined there. NEXT (after 11.39 merges): 11.40 = part 3b run_research(hallazgo=PromotedRule): refuse with variant;
symbols == promoted.rule_symbols; DEV_FULL refused when promoted.validation_used(registry rows); hallazgo through
build_datasets + parallel ds_kwargs to run_symbol_stage; dataset_cache inputs gain hallazgo /
hallazgo_protocol_sha256 (as symbol_stage); checkpoint key must differ from V1 (_checkpoint_key returns pinned_sha256
when options None!); verdict variant / registry variante = HZ id; append_trial hypothesis_id FX-HZ-NNN run_type
hypothesis_test; manifest run_type too; _ATTRIBUTION strings say 'exploratory ... no es una prueba de hipótesis' -
need hallazgo-specific attribution; DEV report gets promoted.SELECTION_NOTE. Then 11.41 = research_cli --hallazgo.
12.7 (W1 in scan) still waits 12.3; scan.py 974 lines - put W1 logic in a new module rather than a split task.
Scratch-copy measuring: `git init` + commit the copy, else research_cli tests fail on git_state. Next free ids:
3.147, 4.20, 9.12, 11.40.

2026-10-23 (spec writer, 05:00 UTC refill): queued 12.17 (29f6066) = scan.py split-prep: 14 pure helpers verbatim into
fxplat.hallazgos.scan_helpers (scan.py 974 -> 870 on prototype; import back WITHOUT noqa - all names used, a noqa F401 is
a RUF100 lint-new violation). Finished 12.7 (9ca4a10, still HELD "draft, under review: lift after 12.3 and 12.17 merge"):
W1 = weekly_bars(D1).assign(thin_flag=False) before _check_lock, emission_base W1 all True, any non-STATE primitive in a
W1 cell refused before the store; OWNS tests/hallazgos/test_hz_scan.py for one edit (it pinned emission_base('W1')
raising -> now M15). Measured on fixture: 43 W1 bars, fixed_h n 17 / brk_2R n 16. Next lifts 12.7 after re-verifying on
main. Follow-ups: confirm.py W1 (KeyError on W1 cells once 12.3 merges), idea_scan REASON_W1 wording. 11.40 still waits
11.39. Next free ids: 3.147, 4.20, 9.12, 11.40, 12.18.

2026-10-23 (spec writer, 07:10 UTC refill): 11.39 merged (387e4a6). Queued 11.40 (6a2b075) = 11.12 part 3b:
run_research(hallazgo=PromotedRule) + build_datasets(hallazgo=) + _check_hallazgo (PromotedRule / not with variant /
symbols == rule_symbols in order / trials.require_registered via MODULE attr - append_trial uses the same global, so
tests fake it on fxplat.common.trials / sha == protocol_sha256 / DEV_FULL refused if validation_used), run_type
hypothesis_test, stem F3_<role>_HZ-NNN_<run>, provenance hallazgo keys (manifest key set is fixed), DEV md gets
dev_verdict_label + SELECTION_NOTE after the title. OWNS test_research_helpers.py to raise its 820-line cap to 950.
Prototype: 888 lines, strict-lint-new clean, new tests 2m54s (3 full e2e runs). NEXT: 11.41 research_cli --hallazgo
after 11.40 merges - NOTE exit codes 5 (RSS) and 6 (symbol stage) are TAKEN; 11.12's "exit 5 validation already
used" must become a new code (7). Next free ids: 3.147, 4.20, 9.12, 11.41, 12.18.

2026-10-23 (spec writer, 09:06 UTC refill): 11.40 + 12.17 merged. Queued 11.41 (0d3eb06) = 11.12 part 4: research_cli
run --hallazgo HZ-NNN [--promotions PATH]; load_promoted in _resolve with protocols_dir=Path('experiments/protocols')
(cwd-relative, = append_trial's require_registered; promote.LEDGER_PATH / PROTOCOLS_DIR are ABSOLUTE repo paths bound
at def time); symbols default rule_symbols, other order = exit 2; DEV_FULL + validation_used = exit 7; every rule
refusal = HallazgoRefusedError -> EXIT_HALLAZGO 7 (5 is MEMORY). Prototype: research_cli 474 -> 556 lines, 21 tests in
~4 s; tests/hallazgos is NOT a package (copy test_hz_promoted helpers, don't import). TASK-11.12 itself keeps its
operator hold (all parts 11.35/36/39/40/41 written). Nothing else spec-able: confirm.py / idea_scan W1 follow-ups wait
12.3 + 12.7; contexto-del-dia (TASK-13.*) drafts wait operator decisions; 4.4 tolerances / C6 / pliegues still OPEN.
Next free ids: 3.147, 4.20, 9.12, 11.42, 12.18.

2026-10-23 (spec writer, 10:30 UTC refill): 12.3 + 12.17 merged -> lifted 12.7's hold after re-verifying (main changes since
6ab580a = exactly those two). CAUGHT: tests/hallazgos/test_hz_scan_helpers.py test_line_caps pins scan.py <= 880 (main 873,
12.7 adds ~14) -> 12.7 now owns that file for 880 -> 950. Wrote 12.18 (confirm._symbol_work W1 twin: weekly_bars of the
confirmation D1 before _check_lock; measured on test_hz_confirm market: 27 W1 decisions, fixed_h n 21 / brk_2R n 20, p 1.0;
test flips reportable on its copy of cells.parquet) and 12.19 (idea_scan: STATE-only W1 ideas scanned, REASON_W1 text ->
"marco W1: solo primitivas de estado"; owns test_hz_idea_scan.py for 4 literals). Both HELD "lift after TASK-12.7 merges"
(review asked). Prototype = /tmp/proto1218 (main + 12.7 scan change + both changes; git init'ed). GOTCHA: the merge gate
RESETS modified tracked files in the main tree - a tasks/*.yaml edit left uncommitted while MERGING.json exists is lost;
keep a /tmp backup and restore before committing. Next free ids: 3.147, 4.20, 9.12, 11.42, 12.20.

2026-10-24 (spec writer, 00:05 UTC refill): 12.7 merged (1b7b72a) -> lifted 12.18 (0a52b2b) and 12.19 (072f5ca) after re-verifying
on main 1a62c4e. 12.7 as merged moved the non-STATE W1 refusal into scan._refuse_w1 (called first in run_scan, not per cell);
behaviour unchanged. Re-measured 12.18 on /tmp/p1218m (git-archive of main + confirm change; run with PYTHONPATH=src or the
editable install imports MAIN's src): every number held (n 21/20, excluded W1 censored 25 / no_entry 6, 27 decisions, truncation
13 decisions / 53 rows). No third task: resume_gate decision = 8.9 (passed); UI-A1..A10, PHASE3 map, R rows all covered;
remaining = operator-blocked (4.4 tolerances, C6, pliegues, D1/fixed_h/W1 promotion via promote.RULE_FRAMES, 12.6/12.16
signatures, 14.2 CFTC dates, 14.7-14.14 outside the operator's 'capture + panel' scope). Next free ids unchanged.
