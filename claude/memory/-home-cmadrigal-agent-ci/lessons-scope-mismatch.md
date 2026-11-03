---
name: lessons-scope-mismatch
description: agent-ci lessons were mostly unreachable (scope format mismatch); fixed d360cf4 on 2026-11-03 — check reach after changes
metadata:
  node_type: memory
  type: project
  originSessionId: 1c4d5b2e-1683-4d80-96df-42f632213acd
  modified: 2026-11-03T14:31:43.973Z
---

2026-11-03: the user asked whether the lessons log still works. It did record lessons (312 on fxplat, about 15 a day), but 210 of them could never reach a prompt. The local curator wrote scopes as "project", dotted modules, "high"/"0.5" or sentences, while `Lesson.applies_to` matched only path prefixes. Only 36 lessons had ever been injected. Their credit was helpful 48 vs harmful 23.

Fixed in agent-ci d360cf4 (`scope_places`, `_mentions` in agent_ci/reporting/lessons.py). Replay over 122 recent tasks: lessons reachable rose from 19 to 73, and tasks receiving at least one lesson from 18 to 40.

**Why:** lessons are part of [[claude-dependency-challenge]]: they are how escalation knowledge goes back to the local builder.

**How to apply:** when touching the lessons or curator code, rerun the reach replay: for recent tasks, count the lessons whose `applies_to` is true. Watch the helpful/harmful ratio in state/lessons.json.
