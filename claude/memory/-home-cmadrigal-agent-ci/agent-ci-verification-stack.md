---
name: agent-ci-verification-stack
description: "Items 1-6 of the 2026-09-08 plan are built; what each catches, and the two false positives found by measuring before shipping"
metadata: 
  node_type: memory
  type: project
  originSessionId: 3a95969f-0700-4e5c-ad17-66cac7a14b11
  modified: 2026-09-12T15:09:24.555Z
---

Built 2026-09-08 on branch `pipeline-revision` (476 tests). Order came from
`docs/research/2026-09-08-follow-back-response.md`.

| # | What | Blocks? |
|---|---|---|
| 1 | env allow-list (`env_policy.py`) — see [[agent-ci-env-policy]] | n/a |
| 2 | policy paths protected from every attempt (`policy.py`: tasks dir + config) | YES, fails validation |
| 3 | check classification (`certification.py`): authoritative vs evidence | no, reviewer only |
| 4 | counterfactual (`counterfactual.py`): replay new tests on the base tree | no, reviewer only |
| 5 | worktree refresh (`git/worktrees.refresh`) | conflict → HUMAN_REQUIRED |
| 6 | provenance (`provenance.py`) → `state/provenance/<TASK>.json` | never |

Item 7 (builder backend protocol) SKIPPED deliberately: `BuilderAgent.run` is
already the boundary and there is no second implementation, so it would be
abstraction with no consumer.

**The biggest find was not on the list.** Measuring item 3 against real runs
showed empty change sets. Cause: `run.base_commit` is the worktree HEAD at
prepare time, so when a task's work is ALREADY COMMITTED on its branch (an
escalation that committed, or a re-run after a refused merge) the diff from it
is empty. **TASK-10.4 was reviewed twice on a 2.7 KB prompt with no diff and
approved both times.** Fixed: review base = merge-base with the integration
branch. `Supervisor._review_base`.

**Two false positives caught before shipping, both "a rule that punishes the
wrong actor":** protecting `state/` (the supervisor writes it every run, so a
diff cannot attribute the write — would fail every task in a repo not
gitignoring it); and using the base-commit diff for policy paths (an
uncommitted task file reads as "added by this attempt"). Item 2 now uses a
content fingerprint taken before the attempt.

**Design rule worth keeping from item 4:** the counterfactual only reports
BASE_ALREADY_PASSES and INDETERMINATE. RED_GREEN_CONFIRMED is deliberately
silent because the base run varies source but not database schema, so a
failure there has other possible causes. Report only the conclusion you can
support.

**Item 4's blind spot, measured 2026-09-12 (snoopy_frog TASK-12.3):** when a task
ADDS a module, the base tree has no such module, so every test copied onto it dies
at collection with ModuleNotFoundError -- red regardless of whether those tests
assert anything real. 12.3 earned RED_GREEN_CONFIRMED TWICE the same night: once
for the attempt whose `render()` inverted the managed/operator rule and wrote
line-based text instead of the JSON chisel reads, and again for the escalation's
correct rewrite. The verdict only discriminates when a task CHANGES existing code;
for a new module it says nothing, so do not read it as evidence the tests are good.

**The test auditor's vacuous flag runs false too:** it called 7 of 12.3's rewritten
tests vacuous ("implementation details ... rather than correctness"), but 6 map
straight onto explicit requirements -- the empty-setting no-op, the per-tick
try/except, the anchored pattern in the form `deploy.sh relay add` writes -- and
the 7th (no temp file left behind) guards a real fault, since chisel watches the
DIRECTORY and reloads on create/rename/remove. It mistakes invariant-testing for
implementation-testing.

**A STAGE NAME IS NOT A VERDICT, AND I MISREAD ONE (2026-09-12, TASK-12.15).**
I reported that the run reaching REVIEWING meant validation had passed "all
five acceptance checks". It had passed ONE. `validation_done` in
`logs/<run>/events.jsonl` read `"passed": false, "failed": ["web-typecheck",
"support-desk-ticket-ui-tests-green", "suite-green"]` and the run advanced to
REVIEWING anyway — and item 3 above is exactly WHY. The `certification` event
recorded `authoritative: ["db-up"]` with all three failures classed as
`evidence`. **A task that fails only EVIDENCE checks still reaches the reviewer,
by design.** So the stage — the thing the dashboard shows and the monitor
reports — says nothing about whether the work is correct. The authority is
`validation_done`'s `passed` field, or `logs/<run>-a<N>/validation.json`.
Read the record, never the label.

**Item 4's blind spot, second instance, and it is worse than "uninformative":**
TASK-12.15's counterfactual returned `status: "INDETERMINATE"` with
`proved_nothing: []` because the candidate's only new test file died at
COLLECTION — `ImportError: cannot import name 'ticket_message'`, a helper that
does not exist. So it never ran the tests it was meant to replay on the base
tree. When the new tests are themselves broken, the counterfactual is not just
silent on whether they are good; it cannot tell you they are broken either.
The one artefact that did say so was the plain check log,
`logs/<run>-a1/support-desk-ticket-ui-tests-green.stdout.log`.

**BUT THE BLIND SPOT HAS AN ESCAPE, AND IT CORRECTS WHAT I WROTE ABOVE
(same task, 2026-09-12 15:05Z).** I had recorded that a task ADDING modules
always earns a meaningless red, because every test dies at collection on the
base tree. That is only true of tests that IMPORT the new code. TASK-12.15's
escalation rewrote its suite in the house source-contract style --
`path.read_text()` + `ast.parse()` + assertions over the TEXT of the new
files, plus an API half asked for real -- and those collect perfectly against
a base tree that lacks the files. Result: `status: "RED_GREEN_CONFIRMED"` with
**28 failed, 4 passed** at base, and the named failures are semantic, not
import errors (`test_the_detail_route_answers_the_shape_the_screen_reads`,
`test_the_thread_carries_all_three_kinds_and_names_their_authors`,
`test_the_body_the_composer_sends_is_accepted_and_the_third_kind_is_not`,
`test_the_org_queue_behaves_exactly_as_before`). The 4 that PASS at base are
the invariants already true there. Compare the same task's first attempt, whose
HTTP-integration tests imported a helper that did not exist: INDETERMINATE,
`proved_nothing: []`.

So the source-reading convention (`tests/test_support_desk_ui.py`,
`test_ticket_web_contract.py`, `test_sso_ui.py`) is not only about catching
untyped drift -- **it is what makes item 4 informative at all for web work.**
**How to apply:** when a task adds new web modules, a source-reading suite buys
a real counterfactual verdict and an importing suite guarantees a worthless
one. Do not dismiss RED_GREEN_CONFIRMED as noise without checking whether any
tests PASSED at base: all-failed means collection died, a mix means the
verdict discriminated.

**How to apply:** items 3 and 4 are advisory ON PURPOSE. A gate that stops
every task gets turned off. Flip either to blocking only after a season of data
— the 11 remaining snoopy tasks are that data. See
[[agent-ci-feedback-response]], [[open-threads-2026-09-08]],
[[spec-given-claims-trap]].
