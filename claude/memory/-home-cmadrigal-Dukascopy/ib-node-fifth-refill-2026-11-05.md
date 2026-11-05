---
name: ib-node-fifth-refill-2026-11-05
description: "Spec-writer refill 2026-11-05 ~05Z — lifted 7.49 / 7.50 (third review OK) and wrote four more IB-node pieces for the TASK-7.2 / 8.4 stubs: 7.51 node_daily (daily reconcile + K6 latch, board written BEFORE cancel), 7.52 node_status (health + status per poll), 7.53 node_context (hashes / StepConfig / K13 marks / K8 model slip / InputsExtra / instruments), 7.54 node_records (decisions log -> records); measured numbers; YAML-escaping trap of the generator; what is left (the poll composition 7.55 needs a prototype of 7.49-7.54)"
metadata:
  node_type: memory
  type: project
  originSessionId: refill-20261105-044719
  modified: 2026-11-05T05:37:52.222Z
---

Refill 2026-11-05 04:47Z (runnable 4.54 / 7.48 / 8.13 / 8.14 < low water 6; drafts 7.49 BLOCK-unresolved + 7.50 OK-held).
1. 7.49: third spec-review OK (one medium: tests must mkdir settings.out_dir because node_marks.append_mark does not;
   approvals dir created by the test) -> applied, --accept-amended, hold lifted, committed 6c50e97; 7.50 lifted, ccb3327.
2. Four new drafts (generator /tmp/sw751/gen.py + specs.py, backups /tmp/sw751/backup, measurements /tmp/sw751/m1-5.py):
   - 7.51 node_daily (deps [8.13]): last_reconcile_ms = node_store.last_ts_ms over the reconciliation log (no remembered
     state); fills_since_ms (7.47 rule); daily_cycle: daily_due -> pending_changes() defers -> reconcile_cache(broker_state_ms
     = now_ms) -> daily_check -> append line -> switch_board.update latches K6 -> write_board BEFORE -> apply_switches (entries
     cancelled, no flatten line). K6 is manual-release with MANUAL_RELEASERS['K6'] None = any principal.
   - 7.52 node_status (deps []): market_data_ms = freshest quote; poll_health -> health_record + freshness(thresholds) +
     write_health; status_counts; write_poll_status (last_decision_ms = the BOARD's).
   - 7.53 node_context (deps [7.49] for InputsExtra): node_hashes (manifest at settings.manifest_path), cost_ticks,
     step_config, read_marks / extraordinary_at (paper_runner rules), model_slip for CLOSED rows = pips*10*point*size*upu
     (entry order only, 7.39 basis), build_extra (thin False, STOP file), instruments_of.
   - 7.54 node_records (deps []): decisions.jsonl -> Records(records, enter_ids, torn); torn-last-line rule; duplicate
     event_id refused.
   All four review OK round 1 (route local; lows applied, --accept-amended) and committed hold-free 2025674 / 4683348 /
   75d1f72 / f2dd890 after the 4.54 + 8.13 gates (8.13 merged 730ef90: daily_reconcile names verified against 7.51).
   The poll composition (7.55: view_at -> decide_cycle -> tail_cycle -> daily_cycle -> poll_health/write_poll_status,
   errors 'decision:'/'switches:'/'reconciliation:') and the Strategy/on_start/on_timer need a PROTOTYPE of 7.49-7.54 to
   measure e2e numbers -> next writer, after they merge. ibapi ask still pending (TradingNode).

MEASURED 2026-11-05 (PYTHONPATH=src, sys.path tests/execution): empty Host(Cache()) reconciles clean; brackets {G: CTX}
+ fills [FE] (test_node_positions) over Cache() -> Finding('position_mismatch','EURUSD','','broker units +0 differ from book
units +5000'), k6 True, latch Latch('K6','global',T1730,'position_mismatch:EURUSD:'); clear evaluation keeps a K6 latch; a
pending group whose legs are accepted in a real cache is clean; test_node_resubmit cache_with(*legs()) + accept -> only
GR+'-E' cancelled. Health: quotes 5 s old, drift 250, broker T-5s, risk T -> allowed; all None -> five missing/unknown
reasons; broker T-60_001 -> broker_state_stale. Status string pinned in 7.52 (c). Cost model v4: every major slippage
pips 0.5; ticks == test_paper_step.TICKS; closed EURUSD 5000-unit row model slip 0.25 (real 0.49999999999994493); bps 2.0
-> 1.1001. current_hashes on a tmp git repo == commit; pin_manifest -> frozen == current; untracked src file -> 'dirty:'.
k13 mark 'nfp-1' active at T for EURUSD/USDJPY, '' one ms before the window and before marked_ms. Cache().instrument(id)
is None for an unknown instrument. from_json_line('{}') and a truncated line raise ValueError.

TRAP (generator): Python `"..."` req strings containing `"` or `\n` -> escape for YAML in gen.py (yq: backslash ->
`\\`, quote -> `\"`) and write `\"` inside the Python string; a blanket replace broke both. Validate with yaml.safe_load
AND check no raw newline in requirements before `agent-ci tasks`.

**Why:** the next writer must not re-measure, must know 7.49-7.54 are queued (7.49/7.50 deps 8.14 / 7.49), and that the
poll composition is the remaining piece.
**How to apply:** `git log --oneline -8 -- tasks/`; `agent-ci status` for 7.49-7.54. See [[ib-node-fourth-refill-2026-11-05]],
[[merge-gate-wipes-uncommitted-task-edits]].
