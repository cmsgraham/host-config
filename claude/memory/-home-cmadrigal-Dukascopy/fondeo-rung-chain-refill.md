---
name: fondeo-rung-chain-refill
description: "2026-11-01 00:2xZ refill: fondeo 2a = 16.54 fun_profiles optional challenge block (review OK, waiter commits after the 16.51 gate); fondeo 3 = 16.55 fun_sim phase-chain wiring left as a 'draft, under review' with its review running detached; fondeo 2b = the shipped fondeo_ftmo rung + re-pins NOT written (next id 16.56); FTMO numbers + the measured fun_sim scenario numbers are inside the two specs"
metadata:
  node_type: memory
  type: project
  originSessionId: 9f493da5-2a35-47d0-9725-9b2d34630602
  modified: 2026-11-01T00:39:30.621Z
---

2026-11-01 (spec writer, 00:22Z refill; runnable 15.34 / 16.51 (merge gate from 00:22Z) / 16.52 / 16.53 / 3.147; main
df5be54; ops 0 cases; 16.49 / 16.51-16.53 had all landed; no drafts, no new RESOLVED since 10-27):
- The FTMO grounding is NO LONGER blocked on web: the Artifact tool READS the operator's report
  https://claude.ai/artifact/3h4CdKki4oQNoJ22FaQsfW (FTMO pages fetched 2026-10-25) - 2-Step Swing: targets 10 % then
  5 %, daily loss 5 % of initial below the 00:00 CE(S)T balance tested on equity, max loss 10 % static, 4 trading days
  per phase, no time limit, leverage 1:30, split 80-90 %; FX commission unconfirmed (~$3/lot) -> broker profile / 16.43.
- tests/execution/test_fun_sim.py and test_fun_sim_dials.py load the SHIPPED config/fun_profiles.yaml and pin the five
  ids (`ids(fun) == [*PROFILE_IDS, 'mi_perfil']`, `== PROFILE_IDS`), test_fun_profiles pins IDS / capital 1000 on every
  rung / len(shas) == 5 -> the shipped rung must be its own task owning those pins (fondeo 2b, next free 16.56).
- 16.54 (fondeo 2a, deps []): fun_profiles optional `challenge:` block -> FunProfile.challenge: ChallengeSpec(rules:
  fun_challenge.ChallengeRules, entry: EntryRules) LAST field default None; _check_keys gains optional=; validation
  delegated to check_rules / check_entry_rules (ValueError -> FunProfileError '{where}: challenge[.entry]: msg');
  hash_document(p) drops 'challenge' when None else {'rules': ._asdict(), 'entry': ._asdict()} (canonical_json turns a
  NamedTuple into a LIST - measured) -> the five shipped shas stay (9a459bea / 889f0206 / 46796a08 / 58d8e8e2 /
  77992e55, full values in the spec). Proto scratchpad 9f493da5.../p1654/fp_proto.py (365 lines, all refusals listed
  in the spec verified). Review OK first round (2 lows applied), hold lifted, ELIGIBLE; waiter
  scratchpad/sw/commit_when_clear.sh (log sw/commit_1654.log, backup sw/TASK-16.54.yaml) commits after the 16.51 gate.
- 16.55 (fondeo 3, deps [16.54]) HELD "draft, under review": fun_sim + fun_sim_helpers (Account LAST fields closes /
  phase / challenge) + new tests/execution/test_fun_sim_fondeo.py; challenge_state every poll after ruin + K3, run ends
  with the status as end_reason, challenge_phase(prev end reason) phase1 -> phase2 -> funded (any failure -> phase1),
  _challenge_reason 'challenge:gap_window' / 'challenge:usd_same_direction' after env + book reasons, root status
  'fondeo' block. MEASURED (scratchpad p1655/test_m1655*.py run with PYTHONPATH=tests/execution, --noconftest): fondeo
  rung (10k, 1 %, lev 30) enters 65000 units risk 99.559248 notional 71819.8; fill mark T+70s 9988.2; the 2xATR stop
  fills AT ITS LEVEL on the 1.0930 gap (net -110.059265, mark 9889.940735) so FTMO's 5 % floor is unreachable in a test
  -> TEST fractions: daily 0.01 -> failed_daily at T+600_000 (to_daily -10.06); HAPPY_PATH win net 195.118465, marks
  10195.118465 -> phase1 target 0.019 (10190) passes at T+130_000, 0.02 stays active (4.88 short); Prague day start of
  C1 = 1791928800000; TEST entry rules {'UTC', 2, 840, 7_200_000, 2} put the Wednesday T+60s submit in the gap window.
  Review launched detached (sw/review-1655.log; logs/spec-review-TASK-16.55-*.md). NEXT WRITER: read the report, apply,
  re-verify the (d) 'funded' pre-seed case (empty run-3 dir -> _load_account run 3; unverified on a prototype) and the
  'marks(run 1) == 3 rows' claim in (c) (the run ends at the T+130_000 mark, so T+145_000 writes no run-1 mark - by code
  reading, not measured), lift the hold, commit with `git add -f` after the gate.
- NOT written: 16.56 fondeo 2b = the shipped rung fondeo_ftmo in config/fun_profiles.yaml (10000.0, risk_pct 0.01,
  max_open 4 / 2, max_open_risk_pct 0.03, every K off, leverage_cap 30.0, IB *reading until the measured FTMO document
  (2c) exists, challenge = the FTMO block version 'ftmo-2step-swing-2026-10-25', entry 17:00 New York Friday = 1020,
  7_200_000, cap 2, lesson_es) + re-pins in test_fun_profiles (IDS, capital, values), test_fun_sim_dials PROFILE_IDS
  (2 literals), maybe test_fun_sim PROFILE_IDS; deps [16.55] (the sim must know the rules before the rung goes live;
  redeploy-fun.sh creates the account at the next redeploy). Then 2c fun_sim cost wiring (cost_document -> profile() ->
  mark(broker_profile=) for the challenge rung) and fondeo 4 exporter fields.
Next free ids: 3.148, 4.20, 9.12, 11.50, 12.20, 14.23, 15.35, 16.56.

**Why:** the next writer must finish 16.55 from its review instead of re-deriving it, must not re-measure the scenario
numbers, and must know the shipped rung is a separate task because of the five-id pins.

**How to apply:** `git log --oneline -4 -- tasks/` first (16.54 landed?); `ls logs/spec-review-TASK-16.55-*`; backups in
scratchpad 9f493da5-2a35-47d0-9725-9b2d34630602/sw/. Related: [[binance-item6-wiring-refill]], [[real-run-task-ids]].
