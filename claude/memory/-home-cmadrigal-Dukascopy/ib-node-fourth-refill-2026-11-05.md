---
name: ib-node-fourth-refill-2026-11-05
description: "Spec-writer refill 2026-11-05 ~01Z — six IB-node composition pieces for the TASK-7.2 / 8.4 stubs: 7.45 node_switches (manual flatten REQUEST, never a close order) / 7.46 node_view / 7.47 node_start / 7.48 node_resume / 7.49 node_decide / 7.50 node_tail; the flatten design point RESOLVED by the registered rule (no -F client id); measured numbers (fixture F verdicts, Cache view, recover on empty Cache, stub enter needs all seven majors quoting); what is left"
metadata:
  node_type: memory
  type: project
  originSessionId: refill-20261105-011714
  modified: 2026-11-05T01:40:28.123Z
---

Refill 2026-11-05 01:17Z (runnable 4.53 / 4.54 / 8.13 / 8.14 < low water 6; no drafts; both 2026-11-04 RESOLVED
decisions already fully specified by 4.48-4.54 / 11.64 / 3.156 / 16.85-16.87; main 52a4781). Source = brief item 1:
the 7.2 / 8.4 stubs' "STILL TO SPECIFY" (flatten at the broker, per-cycle composition, G8 wiring).

DESIGN POINT CLOSED: "flatten at the broker for K1 / K2 / K11" needs NO -F client id and NO nautilus_snapshot change.
PHASE3_PLAN §7 (2026-10-08) registers "a kill switch that cancels orders cancels entries only and NEVER the protective
bracket stops; flattening stays a manual decision", reaffirmed 2026-10-14 item 2 ("simulator only; the 2026-10-08
'flatten is manual' rule stands for real paper / live"). So the node cancels OUR entries in the blocked scopes
(OrderMixin.cancel_entries) and appends a flatten REQUEST line (flatten_requests.jsonl, action 'manual'); a person closes
at the broker; K6 then reviews. G8 wiring = node_gate (8.14) dispatches by settings.mode, nothing more.

