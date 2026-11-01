---
name: binance-io-halves-refill-2026-11-01
description: "2026-11-01 21:42Z refill: the three Binance TESTNET I/O halves that sit between the merged pure modules and the Nautilus glue - 16.69 shadow_poll (1c-i, deps 16.68), 16.70 ledger + start_check (5b-i), 16.71 oco_rest (2b-i); all Nautilus-free with injected clock / transport; what is left = the strategy glue tasks 1c-ii / 2b-ii / 5b-ii (object.__new__(Strategy) test trick); next free 16.72 / 11.58 / 15.43"
metadata:
  node_type: memory
  type: project
  originSessionId: refill-20261101-214212
  modified: 2026-11-01T22:24:50.141Z
---

2026-11-01 21:42Z refill (runnable 16.65 in merge gate from 21:38Z, 16.66 escalation engineer (attempts exhausted),
16.67, 16.68 committed 4f963a2; main lint green; no drafts; ops 0 cases; no new RESOLVED since 10-27). Binance items 3
(exchange_rules.py) and 4 (StopDrill / regression) were already covered; the open work was the I/O between the pure
halves (16.45 shadow / 16.46 brackets / 16.47 reconcile / 16.68 shadow_feed) and Nautilus. Wrote three Nautilus-free
I/O modules (prototypes /tmp/p1669 /tmp/p1670 /tmp/p1671 = copies of the package + the new module + scen.py printing
every number; specs backed up in /tmp/sw1669/, finals in /tmp/sw1669/final/ once the hold is lifted):
- 16.69 shadow_poll.ShadowPoller(sim_dir, data_dir, *, submit, now_ms, ...) (deps 16.68): reads the 3 files via
  shadow_feed.parse_lines, in-flight timeouts (INFLIGHT_MAX_MS 120_000 -> 'expired' no_venue_event) BEFORE pending()
  (else the id is resent in the same poll - caught in the proto), feed.expired -> 'too_old', feed.refused -> reason,
  submit callback None = sent / str = refused / exception -> 'submit_error: <Cls>'; on_fill / on_reject append the
  record (unknown id -> orphan_events); shadow-comparison.json {kind 'binance-shadow-comparison/1', summary, rows,
  inflight, orphan_events} each poll. Scenario torn line = first 40 chars of json.dumps(FILL2), completed later.
- 16.70 ledger: record()/append()/read() (torn tail counted, corrupt -> ValueError), may_submit, signed_query +
  venue_snapshot (GET /api/v3/openOrders all symbols + /api/v3/account balances; check_endpoints first; offset_ms),
  instrument(symbol, dust) <BASE>USDT only, start_check -> hold on blocking finding OR torn line, reconciliation.json.
- 16.71 oco_rest: oco_ids O/T/S letters from shadow.client_order_id's entry id (28 chars), OCO_RE parse, signed POST
  /api/v3/order/oco (+ newOrderRespType FULL) and DELETE /api/v3/orderList by listClientOrderId through an injected
  send(method, url, headers); parse_result (exactly our two legs, VENUE_STATUS map NEW->open ... EXPIRED_IN_MATCH->
  expired, legs target then stop); ledger_rows = 16.70's record shape (schema key + ts_ms + detail) validated with
  reconcile.ledger_index. Nautilus 1.231 facts: spot/http/account.py BinanceSpotOrderOcoHttp 'order/oco',
  BinanceSpotOrderListHttp 'orderList' DELETE(listClientOrderId), schema BinanceSpotOrderOco; spot/execution.py:258
  "List status (OCO) received  # Implement".
LEFT (strategy glue, needs Nautilus fakes): 1c-ii SignalSlot timer -> poller.poll(); submit cb = order_factory.market(
iid, side, inst.make_qty, client_order_id=ClientOrderId(cid)) + submit_guarded -> why; on_order_filled/rejected ->
poller.on_fill/on_reject; compose mount ./sim-data:/sim:ro; export_brokers row from shadow-comparison.json 'summary'.
2b-ii entry fill -> bracket_from_fill -> submit_oco -> ledger.append rows; time exit -> cancel_oco. 5b-ii
_on_reconciled -> ledger.venue_snapshot (needs key/secret + rest.server_offset_ms) -> start_check -> hold => guard.halted
+ write_report. Test trick for Strategy subclasses without a node: `object.__new__(Cls)` + set attributes (precedent
test_binance_trader_safety.py hmac test). Next free ids: 16.72, 11.58, 15.43, 3.148, 4.20, 9.12, 12.20, 14.23.

STATUS 22:1xZ: all three reviews OK round 1 (3 lows each + one medium on 16.69: never pin the exact
records_by_leg message, 16.68 pins only the prefix; 16.70 append() now writes a leading b'\n' after a torn tail so
new records are not lost - registered + measured (6, 1) / (7, 1)); holds lifted, finals in /tmp/sw1669/final/,
validated (16.69 BLOCKED only on 16.68 not passed yet). The 16.65 merge gate (MERGING.json since 21:38Z) blocked the
commits -> detached waiter pid 3649210 `bash /tmp/sw1669/commit_when_clear.sh TASK-16.69 TASK-16.70 TASK-16.71`
(log /tmp/sw1669/commit.log, gives up after 4 h; tasks/ is gate-excluded, so `git status --short tasks/` shows
nothing - check `git log --oneline -4 -- tasks/`). COMMITTED 22:24:30Z once the 16.65 gate cleared: 16.69 64e34d8,
16.70 abad2a3, 16.71 6356dbb; tree clean.

**Why:** the next writer must not re-specify these I/O halves and must know the remaining glue is the only Binance
work left (plus the UI row), and where the prototypes / numbers live.

**How to apply:** `git log --oneline -4 -- tasks/` (16.69-16.71 committed? else `bash /tmp/sw1669/commit_when_clear.sh
TASK-16.69 TASK-16.70 TASK-16.71` once finals exist); review logs /tmp/sw1669/review-16.*.log and
logs/spec-review-TASK-16.69..71-*.md. Related: [[mi-perfil-dials-export-and-funding-refill]], [[binance-item6-wiring-refill]].
