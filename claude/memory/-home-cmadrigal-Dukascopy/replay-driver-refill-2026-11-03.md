---
name: replay-driver-refill-2026-11-03
description: "Spec-writer refill 2026-11-03 ~18Z — TASK-4.45 replay_run / 4.46 replay_report / 4.47 replay_cli close the TASK-4.4 stub's missing file-reading driver (CHARTER §12.9 replay cross-check); measured fixture numbers (risk US$50), design (month windows over a TickSource), what sources are exhausted, traps"
metadata:
  node_type: memory
  type: project
  originSessionId: 5408b0f6-4d04-47b4-ae2f-479428c92b9c
  modified: 2026-11-03T18:08:49.502Z
---

Refill 2026-11-03 17:42Z (runnable 5 < low water 6; no drafts, ops 0 cases, no new RESOLVED decision; the only
pending phone ask is decision:second-ruler-broker sent 13:51Z). Every source above the roadmap stubs is exhausted:
second-ruler sites all specified (4.31-4.44, 9.19), UI-C views all built by the operator (ui/src/views), R rows,
PHASE3 map, UI-A done; family 1/3/4 grammars, C10 externals, replay tolerances, fsv2 counting, floor equality,
positioning asof are expired/unanswered asks; mi_perfil futures item 1 needs web (Binance margin tiers / futures
fees - 16.67 fun_funding already says so). So the source was the TASK-4.4 roadmap stub (brief item 1: stubs are ours):
its last unwritten piece = the file-reading driver. Three tasks, 4.4 stub edited to point at them (keeps its hold):

- TASK-4.45 fxplat.pipeline.replay_run (deps []): read_records(<run>/walkforward/decisions.jsonl), read_pairs
  (symbol_stage.read_symbol_dataset per <run>/<SYM>), windowed_check = replay_check's five callees but
  replay_trades fed per UTC month of ts_submit over TickSource.window(min ts_submit, max t_limit + WINDOW_PAD_MS)
  -> ReplayRun(check, windows[symbol, year, month, n_trades, t0_ms, t1_ms, n_ticks]). MEASURED (proto
  /tmp/proto445: fixture.py, p1-p4.py): windowed == whole-array replay_check frame for frame; the old
  "PairData wants whole tick arrays" blocker is solved this way (one pair-year ~30 M quotes).
- TASK-4.46 fxplat.pipeline.replay_report (deps 4.45): replay_summary plain JSON, Spanish Markdown with estado
  APROBADO / FALLA_TOLERANCIA / MEDICION, replay_report_json, write_replay_report write-once; TASK-4.13's four
  replay differences as registered Spanish sentences.
- TASK-4.47 fxplat.pipeline.replay_cli (deps 4.45, 4.46): manifest (refuses cost_profile, cost_model_sha256 and
  policy_rates_sha256 mismatches), StoreTicks(sym, midnight(start), midnight(end)+1d) = symbol_stage's range,
  risk = config capital x risk_pct, require_fixed or --measure (sentinel 1e9), exit 4 on breach.

KEY FACTS: config risk is now 5000 x 0.01 = US$50 (test_replay_check's 25.0 is stale) -> the fixture labels at
50.0; fixture moved into DEV (2013-09-22 21:00 .. 2013-10-04 21:00, 24 events/pair, 16 enter each, records via
decision_log.decision_record + to_json_line). Numbers (seed 0, LOOSE 1e9): n_matched 32, d_net_usd -10.692741205,
d_sharpe -0.048836882, label_net -1201.483302960039, replay_net -1212.176044165011; EURUSD exits stop 14/target 2,
USDJPY stop 12/target 3/time 1 (usdjpy-e23 = time, latest limit); measure exit_pips 0.8/0.769, odd_lot 0.000567,
trade_R 0.026505; windows EURUSD 2013-09 14 tr 98,639 ticks / 2013-10 2 tr 29,879 / USDJPY 2013-09 16 tr 96,119;
exit_pips 0.5 -> USDJPY 3 breaches; trade_R 0.02 -> 3; cut source -> one 'open' row, open_ids ['usdjpy-e23'].
Dataset dirs written with symbol_stage._write_dataset + os.replace round-trip exactly; replay_trades accepts
empty arrays with 0 trades; run_type must be one of the registered 7 ('exploratory'); verdict.fmt = decimal comma
4 decimals, no thousands separator. tests/pipeline is a package (relative imports between test files allowed).

LANDED 18:17Z (gate of 4.41 cleared; detached /tmp/proto445/commit_when_clear.sh): 4.45 a48b084, 4.46 ef63169,
4.47 0f4a0f7, 4.4 stub edit 154973b. Reviews (gemma4:31b reviewer since 46e9ddf - sharp, 0 false blocks): 4.46 OK
first round; 4.45 / 4.47 BLOCK once, OK after fixes; --accept-amended used on all three. TRAPS it caught: (1) a
cross-pair duplicate-id refusal fires only AFTER every pair is replayed (replay_check order) - never list it under
'refusals with nothing read'; (2) pad_ms 0 turns the latest-limit 'time' trade of a month window into 'open' ->
FALLA_TOLERANCIA / exit 4, not exit 0; (3) a pinned _utc_now + module-scoped reports dir makes every default-stem
run collide with the write-once rule - each test its own tmp_path/'reports'; (4) rerun_cli prints the traceback
FIRST then 'prog: Type: msg' - say explicitly when a new CLI's stderr order differs; (5) argparse usage errors are
SystemExit(2) out of main, not a return value; (6) pandas .dt.year/.month are int32 - cast when a spec pins int64.
At 18:20Z state/STOP existed ('2026-11-03T18:16:24+00:00 requested by the agent-ci watchdog'), no active run, 4.41 back to ELIGIBLE (its 17:57Z gate did not land) - the watchdog's stop, not the writer's business.

**Why:** the next writer must not re-derive that the stubs are the only source left nor re-measure the fixture.
**How to apply:** check `agent-ci status` for 4.45-4.47; after they merge the 5.1 / 6.1 / 6.2 stubs are next
(Phase 5 freeze CLI needs the per-category pattern choice = operator decision; 6.1 needs the holdout partition
guard opened = operator). See [[second-ruler-rerun-brokers-f2-pnl-refill-2026-11-03]], [[real-run-task-ids]].
