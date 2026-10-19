---
name: watchdog-role
description: "The watchdog added 2026-09-06 after a lost night; deterministic checks + bounded actions, installed as a systemd user timer per project"
metadata: 
  node_type: memory
  type: project
  originSessionId: 29d5414b-faf8-42b4-a2dd-34f618e19471
  modified: 2026-09-06T16:33:21.019Z
---

Built 2026-09-06 after a night where a refused restart left an old supervisor
running (nobody checked the pid changed), the old code could not merge, and
one task passed 34 times in eight hours unnoticed.

`agent_ci/watchdog.py` + `agent-ci watchdog [--once] [--fix]`. It asks NO
model anything: every failure of that night was mechanically detectable.
Checks: lock held by a dead pid, loop down with work eligible, escalation
marker whose process died, active run with no events for N minutes, **a
supervisor started before the current commit (stale code)**, gateway
unreachable, nothing landed in N minutes. With `--fix` it clears stale
markers, starts the loop, and asks a stale-code loop to stop at the next
boundary; actions are capped (`max_actions_per_hour`, default 4) so a crash
loop cannot become a restart loop. Reports append to `state/watchdog.jsonl`.

Installed as user units: `~/.config/systemd/user/agent-ci-watchdog@.{service,timer}`,
enabled per project with the path escaped (`snoopy_frog-v3` → `snoopy_frog/v3`
via `%I`), every 15 minutes. **Lingering is off** (`loginctl enable-linger`
needs root), so the timer stops if the user session ends.

**Why:** the user asked for a watchdog role that wakes periodically and
unblocks the pipeline. **How to apply:** add a project with
`systemctl --user enable --now 'agent-ci-watchdog@<escaped-path>.timer'`; a
model tier on top is possible but must never touch a task's outcome —
validation stays the only thing that passes work.
Related: [[pipeline-revision-branch]], [[user-goal-autonomous-devinfra]].
