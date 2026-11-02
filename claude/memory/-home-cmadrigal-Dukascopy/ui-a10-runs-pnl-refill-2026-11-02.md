---
name: ui-a10-runs-pnl-refill-2026-11-02
description: "2026-11-02 11:38Z refill: UI-A10 parts 2 + 3 = 9.12 fxplat.publish.runs (Run monitor summary + index from run_events Envelopes, silence-only stale rule) / 9.13 fxplat.publish.pnl (realised equity/drawdown at exit from closed 'enter' decision_log records + exits map); family-4 grammar ask sent (key decision:family4-grammar, (a) 21 cond m 4548 z 4.570); next free 9.14 / 11.64 / 15.43 / 16.82"
metadata:
  type: project
  originSessionId: refill-20261102-113814
  modified: 2026-11-02T11:59:53.935Z
---

2026-11-02 11:38Z refill (runnable 11.60-11.63 + 16.81, low water 6). Every RESOLVED decision was already specified;
asks pending: positioning-asof-fix, family3-grammar, fsv2-counting (family1-grammar + fondeo-floor-equality expired
at 'wait'). NEW SOURCE found (SPEC_WRITER step 4, UI-A rows): docs/UI_DESIGN.md §11 row UI-A10 "run events +
decision records + P&L series" was only 1/3 written (TASK-9.11 decisions). So:
- 9.12 fxplat.publish.runs (deps 9.1, 3.60): summarize_run(events: list[run_events.Envelope], *, now_ms,
  stale_after_ms=900000) -> RunSummary (cells (symbol|None, stage) replayed by seq like ui/src/data/runEvents.ts,
  counts, last/peak rss, segments '%Y-%m' pattern) + build_runs -> RunsPayload (running first, -started_ms, run_id).
  *reading: state by SILENCE ALONE (runEvents.ts keeps 'running' while a cell runs because it also has the 60 s
  live.json); no prose (warning text / failure reason / report_path stay in the events file the bundle copies).
  Hand values in /tmp/p912 (runs.py + scen.py). Review OK r1 (2 low: (g) k=1 has no k-1 prefix; title abridged).
- 9.13 fxplat.publish.pnl (deps 9.1, 9.11): build_pnl(records, exits{event_id: (ts_fill_ms, t_exit_ms)}, *, run_id,
  role, start_balance_usd, usd_per_r, mode, limit): equity/drawdown per closed trade in (t_exit_ms, event_id) order,
  n_open for open enters, by_symbol / by_exit / 5 CostRow, trades newest first. decision_record FACTS: costs_r None
  -> {} and ANY keys accepted; planned_stop must be on the losing side (shorts need stop > entry); closing group
  all-None or all-set. Hand values binary fractions in /tmp/p913 (pnl.py + scen.py); empty JSON 594 chars.
- Ask sent 12:0xZ: decision:family4-grammar (a) 21 cond 2016 cells m 4548 z 4.570 / (b) 46 cond m 6948 z 4.667 /
  wait; section appended to state/decisions-pending.md. z from fxplat.synthetic.bench_hz.rank1_z(0.10, m).
- COMMITTED 9.12 2793a94 (12:0xZ, after the 11.60 gate) + 9.13 1f86563 (12:05Z, no gate), tree clean. Gate for 11.61 then 11.60 running most of the session -> /tmp/p912/commit_when_clear.sh <id> <backup> <msg> (waits
  for MERGING.json, cp backup over tasks/<id>.yaml, git add -f, commit -- file).
- Left in UI-A10: nothing pure; the publish command (reading run dirs / labels, copying events, writing the bundle)
  is UI-A2's / operator's. Other unwritten sources still blocked: grammar tasks (3 asks), fsv2 wiring (ask),
  positioning.asof fix (ask), perps liquidation tiers (web), CME note (docs), fondeo item 4 (floor ask).

**Why:** the next writer must not re-derive the two exporters' rules, must know UI-A10 is now fully specified, and
must reuse the commit-when-clear pattern while gates run back to back.

**How to apply:** `git log --oneline -3 -- tasks/TASK-9.12.yaml tasks/TASK-9.13.yaml`; if 9.13 is missing, finish
from /tmp/p913 + logs/spec-review-TASK-9.13-*.md. Related: [[scan-room-and-trader-wiring-refill-2026-11-02]],
[[merge-gate-wipes-uncommitted-task-edits]], [[real-run-task-ids]].
