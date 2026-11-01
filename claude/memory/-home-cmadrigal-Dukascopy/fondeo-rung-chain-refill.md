---
name: fondeo-rung-chain-refill
description: "Fondeo chain state (2026-11-01 04Z refill): 16.54 fun_profiles challenge block committed 80c8fb0 and building; 16.55 fun_sim phase-chain wiring committed bc9a9e9 (review OK after 1 BLOCK round; deps 16.54); 16.56 shipped rung fondeo_ftmo + six-rung re-pins drafted (deps 16.55, review launched 04:05Z); still unwritten: fondeo 2c fun_sim cost wiring, fondeo 4 exporter fields; measured scenario numbers live inside the specs"
metadata:
  node_type: memory
  type: project
  originSessionId: 1672ea80-bed5-4a35-91f3-5aba823063a2
  modified: 2026-11-01T03:56:53.623Z
---

2026-11-01 (two spec-writer refills, 00:22Z and 03:39Z; main 0fc6c94 at the second):
- FTMO grounding: the Artifact tool READS the operator's report https://claude.ai/artifact/3h4CdKki4oQNoJ22FaQsfW
  (2-Step Swing: +10 % then +5 %, daily 5 % of initial vs the 00:00 CE(S)T balance on equity, max 10 % static, 4 trading
  days per phase, no time limit, 1:30, smallest account US$10,000). FX commission unconfirmed -> 16.43 measured costs.
- 16.54 (fondeo 2a, deps []): FunProfile.challenge = ChallengeSpec(rules, entry) LAST field default None;
  hash_document drops 'challenge' when None -> the five shipped shas stay (9a459bea / 889f0206 / 46796a08 / 58d8e8e2 /
  77992e55). Committed 80c8fb0; building 2026-11-01 03:40Z.
- 16.55 (fondeo 3, deps [16.54]) committed bc9a9e9 04:04Z. First review BLOCKED on: (1) tests/execution/
  test_fun_sim_helpers.py (TASK-16.49, protected) pins Account's source sha, len(_fields) == 16, _fields[-4:] and
  fun_sim <= 760 lines -> the spec now OWNS that test file with EXACT re-pins (sha recompute command, 19 fields,
  [-7:], cap 820); (2) the poll that starts run n+1 evaluates nothing in _book_step (early return on acct.end) ->
  _new_run evaluates challenge_state once on the first mark (phase2 first mark -> active, target 10500); (3) a disabled
  K switch is `{enabled: false}` with no threshold key. Second review OK (3 lows applied: ended reloaded run shows
  'no_mark'; pre-seeded runs.jsonl rows need run/start_ms/end_ms/end_reason). Verified today: _load_account on a
  pre-seeded runs.jsonl + empty run-3 dir -> run 3, runs_ended 2, marks (); read_lines of a missing file is [].
- 16.56 (fondeo 2b, deps [16.55]) = the shipped rung fondeo_ftmo appended to config/fun_profiles.yaml (10000.0, risk
  0.01, atr 2.0, 4 / 2 / 0.03, every K {enabled: false}, lev 30.0, stop_out 1.0, ruin 25.0, IB *reading, lesson_es
  registered verbatim, challenge = FTMO block version 'ftmo-2step-swing-2026-10-25' + entry America/New_York 4 1020
  7200000 2) + re-pins in test_fun_profiles (IDS, capital 10000 for the rung, values, 16.54's five-sha test -> six, sha
  by formula), test_fun_sim (PROFILE_IDS, got gains fondeo_ftmo (65_000, 'ok', False), len 6), test_fun_sim_dials
  (PROFILE_IDS, 6 -> 7, 5 -> 6), test_fun_pickup (strict zip ladder[:5] -> [:6], len 7). MEASURED six-rung ladder on
  test_fun_sim's market: fondeo 65000 / risk 99.55924820387152 at C1; widened 6000; stale K4; HAPPY net 195.118465.
  COMPUTED sha with the 16.54 formula 058db423cb3248cdb51d5b17399f3901b419a355d0eae7fc09b09afc10b2c0ee (without the
  challenge df19bccf...). Review launched 04:05Z (/tmp/sw1656/review1.log); if HELD when you read this: read the
  report, apply, lift the hold, commit after the gate.
- NOT written: fondeo 2c = fun_sim cost wiring (FunConfig.cost_document from 16.50 -> fun_ftmo_costs document ->
  fun_book.mark(broker_profile=) of 16.44 for the challenge rung; the status says which cost profile it used); deps
  [16.55] (same module). Fondeo 4 = ui/scripts/export_fun_profiles.py gains the status 'fondeo' block per account
  (phase, distances, days traded) for the Perfiles panel, deps [16.55]; tests/publish/test_export_fun_profiles.py.
- Other refill sources checked and EMPTY 2026-11-01: Binance items 1-6 pure halves + 6b/6c written (exchange_rules.py
  exists); trader-concept families 3/4 primitives written (11.45-11.49, prim_commodity, prim_cross); fondeo precision
  items 1-3 written (16.35 fun_minute, 16.36 fun_passprob, 16.43/16.44); item 4 waits on the exact-floor decision;
  3.147 wiring waits on the v2 counting decision; UI-A10 part 2 (run events + P&L series exporter) is unwritten and
  runnable (deps 9.1, 3.60 passed) - the only deps-passed candidate found.
Next free ids: 3.148, 4.20, 9.12, 11.57, 12.20, 14.23, 15.42, 16.57.

**Why:** the next writer must not re-derive or re-measure the fondeo chain, must know why 16.55 owns a 16.49 test file,
and must know which refill sources are already exhausted.

**How to apply:** `git log --oneline -4 -- tasks/` first (16.56 landed?); `git status --short tasks/` (untracked
draft?); `ls -t logs/spec-review-TASK-16.56-*`. Related: [[binance-item6-wiring-refill]], [[real-run-task-ids]],
[[fun-sim-split-and-binance-regression]].
