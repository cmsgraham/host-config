---
name: binance-strategy-glue-refill-2026-11-02
description: "2026-11-02 00:15Z refill: the three Binance TESTNET strategy-glue mixins over GuardedStrategy - 16.72 shadow_glue (1c-ii, deps 16.69), 16.73 oco_glue (2b-ii, deps 16.70+16.71), 16.74 start_glue (5b-ii, deps 16.70); Nautilus Strategy is Cython (no object.__new__, cache read-only) so glue = plain mixins tested on duck-typed hosts; LEFT = one final wiring task (compose the mixins + RestCreds + `run` switch + ./sim-data:/sim:ro mount + export_brokers row); next free 16.75 / 11.58 / 15.43"
metadata:
  node_type: memory
  type: project
  originSessionId: refill-20261102-001527
  modified: 2026-11-02T00:43:20.195Z
---

2026-11-02 00:15Z refill (runnable 16.69 / 16.70 / 16.71, low water 6; no drafts; no new RESOLVED since 10-27; main
609a31e clean, lint green). Everything decision-backed left was the Binance strategy glue, which depends on the queued
I/O halves - written anyway (nothing runnable-now exists: fondeo/mi_perfil items done or web-blocked, family-1 grammar
awaits the phone, roadmap stubs 4.4/5.1/6.x/7.2/8.4 are big late-phase items).
- KEY FACT (verified .venv): nautilus_trader 1.231 Strategy is Cython - `object.__new__(Sub)` TypeError 'not safe',
  `Sub.__new__(Sub)` has read-only .cache and .log None. So each glue is a plain Python MIXIN (class X(Mixin,
  GuardedStrategy)) using only GuardedStrategy's attributes; tests use a duck-typed Base host with fakes (real
  RiskGuard / Status work). Nautilus instruments carry the raw exchangeInfo dict in `.info` -> exchange_rules.parse_rules
  (inst.info) works. Price(65003.0, 2).as_double() == 65003.00000000001 -> use float(x.as_decimal()).
- 16.72 shadow_glue.ShadowMixin (+ ShadowConfig(GuardedConfig) sim_dir '/sim', shadow_poll_s 15): on_start -> ShadowPoller
  + timer 'fxplat-shadow'; poll skipped while start_balances is None; shadow_submit -> order_factory.market(...,
  client_order_id=ClientOrderId(cid)) via submit_guarded (exit = reduce_only), refusal 'guard: <why>'; venue events ->
  poller.on_fill/on_reject; fee_usd_of (USDT as is, base asset x px round 8, BNB None); hooks before_shadow_order(sig) /
  on_shadow_entry_filled(event_id, cid, *, px, filled_qty, partial) no-ops. Review OK r1 (2 lows: wrap E501s, extra
  constant) -> COMMITTED b4cb1e3.
- 16.73 oco_glue.OcoMixin (mixed BEFORE ShadowMixin): RestCreds(base, mode, api_key, api_secret, offset_ms) frozen; entry
  fully filled -> may_submit once-only -> bracket_from_fill(rules from inst.info, sim row with the VENUE filled qty) ->
  submit_oco -> ledger rows; any failure -> two 'rejected' rows + flatten('oco_failed <event>: ...'); before exit ->
  ledger statuses: leg filled -> '<kind>_filled' refusal, rejected -> 'flattened_after_oco_failure', live -> cancel_oco;
  cancel fails -> GET /api/v3/order per leg (order_status) -> rows + verdict, query fails -> 'oco_cancel_failed: ...';
  OCO leg fill events -> ledger 'filled' row.
- 16.74 start_glue.StartCheckMixin replaces _on_reconciled (no super): run_start_check (instruments from inst.info
  min_qty BEFORE the venue call; venue_snapshot; start_check; write_report; any exception -> hold + failure report same
  12 keys); hold -> guard.halted = 'reconcile hold: <line>', NOTHING cancelled; act -> cancel only foreign ('SHD-' kept),
  halted start keeps ours too. No nautilus import (uses host.iids).
- Reviews: 16.73 OK r1 (3 lows applied: FILL1/FILL2 cited from tests/deploy/test_binance_shadow_feed.py, __future__
  in the import list, test cap 520); 16.74 OK r1 (1 medium: C10 line has NO trailing space - verdict_line adds the id
  only when truthy; 1 low: wrap E501s). All three COMMITTED ~00:5xZ (16.72 b4cb1e3, then 16.73, 16.74).
- Prototypes /tmp/p1672 /tmp/p1673 /tmp/p1674 (package copies + the 16.69/16.70/16.71 prototype modules + scen.py
  printing every number; ruff-clean); specs backed up in /tmp/sw1672/, review logs /tmp/sw1672/review-16.7x.log.
- LEFT (next writer): 16.75 final wiring = new module composing class ShadowTrader(StartCheckMixin, OcoMixin,
  ShadowMixin, GuardedStrategy) + config keys (sim_dir, stop_limit_ticks; config.py 'unknown config keys' check must
  learn them) + __main__ `run` switch (RestCreds from gate.endpoints['http'], gate.mode, keys_for, rest.server_offset_ms)
  + compose mount ./sim-data:/sim:ro + export_brokers row from shadow-comparison.json 'summary'. Multiple owned files
  (precedent 16.61/16.65). Next free ids: 16.75, 11.58, 15.43, 3.148, 4.20, 9.12, 12.20, 14.23.

**Why:** the next writer must not re-specify the glue, must know the Cython-mixin constraint and the hook contract
(names/signatures in 16.72 and 16.73), and that only the wiring task remains for Binance.

**How to apply:** `git log --oneline -4 -- tasks/` (16.73 / 16.74 committed? else /tmp/sw1672/ has drafts + review logs);
`git status --short tasks/`. Related: [[binance-io-halves-refill-2026-11-01]], [[mi-perfil-dials-export-and-funding-refill]].
