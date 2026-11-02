---
name: c10-runner-refill-2026-11-02
description: "2026-11-02 16:09Z refill: 3.149 fxplat.pipeline.c10_runner (prompt §10.13 items 3/5/8/10 over a WFInput: shuffled_input / canary_input / run_c10 with an injected runner; synthetic bench T5 'no C10 runner' P11) / 3.150 run_criteria C10 passthrough (RunCriteria.c10 trailing field, with_c10, results_order, 'C10' after 'C8'); both deps []; left = research_run wiring (externals + B3 interval + lock_ms are the operator's call) and the bench T5 world; next free 3.151 / 9.17 / 11.64 / 15.43 / 16.82"
metadata:
  type: project
  originSessionId: refill-20261102-160924
  modified: 2026-11-02T16:36:35.790Z
---

2026-11-02 16:09Z refill (runnable 9.15 / 9.16, both in opus escalation; low water 6). No drafts, no new RESOLVED
decisions; six phone asks pending at 'wait' (positioning-asof-fix, family3-grammar, c6-sharpe-variance,
family4-grammar, fsv2-counting, TASK-4.4 tolerances); `agent-ci ops` 0 cases; UI-A / UI-E Python rows exhausted
(UI views all exist under ui/src/views, so UI-C* TypeScript rows are the operator's); PHASE3 §3 all passed.
NEW SOURCE found: agent-ci docs/research/2026-10-23-synthetic-known-answer-bench.md §13 item 2 / P11 "C10 has
no runner" (leakage_controls gives the functions; nothing injects the canary or shuffles labels inside the
walk-forward; trap T5 blocked) and verdict.REQUIRED has C10 at both stages while run_results never emits it.
- 3.149 (deps []): fxplat.pipeline.c10_runner beside walkforward.py (987 lines, untouched). RUN_ITEMS =
  shuffled_labels / canary / execution / date_lock; EXTERNAL_ITEMS = the other six of C10_ITEMS, passed in by
  the caller as True / False / None. shuffled_input permutes y AND outcome_R with one block_shuffle draw on
  np.arange(n) (rng('c10_shuffled_labels', seed)); canary_input = add_canary(X, outcome_R); gross_ev = mean
  outcome_R over taken_mask rows (taken_mask is DEFINED in fxplat.validation.baselines, trade_criteria only
  re-imports it - review finding); run_c10(inp, result, *, cal, oos_start_ms, oos_end_ms, null_interval,
  external, global_seed, lock_ms, runner=run_walk_forward, **wf_kwargs) calls the runner twice (shuffled, canary)
  - the injected runner makes every fail path testable without a walk-forward. Measured on test_walkforward's
  _synthetic(20261003) (75,120 rows, OOS 2014-01..04): base 1285 trades EV 767/1285; shuffled n 767 EV -13/767;
  canary n 1530 EV exactly 1.0 (also 1.0 on seeds 1-4); run_c10 13-17 s. Prototype /tmp/p3149 (c10_runner.py,
  scen.py = planted seeds, hand.py = the 24-row hand scenario). Review OK (2 low applied).
- 3.150 (deps []): run_criteria gains RunCriteria.c10: C10 | None = None (trailing; all constructions are
  keyword), with_c10(rc, c10) (refuses non-C10, refuses a second attach), results_order(rc) over the four
  (c5, c10) combos, RESULTS_WITH_C10 / RESULTS_WITH_C5_C10 ('C10' after 'C8'); run_results unchanged when c10 is
  None (test_run_criteria:295, test_run_criteria_b5:337/459, test_research_run_c5:125 pins). publish.verdict
  run_measures picks its own ids and verdict_payload tolerates a row without a measure (verified by calling it).
  Hand numbers from tests/publish/test_publish_verdict.py make_rc(): C10 row summary 'failed=();
  not_applicable=(); missing=()' etc. Actuarial lives in fxplat.validation.actuarial (not trade_criteria).
- COMMITTED 17:12Z: 3.149 9a70349 / 3.150 83f9685 (via the committer). Commit path: a 9.16 gate (MERGING.json 16:29Z) was running -> /tmp/p3149/commit_when_clear.sh <ids> re-copies
  /tmp/p3149/TASK-<id>.final.yaml and commits with `git add -f` once the gate clears (the gate had staged
  settings.py / test_settings.py in the main index - not ours).
- Ask sent 16:36Z: decision:c10-externals (a truncation + fit_dates True, rest None / b all six None / wait),
  section "2026-11-02 — NEEDS DECISION C10 in DEV runs" appended to state/decisions-pending.md; the B3 interval
  reading there = [2 x null_mean - null_p95, null_p95].
- LEFT: (1) research_run wiring once the ask is answered: run_c10 after run_criteria (null_interval from rc.b3,
  the externals per the answer, lock_ms = load_periods().locked_holdout start = 1640995200000, with_c10 ->
  verdict); research_run.py is 919 lines. The two gates in flight at 16:36Z (9.16 merge + 9.15 escalation suite
  on the flock) delayed the commits - check `git log -- tasks/TASK-3.149.yaml tasks/TASK-3.150.yaml` first. (2) The bench's T5 world (null world +
  canary) in fxplat.synthetic once 3.149 merges. (3) The TASK-4.4 file-reading replay driver still waits for the
  tolerance ask (measure mode is possible: replay_check with infinite tolerances -> measure_differences).

**Why:** the next writer must not re-derive the C10 runner split, must know the walk-forward numbers and the
hand scenarios are in /tmp/p3149, and that the research_run wiring needs operator input on the external items.

**How to apply:** `git log --oneline -3 -- tasks/TASK-3.149.yaml tasks/TASK-3.150.yaml`; a missing one is
restored from /tmp/p3149/TASK-<id>.final.yaml and committed with `git add -f`. Related:
[[control-service-api-settings-refill-2026-11-02]], [[merge-gate-wipes-uncommitted-task-edits]],
[[walkforward-min-train-years-fixture]], [[real-run-task-ids]].
