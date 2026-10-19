---
name: operator-backlog-artifact
description: The shared TODO list (Operator Backlog artifact, db collection "todos") - add parked/deferred items there, move them when work starts/ends
metadata:
  type: reference
---
Operator Backlog: https://claude.ai/artifact/D4jx5Avy7fVz6cCSyRwEvF (created 2026-10-15 at Cristian's request "we need a todo list so we dont forget").
Data lives in its db collection `todos`; write with ArtifactData (pin if_version on existing docs). Fields: title, detail, area (agent-ci|fxplat|ops|ui), status (open|doing|parked|done), priority 1-3, added, closed, source.

**How to apply:** whenever something is deferred, parked or "later" in chat, add a row; move rows to doing/done as work happens; read it at session start when asked "what's pending". Related: [[spec-risk-measure-future]].
