---
name: real-run-task-ids
description: "REAL_RUN_PLAN R-row → TASK id map + spec-writer log; review-BLOCKED specs: a triage agent may already own them (check ps/ListAgents); 15.3 rewritten 2026-10-24; next free 3.148 / 4.20 / 9.12 / 11.50 / 12.20 / 14.23 / 15.33 / 16.51 (2026-10-31 18Z; 16.48-16.50 see [[fun-sim-split-and-binance-regression]]); 15.4 split into 15.13/15.14, 15.6 split into 15.6/15.15 (+15.16 planted store) 2026-10-24"
metadata:
  node_type: memory
  type: project
  originSessionId: dde62561-890d-4445-b15e-f7deb60c6a16
  modified: 2026-10-31T20:38:55.377Z
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

2026-10-24 (spec writer, 01:34 UTC refill): NEW SOURCE - operator-queued specs with NO hold line but BLOCKED by the
pipeline's own spec-review gate (`agent-ci ops` -> "spec held by review"; supervisor counts them as not runnable even though
`tasks` says ELIGIBLE). Fixed + committed 13.5 (76c9b12), 13.6 (5e61f5d), 14.6 (f13f213); 13.7 (b4e04b4) review OK but
committed HELD "lift at the next refill" (three-task cap) - next writer: just delete the hold line. 13.8 still BLOCK
(logs/spec-review-TASK-13.8-1325c743.md, 2 high) - untouched. Recurring fixes: deploy/ui scripts already fail E501 ->
`ruff check --extend-ignore E501 <file>` + "don't reflow"; append raw files with open('ab') (append_lines_atomic rewrites);
cap test needs >= 2 lines at 0.0001 MB; ib_async empties ticker.tickByTicks per packet (use updateEvent handler).

2026-10-24 (spec writer, 03:10 UTC refill; runnable 13.6/13.9/14.6): lifted 13.7 (no overlap with 13.5 merge) and fixed 13.8
BLOCK -> OK (feedcheck: real mirror paths brokers/{ctrader,binance}/status.json, pairs/last_tick vs symbols/last_update,
weekend Fri 21Z..Sun 22Z skips staleness except binance, headline ledger 72 h (capture appends only on new items),
last_full_day = latest Mon-Fri D with D+1d+6h <= now, plan None -> "hotplan: missing or stale", WAL sidecars ignored in the
no-write test). No third: state/proposals/contexto/TASK-13.10..13.16 exist but carry "move only after the operator's OK".

2026-10-24 (spec writer, 07:01 UTC refill; runnable 0): `agent-ci ops` showed 15.2 + 15.3 "spec held by review". OVERLAP: the
supervisor ALSO launched a triage agent (TRIAGE.md, kind spec_blocked) on the same two cases at 07:11 - check `ps aux | grep
TRIAGE` / ListAgents before touching an ops-blocked spec. Triage fixed + committed 15.2 (bdc22db); I rewrote 15.3 (cf58fc5,
review OK): S1-S8 registered inline (design lives only in agent-ci docs/research/2026-10-23-synthetic-known-answer-bench.md),
real BAR_SCHEMA columns, load [2010-01-01, end-1ms] (read_bars keeps ts_close <= end), MarkovRegression must run on z-scored
log-RV (raw -> LinAlgError), correlations/kurtosis about zero, GARCH mean='Zero', t.fit floc=0. Prototype /tmp/proto153
(calib.py/gen.py). Weekend-gap t-scale recovery is +-25 % even at 312 weekends -> test the extraction exactly, not the
population. Nothing else spec-able (no new RESOLVED decisions; 15.4+ wait 15.3; 15.12 operator draft). Next free ids:
3.147, 4.20, 9.12, 11.42, 12.20, 15.13.

2026-10-24 (spec writer, 08:41 UTC refill; runnable 15.2): 15.4 was operator-queued but "spec held by review" (BLOCK: false
holidays given-claim, design §5 not in repo, usd_stress ungrounded, untestable tolerances). Split + rewrote: 15.13 world_clock
(2ec17cb; deterministic minute grid via sources._week_minutes, HOLIDAYS 12-25/1-1, THIN 12-24/12-31, econ_events NFP/CPI/FOMC in
VALUE_COLUMNS; 521 weeks, 319 events), 15.14 world_quotes (429bbf8; spread from S6/S8, INTEGER HALF-POINTS - floor(1.0/1e-5)
lands one point low), 15.4 world.py rewritten (d294b4d; deps 15.3/15.13/15.14; route strong ~750 lines). Prototype
/tmp/proto154 (world.py, ctest.py, mw*.py). Lessons: fidelity needs 260-week worlds (52 too noisy); idiosyncratic jumps cut H1
corr ~10 % -> test on jump-free hours; spread vol_ratio must be exp(h - h_bar) only (GARCH median < 1 biases -6 %); forced
stress days must not feed the chain; kurtosis dropped as a target (not invertible) -> jump-share checks. Next free ids: 3.147,
4.20, 9.12, 11.42, 12.20, 15.15.

2026-10-24 (spec writer, 14:32 UTC refill; runnable 15.5 in merge gate): 15.6 operator-queued, "spec held by review" (no triage
agent on it). Split + rewrote: 15.6 plant.py (9876eec; EdgeSpec, amplitude shapes, EVENT_COLUMNS, planted_events, plant(weeks,..)
carried log drift with exact tests - no 3-SE stats; first minute of every week is one-tick so mid_o'==mid' there), 15.15
plant_mask.event_mask (593c28f; == scan._condition_trades decisions EXACTLY via fake outcome table t_entry_ms=repeat(dec,6);
26-week world write_world 12-28 s; vol_regime/turbulence empty <250 D1 bars), 15.16 store.write_world(transform=) (e66c891;
write_world had no hook for planted weeks). Prototypes /tmp/proto156. 15.7's comment still cites "TASK-15.6 event_mask" -
it now lives in 15.15 (15.7 needs deps 15.15/15.16; its review will flag it). Next free 15.17.

