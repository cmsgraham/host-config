---
name: claude-usage-50pct-rule
description: Cristian uses the same Claude plan for his own work - stop Claude work (pipeline jobs AND my own) at 50% of the 5-hour or weekly limit; check with `agent-ci usage`
metadata:
  type: feedback
---

Rule (2026-10-11): never let fxplat/agent-ci work push his Claude plan past 50% of the 5-hour or
the weekly limit (he said "daily, weekly or month"; the plan only has 5-hour and 7-day windows).
Enforced for pipeline jobs by agent-ci's usage guard (agent_ci/usage.py, ops.claude_usage_max: 0.5
in fxplat config): escalation, spec writer, spec review, triage refuse to start; one ntfy alert on
pause/resume; deferred escalations are retried on resume. Extra usage is disabled on his org
(overage rejected), so the risk is being blocked, not billed.

**Why:** he needs the plan for his day job; on 2026-10-11 weekly usage was already 49%, mostly
from long interactive sessions like this one.
**How to apply:** before starting any heavy interactive work (UI build, big refactors, research
runs I drive), run `~/agent-ci/.venv/bin/python -m agent_ci.cli --config ~/Dukascopy/config.yaml
usage --probe`; if either window is >= 50%, stop, tell him the reading and the reset time, and
leave work to the local pipeline. Re-check every hour or so during long sessions.
See [[agent-ci-ops-triage]].

**2026-10-19 ~12:00 CST:** Cristian raised the cap to 80% ("we are almost on the reset"; weekly was 46%, resets
Tue 2026-10-20 03:00). Applied to config `claude_usage_max: 0.8` after the 7.23 merge gate (my first edit landed
mid-gate and was reverted). Same pattern as 2026-10-11 (70% then back): return to 0.5 after the reset unless he
says otherwise - tell him when doing it.

**2026-10-20 06:40:** back to 0.5 after the reset (9e64d4f); told Cristian.

**2026-10-24 20:55 CST:** raised to 80% again ("extend the top to 80%", weekly 47%). Done with the
override keys this time (claude_usage_override_max 0.8, _until 2026-10-27T03:00-06:00, commit 1210d23),
so it lapses back to 0.5 at the reset by itself - no manual revert needed.

**2026-11-01 update:** the limit is now set from the gateway Overview "Claude plan" card slider, which writes `~/Dukascopy/state/usage-limit.json` (overrides `ops.claude_usage_max` while present). Read the current limit from `agent-ci --config ~/Dukascopy/config.yaml usage` (running it from ~/agent-ci shows the template's 0 %).
