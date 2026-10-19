---
name: agent-ci-feedback-response
description: The 2026-09-08 architecture review, what it got right, and the agreed build order
metadata:
  type: project
---

Source: `docs/research/2026-09-08-feedback-and-evaluation.md` in agent-ci; my
per-recommendation verdict is `2026-09-08-feedback-response.md` beside it.

**It caught the README overstating twice.** (1) "The reviewer must be a
different model family" — the dogfood reviewer is qwen3-coder-next:80b, the SAME
family as the qwen3-coder:30b builder, one size up. (2) The whole document
implied independent verification while 51 of 52 tasks give the builder `tests/`
and run those tests as required checks. Both corrected in the README, which
gained §17 Known limits and §18 Invariants (each pinned to its test).

Also corrected in CLAUDE.md: "Builder runs Docker-sandboxed (approved)" was
decided in week one and NEVER BUILT.

**Agreed build order** (items 1, 2, 5 done 2026-09-08 — see [[agent-ci-env-policy]]):
1. ~~Env allow-list for builder and escalation~~ DONE.
2. ~~Protected-by-default policy artifacts~~ DONE (tasks dir + config file,
   whatever the task declares; state/ deliberately excluded — the supervisor
   writes it, so a diff cannot attribute the write).
2b. Check classification: a check is *evidence* when the attempt touched
   anything in its CERTIFICATION DEPENDENCY SET (conftest, pyproject, fixtures,
   helpers — not just the literal command args). Fail closed to evidence when
   the set cannot be resolved. Derive it, never let the task declare it.
3. Counterfactual gate: a builder-added test must FAIL on the base tree before
   it counts. Base commit and attempt snapshots already exist, so it is cheap.
4. ~~Worktree refresh policy~~ DONE: reset when the branch has no commits of
   its own, rebase when it has, refuse on conflict, NEVER when the tree is
   waiting to be judged as-is, and never when the worktree is dirty.
5. One `provenance.json` per merged task from RunState, which already holds it.

**Where I disagreed, with reasons:** security sandbox as P0 (single operator,
own machine — the env allow-list is the cheap real step, a container runtime is
for when a second user appears); its dual-GPU parallelism sketch (the builder
needs both 3090s and the gateway serialises generation — the real win is
overlapping CPU stages with a build); adaptive routing (41 tasks from one repo
is not a dataset).

**How to apply:** items 2 and 3 change what passes, so land them between phases,
not mid-phase. Item 1 was landed mid-run safely because it was verified against
real commands first.
