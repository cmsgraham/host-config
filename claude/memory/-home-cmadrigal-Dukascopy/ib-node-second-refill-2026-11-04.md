---
name: ib-node-second-refill-2026-11-04
description: "Spec-writer refill 2026-11-04 09Z — six more Nautilus-light IB node pieces for the TASK-7.2 / 8.4 stubs: 7.34 node_store / 7.35 node_resubmit / 7.36 node_book / 7.37 node_entries / 7.38 node_health / 8.14 node_gate; measured standalone-Cache + replay facts (bare leg has no OUO link -> sibling-cancel rule; OrderCancelRejected on a double cancel); what is still unspecified (decision cycle, composition needs ibapi)"
metadata:
  node_type: memory
  type: project
  originSessionId: refill-20261104-090157
  modified: 2026-11-04T09:30:50.210Z
---

Refill 2026-11-04 09:01Z (runnable 6.5 / 7.31 / 7.32 / 7.33 / 8.13 < low water 6; no drafts, no new RESOLVED decision,
ibapi ask 001cd70c still pending). Source = brief item 1, the 7.2 / 8.4 stubs' "STILL TO SPECIFY" list. Written (all
hold "draft, under review" first; 7.34-7.37 deps [7.32], 7.38 / 8.14 deps []):
- 7.34 fxplat.execution.node_store: MODES {'paper': 'PAPER-IB', 'live': 'LIVE-IB'}; FILES mode/brackets/fills/decisions/
  recovery/reconciliation/gate/health; mode_text = canonical_json (sorted keys) of mode/start_ms/code_commit/account_id/
  risk_fraction, checked vs settings at every start (mode/account/risk mismatch -> ValueError 'mode file: ');
  bracket_line = json of the FULL OrderPlan (nested bracket/legs, 730 chars for P_LONG) -> exact round trip;
  torn-last-line rule copied from paper_store; last_ts_ms for daily_due; append / write_health reuse paper_store's
  append_lines / atomic_write.
- 7.35 node_resubmit: bracket_resubmission = resubmission(bracket, bracket_states(cache, bracket)); protective_legs =
  plan legs when unfilled, reanchor_bracket legs from the real fill otherwise; ResubmitMixin.resubmit_bracket sends the
  whole OrderList on never_reached, BARE stop_market / limit under the leg's own client id on protect, nothing on
  wait/none, registers ctx unless entry_closed; on_order_filled cancels the sibling leg when either leg's
  contingency_type != OUO (bare re-sent leg has NO_CONTINGENCY; a second cancel over an intact OUO yields
  OrderCancelRejected - measured).
- 7.36 node_book: BookMixin records FillRecord from on_order_filled (trade ids NOT deterministic, read them);
  internal_book(brackets, fills, stops) -> InternalBook (signed units, fill-weighted entry, stop = reanchors()[g] if
  present else plan, entry unfilled -> pending_groups); clean reconcile on long/short open and after target/stop.
- 7.37 node_entries: context_for / enter_contexts re-plan each opened PaperPosition exactly as paper_step._decide_candidate
  (ask for long / bid for short, USD-base conversion mid, spec_for(family).m, position.risk_usd, ticks[symbol]) and refuse
  when units / planned_entry / stop / target differ from the 'enter' record; group id depends on event_id only
  ('SIM-E1' -> fx-bd1a2a2030cbc6e612f1).
- 7.38 node_health: freshness(health, Thresholds(market, risk, broker, drift)) -> reasons in fixed order; age == max
  passes, negative age passes; health_text/read_health = canonical_json of health + execution_allowed + reasons.
- 8.14 node_gate: APPROVAL_FILES G7/G8 by mode, '<file>.<principal>.sig' + allowed_signers (TASK-6.1 convention),
  node_gate dispatches NodeSettings to evaluate_paper_gate / evaluate_live_gate; gate_line JSON; tests reuse
  test_live_gate.Signer (real ssh-keygen).

MEASURED (nautilus 1.231): a STANDALONE Cache() works for state tests - cache.add_instrument / add_order, then
order.apply(TestEventStubs.order_submitted/accepted/filled(order, inst, last_px=, ts_event=, last_qty=)/canceled) +
cache.update_order each time; a stub-filled entry's trade id == its client id. OrderFactory.stop_market / limit take
client_order_id= but NO contingency arg. Prototypes /tmp/sw734 (node_resubmit.py, node_book.py, scen.py; backup/ holds
the six drafts). Standalone resubmission table: empty -> never_reached; entry filled + nothing -> protect S 1.0951 /
T 1.1101; + target -> stop only; entry accepted unfilled -> plan prices 1.095/1.11; partial 3000 -> qty 3000; canceled
-> entry_closed; target only -> inconsistent; all -> in_place.

LANDED 2026-11-04 ~10:4xZ after the 6.5 gate cleared: 7.34 c26b6c6, 7.35 2166957, 7.36 1f8f936, 7.38 e3819e5 (reviews
OK first round, findings applied + --accept-amended: 7.35 medium = sibling rule only when the filled leg is FILLED in
full, not on a partial fill). 7.37 and 8.14 BLOCKed round 1 (spec_for raises KeyError not ValueError; 'no_trade'
records need no_trade_reason; a 'garbage' signature fails signature_public_key even with an injected verifier -> use
signer.sign('kR', 'other text'); GOOD is good_dict(tmp_path) in test_node_settings) -> fixed, round-2 OK: 7.37 2e301b6, 8.14 committed right after (git log). Session ~1h50m, six queued.

LEFT for 7.2 / 8.4: the H1-close decision cycle over the broker book (run_step needs (PaperPosition, PositionState) rows
from the broker book + SwitchInputs - heavy), the switch board persistence for the node (paper_store's board_text /
read_board pin MODE 'SIMULATED'), the TradingNode composition (ibapi), 8.4's live wiring. Next free ids 7.39 / 8.15.

**Why:** the next writer must not re-measure the Cache/OUO facts nor re-split the node; 7.34-7.37 depend on 7.32.
**How to apply:** `git log --oneline -10 -- tasks/`; check 7.32 merged before expecting these to run. See
[[ib-paper-node-pieces-refill-2026-11-04]], [[phase5-6-freeze-final-test-refill-2026-11-03]].
