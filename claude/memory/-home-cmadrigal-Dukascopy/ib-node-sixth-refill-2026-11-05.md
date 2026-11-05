---
name: ib-node-sixth-refill-2026-11-05
description: "Spec-writer refill 2026-11-05 ~07Z — the IB node's composition chain for the TASK-7.2 / 8.4 stubs: 7.55 node_poll (one poll from a view), 7.56 node_lifecycle (start_node + resume_approval.json), 7.57 node_review (release / approve CLI), 7.58 node_cli (pin / check), 7.59 node_host (NodeRun, broker_state_ms, clock_drift.json, NodeMixin.node_start / node_poll), 7.60 node_strategy (the Nautilus Strategy, TestClock-tested); measured facts (restart_ms vs broker state, Strategy registration without an engine); what is left (TradingNode behind the ibapi ask)"
metadata:
  node_type: memory
  type: project
  originSessionId: refill-20261105-072108
  modified: 2026-11-05T08:07:11.358Z
---

Refill 2026-11-05 07:21Z (runnable 7.48 / 7.49 / 7.50 / 7.53 / 8.14 < low water 6; no drafts; 7.51 / 7.52 / 7.54 merged;
main fc3889b). Source = brief item 1, the 7.2 / 8.4 stubs: the fifth refill left "the poll composition (needs a prototype)
+ the Strategy + ibapi". No prototype was needed: the poll takes the VIEW as an argument, so its quiet-poll numbers come
from the merged pieces, and every other number is a spec-level fact of 7.49 / 7.50 / 7.53.
Generator /tmp/sw755/gen.py + specs.py (7.55-7.57) + specs2.py (7.58-7.60), backups /tmp/sw755/backup, measurements
/tmp/sw755/m_quiet.py m_start.py m_start2.py m_rest.py, review logs /tmp/sw755/review-7.5x.log.
- 7.55 node_poll (deps 7.49, 7.50, 7.53): poll_once(host, settings, view, *, records: Records, extra, board, config, ...,
  reconciled, broker_state_ms, clock_drift_ms) -> PollReport; decide_cycle -> tail_cycle (try: 'switches:<Type>') ->
  daily_cycle (try: 'reconciliation:<Type>') -> rows_after -> poll_health(risk_state_ms = now only when tail succeeded) ->
  write_poll_status(torn={'records','releases','reconciliation'}).
- 7.56 node_lifecycle (deps 7.48): start_node = seed_host -> read_resume_approval (out_dir/resume_approval.json, keys kind/
  approved_by/ts_ms/broker_state_ms) -> recover_host (last_decision_ms from the board) -> resume_host; broker_state_ms None
  REFUSED (recover_host raises on it). KEY FACT: resume_gate treats broker_state_ms < restart_ms as remembered state ->
  'broker_state_missing'; the approval must cite THIS broker_state_ms and be dated >= it and <= now.
- 7.57 node_review (deps []): release_line (K3/K6/K7/K8/K10 only, scope 'global', by in SIGNER_PRINCIPALS values, K3 only
  rodrigo.murillo-herrera), append_release (mkdir: paper_store.append_lines does NOT), approval_text / write_resume_approval
  (once; --replace), CLI release|approve. No release writer existed in src before.