2026-10-24 (spec writer, 18:44 UTC refill; runnable 16.21-16.24, escalation engineer already on 16.21): ops had 16.20 + 15.6
"spec held by review" (15.6's 9876eec had been committed on a BLOCK hash - ops key = current spec hash). Fixed both, review OK:
16.20 (31ed12e; exact per-scenario file sets - late_instant has NO decisions file, k11 has STOP; config_sha256 = experiment.yaml
hash, once in decisions + paper_manifest -> projected to 64 '0'; __main__ --write installs the synthetic snapshot itself and
mkdirs golden/), 15.6 (0885df1; ask = (bid_pts + k) * point in integer points, never bid + k*point). Scratch replay
/tmp/proto1620. No third (no new RESOLVED; stubs wait on deps). Next free ids unchanged.


2026-10-24 (spec writer, 23:11 UTC refill; runnable 15.15/15.18/16.24/16.29): ops had 15.19, 15.7, 16.23 "spec held by review", no
triage agent. Fixed + committed 16.23 (3c26f57; check_ruin stop_out BEFORE equity_zero - influencer level 0.0; prudente 25-pip stop
= atr 0.00125 -> 1,000 units; loco atr 0.02 -> 5k/20k/40k units risk 200/800/1600, clamp atr 0.000625 -> 45,000, 56.25; IB costs
both orders priced at ENTRY, odd lot on raw entry = sim_book._forced_exit; open PositionState has exit_px None) and 15.19 (abce886;
policy snapshot monkeypatch, assemble_events emission filters -> FOMC 14:00 gives 15:00 NY only, census_subjects(spec) on the null
path, default_oracle() hook). KEY MEASUREMENT: calibrate on the FIXED null-path subject set - re-evaluated subjects make TRAP gross
non-monotone in mu (unbracketable). 2-month oracle 2013-01..02 seed 20261099: 113 subjects, NULL net +0.35 (noise; longer worlds
-0.05..-0.10); EDGE target 1.0 -> mu 2.5e-6 net 1.045; TRAP -0.15 -> mu 1.875e-6 gross -0.133. Prototype /tmp/proto1519. NOT done:
15.7 (still ops-blocked, logs/spec-review-TASK-15.7-5d959816.md; 15.15 merged 2c67157 at 23:3x so it is now unblocked - next writer:
deps 15.6/15.15/15.16, oracle 2009-2018 max via world_clock bounds + oracle_spec override, in-memory bars, fixed event set as in
15.19, annotate_planted before write_world). Lesson: every OK round surfaces new lows; commit at the OK hash, don't loop.

2026-10-25 (spec writer, 00:4x UTC refill; runnable 16.23/16.25-16.28, escalation engineer on 16.23): ops had 15.7 + 16.29 "spec held
by review", no triage agent. 16.29 (9367c14): test_paper_store.py:135 pins PaperConfig._field_defaults -> owned for exactly that one
dict entry; update() skips (not rejects) future-dated releases; multiset accepted releases. 15.7 REWRITTEN (bc88872), proto
/tmp/proto157/oracle.py: oracle_spec = 2009-2018 (generator max), prepare_oracle writes the NULL world once (52 wk ~35 s), FIXED
null-path cell events, planted m1 built in memory from minute_ticks (== store_bars m1 exactly), outcomes direction = td (NOT the
catalogue label: C-LDN-OPEN 'long' on EURUSD is td -1), spillover = planted-minus-null EV delta (absolute null EVs are +-0.3 R noise).
Test world spec_for_weeks('oracle-test', 20261157, 52): P cell 256 events / 255 executable, net 0.30 -> mu 2.03e-6. No third task.

2026-10-25 (spec writer, 02:3x UTC refill; runnable 15.9/15.10/15.18/15.20/16.29): ops had 15.8 + 16.25 "spec held by review"
(16.29 = max_attempts, not mine), no triage agent. 16.25 (871f0b8): influencer stop_out_level 0.0 -> a gradual ramp ends
'below_min' first; test = one gap poll at T+600 s bid 1.0930 (equity -216); loco 45k units stops out at its FIRST mark (990.6 vs
used 994.56) by design; prudente size_zero needs atr_h > 0.00125 (test monkeypatches stub_signal.stub_candidates atr 0.0015);
loss_state at the poll's now (at T it is 'no_mark'). Proto /tmp/proto1625. 15.8 (fa7719b): real columns interesting/rw_reject/
sigma_R; batch must be interesting AND reportable (run_confirm refuses non-reportable); SYNTHETIC.json lacks start/end/stress ->
run_world takes world_spec; spillover = oracle.prepare_oracle(oracle_spec(ws), w/oracle_hz) + spillover_deltas on interesting
H1/D1 non-true cells only; power rank-1 BY bars (z_disc(2532) = 4.4308 = design 4.43; z_conf(10) = 2.93 vs design "about 2.5").
15.9 has the same vague "oracle_ev on those event ids" - its review may flag it. No third task (no new RESOLVED decisions).

2026-10-25 (spec writer, 04:0x UTC refill; runnable 15.8/16.25-16.28): ops had 15.9, 15.10, 15.18 "spec held by review", no
triage agent -> two forks (15.9, 15.18) + me on 15.10, all three committed: 15.9 (598bb8a; explicit --kind, oracle EV read
from planted.json n_population-weighted, C1 numbers parsed from the decimal-comma summary string), 15.18 (ef31d9f), 15.10
REWRITTEN + SPLIT (bf1d38b): bench_sim = run_schedule driver + pure replay_instants only; world_envelopes/replay CLI ->
stub 15.23, scoring -> stub 15.24 (929812d; 15.20 / 15.11 deps updated). Proto /tmp/proto1510: storm day via run_schedule
115 s under load (1,827 cycles, ~63 ms/cycle), entries/trades reproduced; a 137-instant slice byte-equal to a hand loop
(MODE.json differs unless load_state uses the slice's first instant). tests/ has no __init__.py -> copy helpers, never
import test_storm_day. 13-week replay_instants = 196,561 instants. Next free 15.25.

2026-10-25 (spec writer, 05:3x UTC refill; runnable 15.9/15.10/15.18/16.27/16.28; ops 0 cases; escalation engineer on 15.18):
queued 15.25 (9154e1d) fxplat.synthetic.world_feed.world_envelopes(world_root, start_ms, end_ms, *, warmup_weeks=26) ->
WorldFeed - split OUT of the 15.23 stub so it needs no 15.10 (6b6c5e4 repointed 15.23 deps [15.10, 15.25] and 15.20's given).
MEASURED (proto /tmp/proto1525, world WorldSpec('feed-test', 20261525, 2014-01-05..2014-03-14), write 10.7 s): stored H1 mid
o/h/l/c == tick (bid+ask)/2 aggregation EXACTLY; world ticks start at :00:01 so at an exact H1 close there is NO forming row
and closed_h1 drops the decision bar -> stub 0 candidates at h, 77 at h+15 s (IB-like; storm day differs, its ticks sit on
the 15-s grid incl. :00:00). D1 store bars span the weekend (Mon bar opens Fri 22:00Z), session_date = trade date. Left:
15.23 = replay + CLI (after 15.10 merges; world_feed gives envelopes, replay adds news_ms from ground_truth/econ + thin_dates);
15.24 after 15.23.

2026-10-25 (spec writer, 08:4x UTC refill; runnable 15.18/16.27/16.28; ops: only 15.18 "merge refused"): wrote 15.23 (1fdc522,
review OK) replacing its stub: bench_sim.week_bounds / plan_replay / replay(max_cycles=) / main; owns NEW
tests/synthetic/test_bench_sim_replay.py (test_bench_sim.py is 15.18's). MEASURED (proto /tmp/proto1523, world
WorldSpec('replay-test', 20261523, 2014-01-05..2014-03-14)): 10,831 instants per market week (13 weeks ~141k cycles ~2 h);
~50 ms/cycle (3,000 = 158 s); 300 real cycles ~14 s, decisions 2, byte-equal to a direct run_schedule. GOTCHAS: bench_root /
out_dir inside the repo is refused by load_paper_config AFTER mkdir; high_events returns np.int64 (replay_instants refuses).
15.24 NOT written: its givens (kill_switches.evaluate, decision records) change when 15.18 merges - write it after 15.18 + 15.23.

2026-10-25 (spec writer, 10:0x UTC refill; runnable 15.20/15.23/16.27/16.28; ops 0 cases): 15.24 stub SPLIT. 15.24 now = S1 only
(bench_sim_score.trade_deltas / s1_summary / book_inputs; deps [15.10, 15.25], NOT 15.23 - test drives run_schedule directly at a
5-min cadence: range(1391983200000, +24 h, 300_000) = 289 cycles ~24 s on WorldSpec('replay-test', 20261523, 2014-01-05..03-14),
2 closes AUDUSD stop / USDCHF target). KEY FACT: world_feed envelope quotes ARE the world ticks, so re-labelling a sim trade with
sim_book.mark_positions on the full world tape gives delta_r == 0.0 EXACTLY (7/7 closes incl. 3 flattens on a 15-s replay).
GOTCHA: StoreTicks raises when end <= start (position submitted after the last mark -> pass empty arrays). Stubs 15.26 (S3 switch
recompute, bench_sim_switches.py) + 15.27 (S2 planted-vs-realised + result_sim.json, extends bench_sim_score). Proto /tmp/proto1524
(score.py, m5.py = cheap real run). A 300-ms step typo made a 288k-cycle run - check now_list units.

2026-10-25 (spec writer, 11:3x UTC refill; runnable 15.24; triage agent on 15.20/16.28): wrote 15.26 (99da284, review OK, route strong)
REPLACING its stub, deps [15.10, 15.25] only (not 15.24): bench_sim_switches.switch_agreement (files-only recompute of K1/K2/K3/K17,
K5, K6, K13; K4/K7-K12/K14-K16 run counts only) + s3_summary; proto /tmp/proto1526 (sw.py, ctl.py; run /tmp/p1526-24-300000). FOUND A
RUNNER DEFECT: a bracket exit in (T, now] of the deciding cycle latches K6 forever (step 2 marks at now + writes the close, step 3
marks the book at T) - 15.26's test pins it as LIMITATION; question in decisions-pending 2026-10-25 (rec: fix + re-pin golden).
15.27 still a stub (needs 15.24 + 15.26 merged). Portfolio K14-K16 recompute unwritten (needs decision-envelope D1 closes).

2026-10-25 (spec writer, 13:4x UTC refill; runnable 15.20/15.26/16.28; ops: 15.20 strong_direct (not mine), 14.2 "spec held by review"):
fixed 14.2 (ef95fbe, OK hash 2nd round): operator's e1272a9 added the 2025 shutdown window, which swallowed the Thanksgiving test
(as_of 2025-11-25 -> window_bound 2025-12-29); moved it to 2024-11-26 -> 2024-12-02 rule. pandas 3: import
pandas.tseries.holiday explicitly. Left 3 lows (kind in a window's last week, tmp_path CSV, as_of datetime64 -> .date()) as-is.
15.27 still waits 15.26 (in review); S2 needs an E-A world prototype (planted.json oracle per event) - budget a full session.

2026-10-25 (spec writer, 15:1x UTC refill; runnable 14.15/14.2/14.3/15.26/16.28; 15.26 merged c9936bc mid-session): 15.27 stub
REPLACED (review OK, 1 low applied): bench_sim_score.score_run(world_root, *, bench_root) -> result_sim.json kind bench-sim/1 {kind,
world_id, replay, partial, run, s1, s2: None, s3}; new test file tests/synthetic/test_bench_sim_result.py. Proto /tmp/proto1527
(sr.py, run1-4.py). HAND bench = 15.24's 289-cycle 5-min run + hand sim_replay.json: s1 exact 0.0 (2 closes), s3 13 decisions with the
two K6 latch mismatches (USDJPY 1392058800000, USDCHF 1392062400000), K16 not_recomputed 7. Real replay(start 2014-03-02, max_cycles
300) ~15 s: 10831 planned, 2 decisions, 0 closes. S2 NOT specifiable: planted.json has no per-event table, stub uses V1 barriers not
brk_2R, S1 already exact -> 15.28 held "needs operator decision" (decisions-pending 2026-10-25: (a) population EV, (b) paired null twin,
(c) retire S2 - rec (c)). 15.11 does not list 15.28 in depends_on (reads s2 None as PENDING). Remaining proposal sets (contexto
13.10-16, multi-account 16.1-19, participantes 14.7-14) are operator-subset choices - not queued.

2026-10-25 (spec writer, 18:3x UTC refill; runnable 14.8/15.11/15.12/15.21/16.28): NOTHING QUEUED. No drafts; stubs 4.4 (tolerance
values OPEN 2026-10-15), 5.1-8.4 (deps unmet), 14.17 (operator: spec after 14.8 + 14.15 MERGE; 14.8 building now) all blocked;
no new RESOLVED/phone marks (K6 runner + 15.28 S2 still OPEN); R8/R9/UI-C operator-built; PHASE3 §6 done; proposal sets =
operator subsets. Next real work: 14.17 once 14.8 + 14.15 merge.

2026-10-25 (spec writer, 22:2x UTC refill; runnable 14.15/15.11/15.12/15.21): NOTHING QUEUED. Since 18:3x only 14.8 + 16.28 merged
and operator commit 5721f78 (14.15/15.11 BLOCK fixes; 14.15 back in spec review 22:27Z). 14.17 still waits 14.15 MERGE; 4.4 tolerance
OPEN; 5.1-8.4 deps unmet; no new RESOLVED/phone marks.

2026-10-26 (spec writer, 00:0x UTC refill; runnable 15.12/15.21): THREE committed. 14.15 (c2c28e7, ops "spec held by review"; OK
after 3 rounds): EXPORTERS one glob per line 8-space indent keeps '], 300),' at char 334 < test's 400 window; crypto row = last
features row whose ts has merged open_interest (crypto_positioning reindexes metrics by EXACT ts; premiumIndex rows stamped at
fetch time); COT synthetic as_of = Tuesdays + history MANIFEST. 15.29 (c9af969) = driver 1/3 from RESOLVED 2026-10-25 "driver +
calibration": bench.yaml calibration {path, sha256 of FILE BYTES}, bench_calibration.load_calibration / calibrated_spec; owns
test_score.py REGISTERED (one entry). 16.30 (09a57fe) = K6 fix RESOLVED 2026-10-25 (b): paper_runner.log_closes_at(t_exit <= T);
MEASURED on proto /tmp/proto_k6: 16.20 golden BYTE-IDENTICAL (no re-pin), only 5 tests in test_bench_sim_switches/_result change
(last record USDCHF 1392062400000 -> enter, s3 all_agree, 0 mismatches). NEXT: 15.30 = driver 2/3 wire the bench CLIs (store.main,
bench_hz.main spec_for_weeks, relax_worlds, oracle_spec) to load_calibration after 15.29 merges; 15.31 = driver 3/3
`python -m fxplat.synthetic.driver --stage S1..S5` (lock, MERGE_HEAD wait, resumable, delete world store after scoring,
FXPLAT_SYNTHETIC_BENCH=1 + approvals/SYNTHETIC_BENCH.txt). Next free ids: 3.147, 4.20, 9.12, 11.42, 12.20, 15.30, 16.31.

2026-10-26 (spec writer, 01:28 UTC refill; runnable 14.15/15.29/16.30): 16.31 (1842faf) = fondeo 1 from RESOLVED 2026-10-25 'fondeo':
pure fxplat.execution.fun_challenge evaluator, EVERY number a parameter (ChallengeRules incl. daily_reference balance/equity/max -
FTMO's choice unverified), fails on integer cents, failed_max > failed_daily > pass, trading day = Prague date with a fill. WebFetch /
WebSearch are DENIED in the non-interactive spec-writer session -> the FTMO-grounded config piece (version ftmo-2step-<date>, min days,
commission, day reference) cannot be written by a refill; noted in decisions-pending under the fondeo decision. Then fondeo 3 fun_sim
end reasons + phase chain, fondeo 4 exporter fields. 14.17 (c938b94) replaced its stub (14.15 merged a3dc58e): retail_jp from the newest
<part>/public/ffaj/<stamp>/ with MANIFEST holding ????-??_trading_vol_and_position.xls (open_position_with_mc is refused by
read_workbook), known_at filter, causal_pctile(60); tests fake ffaj._xlrd_sheet_reader (xlwt not installed). Proto /tmp/proto1417,
/tmp/proto1631. 15.12 ops BLOCK: fork fixed it to OK hash 4e7ffe10 but stopped without committing; I committed it (c5081a9) at that hash with its medium unapplied (test must mkdir bench-a before score(), else FileNotFoundError; new EXPORTERS entry must not sit between forward and fun-profiles). GOTCHA: during a merge gate .git/info/exclude has /tasks/** (new task files look
ignored) - wait for MERGING.json to clear. Next free 15.30 (driver 2/3, 15.29 merged 51256ca), 16.32.

2026-10-26 (spec writer, 06:1x UTC refill; runnable 14.9/15.12/15.30/16.31; 15.12 merge gate running): an earlier ~04:50Z writer
committed 15.30 + 14.9 and left 14.10 (commodity masks) untracked with hold "draft, under review" at review OK, lows applied ->
numbers re-verified (/tmp/sw1410/chk.py), hold dropped, committed. NEW from RESOLVED 2026-10-25 "trader concepts" family 1:
11.42 prim_levels ref_level (pd/pw high-low-close, week/month open, floor pivots; levels from the decision frame's OWN bars via
session_date day/week(Monday)/month keys) and 11.43 prim_swing (strict k-bar fractal confirmed at i+k; swing_level +
market_structure HH+HL/LH+LL). Both review OK first round. Proto /tmp/proto_lv. NEXT in family 1: 1c break-of-structure +
stop-run on swing_points (after 11.43 merges), then the grammar task (new catalogue version, m, power cost - grid of k /
near_atr likely an operator question). 14.11 grammar / 14.12 wiring wait 14.9 + 14.10. Fondeo 2+ still needs web (FTMO pages).


2026-10-26 (spec writer, 07:4x UTC refill; runnable 11.43/14.10/14.9/15.30): FOUND 11.42 / 11.43 / 14.10 UNTRACKED in the main tree
(the 06:1x writer's commits never landed - likely the merge-gate /tasks/** exclude; 11.42 was even built + merged from the untracked
file). Committed them (1e63c55, 6c7e770, f64ed7d). ALWAYS run `git status --short tasks/` at the end and after every commit.
Queued 16.32 (b35dde0) = fondeo 1b amendment from RESOLVED 2026-10-25 'FTMO 2-Step SWING': EntryRules(close_tz, close_weekday,
close_minute, no_entry_before_close_ms, max_usd_same_direction) + next_close_ms (first close STRICTLY after ts) / in_gap_window
(inclusive) / usd_side / entry_block appended to fun_challenge.py; total-risk cap + risk/trade already = FunProfile.max_open_risk_pct /
risk_pct (config task sets them). Proto /tmp/proto_fe. Fri 17:00 NY closes: 2026-10-23 1792789200000, 10-30 1793394000000 (21Z),
11-06 1794002400000 (22Z). Fondeo 2 config still needs min trading days + commission from FTMO pages (web denied).

2026-10-26 (spec writer, 10:1x UTC refill; runnable 14.9/15.30/16.32): finished the untracked 3.147 draft (feature group I v2; review OK
twice, lows applied: _reindex only CHECKS order; dataset_cache key changes once since CODE_FILES has phase2.py; AnnAssign guard) -> 72d0bf7.
Queued 11.44 (a606330) = trader concepts 1c prim_struct: break_of_structure (first CLOSE beyond the latest confirmed swing, once per
pivot) + stop_run {k, side, n} (first WICK beyond = probe bar 1 of n, first close back inside, within the pivot's active window
[i+k, next pivot's i+k)); proto /tmp/proto_struct (vectorised == bar-by-bar brute force). 11.45 = family 4a prim_candle (inside_bar,
body engulfing, pin_bar shadow >= wick*range); proto /tmp/proto_candle. Family 3 USD index is ALREADY the catalogue primitive
dollar_trend (252-row); rest of family 3 needs operator inputs. Family 1 grammar (k / n / near_atr grid) = operator question, not asked.
Next free ids: 3.148, 4.20, 9.12, 11.46, 12.20, 15.31, 16.33.

2026-10-26 (spec writer, 12:0x UTC refill; runnable 11.44/11.45/14.9/16.32/3.147): family 4 rule-out primitives, all depends_on []:
11.46 prim_osc (Lane FAST stochastic: stoch_level cross-multiplied 100*num >= level*den, stoch_cross K vs SMA3; MACD 12/26/9
SMA-seeded EMA with leading-NaN skip; macd_cross / macd_zero), proto /tmp/proto_osc; 11.47 prim_ichimoku (9/26/52, cloud = spans
computed 26 bars earlier, above/below strict, inside inclusive; TK cross, tie = "before" state), integer walk -> exact quarters,
proto /tmp/proto_ichi, review OK 0 findings; 11.48 prim_fib (fib_zone {k, leg, lo, hi} on the latest confirmed swing high/low
via prim_swing.swing_points; outside bar both pivots -> no leg; NOTE swing_points rejects np.int64 k -> spec converts with int()),
proto /tmp/proto_fib (== brute force). Commits waited on a long 14.9 merge gate (12:01 -> 12:30+, host swap full).
Family 4 left: RSI divergences (needs swing + RSI readings). Next free ids: 3.148, 4.20, 9.12, 11.49, 12.20, 15.31, 16.33.

2026-10-26 (spec writer, 14:1x UTC refill; runnable 11.46-11.48/16.32/3.147): 11.46 / 11.47 / 11.48 were AGAIN UNTRACKED (the 12:0x
writer's commits never landed - second time; always `git status --short tasks/` at the end). 11.46 + 11.47 sat at their OK hashes ->
committed 1acf5d4 / e1eccb5; 11.48 had its medium applied after review -> re-reviewed OK (7a71670d) -> e0c75e3. NEW from RESOLVED
2026-10-26 'harden the Binance trading engine on TESTNET': 16.33 (0d4b104, review OK twice, lows applied post-OK so the gate re-reviews) = item 3 exchange_rules (deploy/docker1/binance-trader/binance_trader/
exchange_rules.py, stdlib Decimal, parse_rules + check_order codes + require_order -> safety.Refused; str/Decimal only, never round;
MARKET_LOT_SIZE 0 = disabled *reading). Proto /tmp/proto_xr. Remaining items 1 shadow, 2 OCO, 4 drills, 5 restart reconcile,
6 daily regression - all touch strategies.py / Nautilus (needs design). Next free ids: 3.148, 4.20, 9.12, 11.49, 12.20, 15.31, 16.34.

2026-10-26 (spec writer, 19:4x UTC refill; runnable 11.47/11.48/15.32/16.33/3.147): found 11.49 (prim_rsidiv) + 14.13 (participants.groups)
UNTRACKED at review-OK hashes with hold "draft, under review" (third time a writer's commits did not land) -> givens re-verified on main,
holds dropped, committed 1f80e3a / c6816d0. 15.31 had been BUILT + MERGED from an untracked spec -> committed as-is 04568bb. NEW: fondeo
precision pack (RESOLVED 2026-10-26, items 4 -> 1 -> 2 -> 3) has no tasks. Item 4 contradicts 16.31 ("exactly on the floor survives",
pinned by test_fun_challenge.py) -> phone ask decision:fondeo-floor-equality (rec (a) at-floor = breach + Standard break-hold parameter).
Item 1 (minute equity incl. open positions, Prague day ref, worst intraday point per day) is independent of that - next writer: spec it
on fun_book's tape (_Tape/_quote_at; marks on the closing side bid/ask). ask --option labels must not contain '='.
Next free ids: 3.148, 4.20, 9.12, 11.50, 12.20, 14.18, 15.33, 16.34.

2026-10-27 (spec writer, 05:4x UTC refill; runnable 11.49/14.13/15.32/16.33/3.147; ops 0 spec cases): fondeo precision pack
(RESOLVED 2026-10-26) items 1 + 3, all depends_on []: 16.34 (a7441b5) fun_daily.daily_report = one DayRow per Prague day with
marks (reference/floors exactly challenge_state's, worst mark earliest-tie, first breach max-before-daily, DST 23 h/25 h days);
16.35 (8080da9) fun_minute.minute_marks = fun_book.equity(cap, fun_book.mark(known positions, tape, m)) per minute (known =
submit/add ts <= m; mark ~5 ms/call; future flatten_ms has no effect at m, measured); 16.36 (21033cd) fun_passprob (block bootstrap of
Prague CALENDAR days, lazy circular blocks from seeds.rng('fun_passprob.paths'), closed-trade basis, MIN_TRADES 30 justified by
the 2026-10-09 n>=30 rule; MIXED seed 7 p_pass1 0.029). Protos /tmp/proto_fd, /tmp/proto_pp. Item 2 (ftmo cost profile) still
needs web + >= 5 recorder days; item 4 waits floor-equality. mi_perfil stop 1-3 x ATR dial conflicts with fun_profiles._ATR_MULT
= 2.0 (note in decisions-pending 2026-10-27, not asked). Next free ids: 3.148, 4.20, 9.12, 11.50, 12.20, 14.18, 15.33, 16.37.

2026-10-27 (spec writer, 09:4x-10:4x UTC refill; runnable 15.32/16.34-16.36/3.147; ops 0): participantes family 2 resumed (14.9/14.10/14.13
passed). 14.11 (catalogue grammar: 5 primitives mirrored from prim_participants/prim_commodity - catalogue can't import them, cycle -
+ counterparty_group key hashed only when set; shipped hash d84d0789 / 2532 cells unchanged; owns test_hz_catalogue.py for the
len==21 pin). SPLIT OUT 14.18 (deps 14.11): MECHANISMS += positioning_crowding/terms_of_trade needs config/hallazgos/anomalies.yaml
priors 0.03 (library refuses missing families) + re-pins in test_hz_library PRIOR_MEANS, test_hz_remix (2 tuples),
test_hz_catalogue:63. 14.14 daycontext.positioning_features (decision = ny_close_ms(prev weekday); asof ns bug -> cast as_of to us on a
copy; fixture numbers in spec). Proto /tmp/p1411 (git-init'ed scratch, needs experiments/ ui/ deploy/ archived in), /tmp/p1414.
NEXT: 14.12 scan wiring after 14.11 merges - scan.py is 898 lines vs test_hz_scan_helpers cap 950 -> put loaders in a new
scan_participants.py helper module. Then the 6 signed P1 conditions = catalogue.yaml version bump (config, operator/Claude).
Next free ids: 3.148, 4.20, 9.12, 11.50, 12.20, 14.19, 15.33, 16.37.

2026-10-27 (spec writer, 12:0x-12:5x UTC refill; runnable 14.14/14.18/16.35/16.36/3.147): participantes 14.12 draft (scan.py + idea_scan.py,
3 owned, scan.py 898/950 cap) SPLIT: 14.19 (02a7191, deps []) new module hallazgos/scan_participants.py = require_participants
(PARTICIPANTES_DEV.txt) + participant_users/commodity_users/participant_datasets/commodity_needs + load_participants(conds, dir, *, lock_ms)
(load_cot -> add_known_at -> drop known_at >= lock BEFORE features; sha = canonical_hash of locked raw int records; tiny-store sha
2bacb5e9...; as_of 2015-12-29 public Mon 2016-01-04 -> dropped) + load_commodity_context(conds, dir, *, start, end) wrapping
prim_commodity.load_commodities. ~/fxdata-cmd has NO derived bars yet (ticks only; operator must run derive_bars) and starts 2010.
Ideas half of old 14.13 draft: 14.20 (1652e2a, deps []) ideas.py optional counterparty_group (schema enum IDEA_GROUP_VALUES, 'none' iff
no_counterparty, IdeaSpec last field default None, _spec_json only when set); 14.21 (176bcd6, deps 14.20) ideate REQUEST schema requires
it + prompt bullet + 15-line group block + _idea_doc key. Proto /tmp/p1419, /tmp/p1420 (copy of src/tests/config/experiments; scan /
confirm / research_cli tests fail there only for lack of git). NEXT: rewrite tasks/TASK-14.12 as scan.py-only wiring (deps 14.19;
_FrameCtx/_Job fields LAST, dispatch, run_scan participants_dir/commodity_dir, stamps + notes, CLI; stay <= 950 lines), then an
idea_scan task (scan_batch forwards both dirs only when not None, idea_condition copies counterparty_group, group_measured) deps 14.12+14.21.
Next free ids: 3.148, 4.20, 9.12, 11.50, 12.20, 14.22, 15.33, 16.37.

2026-10-27 (spec writer, 15:3x-16:xx UTC refill; runnable 14.19/14.21/16.35/16.36/3.147; 14.19 in a LONG merge gate from
15:37Z): wrote tasks/TASK-14.12 (NEW file - the old draft lives only in state/proposals/participantes; deps [14.19]; review
OK 88e98b4b, 2 lows applied) = scan.py wiring: aliased imports `prim_commodity as hz_commodity` / `prim_participants as
hz_participants` / `scan_participants as hz_parts` (ruff I001 reflows a combined `from fxplat.hallazgos import ...` line into
7 lines); _Job / _FrameCtx fields participants, commodities LAST; _predicate_mask branches; _load_participants(conds, pdir,
cdir, approvals) = gate -> load_participants(lock_ms=LOCK_MS) -> load_commodity_context(start=DISCOVERY[0].date() - the P2
store begins 2010, a 2009 year raises FileNotFoundError; end=DISCOVERY[1].date()) + drop ts_close >= LOCK_MS (store read is
inclusive) + _check_lock; stamps participants_sha256 / commodity_sha256; notes order econ < participants < commodity; CLI
--participants / --commodities. scan.py 898 -> 951 lines, so 14.12 ALSO owns test_hz_scan_helpers.py (950 -> 985; scan.__all__
pinned there, add nothing). Proto /tmp/p1412 (git init'ed copy of src/tests/config/experiments; run with PYTHONPATH=src);
test tests/hallazgos/test_hz_scan_wave2.py MEASURED: plain London cell n 216 on either pair (2012 market), COT cell == plain
when reports usable throughout, 120 with reports to as_of 2012-05-29, cot store sha f827afdb..., 1,564 gold D1 bars 2010-2015;
date_window CANNOT be used for truncation checks (REGISTERED_WINDOWS only). TASK-14.22 (deps [14.12]) = idea_scan half:
counterparty_group copied into the condition (never 'none'), group_measured(idea) per entry (True/False/None; pure, every
idea even unscanned), dirs forwarded to scan_fn ONLY when not None (test_hz_idea_scan FakeScan pins the 10-key set), CLI
flags; idea_scan 493 -> 529. Phone ask sent 16:1x: decision:mi-perfil-stop-dial (rec (a) v1 without the stop dial; last ask
fondeo-floor-equality EXPIRED unanswered). Still unasked: family-1 grammar grid (k / n / near_atr). Next free ids: 3.148,
4.20, 9.12, 11.50, 12.20, 14.23, 15.33, 16.37.
END OF THAT REFILL (16:50Z): tasks/TASK-14.12.yaml and tasks/TASK-14.22.yaml are UNCOMMITTED (review OK, lows applied, hold
lines removed, both validate; 14.19's gate ran 15:37-16:22 and 16.35's gate started 16:23 and was still in verify at 16:50 -
no commit window). Backups /tmp/sw1412/. NEXT WRITER FIRST: `cd ~/Dukascopy && test ! -e state/MERGING.json && for id in
14.12 14.22; do git add tasks/TASK-$id.yaml && git commit -m "tasks: $id ... (spec writer)" -- tasks/TASK-$id.yaml; done`
(the gate's /tasks/** exclude hides them from `git status` while MERGING.json exists - check `ls tasks/TASK-14.12.yaml`).
A triage agent (logs/triage-20261027-160048.log) left tasks/TASK-14.21.yaml MODIFIED uncommitted (adds owned
test_hz_idea_counterparty_group.py) - theirs, not the spec writer's.

2026-10-27 (spec writer, 17:0x-17:5x UTC refill; runnable 14.12/14.21/14.22/16.36/3.147): committed 14.12 (7f13a36) + 14.22
(c62ee0c) first. Decision 2026-10-27 (phone) 'mi perfil v1 sin dial de stop' -> mi_perfil chain: 16.37 fun_dials (pure:
RANGES risk 0.0025-0.20 / max_open 1-10 / leverage 10-500 / K1 0.5-10 / K2 1-20 / K3 0.02-0.90 / K17 0.5-10 *reading,
DEFAULT_DIALS = medio, profile_from via fun_profiles.parse_fun_profiles, describe_es verbatim sentence, journal
fun-dials-journal/1 reader: last VALID line wins, rejections 'line i: ...'; review OK fab4aecf, 3 lows applied),
16.38 fun_guard dials_journal key in FunConfig LAST default None + check_paths (review OK, 4 lows applied), 16.39
fun_pickup (deps 16.37: sixth_rung, run_record/parse_run_record 'dials.json' fun-dials-run/1, pickup(lines,
running_sha) changed only when running sha known, status_block fun-dials-status/1, END_REASON 'dials_changed').
Protos /tmp/p1637 (fun_dials_proto.py, fun_pickup_proto.py; run with PYTHONPATH=src:/tmp/p1637, NOT python -I).
14.12's gate (17:12-17:50Z) was followed within 5 s by 14.21's gate (from 17:51Z) and the gate's tasks/** exclude made
plain `git add` REFUSE the file ("ignored by .gitignore") -> commit spec files with `git add -f` after the gate clears
(a detached setsid script that waits for MERGING.json then force-adds works; /tmp/sw1637/commit_all.sh). LANDED
18:18Z: 16.37 cf12253, 16.38 89cb6de, 16.39 e161cea. tasks/ clean.
NEXT (mi_perfil 4-6): 16.40 fun_sim wiring (deps 16.38, 16.39: build_context -> sixth_rung when cfg.dials_journal;
per cycle pickup(read_lines(journal), acct run record sha); at a decision instant changed -> _end_run 'dials_changed'
+ _new_run + write run-<n>/dials.json; Account gains dials sha LAST; status.json 'mi_perfil' block = status_block;
fun_sim 839 lines -> keep < 950), 16.41 request service write path (deploy/server/requests/replay_requests.py POST
/app/api/mi-perfil, APPROVER_EMAILS only, appends fun_dials.journal_line to /data/mi-perfil.jsonl; home mirror pulls
it like whatif-registrations), 16.42 exporter fields + UI dials on Perfiles (juego). Still unasked: family-1 grammar
grid. Next free ids: 3.148, 4.20, 9.12, 11.50, 12.20, 14.23, 15.33, 16.40.

2026-10-27 (spec writer, 19:2x-20:xx UTC refill; runnable 16.36-16.39/3.147; ops 0): mi_perfil 4-6 written. 16.40 (78d6d73, review
OK, 3 findings applied) = fun_sim wiring: Account gains LAST fields dials (RunRecord) + profile; record run-<n>/dials.json (ONE line)
written with the run's FIRST mark (run 1 at the first poll's now, _new_run at t) via `out`; at a decision instant (due late/decide)
a changed pickup -> _end_run(now, 'dials_changed') + _new_run(now, pick) IN THE SAME POLL (*reading: like run 1 starting at its
first poll; an ENDED run restarts at t as today); journal read once per poll in cycle (OSError -> root error 'dials:<Type>', block
None); root status gains key 'mi_perfil' (status_block), 'fun-status/1' name kept. MEASURED (proto /tmp/p1640, scratch src copy +
`ln -s config`; run with PYTHONPATH=/tmp/p1640/src, Fun helper subclass): DEFAULT dials enter 13,000 units == medio; top dials
(0.2/10/500) 130,000; K3 at 0.02 ends run 1 at T+70_000; test list 8 s; fun_sim 948 lines on the proto (cap < 1000). 16.41 (request
service POST /app/api/mi-perfil, deps [16.37]; proto /tmp/p1641 replay_requests.py + harness.py = socket-free Handler driving via
Handler.__new__ + BytesIO) - stdlib dials_sha256 reproduction == fun_dials (asdict form: loss {id: {enabled, threshold|None}},
floats coerced) verified on 4 dial sets; lines 2+ byte-identical to journal_line; the PROTO's changed_fields(None, d) is unsorted
while 16.37's spec says sorted -> 16.41 test compares line 0's 'changed' as a SET. 16.42 (deps [16.38, 16.41]) = static deploy
wiring: compose.fun.yml `./requests/mi-perfil:/journal:ro` (never ./requests - private/ asks/), fun.json dials_journal
/journal/mi-perfil.jsonl, both redeploy scripts `install -d -o 65534` the dir (Docker would create a root-owned mount source).
LEFT for mi_perfil: exporter fields (ui/scripts/export_fun_profiles.py reads status['mi_perfil']) + UI dials on Perfiles (juego)
= operator/UI work; futures extensions (crypto perps, CME) = separate later decisions. Next free ids: 3.148, 4.20, 9.12, 11.50,
12.20, 14.23, 15.33, 16.43.
STATUS 19:5xZ: 16.41 (review OK round 3, hash f649ad67 + 3 lows applied) and 16.42 (review OK round 2, 55b922ec + lows
applied) holds lifted, copies in /tmp/sw1640/; a detached /tmp/sw1640/commit_all.sh (log commit_all.log) waits for the
16.36 merge gate (MERGING.json since 19:40Z) then `git add -f` + commits both. NEXT WRITER: check `git log --oneline -3`
and `ls tasks/TASK-16.41.yaml tasks/TASK-16.42.yaml` + commit_all.log; if uncommitted, run the script again.
UPDATE 20:25Z: 16.36 gate landed 7700f88 but a 16.37 gate started 20:21Z before the script could commit; relaunched the script (pid 2289320, `setsid nohup ... < /dev/null &` in a subshell - the first launch died with the session). Verify 16.41/16.42 landed (git log) before anything else.

2026-10-27 (spec writer, 22:4x-23:1x UTC refill; runnable 16.39-16.42/3.147; 16.41/16.42 had landed; ops 0): fondeo precision
item 2 (RESOLVED 2026-10-26) split in three. 16.43 fun_ftmo_costs (review OK 47e15143, 2 lows applied: fsum over rows sorted
by hour; caps 350/420) = pure document from the cTrader recorder files (hourly lines -> one cell per (pair, UTC hour): median
of hourly medians / tick-weighted mean; symbols doc -> commission = preciseTradingCommissionRate / 1e9 per 100k per side,
min = preciseMinCommission / 1e8, swaps RAW; MIN_TRADING_DAYS 5 Mon-Fri UTC dates; canonical_hash seal; profile() ->
broker_costs.Profile kind 'measured' raw {floors_pips {pair: [24]}, commission {pair}, min_commission {pair}, slippage,
stop_extra, financing none_v1, source_sha256}). 16.44 fun_book (review OK 53408845, 2 lows applied) = mark(...,
broker_profile=None) LAST keyword; 'measured' branch = floor kind per leg at the leg quote's UTC hour + two sides of
max(min, rate x units/100k); override appended to the loaded Profiles so _check_slippage still covers brokers.yaml; MEASURED
on proto /tmp/p1644 (scratch src + `ln -s config`): 20k units floor 0.6 over 0.2 pip -> (1.2, 0, 0.8, 0); straddle base
T+58m30s -> 0.4 + 0.8; all-0.6 measured == EXNESS_PRO bit for bit; USDJPY 0.5079365; fun_book 597 lines (cap 650). LEFT: 2c
= fun_sim wiring (document file -> profile() -> mark(broker_profile), status says the cost profile) - fun_sim will be ~948
lines after 16.40, so 2c needs a helper split first (do NOT touch fun_sim while 16.40 is unbuilt). FTMO recorder files are
NOT mirrored home yet (only ~/.cache/fxplat/brokers/ctrader = IC Markets; 7 days, no holes) - operator/2c. Real IC data read
only for a sanity run. Phone asks sent 23:0xZ: decision:fondeo-floor-equality (re-ask, 720 min) and decision:family1-grammar
(a 21 cond / b 58 cond; z table from bench_hz.rank1_z(scan.BY_Q=0.10, m): 2532 -> 4.431, 4548 -> 4.570, 8100 -> 4.702).
GOTCHA: `pkill -f commit_when_clear.sh` kills the calling Bash too (exit 144) - use `pkill -f "commit_when_clea[r]"`. Commit
script /tmp/sw1643/commit_when_clear.sh TASK-16.43 TASK-16.44 waits for the 16.39 gate (MERGING since 22:37Z). Next free
ids: 3.148, 4.20, 9.12, 11.50, 12.20, 14.23, 15.33, 16.45.

2026-10-30 (spec writer, 16:0x UTC refill; runnable 16.42/16.43/16.44/3.147; pipeline was under operator STOP 10-28 00:11Z ->
10-30 ~15:58Z while the S2 synthetic bench ran; `auto` restarted 15:58Z; nothing merged since 10-27): Binance testnet hardening
(RESOLVED 2026-10-26) pure halves, all depends_on []: 16.45 binance_trader.shadow (sim 'fill' rows + closes-SIMULATED rows ->
Signals; cid 'SHD-<event id minus SIM-CRYPTO->-<E|X><attempt>' 28 chars; pair -> rows filled/missing/failed/orphan; summary
nearest-rank p90), 16.46 binance_trader.brackets (OCO = LIMIT_MAKER target + STOP_LOSS_LIMIT stop; prices snapped to the tick
ONLY toward the entry (LONG stop ceil, target floor), qty never rounded; stop_limit_ticks REQUIRED; codes stop_not_protective /
target_not_beyond / stop_limit_nonpositive then limit:<code> / stop:<code>; oco_params with Nautilus 1.231
BinanceSpotOrderOcoHttp.PostParameters names - its exec client does NOT implement OCO, wiring calls the HTTP endpoint), 16.47
binance_trader.reconcile (ledger last-record-wins; may_submit once-only ids; CODES 5 blocking + stop_without_position /
venue_order_foreign notes; covered within one dust_qty counts as covered -> a balance exactly at dust is a position with no
finding). Proto + measured numbers: scratchpad bt/ (shadow.py, brackets.py, reconcile.py, check.py). Remaining items: 1b/2b/5b
wiring in strategies.py (needs the ledger file + REST OCO submit), 4 drills (network), 6 daily regression line (pure summariser
of <data>/smoke/*.json is spec-able). Phone asks sent 16:1xZ: decision:feature-set-v2-count (rec a) and decision:positioning-
asof-ns (rec a); family1-grammar + fondeo-floor-equality EXPIRED unanswered 10-28 (don't re-ask again without a reason).
LANDED 16:2xZ: 16.45 1b4faba, 16.46 4df8f60, 16.47 47ae3bb (each review OK round 2, lows applied post-OK). MAIN LINT RED:
`ruff check src tests` fails on main deeeda9 (operator 45323e4: synthetic/plant.py E501 + B905, tests/synthetic/test_plant.py
E501) -> every spec whose lint step is the full `ruff check src tests` (16.42 / 16.43 / 16.44 / 3.147) fails on a correct build;
the three new specs lint owned files only; phone ask ops:main-lint-red sent 16:16Z (a = operator fixes main, b = writer narrows
the four lint steps). Next free ids: 3.148, 4.20, 9.12, 11.50, 12.20, 14.23, 15.33, 16.48.

2026-10-31 (spec writer, 20:17Z refill; see [[binance-item6-wiring-refill]]): item 6 wiring halves 16.51 (health lines,
deps 16.48) / 16.52 (export_brokers regression block, deps 16.48) / 16.53 (docker1 regression-daily.sh + root systemd
timer, deps []). 16.49 still uncommitted behind the 16.47 gate (20:17Z -> 21:3xZ+). Detached waiter
scratchpad 5fa440d2.../sw/commit_when_clear.sh (log commit_a.log) commits 16.49 + 16.51 + 16.52 when MERGING.json
clears; 16.53 gets its own run after review OK. Deps-blocked specs show BLOCKED in `tasks` (not review-blocked).
Next free ids: 3.148, 4.20, 9.12, 11.50, 12.20, 14.23, 15.33, 16.54.
