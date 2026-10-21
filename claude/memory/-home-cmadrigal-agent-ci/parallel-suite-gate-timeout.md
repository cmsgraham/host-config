---
name: parallel-suite-gate-timeout
description: "My own full-suite runs (agents, probes) starve the fxplat merge gate; suite-green hit its 1800 s timeout at 83% with zero failures and TASK-3.113 was refused; always nice -n 19"
metadata:
  node_type: memory
  type: feedback
  originSessionId: 0c1852ef-3212-4405-b486-5cda3eb63786
  modified: 2026-10-17T02:49:14.180Z
---

2026-10-16 20:47: a cost-v4 probe subagent ran two full fxplat suites with xdist (~15 cores) while the merge gate ran
its own; the gate's `suite-green` TIMED OUT (1800 s, 83%, no failure) and TASK-3.113 was refused as "fails once
combined with main". Recovered with renice 19 on the probe + `agent-ci retry TASK-3.113` after it finished.

**Why:** the gate's suite has a hard 30-min timeout and no CPU reservation; anything heavy I start competes with it.
**How to apply:** any test suite or heavy job I or a subagent run on this box while the loop is live goes under
`nice -n 19` (tell subagents explicitly, and cap xdist workers, e.g. `-n 4`). When a gate refusal says suite-green
failed, check validation.json for `timed_out: true` before treating it as an integration bug. Related:
[[merge-pending-race]], [[runaway-background-search]].

**Again 2026-10-21 09:xx CST:** my xdist trial agent (-n 8) + a statistics prototype (4 procs) pushed load to ~60;
TASK-3.142's merge gate timed out at 3600 s and was REFUSED (retried). Rule for agents: check for an active merge
gate (`agent-ci status | grep '^merge gate:'` / .git/MERGE_HEAD) before any heavy run, cap workers, single-thread BLAS.

**2026-10-21 fix landed (c3e0c4f):** the full suite now runs on 6 xdist workers (--dist loadfile, native threads
capped at 1) via tests/_plugins/fxplat_parallel.py (auto-on for a whole-suite run when xdist is installed; per-file
checks stay serial). 3 clean runs, ~9 min vs 23-36. Fallback: FXPLAT_XDIST=0 in the supervisor env (or =N). Floor =
tests/validation/test_discovery_motif_search.py ~305 s. Also max_parallel_tasks 2 (f5d3c33).
