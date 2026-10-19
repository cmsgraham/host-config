---
name: queue-refill-autostash
description: "2026-10-07 fix for idle GPUs - automatic spec-writer refill below a low-water mark, and merge-gate autostash of operator edits"
metadata:
  node_type: memory
  type: project
  originSessionId: 1e08dd12-044d-459f-8438-708c6962279f
  modified: 2026-10-07T13:48:50.027Z
---

Built 2026-10-07 (agent-ci 55d734e) after the fxplat queue ran dry twice (4 h 47 min one night) and a
passed task's merge was refused behind an unstaged edit I left in ~/Dukascopy.

- `execution.queue_low_water` / `queue_refill_cmd` / cooldown / timeout: below the mark of RUNNABLE tasks
  (not passed, not held, not awaiting a person, deps runnable) the loop starts the refill detached, writes
  state/QUEUE_LOW.json + state/refill.json, logs/refill-*.log, and WAITS instead of exiting. `status` shows `queue:`.
- fxplat: low water 4, cooldown 90 min, refill = headless Claude following docs/SPEC_WRITER.md (drafts with
  hold "draft, under review", spec-review, applies findings, commits only the task file). APPROVED by Cristian
  2026-10-07 (the auto-mode classifier blocks configuring this without the user's explicit yes).
- `git.autostash_foreign` (default on): stray tracked edits in the integration tree are stashed for the merge
  gate and restored; a conflicting restore stays in `git stash list`.
- Subagent drafting worked well: 3 parallel agents drafted 3.17/3.18/3.26/3.27, each spec-review OK first try.
  A subagent cannot release a hold on approval relayed by me (classifier) - release holds myself.

**Why:** the user's top concern is GPUs never idle and no production stops.
**How to apply:** check `status` queue line and logs/refill-*.log; if refills start producing BLOCKed or
bad specs, tighten docs/SPEC_WRITER.md rather than disabling it. See [[agent-ci-failure-modes]],
[[fxplat-phase3-specs-2026-10-06-decisions]].

Dashboard trap (same day): the fxplat dashboard on :8767 is a plain nohup process (not a unit) and kept running
pre-`hold:` code; once a task file used `hold:` its task list failed to load ("unknown keys") and the gateway page
showed only history (2 statuses, 2 resolutions, "2.21 is the last task"). After any agent-ci change that adds a
task/config key, restart the dashboards: `agent-ci --config ~/Dukascopy/config.yaml dashboard --port 8767`.
