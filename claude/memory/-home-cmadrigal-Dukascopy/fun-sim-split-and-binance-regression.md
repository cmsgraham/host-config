---
name: fun-sim-split-and-binance-regression
description: "2026-10-31 refill: 16.48 binance_trader.regression (item 6 pure half), 16.49 fun_sim -> fun_sim_helpers verbatim split (prototype numbers), 16.50 fun_guard cost_document key; what is left for fondeo 2c and Binance wiring; family 3 USD index already = prim_state dollar_trend"
metadata:
  node_type: memory
  type: project
  originSessionId: 54123a92-56d1-44d3-a70b-b3b3558a51be
  modified: 2026-10-31T18:52:06.490Z
---

2026-10-31 (spec writer, 18:2x UTC refill; runnable 16.43 (VALIDATING) / 16.46 / 16.47 / 3.147; pipeline restarted
18:25Z after the operator STOP; ops: 16.43 strong_direct + np, no triage agent on specs; main ec6a66d, lint green):
no drafts, no new RESOLVED since 10-27, phone asks of 10-30 (feature-set-v2-count, positioning-asof-ns) unanswered.
Found: trader-concepts family 3 "USD index from the 7 majors" ALREADY EXISTS as prim_state `dollar_trend`
(decay_study.dollar_trend_at); family 3 rest = rate differentials (source = operator), risk-on/off (~/fxdata-idx has
only tick dirs <SYMBOL>-<startyear>/ticks, no derive_bars output -> not loadable like prim_commodity), so family 3 is
not spec-able. Family 4 (11.45-11.49) and family 1 primitives done; family-1 grammar still waits the expired ask.
Wrote (ids 16.48 / 16.49 / 16.50; prototypes in scratchpad bt/regression.py + check_regression.py and p1649/):
- 16.48 binance_trader.regression: result files <kind>-<%Y%m%dT%H%M%SZ>.json (kind = type(self).__name__.lower():
  smokestrategy / stopdrill), ok = PASS and open_orders_left 0 and mode testnet; per-kind state PASS/FAIL/STALE/MISSING
  at now_ms (results with ran_at_ms <= now only), MAX_AGE_H 36, WINDOW_H 168 (exactly 168 h old = out),
  problems() -> fxplat-health `key|message` lines (cryptoreg<kind>, cryptoregskipped), summary(), status_line().
  Fixture stamps: 20261030T060000Z = 1793340000000, NOW_A 20261031T06 = 1793426400000, NOW_B 20261026T06 =
  1792994400000; usdt_delta -1.5e-06. Wiring half left: docker1 timer running smoke + drill daily, the call from
  fxplat-binance-health (deploy/docker1/binance-recorder/home/), export_brokers panel row.
- 16.49 fun_sim split: 24 defs (FunContext, Account, SimState, _Cand, _Instant, _json_rows, _trailing_losses, _dumps,
  _emit, _mark_line, _position_line, _opt_float, _close_line, _profile_sha, _decision_line, _utc, _env_reason,
  _book_reason, _size_reason, _next_cursor, _trim, _account_status, _loss, _read_feed) + _Lines + constants
  POSITION_SCHEMA / CLOSE_SCHEMA / DECISION_SCHEMA / _EPOCH / TAPE_KEEP_MS moved verbatim; fun_sim imports back 24
  names (23 defs + _Lines; not the constants, not _profile_sha) in ONE statement WITHOUT noqa (all used) - round-1
  review BLOCKED on my "23" miscount (reviewer prototyped it: _Lines is needed in 9 annotations); measured fun_sim 702 /
  helpers 293 lines, 94 + 128 fun tests green on PYTHONPATH=scratch src. Tests only touch fun_sim.{main,
  build_context, load_state, cycle, TAPE, CURSOR, STATUS, RUNS, POSITIONS, DECISIONS, CLOSES, MARKS, DIALS}; only
  patch = fun_sim.cycle. test_fun_sim_dials.py imports `from test_fun_sim import Fun` (tests/execution works as a
  package here) - include it in fun_sim acceptance lists.
- 16.50 fun_guard `cost_document` LAST FunConfig field (after dials_journal), sealed like dials_journal; owns
  test_fun_guard.py because it pins _fields[-1] == 'dials_journal' (re-pinned to cost_document).
NEXT for fondeo 2c (after 16.43 + 16.49 + 16.50 merge): fun_sim wiring = build_context reads cfg.cost_document
(json -> fun_ftmo_costs.parse -> profile(doc, MAJORS, name=..., slippage/stop_extra from the fondeo profile) ->
FunContext gains a LAST field), fun_sim._mark passes broker_profile= for the fondeo rung only, status says which
cost profile; compose.fun.yml / redeploy-fun.sh mount + key = deploy task (16.42 pattern). Binance wiring 1b/2b/5b
still needs the ledger file + REST OCO submit in strategies.py (after 16.46/16.47 merge).
Next free ids: 3.148, 4.20, 9.12, 11.50, 12.20, 14.23, 15.33, 16.51.

**Why:** the next writer must not re-specify family 3's USD index, must know the fun_sim name constraints, and must
pick up fondeo 2c / Binance wiring with these ids.

STATUS 18:5xZ: 16.48 f6086e3 and 16.50 0c6e243 committed; 16.49 review OK (round 2) and hold lifted, but the
16.43 merge gate (MERGING.json 18:50:59Z) blocked its commit -> a detached waiter
scratchpad/sw/commit_1649.sh (pid 3193441, log commit_1649.log, backup sw/TASK-16.49.yaml) force-adds + commits
it when the gate clears. NEXT WRITER: `git log --oneline -5` - if 16.49 is not there, run that script again.

**How to apply:** check `git log --oneline -5` for 16.48-16.50 commits first; if absent, look for
scratchpad/sw/*.yaml backups of this session (path in [[real-run-task-ids]]) and the review logs
logs/spec-review-TASK-16.4[89]-*.md / -16.50-*.md.
