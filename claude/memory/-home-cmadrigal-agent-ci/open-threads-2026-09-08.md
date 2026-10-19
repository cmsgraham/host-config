---
name: open-threads-2026-09-08
description: "Pinned for later review: spec-review panel, 100% escalation rate, local-tier experiment never run, phase 8, prod blockers"
metadata: 
  node_type: memory
  type: project
  originSessionId: 025cf55b-64c5-455a-bf92-9d6edbbd538b
  modified: 2026-10-05T14:57:55.824Z
---

Pinned 2026-09-08 at the operator's request. These are decided-but-unbuilt or
measured-but-unexplained; none is blocking the loop.

**1. Multi-model spec review, not built.** The operator wants specs reviewed by
several models before coding rather than trusting one author. Argued and agreed:
deterministic rules go first because 3 of 4 spec defects were mechanical, and
those now exist in `agent_ci/contour.py::lint`. What a panel adds that counting
cannot: *is this one task or three*, *could a stub pass these checks*, *do these
requirements contradict each other*. Shape: a stage using architect +
test_auditor + reviewer before a task enters `tasks/`. See [[contour-and-watchdog-redesign]].

**2. The local builder has landed NOTHING unaided.** 9 of 9 tasks on phases
7/10 needed the strong tier. The marker briefing, baseline probe and
existing-coverage sections were sound reasoning and have not yet paid off. The
clean experiment was never run: adding a `db-up` check moved TASK-7.11 from 8.5
to 9.0 and reclassified it local -> strong before it built. After db-up stopped being scored (14:50 UTC), honest local candidates are
**TASK-7.11 (8.5)**, **TASK-7.13 (8.0)**, **TASK-7.14 (8.5)**, **TASK-10.2 (8.0)**, **TASK-7.12 (8.0)**. Until one of
those lands unaided, the split-for-local strategy is unproven.

**3. Phase 8 (design system, density, mobile)** stays in
`state/proposals/phase-8/` — 3 tasks, gate-clean, deliberately not queued. It
must land BEFORE TASK-7.9 and 7.10 or both ticket UIs get built twice.

**4. Production blockers, none of them code:** no backups (no pg_dump or
snapshot tooling anywhere), no monitoring/alerting/error tracking, 1 healthcheck
across 5 services, and no data export/deletion for GDPR while holding LinkedIn
contact data. See [[snoopy-production-readiness]].

**5. External credentials gate three queued tasks.** 7.4 needs an S3 bucket,
7.6 SMTP, 7.8 a WhatsApp provider — **Meta app review is a calendar dependency,
days not compute**. All three build and pass on in-memory implementations, so
nothing proves real delivery works.

**Why:** the operator asked to pin these rather than act, having seen a week
lost to problems nobody was tracking.

**How to apply:** revisit when the loop is idle or Phase 7 completes. Item 2 is
the one that decides whether local inference is worth keeping in the loop at
all — do not declare the balance improved without a clean unaided local pass.

**6. (added 14:55 UTC) Per-attempt slot teardown.** A task's own Postgres
container survives between attempts, so a task without `db-up` passes in its
worktree and fails the gate. The contour rule now blocks the spec shape, but
the honest fix is tearing the slot down after each attempt; not built.
**7. Merge `pipeline-revision` → `master` on agent-ci** (14 commits ahead) — the
README lives there and the GitHub front page still shows the old one.

