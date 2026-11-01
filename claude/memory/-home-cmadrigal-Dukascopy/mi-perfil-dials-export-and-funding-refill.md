---
name: mi-perfil-dials-export-and-funding-refill
description: "2026-11-01 20:11Z refill: 16.66 export_fun_profiles card 'dials' (mi_perfil fun-dials-run/1 record minus set_by, per-run history with changed fields, fun-dials-status/1 block; params/lesson_es from the record via profile_from; key inserted AFTER 'curve' so the 16.58/16.62/16.64 tail pins hold; own NEW test file) + 16.67 fun_funding (pure perps funding accrual; archive stamps <= 47 ms late on the 8 h grid); Binance 1b transport IS settled by shadow.py (files) and Nautilus 1.231.0 order_factory.market takes client_order_id; next free 16.68 / 11.58 / 15.43"
metadata:
  node_type: memory
  type: project
  originSessionId: refill-20261101-201120
  modified: 2026-11-01T20:40:04.272Z
---

2026-11-01 20:11Z refill (runnable 16.60 in gate -> merged 97adc51 at ~20:40Z, 16.61 / 16.62 / 16.64 / 16.65; main lint
green; no drafts; no new RESOLVED since 10-27; all phone asks expired 'wait'; ops 0 cases). Sources found:
- mi_perfil EXPORTER was never written (memory 10-27 said "exporter/UI (operator)", but 16.58/16.62/16.64 set the
  precedent that export_fun_profiles edits ARE spec-writer work). fun_sim already writes run-<n>/dials.json
  (fun-dials-run/1, incl. set_by = approver EMAIL) and the root status key 'mi_perfil' (fun-dials-status/1); the
  exporter published none of it and card params / lesson_es were None for mi_perfil (profile_specs reads only the YAML).
- 16.66 (deps 16.64, same two files chain): card['dials'] = {record (public keys sha256/dials/set_at_ms/journal_line/
  started_ms - set_by DROPPED, the bundle is public; 'who' comes from GET /app/api/mi-perfil behind the login), history
  [{run, ...public, changed (vs previous VALID row; first row []), end_ms, end_reason}], status (block minus set_by)};
  dials_spec(card) -> params / lesson_es from fun_dials.profile_from(parse_dials(record), version=profile_version) under
  the SAME sha rule (decision sha = profile_sha256(profile_from(record.dials)), version 1). KEY TRICK: 'dials' inserted
  after 'curve' and BEFORE 'profile_sha256' in read_account, so the queued siblings' tail pins ([-7:], [-4:]) hold and
  test_export_fun_profiles.py is not touched; the task owns a NEW tests/publish/test_export_fun_profiles_dials.py
  (tests/publish is not a package: copy helpers). Prototype /tmp/p1666 (export_fun_profiles.py 610 lines, scen.py prints
  every number; all 17 existing exporter tests green on it). Measured: d0 sha 91670346..., profile bd0cad3f...; d5
  (risk 0.05) sha b271d0c8..., profile 7848db3c...; changed_fields(d0, d5) == ('risk_pct',).
- 16.67 (deps []): fxplat.execution.fun_funding = decision 2026-10-25 'mi perfil futures' item 1 first brick. Archive
  facts (binance_archive.load_funding, BTCUSDT/ETHUSDT 7,395 rows 2020-01..2026-10): every interval_h 8, stamps 0-47 ms
  LATE vs the 8 h grid (3,312 rows), never early -> grid_ms = nearest multiple with 60 s tolerance. Rules: open AT the
  grid instant pays, closed AT it does not; settlement known iff ts_ms <= now; mark = last mark <= settlement ts
  (ValueError if none); amount = round(-dir x qty x mark x rate, 8); expected grid instants vs missing (never invent a
  payment). Prototype /tmp/p1667 (fun_funding.py 188 lines + scen.py). Real Jan-2025 BTCUSDT: 93/93, -0.00724185.
