---
name: binance-final-wiring-refill-2026-11-02
description: "2026-11-02 04:05Z refill: the LAST Binance TESTNET tasks - 16.75 shadow_trader final wiring (ShadowTrader mixin composition + config `shadow:` block + __main__ run switch + ./sim-data:/sim:ro + shipped config on; deps 16.72/73/74), 16.76 export_brokers payload.crypto.shadow panel row (deps []), 16.77 mirror + fxplat-binance-health shadow lines (deps []); KEY FACT: a Nautilus Strategy CAN be constructed without a node (only running needs one); next free 16.78 / 11.58 / 15.43"
metadata:
  node_type: memory
  type: project
  originSessionId: refill-20261102-040510
  modified: 2026-11-02T04:29:54.617Z
---

2026-11-02 04:05Z refill (runnable 16.70 (merge gate) / 16.71 (spec review) / 16.72 / 16.73 / 16.74, low water 6;
no drafts; no new RESOLVED since 10-27; main a0c1109). After 16.72-16.74 the only Binance work left was the
composition + the home/panel side, so three tasks:
- KEY FACT (verified .venv): `SignalSlot(GuardedConfig(...), guard, status, 'testnet', lambda: None)` works WITHOUT a
  TradingNode (it is what __main__ does before add_strategy): str(id) 'SIGNALSLOT-001-SIG', .config, instance attrs
  settable, .cache None. Only RUNNING needs a node. So 16.75's test constructs the real ShadowTrader and checks
  MRO / config / rest_creds - no duck-typed host.
- 16.75 shadow_trader.py: ShadowTrader(StartCheckMixin, OcoMixin, ShadowMixin, GuardedStrategy), __init__ Refused
  off TESTNET; ShadowTraderConfig(ShadowConfig) + stop_limit_ticks; rest_creds_for(gate, env, offset_ms) ->
  RestCreds(gate.endpoints['http'], mode, keys_for, int(off)); common_fields(cfg); build_strategy(cfg, gate, env,
  guard, status, connected_fn, *, offset_ms) -> SignalSlot when cfg.shadow is None (any mode) else Refused on live
  else ShadowTrader with strat.rest_creds set as instance attr. config.py: ShadowSettings(sim_dir '/sim', poll_s 15,
  stop_limit_ticks 5), TraderConfig.shadow last field default None, shadow_settings(block) (None/False -> None,
  True/{} -> defaults, refusals measured). __main__: Refused guard inside the try before keys_for; lazy `from . import
  shadow_trader`; SignalSlot/GuardedConfig imports removed (F401). compose: './sim-data:/sim:ro' 5th volume of
  binance-trader. config.yaml: shadow block ON (decision item 1). Owned 6 files (precedent 16.61). ids
  'SHADOW-001-SHD'. ruff: main's __main__+config have 15 pre-existing E501 -> acceptance `--extend-ignore E501`.
- 16.76 export_brokers.crypto_shadow(trader_dir, now) -> {'kind': 'binance-shadow-panel/1', state ok/stale/missing/
  invalid, generated_at, age_min (rounded 0.1 THEN > 20 = stale), summary as-is, inflight len, orphan_events,
  reconciliation {verdict, line, at, n_findings, n_open_orders, torn_lines} | None}; point in time (generated_ms >
  now -> missing; at_ms > now -> None); build_crypto(..., shadow=None) LAST key -> the sibling
  test_export_brokers_regression.py list(p) pin had to be owned + amended (+ cap 560 -> 600). Exporter must keep ONE
  `from binance_trader import regression` (sibling pin) -> kinds as literals.
- 16.77 mirror trader line "smoke shadow-comparison.json reconciliation.json shadow-fills.jsonl ledger.jsonl
  status.json" (status.json last = done marker); health shadow_problems: cryptoreconcilehold (verdict 'hold' in
  status.json 'reconciliation'), cryptoshadowerror (status 'shadow'.last_poll.error), cryptoshadowfile,
  cryptoshadowstale (> STALE_S 1200 s); silent without 'shadow' key (SignalSlot) or without status. NO summary
  counts in health (they accumulate forever -> panel's job). test_binance_health.py re-owned (cap 130 -> 175; e2e key
  list of today unchanged).
- Prototypes /tmp/p1675 (package + queued modules + scen.py), /tmp/p1676 (export_brokers.py + scen.py), /tmp/p1677
  (health + mirror + scen.py); drafts backed up /tmp/sw1675/; review logs /tmp/sw1675/review-16.7x.log.
- STATUS 2026-11-02 ~04:40Z: all three reviews OK round 1 (16.75: re.escape for match=; 16.76: wrong-typed
  inflight / orphan_events -> 'invalid', non-list findings -> reconciliation None, caps 620; 16.77: test cap 400, line
  counts 116 / 187) -> holds lifted, COMMITTED 89b51a3 (16.75) / 0b57cbc (16.76) / b1533a8 (16.77); tree clean.
- Binance decision 2026-10-26 is now FULLY specified (items 1-6). Left for Binance: nothing to spec; the operator
  runs redeploy-binance.sh + installs mirror/health (README). Other open work needs the phone (family-1 grammar,
  3.147 v2 counting, S4/S5 worlds) or is a late-phase roadmap stub.

**Why:** the next writer must not re-specify the wiring, must know the standalone-Strategy construction fact (it
replaces the duck-typed-host workaround for composition tests) and the sibling-pin traps (list(p) key order, single
binance_trader import, health line cap).

**How to apply:** `git log --oneline -4 -- tasks/` (16.75-16.77 committed?) else drafts in /tmp/sw1675/ + review
logs; `git status --short tasks/`. Related: [[binance-strategy-glue-refill-2026-11-02]],
[[binance-io-halves-refill-2026-11-01]], [[binance-item6-wiring-refill]].
