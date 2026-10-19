---
name: focus-fxplat-2026-10
description: since 2026-10-04 the only live agent-ci project is fxplat (Dukascopy); other projects stopped; 2026-10-05 local-tier A/B started (27b builder, action policy, interpreter rule, own-tests repair) after 30/30 tasks needed escalation
metadata:
  node_type: memory
  type: project
  originSessionId: e2e1e562-e852-469b-98e4-f8f9b218520e
  modified: 2026-10-05T04:22:43.253Z
---

On 2026-10-04 the user said: focus on fxplat (`/home/cmadrigal/Dukascopy` since 2026-10-05, see [[fxplat-in-wsl]], dashboard `agent-ci-dashboard-fxplat.service`
on 127.0.0.1:8767, watchdog `agent-ci-watchdog@Dukascopy.timer`), stop everything else.
- `agent-ci-watchdog@snoopy_frog-v3.timer` was DISABLED (it had logged "no progress for 17 days" 1709 times; all 98 tasks passed, queue empty).
- `agent-ci-dashboard.service` (x-scraping, :8765) and `agent-ci-dashboard-v3.service` (snoopy_frog, :8766) were STOPPED but left enabled, so they return after a WSL reboot. The gateway's agentci page tolerates an unreachable project (its fetch returns None).
- Merged task worktrees were pruned in x-scraping (37) and snoopy_frog (124); the Dukascopy prune and the orphaned TASK-1.13 tmux session (`tmux -L openhands`) were left for the user because the auto-mode classifier refused deletions in the live project.

**State of fxplat on 2026-10-04:** 16 tasks passed, every one needed an escalation first (escalation 120 min vs build 75 min; 17M escalation prompt tokens). max_attempts 1, contour routes big specs straight to the strong tier. Phase 0 done, Phase 1 in progress (TASK-1.4 went HUMAN_REQUIRED 22:01 and is in escalation). The watchdog restarts the auto loop from its own oneshot cgroup (KillMode=process), so "left-over process" journal lines are expected.

**How to apply:** do not start work on snoopy_frog or x-scraping without asking; x-scraping still has 13 task YAMLs moved to tasks/completed but uncommitted, Chrome-extension edits uncommitted, and an unacknowledged DRIFT phase-6 review. See [[fxplat-80b-hand-registered]], [[open-threads-2026-09-08]], [[watchdog-role]].

**2026-10-05 ~07:30, the local-tier A/B (user decision "fix this mess"):** baseline 30 tasks landed, 30 via
escalation, qwen3-coder:30b 0 of 23 local attempts, escalation rewrote 85-95% of its code. Changes:
fxplat builder = `qwen3.8:27b` (full 262144 window; a 163840 pin on 2026-10-05 rested on a wrong KV estimate,
measured 23.0 GB resident at 163840); `security.action_policy: true`; gateway interpreter rule (bare python/pytest/pip/ruff refused
when the worktree has `.venv`; replay: 120 of 570 recorded calls); agent-ci `execution.repair_own_tests`
(one local repair when only the attempt's own tests/lint fail). Judge after ~10 tasks with
`agent-ci stats`: local pass rate vs 0/23, escalation reliance vs 100%, build minutes. If the 27b does
not move the number, the next lever is routing everything strong_direct (contour.local_max: 0).

**First data point, 2026-10-05 08:57:** TASK-2.5 PASSED on the 27b's first local attempt (45 min, 51 turns,
1 veto: a bare `ruff` in a chained command, re-planned correctly), reviewer APPROVE. The first task this
project ever landed without an escalation (previous record 0 of 23). The 27b re-runs its own tests,
checks fixtures and runs the full suite before returning control; the 30b declared done without a working
test setup. Keep counting: `agent-ci stats` escalation reliance should fall below 100%.
