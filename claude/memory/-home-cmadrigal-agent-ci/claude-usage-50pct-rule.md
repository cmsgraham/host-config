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
