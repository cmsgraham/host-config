---
name: judged-rekey-and-passprob-refill
description: "2026-11-01 15:39Z refill: 11.57 export_hallazgos cost bridge keyed on findings judged_profile, 15.42 bench_hz SCAN_FIELDS = mean_net + every mean_net_<P> prefix (test_rescore non-owned pins the old two names - prefix rule keeps it green), 16.60 fun_passprob_report I/O half (fixture numbers measured in /tmp/p1660); Binance wiring 1b/2b/5b and the fondeo deploy wiring still unwritten; next free 11.58 / 15.43 / 16.61"
metadata:
  node_type: memory
  type: project
  originSessionId: d13b5b5d-7273-45a5-870b-94a5da67f64e
  modified: 2026-11-01T15:59:44.817Z
---

2026-11-01 15:39Z refill (runnable 11.54 reviewing / 16.53 / 16.57 / 16.58 / 16.59; main 12e8195, lint green, ops 0
cases, no drafts, no new RESOLVED since 10-27, phone asks all expired). Wrote three specs from the TASK-11.53 "follow-up"
note and fondeo item 3:
- 11.57 (deps []): ui/scripts/export_hallazgos.py _cost_bridge iterates ("IB", *profiles) -> with the shipped judged
  IC_RAW the "IB" entry built from mean_net is OVERWRITTEN by mean_net_IB and the judged mean vanishes. Fix: judged =
  findings.get("judged_profile", "IB") (point-in-time, from the scan's own findings), bridge keys judged first then
  mean_net_<P> for P != judged (skip P == judged -> no duplicate), scan block LAST key judged_profile; SCHEMA stays
  'hallazgos/1'. The existing test fixture (no judged_profile, mean_net_D / _B) stays valid under the default.
- 15.42 (deps []): bench_hz SCAN_FIELDS hard-code mean_net_IC_RAW / mean_net_EXNESS_PRO; after 11.53 mean_net_IC_RAW is
  absent (test_hz_scan.py:396) so scan_fields drops the judged mean silently. Fix: SCAN_FIELDS = 5 fixed names incl.
  mean_net + copy every row key starting with "mean_net_" in row order. tests/synthetic/test_rescore.py (NON-owned,
  TASK-15.33) pins a parquet with the OLD two names and no mean_net -> the prefix rule keeps it green unchanged;
  acceptance runs it. test_bench_hz CELL_KEYS gains mean_net.
- 16.60 (deps []): fxplat.execution.fun_passprob_report = I/O half of fondeo item 3 (fun_passprob = TASK-16.36, pure).
  Reads <out_root>/fondeo_ftmo/run-*/closes.jsonl (every run, forced liquidation closes included, by_exit_reason shows
  them), net_r = net_usd / r_usd(profile, starting_capital) so risk_frac x initial = r_usd (balance moves by the exact
  net_usd), span = [min ts_fill, max t_exit], params N_PATHS 2000 / BLOCK_DAYS 5 clamped to n_days (pass_probability
  checks block <= len(days) BEFORE the MIN_TRADES check!) / MAX_DAYS 365 / FUNDED_DAYS 91 / SEED 20261026, writes
  <out_root>/<id>/passprob.json via paper_store.atomic_write (idempotent), CLI exit 2; load_fun_config(repo_dir)
  REFUSES an out_root inside repo_dir -> tests need repo_dir = a sibling tmp dir. Fixture: 60 trades, 2/weekday from
  Mon 2026-10-05 (Prague), net 150 when i%5<2 else -100 (mean R 0) -> p_pass1 0.486 (seeds 1-6: 0.472-0.502),
  p2|1 581/972, funded 461/581, medians 117/60, main_breach failed_max, ends sums = 2000 / 972 / 581; INSUFFICIENT on
  run-2 alone (20 trades). Prototype + scenario scripts: /tmp/p1660 (src copy; scen/final.py prints every number).
  UI/exporter publication of passprob.json is a follow-up of 16.58 (its owned exporter file is still queued).
COMMITTED 2026-11-01 15:59Z after one OK review round each (11.57 3 lows applied, 15.42 none needed, 16.60 0 findings):
11.57 9615083, 15.42 8da6c51, 16.60 2ca98f3 (gate-aware script /tmp/sw1660/commit_when_clear.sh; the merge gate's
.git/info/exclude hid the untracked drafts from `git status tasks/` -> `git add -f`).
Still unwritten: Binance wiring halves 1b (SignalSlot.on_signal + shadow fill records file), 2b (OCO submit via REST +
ledger), 5b (reconcile at start; needs the ledger file) - all need Nautilus-side code in strategies.py (nautilus_trader
1.231.0 IS installed in .venv) and a transport design (crypto-sim -> trader) nobody has registered; the fondeo deploy
wiring (compose.fun.yml mount + fun.json cost_document + timer for 16.59). Backups + review logs: /tmp/sw1660/.
Next free ids: 3.148, 4.20, 9.12, 11.58, 12.20, 14.23, 15.43, 16.61.

**Why:** the next writer must not re-specify the two re-keys or item 3, must know the non-owned test_rescore pin and
the block_days-before-MIN_TRADES ordering trap, and must know what the remaining Binance/fondeo wiring needs.

**How to apply:** `git log --oneline -6 -- tasks/` (are 11.57 / 15.42 / 16.60 committed?); `git status --short tasks/`;
`ls -t logs/spec-review-TASK-1[16]\.[56]*`. Related: [[fondeo-rung-chain-refill]], [[ops-blocked-specs-refill-2026-11-01]],
[[real-run-task-ids]], [[binance-item6-wiring-refill]].