- 7.58 node_cli (deps 8.14, 7.53): pin (paper_runner._pin mirrored) and check (gate at 'start' WITHOUT appending; exit 0/3/2).
- 7.59 node_host (deps 7.55, 7.56): NodeRun; build_run loads load_quality_config().calendar (fxplat.quality.checks) +
  load_cost_model(); read_clock_drift(out_dir/clock_drift.json {ts_ms, drift_ms}, stale -> None); broker_state_ms = max(last
  order event ms, account.last_event.ts_event // 1e6); NodeMixin.on_order_event / on_fill_recorded (append 'fills') /
  node_start / node_poll. Tests monkeypatch node_host.node_hashes -> Hashing(H, H) (tmp repo is not git; G7 text cites H).
- 7.60 node_strategy (deps 7.59): NodeStrategyConfig(settings_path, repo_dir, approvals_dir, venue, restart_kind,
  restart_ms REQUIRED = launcher's process start, poll_s 15); NodeStrategy(NodeMixin, Resubmit, Reanchor, Switch, Cycle,
  Book, OrderMixin, Strategy); on_start -> node_start or stop(); on_timer -> node_poll or stop().

MEASURED 2026-11-05 (nautilus 1.231): a Strategy subclass registers with Strategy.register(trader_id, portfolio, msgbus,
cache, clock) over TestClock / Cache / MessageBus / Portfolio (no engine); start() runs on_start; set_timer in on_start fires
via [h.handle() for h in clock.advance_time(ns)]; stop() inside on_start or a timer callback -> STOPPED, timer_count 0;
an exception in on_start PROPAGATES out of start(); handle_event order = on_order_accepted -> on_order_event -> on_event;
MarginAccount(AccountState(... ts_event=NOW ns)).last_event.ts_event // 1e6 == NOW; view_at over an account-only Cache =
NodeView(T, {}, {}, {}, False, None, frozenset(), empty df, 1e6) -> K4 fired, verdict state () flatten (). Quiet poll at T
(seven quotes 5 s old, bar_t None, equity 5000, empty host): one mark, clear verdict, daily not due (09:00 PA), files
['board.json','health.json','marks.jsonl','status.json']; status string pinned in 7.55 (a). test_node_orders.Base has
only cancel_order / submit_order_list (no fill hooks, no order_lists) - use test_node_resubmit.Base for hosts that submit.

HASH-FORM DEFECT (7.59 round 2, strong reviewer): current_hashes gives code = 40-hex commit (or 'dirty:'+commit);
node_store.mode_text and paper_store.record_hashes NEED the commit; paper_gate (G7, via node_gate) needs 64-hex K9 values
and the approval's FROZEN_CODE hash == frozen['code'] -> no single map serves both. Registered node_host.gate_hashes(Hashing)
= {'code': sha256_bytes(code.encode('ascii')), config, model} (dirty prefix NOT dropped -> K9:code fires); node_start refuses
a dirty code before start_node; step_config keeps the commit form; build_extra / the gates get the gate form. Tests mock
node_hashes -> Hashing(HC, HC) with HC = {'code': COMMIT, ...H config/model} and write_g7c = write_g7 with A7.replace(C, GC),
GC = sha256_bytes(COMMIT.encode('ascii')) = 50ba47be... (test_node_gate's A7 is FIXED, cites C = H['code']). 7.58 check()
now uses gate_hashes too (deps += 7.59). 7.59 left HELD "BLOCK unresolved" with the fixes applied (routine: one fix round) ->
next writer: spec-review TASK-7.59 once, lift; 7.60 depends on it.

FINAL STATE 2026-11-05 ~08:10Z: 7.55 / 7.56 / 7.57 review OK, hold-free; 7.58 / 7.60 review OK but HELD "lift only after
TASK-7.59 is re-reviewed, lifted and MERGED" (reviewer lift condition; both import 7.59's gate_hashes / HC / GC / write_g7c);
7.59 HELD "BLOCK unresolved" (fixes applied). Commits by /tmp/sw755/commit_all.sh (detached; log commit_all.log) after the
7.48 gate - `git add -f` because .git/info/exclude line 14 (/tasks/**) hides untracked tasks/ during the gate. NEXT WRITER:
spec-review TASK-7.59 once -> lift -> after it merges lift 7.58 and 7.60 (re-check the names). GOTCHA: `pkill -f <pattern>`
kills the calling Bash when the SAME command line also contains the pattern literally (e.g. a relaunch after the kill);
kill and relaunch in separate calls. gen.py re-adds `hold: "draft, under review"` on every regen -> restore hold-free files
from backup/ afterwards (the waiter copies backup/ over tasks/ before committing).

LEFT for 7.2 / 8.4: the TradingNode + IB client configs + `run` launcher (ibapi ask 2026-11-04 still pending; rec (b)/wait),
the operator-side clock-drift probe (deploy), a Forward export of the node folder (no node runs yet). Next free ids 7.61 / 8.15.

**Why:** the next writer must not re-measure these, must know 7.55-7.60 are queued (chain 7.55/7.56 -> 7.59 -> 7.60) and
that the only unspecified piece is the ibapi-bound TradingNode.
**How to apply:** `git log --oneline -8 -- tasks/`; `agent-ci status` for 7.55-7.60. See [[ib-node-fifth-refill-2026-11-05]],
[[merge-gate-wipes-uncommitted-task-edits]].
