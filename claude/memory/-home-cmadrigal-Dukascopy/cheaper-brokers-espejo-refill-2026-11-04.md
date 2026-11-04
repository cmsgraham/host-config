---
name: cheaper-brokers-espejo-refill-2026-11-04
description: "Spec-writer refill 2026-11-04 ~16Z — the two RESOLVED 2026-11-04 decisions (DUKASCOPY cost profile + espejo_ic / espejo_dukascopy parity accounts on Forward; second ruler extended to IC_RAW / DUKASCOPY): TASK-11.64 brokers.yaml v2 DUKASCOPY / 3.156 cost_profiles / 16.85 fun_profiles sizing_base / 16.86 fun_book / 16.87 yaml rungs + parity test / 4.48 export_forward mirrors; measured parity numbers, pins, traps, what is left"
metadata:
  node_type: memory
  type: project
  originSessionId: refill-20261104-16
  modified: 2026-11-04T16:07:29.153Z
---

Refill 2026-11-04 ~15:50Z (runnable 7.42-7.44 / 8.13 / 8.14 < low water 6; no drafts; main 1a8fa8e). Source = brief
item 2: TWO new `### RESOLVED 2026-11-04 (Cristian)` entries in state/decisions-pending.md with no task yet -
"Cheaper-broker simulated accounts on Forward (IC Markets Raw + Dukascopy) and a DUKASCOPY cost profile" (items 1-3)
and "Second ruler (US$1,000) - option (b), extended to Dukascopy" (depends on the DUKASCOPY profile; one task per module).
Written (hold "draft, under review" first, all six valid, reviews started together):
- 11.64 broker_costs `_VERSIONS = (1, 2)` (+ `_VERSION = 2`), brokers.yaml version 2 + DUKASCOPY block AFTER EXNESS_PRO
  (test_research_run_cost_profile._brokers_copy splits the shipped text on '\n  EXNESS_PRO:' - a block between IC_RAW
  and EXNESS_PRO breaks it). Owns test_hz_broker_costs (version/set/known-list pins) + test_hz_ideate line 342 (set of
  shipped brokers). Hand: EURUSD mid 1.1, spreads 1e-4, atr 1e-3, risk 50 -> 25,000 units; DUK cost_r 0.135 target /
  0.16 stop = IC_RAW + 0.005. Shipped v1 hash 0062ee00...
- 3.156 cost_profiles COST_PROFILES = ('IB', 'IC_RAW', 'DUKASCOPY'); _raw_entry unchanged (kind raw, policy_rate_v1,
  margin 0.015 all satisfied); owns test_research_run_cost_profile.py (line 187 tuple pin). research_cli choices come
  from research_run.COST_PROFILES -> no edit.
- 16.85 fun_profiles optional key sizing_base ('equity' default | 'starting_capital'), FunProfile LAST field with
  default, hashed only when 'starting_capital' (SHIPPED_SHAS must hold); refused with fixed_lots. Pins: names[-2:]
  == ['lesson_es','challenge'] (test_challenge_spec...) and test_hash_document_and_sha_form's asdict copies.
- 16.86 fun_book.size_for base = starting_capital_usd when sizing_base == 'starting_capital'; clamp stays on equity.
  Hand (atr 0.0007658403707990117 = happy-path candidate, upu 1, price 1.1, 5000/1%): 32_000 at any equity
  (equity-based: 33_000 at 5075, risk 50.54546447273477); risk_usd 49.01378373113675; clamp at equity 500 -> 22_000;
  martingale x2 step 1 -> 65_000 (equity twin at 4925 -> 64_000).
- 16.87 yaml espejo_ic / espejo_dukascopy appended (5000, 1 %, sizing_base starting_capital, limits 4/2/0.04,
  K 2/4/0.10/2 = LossLimits defaults, ruin_below_usd 0.0, leverage 50) + tests/execution/test_fun_sim_espejo.py.
  MEASURED (scratch /tmp/sw1104/parity.py: Rig + fun side by side on HAPPY_PATH, DUKASCOPY patched in): protocol
  close EID ts_fill 1791982860000 t_exit 1791982905000 fill 1.10507 -> 1.108133361 target r_gross 2.005351039999823
  r_net 1.8805510399999559 costs_r commission 0.08 (= US$4 = two IB minimums); mirrors: units 32_000, gross
  98.0275519999978 (= r_gross x 49.01378373113675, NOT x 50 - the protocol's r_gross divides by the real risk),
  IC commission 1.92 net 96.1075519999978 equity 5096.107551999998; DUK commission 2.24 net 95.7875519999978 equity
  5095.787551999998. Pins owned: test_fun_profiles (IDS, SHIPPED_SHAS, capital loop), test_fun_sim line 420 (keep
  PROFILE_IDS six - test_fun_sim_fondeo 415 reads units in that order), test_fun_sim_dials (list + 7->9, 6->8),
  test_fun_sim_costs 343-349 dicts, test_export_fun_profiles_ends 181-184. Known divergences written in the yaml
  header: no corr / currency-exposure rule in the fun ladder; fun K3 restarts the run where the protocol latches.
- 4.48 export_forward build(..., fun_mirror=None) -> payload['mirrors'] rows (keys registered in the spec) from
  FUN_MIRROR data/fun-v<N>/<acct>/run-<n>; mirror_r_usd lazy via fun_profiles; row-level skipped so the protected
  p['skipped'] pin holds. Hand rows: IC net 96.11 / net_r 1.9222 / pct 1.9222; DUK (two closes +95.79, -52.24)
  net 43.55 / net_r 0.871 / cost 4.48 / per trade 2.24.

LEFT (next writer): decision B "Second ruler extended" = F1 'Cuenta en vivo' at IC_RAW / DUKASCOPY + the US$1,000
exporters (export_brokers / pnl / risk / forward) beside IB - f1_costs.py is 994 lines (cap 1000!) so any F1 wiring
needs a new owned module + a brokers argument on run_f1_costs (price_instants needs per-instant arrays, not in the F1
JSON -> a re-measure per broker variant via resolve_cost_profile); the ForwardView TSX rows for payload.mirrors
(UI-C, ui/package.json exists); the IB-node stubs 7.2 / 8.4 (flatten-at-broker, composition, ibapi ask pending).
Next free ids: 11.65 / 3.157 / 16.88 / 4.49 / 7.45 / 8.15 / 9.20.

**Why:** the next writer must not re-measure the parity numbers nor re-grep the ladder pins; the EXNESS_PRO split
marker and the r_gross-divides-by-real-risk fact are traps already hit once.
**How to apply:** `agent-ci status` for 11.64 / 3.156 / 16.85-16.87 / 4.48; 16.87 waits on 11.64 + 16.86. See
[[fun-sim-split-and-binance-regression]], [[second-ruler-rerun-brokers-f2-pnl-refill-2026-11-03]], [[real-run-task-ids]].
