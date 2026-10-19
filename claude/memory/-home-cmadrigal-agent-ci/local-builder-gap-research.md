---
name: local-builder-gap-research
description: "2026-10-18 the user ranks \"make local models better at completing tasks\" as valuable as the app itself; Phase 1 retrospective (local vs escalation) started, Phase 2 replay bench needs OK"
metadata:
  node_type: memory
  type: user
  originSessionId: 0c1852ef-3212-4405-b486-5cda3eb63786
  modified: 2026-10-18T18:27:51.402Z
---

Cristian, 2026-10-18: compare what the local builder did vs what the escalation resolved to find where the gap
comes from (model? wiring? complexity? splitting?) — "this analysis will be as valuable as the application itself,
find out a way to make local models better on completing tasks".

Plan agreed in session: Phase 1 = read-only retrospective over all recorded attempts (fxplat, snoopyfrog,
x-scraping): failure taxonomy per local stall, local-vs-escalation diffs, feature predictors, model 30b vs 27b;
report at ~/agent-ci/docs/research/2026-10-18-local-builder-gap.md. Phase 2 = controlled replay bench (historical
tasks with known-good answers, vary one thing at a time: 80b builder, split specs, prompt/context layout, time
limit) — uses GPU time, needs his OK and scheduling around the pipeline.

Baseline numbers 2026-10-18 (`agent-ci stats`): since 10-06, 134 tasks tried locally, 119 landed (~89%); 56 sent
strong_direct by design; escalations 81/81 succeeded (~5 min each).

**Why:** agent-ci is a product; local-model completion rate is its core economics and independence from Claude.
**How to apply:** treat findings here as first-class work, link agent-ci changes to evidence from this research.
Related: [[agent-ci-is-a-product]], [[spec-risk-measure-future]], [[user-goal-autonomous-devinfra]].

**Progress 2026-10-18:** Phase 1 done (agent-ci a9ee7dd): with the 27b the gap is the harness + 3600 s clock, not
the model (~2 of 18 recent stalls are the model). Harness fixes merged (agent-ci 1924e4f): ruff `-->` repair
regex (12/62 stalls), fast check (suite supervisor-only in the prompt), clock block, single-finding repair (5/62);
flags execution.builder_fast_check / prompts.builder_clock_block / execution.repair_single_finding (on).
Gateway veto "skeleton" fix in progress on branch veto-skeleton (97 -> ~52 refusals on telemetry). Phase 2
bench being built on branch replay-bench (separate clone ~/replay/fxplat, idle gate); stages 0-1 approved.