Written (hold "draft, under review" first; all six valid; reviews started together ~02:35Z; generator /tmp/sw745/gen.py
+ specs.py, backups /tmp/sw745/backup):
- 7.45 node_switches (deps []): accepted_k3 / k3_rebase (paper_runner._switch_step's K3 rule), switch_verdict
  (evaluate -> decide -> flatten_due), blocked_scopes, live_event_ids, flatten_request_line, append_flatten_request,
  SwitchMixin.apply_switches (cancel_entries + request line, never a close order).
- 7.46 node_view (deps []): NodeView; view_at (7.40 readers + 7.41 equity; missing = ids - has_bar only when bar_t set),
  candidates_at (paper_runner._candidates: pairs without H1 bars contribute nothing; stub_candidates RAISES on ()),
  entry_states (duck-typed cache.order; fresh order status 'INITIALIZED').
- 7.47 node_start (deps []): thresholds(settings) = Thresholds(120_000, 120_000, max_broker_age_ms, max_clock_drift_ms);
  seed_host (store -> brackets()/fills(), refused when non-empty); recover_host (recover over host.internal_book(),
  fills_since_ms = last fill ts inclusive, recovery line appended, health written).
- 7.48 node_resume (deps 7.47, 8.14): gate at stage 'start' always logged; resubmission of every stored bracket with
  view_complete=True only when recovery AND gate allow; instruments checked before anything is sent.
- 7.49 node_decide (deps 7.46, 8.14): InputsExtra; mark_equity; node_rows; switch_inputs; decide_cycle (due -> the view
  AT the bar via view_at(now_ms=bar_t) -> decide_at -> decision lines -> gate 'order' only when contexts -> place ->
  bracket lines -> board); error path 'decision:<Type>' leaves last_decision_ms and board untouched.
- 7.50 node_tail (deps 7.45, 7.49): releases read -> k3_rebase -> switch_inputs at now -> switch_verdict ->
  apply_switches -> flatten request append -> board written with releases consumed.

MEASURED 2026-11-05 (/tmp/sw745/measure*.py; .venv, PYTHONPATH=src, sys.path tests/execution):
- fixture F (T 1791982800000): clear -> state () flatten (); stop_requested -> ('K11',); 3 x 'rejected' outcomes ->
  Latch('K7','global',T,'streak:3'); marks [5000, 4890] -> ('K1',) K2 clear. Release K3 on empty board -> rejected
  'not_latched'; on a K3 latch -> released; by='nobody' -> 'releaser_not_allowed'. fecha_hora_pa(T) =
  '2026-10-14T08:00:00-05:00'. Host(_three_leg_cache()).cancel_entries({'global'}) -> (G+'-E',).
- node_quotes cache at TQ 1_772_460_000_000 (+ margin account): bar_t TQ, has_bar {EURUSD}; USDJPY missing_bars 1
  (200 s old tick); feed_up 120 s True / 5 s False; daily_close (3, 2) index 02-27..03-01; equity 1,000,000; bar_rows
  301 rows; candidate SIM-8a17c6ac55f39253; stub at TQ-1h -> 0 rows.
- recover(Cache(), empty book, NOW 1_772_490_600_000, broker_state NOW-5000, drift 250): planned_gateway_restart allowed,
  crash -> ('not_approved',); freshness w/o market/risk ms -> ('market_data_missing','risk_state_missing'); FakeCache
  -> error 'ValueError: cache: expected Cache, got FakeCache', reasons ('not_reconciled','not_approved').
- K4 fires unless ALL SEVEN majors have a quote <= 120 s old (symbols=MAJORS) and every pair has the decision bar
  (missing_bars). Fixture SEVEN (seven instruments, one tick each at TQ-10 s, one H1 bar at TQ for the six, EURUSD
  300-bar series, 80 D1 EURUSD closes): stub ENTERS - units 25000, entry 1.1003, stop 1.09835, target 1.10425, group
  fx-1a284cf8cd5206527b5b, atr 0.0009915614151017917, m 2.0; place -> ('placed',); row 'pending' at TQ+5 s.
- bracket_states (8.12) needs a REAL Cache (FakeCache raises) -> resubmission tests use test_node_resubmit.cache_with;
  empty cache -> all 'submit' 'never_reached' (ONE OrderList); legs accepted -> 'none' 'in_place'; view_complete False
  -> 'wait' 'view_incomplete'.

REVIEWS 2026-11-05 ~01:40-02:00Z: 7.46 / 7.48 / 7.50 OK round 1 (lows applied, --accept-amended); 7.45 / 7.47 BLOCK
round 1 -> OK round 2 (7.45: NO pair-scoped Latch exists - every latching switch K3/K6/K7/K8/K10 is global in
switch_board.REQUIRED_SCOPE; 7.47: test_node_store.CTX group != test_node_positions.G 'fx-bd1a2a2030cbc6e612f1' -
never mix their fixtures); 7.49 BLOCK twice (round 1: EXTRA must use TASK-8.14's H hashes because the G7 text cites
H['code'] - FROZEN gives 'approval_frozen_code_mismatch'; a decision at bar T reads only marks <= T, so append a mark
at T before a later poll; round 2: position_rows applies reanchor stops only to FILLED rows; the second poll needs the
first poll's record read back via from_json_line). Round-2 findings APPLIED to 7.49 but NOT re-reviewed -> hold
'draft, under review: BLOCK unresolved'; 7.50 (OK) held because it depends_on 7.49. Commit script
/tmp/sw745/commit_when_clear.sh (detached, log /tmp/sw745/commit.log) commits 7.45-7.48 hold-free and 7.49 / 7.50 WITH
their holds once the 4.53 gate clears. NEXT WRITER (brief item 1): spec-review TASK-7.49 once, lift it, then lift 7.50.
Reviewer traps this round: paper_store.append_lines does not mkdir (tests must create out_dir); test_node_store's
settings() does not create out_dir either; write_g7 does not mkdir the approvals dir.

LEFT for 7.2 / 8.4: the daily reconcile inside the node (8.13 wiring: daily_due -> reconcile_cache -> daily_check ->
board update -> 'reconciliation' line -> cancel entries on K6), the status + health writer per poll (7.43 status_text /
7.38 health over the poll), the Strategy composition (on_start = seed_host -> recover_host -> resume_host; on_timer =
view_at -> decide_cycle -> tail_cycle; timers) and the TradingNode itself (ibapi ask 001cd70c still pending). Next
free ids 7.51 / 8.15.

**Why:** the next writer must not re-measure these, must not reopen the flatten design point, and must know the
dependency chain 7.47 -> 7.48, 7.46 -> 7.49 -> 7.50 (7.45 -> 7.50), with 8.14 under 7.48 / 7.49.
**How to apply:** `git log --oneline -8 -- tasks/`; `agent-ci status` for 7.45-7.50. See
[[ib-node-third-refill-2026-11-04]], [[ib-node-second-refill-2026-11-04]], [[merge-gate-wipes-uncommitted-task-edits]].
