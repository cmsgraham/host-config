---
name: pipeline-revision-branch
description: "Branch `pipeline-revision` (2026-09-05) carries items 0-9 of the consolidated plan; what landed, what is open, how it was validated"
metadata: 
  node_type: memory
  type: project
  originSessionId: 29d5414b-faf8-42b4-a2dd-34f618e19471
  modified: 2026-09-05T15:54:46.701Z
---

On 2026-09-05 the user asked to create a branch and apply the suggested
changes from the reference-repo review + revision-plan feedback. Branch
`pipeline-revision` (off master) now has one commit per item, suite green
(281 tests). Tracking doc with per-item status:
`agent-ci/docs/research/2026-09-05-consolidated-plan.md`.

Landed: `agent-ci stats`; deterministic failure classification with
transient retries and unrepairable stop (`validation/classify.py`,
`RunState.stall_kind`); prompt budgets (`prompts/budget.py`); findings with
stable ids (`findings.py`); evidence-based repair contract; snapshot commits
under `refs/agent-ci/attempts/` with tree-drift; lessons from escalation
(`reporting/lessons.py`, `state/lessons.json`); run isolation env
(`validation/isolation.py`); module graph + collision gate (`git/modules.py`).

Live runs 2026-09-05 (x-scraping TASK-7.5): run 1 exposed two branch bugs
(TMPDIR inside a /mnt/c worktree broke pytest capture; classifier read "no
tests ran" as a missing test target) — both fixed. Run 2 PASSED on attempt 1
but the integration gate refused the merge: 7 integration tests fail on
main itself (root-owned /tmp/scraper_workers from the 09-04 real-cloud run;
needs sudo). Branch agent/TASK-7.5 holds the passing commit, unmerged.
Lesson curation (`lessons.extract`, off by default) and the gateway
multi-project selector (~/ollama-gateway-multiproject, branch multi-project,
NOT deployed; live dir is git master = baseline) were built the same day.

Later on 2026-09-05/06 (same branch): escalation handoff (validate_first),
required actions (reporting/actions.py), lesson curation (off by default;
ON in snoopy config), continue_past_stalls, machine lock + --wait, pre-flight
briefs incl. fixtures, merge-gate marker, git-index file listing, containment
never reverts config.yaml/tasks. snoopy overnight: 2.4-2.7 merged, one
escalation each; loop restarted on 7d4c385 with pending task YAMLs at
max_attempts 3 (the per-task YAML is the real cap; config.execution.max_attempts
is inert). Gateway live dir fast-forwarded to multi-project + projects.json;
process restart needs the user's sudo. Reports: agent-ci artifact
4c529136…, SnoopyFrog artifact 9e7ac3a7… + PDF in Downloads.

Overnight 5→6 Sep: baseline recorded in
`docs/research/2026-09-06-overnight-baseline.md` — 4 of 4 passed tasks needed
a stall first (100%), fixture/import errors gone after the fixture brief,
remaining failures are assertion/value (behaviour, not knowledge). Curator
altitude fixed (facts only; instructions and status reports dropped by
deterministic rules; `agent-ci lessons prune`); snoopy store pruned 14 → 8.
`agent-ci stats` now reports escalation reliance + failure classes — that is
the morning comparison.

Open: item 9b (gate baseline: only NEW failures vs main should block), item 10 (model-residency replay; the gateway does not pass Ollama's
`load_duration`, needs a gateway change), 11 (stage overlap only for tasks
with no depends_on / owned_paths overlap), 12 (dependency waves, daemon).

**Why:** the user wants the pipeline improved from measured evidence, not
guesses; every change is anchored to a number in the revision plan.
**How to apply:** continue from the plan doc's next open item; run
`agent-ci stats --since <date>` before and after a change and compare the
three accounting totals. Not merged to master yet; the user decides when.
Related: [[reference-repos-review]], [[agent-ci-failure-modes]].