**8. (15:20 UTC) Flaky test: `tests/db/test_api_withdraw.py::test_withdraw_oldest_validates_bounds`.**
A fresh registration's token gets 401 "Invalid or expired token" on the next
call, in ONE random parametrization, ONLY inside the full suite (6/6 clean in
isolation on master). Seen 2026-09-06 twice (TASK-3.1, 3.2) and 2026-09-08 at
TASK-10.1's gate — unrelated to 10.1. test_api_auth.py (runs just before)
does not clear the settings cache; cause unknown. Do NOT xfail/skip it (the
operator's guardrail); find the cause as a snoopy task. Until then a gate can
be refused by it once in ~20 full-suite runs; the retry is now cheap
(validate_first → straight to the gate).

---

## 2026-09-09 overnight update

**Item 2 is STILL OPEN, and the way it looked answered is the finding.**
TASK-7.11 passed on attempt 1 with `qwen3-coder:30b` and `agent-ci` recorded it
as a local pass. It was not one. An earlier run (run-20260908-053312-e6aec1)
escalated, and that escalation was KILLED AT ITS TIMEOUT, leaving its work in
`.agent-worktrees/TASK-7.11` with nothing recording it. When the task came round
again on 2026-09-09 the builder ran **9 file `view` commands and zero edits** —
its activity log says "most of the functionality is already implemented" — ran
the tests, found them green, and finished.

So the local tier has still landed NOTHING unaided, and worse: **`history.json`
and therefore `agent-ci stats` credit the local builder for strong-tier work
whenever an escalation dies without exiting 0.** Any past "local pass" whose
task has a non-zero escalation count deserves the same audit — check the run's
`builder-activity.log` for actual edit commands, not just its PASSED status.

The underlying bug is fixed (agent-ci `3d99401`): both the timeout and the
non-zero-exit paths now record the tree as unvalidated, so the next pick judges
it instead of letting a builder build over it and take the credit. The check is
a content fingerprint taken before/after the escalation process, because the
worktree is ALWAYS dirty when an escalation starts.

**Item 7.11's merge is done, by hand, and the reason matters.** The branch was
23 commits behind and both it and master had created
`services/api/app/routers/tickets.py`, so the gate died on an add/add conflict
no rebase could resolve either. The route sets were disjoint halves of ONE
router (7.2 owns the thread and its docstring says "The ticket CRUD surface
itself is TASK-7.11"), so both were kept. **Three defects existed only in the
combination** — the kind no single task's checks can catch:

1. `main.py` mounted the tickets router TWICE. Git auto-merged both sides'
   identical `include_router` into two calls at different positions with **no
   conflict**, which would have registered every ticket route twice.
2. PATCH passed no `actor_id`, which 7.3 added for the history — every manual
   ticket change would have had `actorId: null` in the audit trail.
3. Two copies of the "invisible is 404, never 403" rule (`_load_visible` and
   `_authorized_ticket`). Collapsed to one.

The supervisor bug that caused the stale base is already fixed on
`pipeline-revision`: `WorktreeManager.refresh` now commits dirty work and
rebases instead of skipping, and its docstring names TASK-7.11 as the case
that proved it. **The fix landed after 7.11 had already built.**

**Item 3 acted on:** TASK-7.9 and TASK-7.10 moved to `tasks-held/` (outside the
loader's walk) with a README, because both became eligible and the overnight
loop would have built both ticket UIs before Phase 8's design system. Nothing
depends on either. Queueing Phase 8 is still a decision for a person — release
the hold with `git mv tasks-held/TASK-7.{9,10}.yaml tasks/`.

**Item 8 (the flaky auth test) did not appear** in three full-suite runs tonight.

**New:** `state/unmerged.json` is what keeps a task out of `passed_task_ids()`
(passed = PASSED-history MINUS unmerged), so a hand-merge must clear the task
from it or the loop re-runs the task forever.

### The attribution audit (2026-09-09) — what the 44 passing runs actually show

Method: for each task's PASSING run, count real edit commands
(`create|str_replace|insert|write|edit`) in `logs/<run>/builder-activity.log`.
A run where the builder wrote nothing did not build the task, whatever
`history.json` says.

| class | n | what it means |
|---|---|---|
| A. builder WROTE code | 9 | 0.0, 0.1, 0.2, 0.3, 0.4, 2.2, 2.3, 3.1, 3.2 |
| B. builder ran, inspected, wrote NOTHING | 10 | 1.2, 1.3, 1.6, 1.7, 1.8, 2.1, 3.3, 3.6, 4.1, 7.11 |
| C. no builder ran at all (log is just its header) | 25 | validate-first after an escalation exited 0 |

**Class C is legitimate and by design** — the escalation succeeded, the re-run
only validated, no builder was asked to do anything. **Class B is the problem:**
a builder ran in a worktree that already held an earlier escalation's work,
edited nothing, and the run was recorded PASSED with
`builder_model: qwen3-coder:30b`. Every one of the 10 has a prior escalated run.

**Only 3 tasks are unaided local builds — TASK-0.0, 0.1 and 0.4** (edits > 0 and
zero escalations ever on the task). All three are Phase 0, the simplest work in
the project. The other 6 in class A had an earlier escalation, so the builder
edited, but possibly on top of strong-tier leftovers.

**So: 35 of 44 passing runs involved no local-builder authorship at all.**
`history.json` records `builder_model` as a config field, not as a claim about
who wrote the code, and `agent-ci stats` cannot tell the three classes apart —
which is why the local tier looked more productive than it is.

**How to apply:** before crediting the local tier for anything, run the edit
count above. A cheap permanent fix is to record the builder's edit count in the
attempt record, so `stats` can separate "built it" from "agreed with it".


### Item 6 (per-attempt slot teardown) now has a measured cost — 2026-09-09

A KILLED escalation does not tear down the Postgres it started in the task's
slot. `gate_teardown_cmd` covers the merge gate only; nothing covers an
escalation that is killed at its timeout.

TASK-7.5, five minutes after its escalation was killed at 2400s: 12 SLA tests
failed with a foreign key violation where a ticket's own event could not see
the ticket (`Key (ticket_id)=(...) is not present in table "tickets"`). The
SAME TREE passed all 9 checks 35 minutes later:

    run-20260909-094825-f4203f  tree 101f666f...  12 failed
    run-20260909-102714-3660ec  tree 101f666f...  9/9 passed

**The expensive part was not the lost cycle, it was the diagnosis.** The symptom
is a textbook connection-threading bug — it even contradicts the invariant 7.3's
docstring spells out — so reading the output produced a confident, specific and
entirely wrong root cause, aimed at code that was never broken.

**How to apply:** compare `refs/agent-ci/attempts/<TASK>/<run>/<n>` tree hashes
BEFORE diagnosing any failing check. Same tree + different verdict = the answer
is not in the diff, and the failure is environmental. This is what the attempt
snapshots are for; use them first, not last. A cheap partial fix is to run
`gate_teardown_cmd` after a killed escalation too.

---

## 2026-09-12 overnight update (Phase 12)

**9. NEW PINNED DECISION, and it is a security one: after an automatic Google
link, should the account's DEVICES be revoked as well as its refresh tokens?**
`_revoke_every_session` (`services/api/app/auth/oauth.py:491` on
`agent/TASK-12.16`) is exactly one statement:
`UPDATE refresh_tokens SET revoked_at = now() WHERE user_id = $1 AND revoked_at
IS NULL`. Its docstring says it fires on an AUTOMATIC LINK — Google verified an
email matching an existing account — so it is the one flow whose premise is
"someone may just have taken this account". After TASK-12.16 the refresh tokens
die but the DEVICE rows stay live, and since 12.16 makes `get_current_user`
check the device rather than the token, every access token minted before the
link keeps working for up to `access_token_minutes` (30). That is precisely the
window the objective's "revoking a device takes effect at once instead of when
its access token runs out" exists to close.

**TASK-12.16's escalation found this and deliberately did NOT fix it, correctly:**
requirement 7 names only `/logout` and `_revoke_others`, and widening scope
unasked is the TASK-1.4 failure mode. One line in that function closes it.
Natural home is TASK-12.18, which owns device revocation. Do not amend a spec
that is already built; this needs the operator, not a quiet patch.
**How to apply:** if adopted, the fix is `revoke_devices_except(conn,
user_id=..., keep_device_id=None, reason=...)` from the new
`services/api/app/auth/devices.py`, which already does exactly this for
`_revoke_others`.

**Item 2 now has five more data points, all negative.** Phase 12 ran 16 tasks
and **every one needed the strong tier — 16 escalations across 16 tasks, none
needing its second.** 12.15 and 12.16 are the clearest cases yet and neither is
a class-B "inspected and wrote nothing": both builders wrote real code that
failed for reasons no local model was going to catch. 12.15's builder wrote 8
HTTP integration tests against a route that exists only as a client screen (see
docs/FAILURES.md), and 12.16's wrote 8 tests of which **two had empty bodies**,
for exactly the two requirements it never implemented — so `devices-tests-green`
reported "8 passed in 2.98s" over an unbuilt feature. The local tier is not
merely unproven after three days; Phase 12 is 16 more runs of evidence against
it. **How to apply:** item 2's question is no longer "has it landed one
unaided" but "is the builder attempt worth its ~16 minutes at all, given
`max_attempts: 1` makes escalation the primary repair path". That is an
operator decision about `config.yaml`, so do not change it — raise it.

---

## 2026-10-05 update: item 2 has its first clean unaided local pass

Raised on fxplat with the numbers (30 of 30 tasks escalated, qwen3-coder:30b 0 of 23 local attempts,
escalation rewrote 85-95% of its code). The operator chose an A/B: builder `qwen3.8:27b`, action policy on,
a gateway rule refusing the system interpreter when the worktree has a `.venv`, and one local repair when
only the attempt's own tests fail ([[focus-fxplat-2026-10]]). **TASK-2.5 then PASSED on the 27b's first
attempt**: 23 real edit commands in `builder-activity.log`, 0 prior escalations on the task, 337 lines in
2 new files, 1 veto re-planned, reviewer APPROVE. By this file's own audit method that is class A, unaided.
One point is not a trend; judge after ~10 tasks with `agent-ci stats`.
