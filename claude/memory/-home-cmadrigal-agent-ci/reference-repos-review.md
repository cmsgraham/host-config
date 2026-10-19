---
name: reference-repos-review
description: Three comparable orchestrator repos cloned to ~/reference-repos and reviewed 2026-09-05; ranked adoption plan in docs/research/2026-09-05-reference-repos.md
metadata: 
  node_type: memory
  type: reference
  originSessionId: 29d5414b-faf8-42b4-a2dd-34f618e19471
  modified: 2026-09-05T14:55:34.246Z
---

On 2026-09-05 the user asked to study three similar initiatives and extract
what agent-ci can adopt. Clones (outside the repo): `~/reference-repos/`
standalone-orchestrator (TenchiNeko, Python lab, stale), ralph-review
(kenryu42, TS reviewer→findings→fixer), gascity (gastownhall, Go fleet
platform). Full review + 12-item ranked plan:
`agent-ci/docs/research/2026-09-05-reference-repos.md` (uncommitted at time of
writing).

Tier 1 (small, each closes a known stall cause): failure classification
(transient|hard, env|code|spec|infra), findings inventory with stable ids and
`disputed` status, ralph-review fixer discipline in the repair prompt,
snapshot-commit for review, context-budget module. Tier 2: module graph +
collision check, persistent lessons, supervisor-owned acceptance tests +
`agent-ci plan`, task `vars`/`steps`. Tier 3: dependency-wave parallelism,
multi-project daemon, event-log hardening + benchmark ladder.

**How to apply:** when the user says "the plan from the reference repos" or
picks up any tier item, start from that doc; do not re-review the clones.
Related: [[agent-ci-failure-modes]], [[roadmap-and-wsl-switch]].