- NOT written (out of scope / needs web): liquidation price (Binance maintenance-margin tiers, must cite page + date),
  perps fee schedule (recorder snapshot is SPOT commission only: /api/v3/account/commission), the perps rung / market
  switch on mi_perfil (changes the fun-dials/1 journal schema that 16.41's request service validates - design first).
- Binance 1b FINDING: the "transport design" is NOT open any more - shadow.py (16.45) derives the shadow Signals from the
  sim's positions.jsonl 'fill' rows + closes-SIMULATED.jsonl lines, so the trader READS THE SIM FILES: mount
  ./sim-data:/sim:ro into binance-trader (compose.crypto.yml: trader has ./trader-data:/data, ./control ro,
  ./approvals ro; crypto-sim writes ./sim-data). Fill records shadow.pair expects: {client_order_id (SHD-...), status in
  FILL_STATUSES, symbol, side, qty, px, fee_usd, ts_fill_ms, reason}. Nautilus 1.231.0 OrderFactory.market(instrument_id,
  order_side, quantity, time_in_force, reduce_only, quote_quantity, exec_algorithm_id, exec_algorithm_params, tags,
  client_order_id=None) ACCEPTS a custom client_order_id -> shadow.client_order_id(event_id, leg, attempt) can be the
  venue id. SmokeStrategy (strategies.py 236-345) is the submit/on_order_filled precedent. A next writer can spec 1b as
  (i) binance_trader.shadow_feed: stdlib tailer of the two sim files + shadow-fills.jsonl -> pending Signals (dedupe by
  (event_id, leg) from parsed client ids, STALE cut-off, cap per poll), (ii) SignalSlot.on_signal wiring + fill writer
  (Nautilus; tests with fakes like test_binance_trader_safety.py), (iii) compose mount + panel row (export_brokers).
STATUS ~20:50Z: 16.67 COMMITTED 13dff05 (review OK r1, 2 findings applied: the 'open position now T+2G-1 -> 2' literal
needed P's opened_ms, and accrue re-checks ordering / one-per-grid on hand-built tuples); 16.66 COMMITTED 27dbab2
(r1 BLOCK: test (k) must monkeypatch.setattr ex.FUN_MIRROR / PAPER_MIRROR - module constants read at import, env vars
do nothing - and setenv only FXPLAT_BUNDLE_OUT; cap 420 -> 480; r2 OK 0 findings). THIRD spec written from the 1b
finding above: 16.68 binance_trader.shadow_feed (pure poll logic: parse_lines lenient, records_by_leg with shadow.pair's
rules, pending(signals, fills, now_ms, max_age_ms 900_000, max_per_poll 2) -> Feed(submit / expired / refused
'no_entry' / waiting / done), one attempt per leg, fill_record kind 'binance-shadow-fill/1' with keys client_order_id,
event_id, leg, symbol, side, status, ts_ms, qty, px, fee_usd, ts_fill_ms, reason, ref_px, ref_ms, sim_qty,
sim_fee_usd); prototype /tmp/p1668 (shadow_feed.py 154 lines + scen.py; pair rows slippage 0.4615 / 1.5142 bps,
latency 1150 / 5900 ms). Task 1c = SignalSlot timer + file reads + order_factory.market(client_order_id=) +
on_order_filled -> fill_record + compose mount ./sim-data:/sim:ro + export_brokers row (needs Nautilus fakes).
16.68 review r1 OK (1 low applied: ts_ms / ts_fill_ms rules registered), hold lifted 20:39Z, final in
/tmp/sw1666/final/TASK-16.68.yaml; the 16.62 merge gate (MERGING.json since 20:34:36Z) blocked the commit -> detached
waiter `bash /tmp/sw1666/commit_when_clear.sh TASK-16.68` (pid 3306854, log /tmp/sw1666/commit_TASK-16.68.log, gives
up after 4 h). NEXT WRITER FIRST: `git log --oneline -3 -- tasks/`; if 16.68 is missing, rerun that script.
Next free ids: 3.148, 4.20, 9.12, 11.58, 12.20, 14.23, 15.43, 16.69.

**Why:** the next writer must not re-specify the dials export or funding, must know the key-insertion trick that
avoids editing a sibling's pinned test, and must know 1b is spec-able now (no design ask needed).

**How to apply:** `git log --oneline -4 -- tasks/` (16.66 / 16.67 committed? else /tmp/sw1666/ has the drafts and
review logs review-16.6[67].log); `git status --short tasks/`. Related: [[fondeo-daily-report-wiring-refill]],
[[judged-rekey-and-passprob-refill]], [[binance-item6-wiring-refill]], [[real-run-task-ids]].
