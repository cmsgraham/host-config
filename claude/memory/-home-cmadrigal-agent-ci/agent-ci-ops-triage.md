---
name: agent-ci-ops-triage
description: 2026-10-11 agent-ci got phone alerts (ntfy) + automatic headless-Claude triage after Cristian found stalls only by asking; how it works and its limits
metadata:
  type: project
---

Built 2026-10-11 (agent-ci d652eb8) because Cristian kept discovering stalls only when he asked
("not conceivable"). Each watchdog pass (15 min) now runs agent_ci/ops.py:
- cases: HUMAN_REQUIRED past 45 min grace (not an operator stop), merge refused (unmerged.json,
  not "pending"), spec-review BLOCK / diagnosis holds, no merge for 180 min with work ready;
- one triage at a time (cooldown 30 min, 6/day, 60 min timeout) = headless Claude following
  ~/agent-ci/docs/TRIAGE.md: may edit tasks/*.yaml + decisions file and `agent-ci retry`;
  never src/tests/config/worktrees/approvals/data, never git stash/reset/plain commit;
- ntfy push alerts: triage started/done (report first line RESULT: ...), NEEDS DECISION headers
  of state/decisions-pending.md, gateway/GPU/wedged-run, digest 07:00 + 19:00.
Topic in ~/.config/agent-ci/ntfy.env (600, never in chat/repo; sent to his phone as a file).
Supervisor fix: only a PERSON's STOP ends a task between attempts (a watchdog restart stop
had cut TASK-3.68's escalation). CLI: agent-ci ops | retry <id> | notify <title> <msg>.

**Why:** user goal is minimal human intervention and he must hear about problems first.
**How to apply:** when he asks "how is it going", check `agent-ci ops` and state/triage/*.md
too; if triage misbehaves, tighten docs/TRIAGE.md rather than disabling it. See
[[user-goal-autonomous-devinfra]], [[watchdog-role]].
Quiet hours (Cristian 2026-10-11: "no alerts overnight, resume at 6.45 CR"): ops.quiet_hours '21:00-06:45' in
fxplat config; notify.post holds alerts in state/notify-quiet.json and the first watchdog pass after 06:45 sends
ONE "overnight: N alert(s)" summary. Don't SendUserFile / ping him overnight either.

**2026-10-25 alert sweep (operator: "only really needed alerts"):** agent-ci 2729fed: tests block real ntfy (my
suite paged 'proj: loop down'), own-restart start skips the action budget, VALIDATING with a live check = 120 min
before wedged, spec_blocked pages after 6 h, gone cases close silently, triage started/done are PRIO_LOW.
~/.local/bin/fxplat-health (backup .bak-20261025): marketlive/swfxempty/swfxfail skipped while FX is closed
(Fri 17:00 - Sun 17:00 NY), ollama-gateway dropped (watchdog gateway_down covers it). Kept loud: needs-you
triage, gateway, gpu_pv, failed loop start, real wedge, usage pause, decisions, health problems, paper latches.
Relax experiment: 15.21 sends one finish/FALLO alert; the 15.20 run wrapper must call agent-ci notify on failure.
