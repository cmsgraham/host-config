---
name: ib-node-third-refill-2026-11-04
description: "Spec-writer refill 2026-11-04 ~12Z — six more IB-node pieces for the TASK-7.2 / 8.4 stubs: 7.39 node_positions / 7.40 node_quotes / 7.41 node_marks / 7.42 node_inputs / 7.43 node_board / 7.44 node_cycle (the H1 decision cycle over the broker book is now fully specified except flatten-at-broker + composition); measured Cache facts (quote_ticks / bars newest first, account balance_total = IB NetLiquidation, Cache is Cython: subclass, never monkeypatch); what is left"
metadata:
  node_type: memory
  type: project
  originSessionId: refill-20261104-12
  modified: 2026-11-04T11:55:46.294Z
---

Refill 2026-11-04 ~11:5xZ (runnable 7.35 / 7.36 / 7.37 / 8.13 / 8.14 < low water 6; no drafts, no new RESOLVED
decision, ibapi ask 001cd70c still pending, main dca8510). Source = brief item 1, the 7.2 / 8.4 stubs' "STILL TO
SPECIFY" (the H1-close decision cycle over the broker book). Written (hold "draft, under review" first):
- 7.39 node_positions (deps 7.36): position_rows(brackets, fills, records, entry_states, *, at_ms, stops=None) ->
  (PaperPosition, PositionState) rows for run_step: pending / no_fill (entry CANCELED/REJECTED/EXPIRED) / open /
  closed; entry_px fill-weighted, exit by leg suffix (-T target / -S stop / mixed 'flatten'), r_gross = d *
  (exit - entry) * size * upu / risk (1.980000000000004 on P_LONG 1.1001 -> 1.11), slip = d * (entry_px - entry_ref)
  * size * upu (0.49999999999994493), costs 0.0 / r_net == r_gross (*reading: the statement holds the broker costs);
  session_date = NY date of ts + 7 h (T=1_772_460_000_000 -> 03-02; 22:30Z -> 03-03).
- 7.40 node_quotes (deps []): instrument_ids / bar_type / quote_series / quote_states / feed_up / bar_rows (+ forming
  sentinel so closed_h1 keeps the last cached bar) / bar_closes / daily_close over a standalone Cache; 300 synthetic
  H1 bars (rng('node_quotes', 0)) give stub candidate SIM-8a17c6ac55f39253 level 1.10341 atr 0.0009915614151017917.
- 7.41 node_marks (deps []): account_equity_usd(cache, venue) = balance_total(USD).as_double() (IB adapter maps
  NetLiquidation -> total; IB_VENUE 'INTERACTIVE_BROKERS'); marks.jsonl in paper_store mark_line format; marks_at.
- 7.42 node_inputs (deps 7.39): node_inputs(...) -> SwitchInputs mirroring paper_runner._switch_inputs; log_open_ids
  = enter_ids - finished rows (K6 sees a decision without a bracket); model_slip mapping for K8; verified equal
  statuses to test_paper_step.fixture_f with a full quote set.
- 7.43 node_board (deps []): board_text / read_board with mode PAPER-IB / LIVE-IB (paper_store pins SIMULATED),
  releases via paper_store.read_releases, status_text with execution_allowed / reasons appended.
- 7.44 node_cycle (deps 7.37): decision_due (None / 'decide' / 'late'), decide_at = run_step + enter_contexts +
  to_json_line, CycleMixin.place_decision (all-or-nothing instrument check, then place_bracket per ctx). Fixture P
  gives one enter 25000 units, group fx-774c0d147899adfc49a1; quotes_at(EURUSD=None) with fixture_f makes run_step
  RAISE ('K4 should have blocked it'), it does not block.

MEASURED (nautilus 1.231): cache.quote_ticks / cache.bars return NEWEST FIRST; Bar.ts_event = close; standalone
Cache.add_account(TestExecStubs.margin_account()) -> account_for_venue(Venue('SIM')) total 1,000,000 USD; a Cache
instance cannot be monkeypatched (Cython AttributeError) but a Python subclass overriding account_for_venue works; K5
with hour median None is 'clear' (median_not_evaluable) so short tapes are fine. tests/execution test modules import
each other absolutely (`from test_paper_step import ...`). Prototypes /tmp/sw739 (node_positions.py, node_quotes.py,
scen*.py; backup/ holds the six drafts).

LEFT for 7.2 / 8.4: flatten at the broker for K1 / K2 / K11 'cerrar todo' (open design point: a close order needs a
client id OUR_ID_RE accepts - today only -E/-S/-T - else reconcile sees a foreign fill; nautilus_snapshot is 8.11's),
the cycle composition (recover -> gate -> marks -> inputs -> decide_at -> place -> store lines -> board -> status)
and the TradingNode itself (ibapi ask). Next free ids 7.45 / 8.15.

**Why:** the next writer must not re-measure the Cache facts nor re-split the cycle; 7.42 depends on 7.39, 7.44 on 7.37.
**How to apply:** `git log --oneline -10 -- tasks/`; check which of 7.39-7.44 landed. See
[[ib-node-second-refill-2026-11-04]], [[ib-paper-node-pieces-refill-2026-11-04]].
