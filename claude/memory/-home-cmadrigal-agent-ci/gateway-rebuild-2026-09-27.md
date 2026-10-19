---
name: gateway-rebuild-2026-09-27
description: The gateway ops-console rebuild (7 waves of AI_GATEWAY_REBUILD_BACKLOG.md) was executed on 2026-09-27; where things live now and the rules for touching them
metadata:
  type: project
---

On 2026-09-27 the whole gateway rebuild backlog (`~/agent-ci/AI_GATEWAY_REBUILD_BACKLOG.md`,
waves 0-7, every item has a **Status** line) was executed and committed in `~/ollama-gateway`
(one commit per wave on top of baseline 7c162a6) and `~/agent-ci` (correlation headers,
escalation ledger in /api/task).

**What exists now:** `telemetry.py` (SQLite `telemetry.db`: requests with measured
queue/TTFT/generation, GPU samples, events, model placements from the Ollama journal),
`health.py` (deterministic rules: health state, GPU state, insights, recommendations),
`ui/` (index.html, app.css, components.js, app.js). APIs under `/_dash/*?range=`.
agent-ci sends X-AgentCI-Run/Task/Stage/Project on every gateway call (`agent_ci/correlation.py`).

**Why:** the user wanted an infrastructure-grade console, not decorative cards; the backlog's
guardrails (never fabricate telemetry, deterministic diagnostics, raw values preserved) drove
every design choice (see [[gateway-dashboard-live-file]], [[wsl-passwordless-sudo]]).

**How to apply:** UI edits need no restart; backend edits need an idle-gap restart. Never add
a heuristic where the host cannot measure (WSL2 process mapping, KV-cache usage are shown as
unavailable). TTFT of non-streaming replies = upstream time by construction. The journal
backfill is slow (minutes for 7 days) and runs in a thread; loads are deduped by digest+time.
