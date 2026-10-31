---
name: binance-item6-wiring-refill
description: "2026-10-31 20:17Z refill: Binance item 6 wiring split in three (16.51 health lines, 16.52 export_brokers regression block, 16.53 docker1 daily timer script + units); fondeo chain has NO fondeo rung yet (fun_profiles / fun_sim / YAML know nothing of fondeo) - the FTMO numbers ARE grounded in the operator's 2026-10-25 report artifact; 16.49 commit waiter"
metadata:
  node_type: memory
  type: project
  originSessionId: 5fa440d2-e61b-4c5b-b254-2ecc2a7e0466
  modified: 2026-10-31T20:40:00.638Z
---

2026-10-31 (spec writer, 20:17Z refill; runnable 16.47 (merge gate from 20:17Z, still MERGING at 21:1xZ) / 16.48
(BUILDING) / 16.49 / 16.50 / 3.147; main 81ad0d7, lint green; ops 0 cases; the four phone asks of 10-27/10-30 all
EXPIRED as 'wait'): no drafts, no new RESOLVED. 16.49 was still UNCOMMITTED (review OK, hold lifted) with the
previous writer's waiter alive (pid 3193441, scratchpad 54123a92.../sw/commit_1649.sh) waiting on the 16.47 gate -
verify with `git log --oneline -5`; the backup sw/TASK-16.49.yaml == tasks/TASK-16.49.yaml.

Wrote the three WIRING halves of RESOLVED 2026-10-26 item 6 (prototypes in scratchpad 5fa440d2.../p1651 p1652
p1653, backups in sw/):
- 16.51 (deps 16.48) fxplat-binance-health: regression_problems(root, now, repo=REPO) loads
  deploy/docker1/binance-trader/binance_trader/regression.py BY FILE PATH (spec_from_file_location + sys.modules
  registration - dataclasses with future annotations raise AttributeError without it), FXPLAT_REPO default
  ~/Dukascopy; cryptoregmodule line when the judge is missing. The script has 17 pre-existing E501 -> lint with
  --extend-ignore E501; test_crypto_sim.py pins sim_problems. Measured lines in the spec (NOW 1793426400.0).
- 16.52 (deps 16.48) export_brokers: crypto_regression(smoke_dir, now) = summary(reg) + 'problems'; build_crypto
  LAST kw regression=None -> LAST key 'regression' BESIDE trader (test_ui_dash_exporters pins p['trader'] == 6 keys
  EXACTLY); import via sys.path insert of deploy/docker1/binance-trader like export_crypto_market.py; exporter has
  44 E501 + 1 B023 on main -> lint with --extend-ignore E501,B023. UI row (BrokersView CryptoPayload) = UI-C work.
- 16.53 (deps []) regression-daily.sh + fxplat-crypto-regression.service/.timer under deploy/docker1/binance-trader/
  (NOT in the image: redeploy copies only Dockerfile + binance_trader/*.py): STOP -> exit 3 before any docker call;
  WAS_RUNNING via `compose ps -q --status running`; trap EXIT restarts only if it was running; smoke then drill via
  `timeout --kill-after=30 600 docker compose run --rm --no-deps -T -e BINANCE_MODE=testnet binance-trader <cmd>`
  with crc=${PIPESTATUS[0]} under set +e (a `|| true` after the pipeline RESETS PIPESTATUS - caught in the proto);
  tests drive it with a fake `docker` on PATH (call log). Timer 06:00 UTC Persistent RandomizedDelaySec 300.

FONDEO FINDING: there is NO fondeo rung anywhere (fun_profiles.py / config/fun_profiles.yaml = prudente, medio,
arriesgado, loco, influencer; fun_sim has no challenge code; fun_challenge / fun_daily / fun_minute / fun_passprob /
fun_ftmo_costs are pure and unwired). "Fondeo 2 config + profile wiring" and "fondeo 3 fun_sim phase chain" were never
written because FTMO grounding needed web. The operator's own report https://claude.ai/artifact/3h4CdKki4oQNoJ22FaQsfW
(fetched FTMO pages 2026-10-25, cited in decisions-pending RESOLVED 2026-10-25 'FTMO 2-Step SWING') HAS the numbers:
2-Step targets 10 % then 5 %, max daily loss 5 % of initial below the balance at 00:00 CE(S)T tested on EQUITY,
max loss 10 % STATIC, minimum trading days 4 per phase, Swing leverage 1:30, no time limit, profit split 80-90 %;
FTMO FX commission NOT confirmed (~$3/lot, per side unclear) -> use the measured document (16.43) / broker profile.
A next writer can spec fondeo 2 (fun_profiles optional `challenge:` block mapping to fun_challenge.ChallengeRules
(version, phase1/phase2_target_frac, max_daily_loss_frac, max_loss_frac, min_trading_days, day_tz, daily_reference
'balance') + EntryRules (close_tz, close_weekday, close_minute, no_entry_before_close_ms, max_usd_same_direction) and
the YAML rung) citing that report; WATCH: profile_sha256 = canonical_json(asdict(p)) -> a new FunProfile field changes
EVERY rung's sha (hash it only when set, like 14.20); test_fun_profiles IDS tuple pins the 5 ids and
len(shas) == len(IDS); fun_sim creates an account per YAML rung at the next redeploy. Then fondeo 3 (fun_sim, after
16.49 lands) and 2c cost wiring.

Next free ids: 3.148, 4.20, 9.12, 11.50, 12.20, 14.23, 15.33, 16.54.

STATUS 21:5xZ: all three review OK (16.51 round 1 + 2 lows applied; 16.52 round 1 + 1 low; 16.53 BLOCK -> OK round
2 + 2 lows), holds lifted, validated. NOT YET COMMITTED: the 16.47 merge gate (MERGING.json since 20:17Z, pid 3107552,
alive at 22:3x local = 2 h 15 min) blocks every commit. Two detached waiters (sw/commit_when_clear.sh; logs
commit_a.log for 16.49+16.51+16.52, commit_b.log for 16.53; give up after 2 h) force-add + commit when the gate clears.
NEXT WRITER FIRST: `git log --oneline -6 -- tasks/`; if 16.49 / 16.51-16.53 are missing, rerun
`bash <sw>/commit_when_clear.sh TASK-16.49 TASK-16.51 TASK-16.52 TASK-16.53` (backups in sw/ and 54123a92.../sw/).

**Why:** the next writer must not re-specify item 6 wiring, must know the fondeo chain is blocked on a missing rung
(not on web any more), and must check 16.49/16.51-16.53 landed.

**How to apply:** `git log --oneline -8 -- tasks/` first; if 16.49 or 16.51-16.53 are missing, see the sw/ backups and
review logs (scratchpad 5fa440d2.../sw/review-16.5x.log, logs/spec-review-TASK-16.5x-*.md). Related: [[fun-sim-split-and-binance-regression]], [[real-run-task-ids]].
