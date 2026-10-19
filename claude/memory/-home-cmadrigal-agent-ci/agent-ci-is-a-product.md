---
name: agent-ci-is-a-product
description: "agent-ci is meant to be application-agnostic and reused on future projects, not a one-off for x-scraping"
metadata: 
  node_type: memory
  type: project
  originSessionId: d4d5e3c0-0561-47b1-94a1-24f753f10ea0
  modified: 2026-09-02T17:18:24.126Z
---

2026-09-02: after watching the full loop work end to end (local tier → Claude
escalation → validation → merge gate) on x-scraping-project, the user said the
flow is for "this and coming projects" and asked that the solution be treated
as application-agnostic, working on any use case.

Onboarding a new repo is `agent-ci init` (scaffolds a commented config.yaml +
TASK-0.1 that proves the loop), then: endpoint URL, `git.worktree_setup` for
the toolchain, task YAML. Known portability limits: endpoint `auto` mode is
WSL-only (use `type: url` elsewhere), builder is OpenHands behind a swappable
Protocol, `/proc` + bash assume Linux.

**Why:** the user sees the pipeline as durable infrastructure for all their
projects; design decisions should favor generality over x-scraping shortcuts.
**How to apply:** when adding agent-ci features, keep project specifics in
config/task YAML, never in core; language/toolchain assumptions go in
`worktree_setup` and acceptance commands. See [[agent-ci-failure-modes]],
[[agent-ci-build-progress]].

**2026-10-06 onboarding retrospective** (docs/research/2026-10-06-onboarding-retrospective.md): snoopy_frog's
"strong pipeline" was the escalation — 94 of 98 passed tasks needed Claude first; the local path's defects (comment
notes never in prompts, 300 s client timeout, misrouting) were masked and surfaced only when fxplat's 27b builder
did real work. Report local pass rate + escalation reliance per project from day one; proposed T1-T6 transparency
mechanisms (scorecard, prompt render, canary task, pre-queue spec review, declared sources, onboarding log).
