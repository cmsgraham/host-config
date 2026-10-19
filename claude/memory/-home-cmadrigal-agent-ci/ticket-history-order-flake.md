---
name: ticket-history-order-flake
description: tests/db/test_ticket_history_api.py::test_the_endpoint_returns_the_timeline_oldest_first fails intermittently because tied occurred_at values are broken by a random UUID -- it blames whatever task happens to be running
metadata: 
  node_type: memory
  type: project
  originSessionId: 3a95969f-0700-4e5c-ad17-66cac7a14b11
  modified: 2026-09-12T23:04:40.317Z
---

snoopy_frog v3. `test_the_endpoint_returns_the_timeline_oldest_first` failed on
2026-09-12 05:01Z inside TASK-12.6's full suite -- `1 failed, 2245 passed` --
with `At index 0 diff: 'ticket.message_added' != 'ticket.created'`. TASK-12.6
touches only `services/linkedin-worker/modules/proxy.py`, so the task was blamed
for a failure it could not have caused. It did NOT reproduce: the escalation ran
the full suite twice, 2313 passed / 0 failed both times, without touching any
ticket file.

**But the flake was not the whole story, and assuming it was is the trap.** I
told the escalation its task looked otherwise complete and a re-run would do.
That was wrong: the builder's diff was 37 lines -- an uncalled
`build_connector_proxy_url()`, an import of `services.api.app.services.
connector_credentials` (a path absent from the worker image), and three tests,
one a bare `pass`. Requirements 2-5 had NO implementation, and the reviewer's
five P0 findings were all accurate. A plain re-run would have merged a stub.
The failing CHECK was noise; the task was still broken. The index-0 tie also
means `created` tied with `message_added`, so the tie window is wider than just
the one-transaction reply pair.

**Mechanism.** `ticket_events.occurred_at` is stamped with `clock_timestamp()`
by `_insert_row` (NOT the column's `now()` default -- that was deliberate, since
`now()` is the transaction clock and would tie a reply with the state change it
drives). `list_ticket_events` orders `occurred_at ASC, id ASC`, and `id` is
`gen_random_uuid()`. So ANY tie in `occurred_at` is resolved by a coin flip.
Two events written inside one clock tick therefore come back in random order.
Leading explanation is coarse `clock_timestamp()` resolution under WSL2; NOT
proven empirically (the test database is rolled back, and measuring it means
touching a running slot's container).

**It is not caused by 26eb0b9** (the 2026-09-11 "ticket filed through the API
gets its ticket.created row" commit): the same tree passed 12.3's merge gate at
04:18Z with 2243 passed, and 12.5's suite with 2198 passed, within the hour.
A 2026-09-09 failure of the same test exists but is weak evidence -- that run had
32 failures in 14 minutes, i.e. a broken environment.

**THE FAMILY HAS THREE MEMBERS.** The third, found during TASK-12.12 on
2026-09-12: `tests/db/test_ticket_events.py::
test_a_failed_emit_does_not_take_the_ticket_write_down_with_it` — failed once in
a full run, passed alone and in two later full runs, no prior failure in any log.

**THE SECOND MEMBER:** `tests/db/test_followups.py::
test_the_invite_gate_parks_the_step_before_any_follow_up` is the second:
line ~257 is `assert await dispatch_due(db_pool) == counts(claimed=1,
skipped=1)`, a timing-sensitive counts assertion. It failed in exactly 2 of the
20 recorded runs that mention it -- 2026-09-09 and TASK-12.5's builder run on
2026-09-12 -- passed in isolation, and passed on the immediate full-suite
re-run (2404/0). So when a task fails the suite on ONE test it cannot have
touched, check both of these names before letting an escalation hunt.

**A FOURTH MEMBER, AND IT IS FROM A DIFFERENT FAMILY TREE (2026-09-12 17:10Z).**
`tests/db/test_scheduler_dispatch.py::test_dispatch_with_reserved_accounts`
failed TASK-12.16's post-escalation suite -- 1 failed / 2574 passed -- on
`assert await dispatch_due(db_pool) == counts(claimed=1, enqueued=1)` returning
`claimed: 0, enqueued: 0`. TASK-12.16 touches auth only; the file is in neither
the escalation's diff nor the task's.

**CORRECTION, made minutes after first writing this entry: the corroboration is
ONE occurrence, not two, and it is weak.** I first recorded that it "had already
failed twice the same night" — wrong on both counts. Searching only `-a1`
suite logs, exactly TWO runs in the whole history recorded this failure:
`run-20260912-025748-96b63b` (TASK-12.5) at **45 failed / 2142 passed** — a
broken environment, which my own note below already says is weak evidence — and
this one at 1 failed / 2574 passed. The second "occurrence" I cited,
`logs/auto-20260912-002759.log`, is the LOOP's log, which contains that same
run's output; it also shows the test PASSED in another run that night. So there
is exactly one CREDIBLE failure: this one. That is consistent with a flake but
does not establish one, and I stated it as established. When counting
occurrences of a failure, count DISTINCT RUNS from per-run artifacts, never
grep hits across `logs/` — the loop log and the run logs double-count, and a
run with dozens of failures is environmental and should not be counted at all.

What makes this one different from the three above: the WHOLE FILE is weak, not
just one assertion. It was written by `6a7fc6a TASK-1.3: database-backed
scheduler tests` -- an early dogfood builder -- and it shows: the failing test
is commented `# (c) with reserved_accounts={the account id} nothing is
dispatched` while its body passes NO reserved_accounts and asserts the opposite,
and a sibling carries `# we're not testing complex blocking in this simple
version`. Other tests in it have failed across several dates
(`test_dispatch_due_dry_run_enrollment`, `test_dispatch_due_future_enrollment`,
`test_account_busy_blocks_second_enrollment`).

**Why it matters:** I spent a cycle hypothesising that TASK-12.16's own new
migration-replay test had caused it, which was wrong -- that test reads 039 and
runs it twice through the test's own `db` connection with no migrator, no
`schema_migrations` and no subprocess, so it has no suite-wide side effect. The
tidy causal story ("the fix broke something") was more attractive than the
boring one ("this file was always flaky"). **How to apply:** before blaming a
task for a one-test suite failure, grep `logs/` for that test name EXCLUDING the
current run -- a hit on an earlier run's log settles it in seconds. And for this
file specifically, read the test's own comment against its body: several do not
test what they say.

**SOLVED, 2026-09-12 20:12Z — TWO CLOCKS, AND IT WAS NEVER THE SCHEDULER.**
TASK-13.2's escalation found the cause and it is not a race in `dispatch_due`:
`tests/db/factories.py::create_enrollment` stamped `next_action_at` with
`_utcnow()` -- THIS PROCESS's clock -- while every claim query compares
`e.next_action_at <= now()`, the POSTGRES clock. pytest runs in the WSL VM and
the test Postgres runs in Docker Desktop's own VM, and nothing keeps those in
step to the millisecond. Measured margin between the INSERT and the dispatch
transaction's `now()`: **median 1.5 ms**. Whenever the server's clock sits
behind the client's, a row the test believes is due is NOT due, and
`dispatch_due` truthfully returns `claimed: 0`. Fix: read the due time off the
server (`SELECT now() - interval '1 minute'`), which is what test_ai_mode,
test_event_emitters, test_stop_on_tag and four other files already did by hand.

**Two things I got wrong about it.** (1) I flagged the `factories.py` change as
the suspicious, unexplained part of the diff -- it was the diagnosis. (2) My
briefing told the escalation "if the claimed:0 flake does not reproduce, say so
and move on -- do not hunt it", because I had classified it as one credible
occurrence of an unexplained intermittent. It hunted it anyway and found a real
two-clock bug that had been refusing merges on innocent tasks for days. **Do
not tell an escalation to stop looking at an intermittent it can reproduce in
its own slot**; "probably a flake" is a reason to time-box a hunt, never to
forbid one.

**How to apply:** any db test whose subject compares a timestamp against
Postgres `now()` must take that timestamp FROM Postgres. A Python-stamped
"due now" is a coin flip on this host. When a scheduler/claim test fails with a
count of 0 where 1 was expected, suspect the two clocks before suspecting the
query.

**A FIFTH MEMBER, 2026-09-12 22:44Z: THE WALL CLOCK ON THIS BOX STEPS
BACKWARDS, and this is the first direct observation of it.**
`tests/db/test_auth_devices.py::test_a_login_is_its_own_device` failed inside
TASK-13.2's suite -- 1 failed, 2634 passed -- with
`['Safari on iPhone', 'Chrome on Windows'] != ['Chrome on Windows', 'Safari on iPhone']`.
13.2 touches only `factories.py` and `test_scheduler_dispatch.py`, neither of
which that test uses, so it was collateral.

**I FIRST DIAGNOSED THIS WRONG AND BRIEFED THE WRONG FIX; `task-13-2-b2`
refuted it with the run's own log.** My story was: `created_at` ties on the
transaction clock and `d.name` breaks the tie alphabetically. **That story
cannot produce this failure, and one line of arithmetic kills it** -- with
`ORDER BY d.created_at, d.name`, a tie puts "Chrome on Windows" FIRST, which is
exactly what the test EXPECTS. A tie PASSES. The only arrangement that yields
the observed `['Safari', 'Chrome']` is `created_at(login) < created_at(register)`
-- the second call getting an EARLIER timestamp than the first.

**The proof was in the failing run's own captured stderr**
(`logs/run-20260912-220752-05dae3-a1/suite-green.stdout.log:58-59`):

    [api] ... 16:38:53,862 INFO httpx POST .../auth/register "200 OK"
    [api] ... 16:38:53,501 INFO httpx POST .../auth/login    "200 OK"

The later call is logged **361 ms EARLIER**. And the cause was ALREADY WRITTEN
DOWN IN THIS REPO, in `tests/db/api_client.py:33-35`: "the WSL2 wall clock is
stepped backwards by the hypervisor's time sync under load, so a token issued
at T can be validated at T - 0.3s and be 'not yet valid'" -- the known cause of
an intermittent 401, for which that module already carries
`JWT_CLOCK_LEEWAY_SECONDS = 60`. The test Postgres runs in Docker Desktop's VM
off the same time source.

**So this CORROBORATES the two-clocks fix above rather than being unrelated to
it** -- and by hundreds of ms, not the 1.5 ms margin the builder measured.
Two clocks disagreeing and one clock moving backwards are the same root
condition on this host.

**MY PRESCRIBED FIX WAS ALSO WRONG.** I told the escalation to copy the API's
`ORDER BY d.last_seen_at DESC, d.created_at DESC, d.id DESC`. That reads the
SAME backwards wall clock, and `id` is `gen_random_uuid()`, so it breaks ties
randomly. **`auth_devices` has nothing monotonic to order by** -- unlike
`ticket_events`, which TASK-13.1 could give a `seq`. The real fix is to STOP
IDENTIFYING A ROW BY ITS POSITION: `_device_of_token(db, tokens)` joins
`auth_devices` through the `refresh_tokens` row bound to it
(`JOIN refresh_tokens t ON t.device_id = d.id WHERE t.token_hash = $1`) -- the
binding the product actually relies on. `_devices_of` survives only behind a
`sorted(...)` SET assertion, where order cannot matter. The same latent flake
was fixed in `test_a_shared_computer_lasts_twelve_hours`, which took `[-1]` and
where BOTH devices are named "Chrome on Windows" -- no name to fall back on at
all, so my tiebreaker theory had nothing to stand on there either. Commit
`dd42b45`, tests/ only.

**How to apply.** (1) On this host, a backwards wall-clock step is a REAL and
now-observed failure mode: when timestamps order wrongly, check whether the
later operation carries the earlier stamp before theorising about ties, and
grep the run's captured stderr for the two requests' own log lines -- they are
timestamped and they settle it in seconds. (2) An ordering assertion is the
smell; the cure is usually to assert the BINDING (a foreign key that says which
row is which) and reduce the list assertion to a set. (3) Before prescribing a
tiebreaker, check the table HAS a monotonic column -- `created_at` and a random
UUID are not one. (4) My tie story was plausible, cited real line numbers, and
was refuted by arithmetic on the assertion it claimed to explain: when
diagnosing an order flip, FIRST work out which orderings would PASS, because a
mechanism that predicts the expected output is not the mechanism.

**Why it matters:** every task runs the full suite TWICE (task validation and the
merge gate), so a random ordering flake gets many chances per night, and each hit
costs a ~$6.50 escalation plus 40-80 minutes on an innocent task.

**How to apply:** when a task fails the suite on exactly one test it could not
have touched, check whether the same tree passed a merge gate recently before
letting the escalation hunt for a cause. Then READ THE REVIEWER'S FINDINGS
anyway before concluding the task is otherwise done -- a flaky check says
nothing about whether the work is real, and with `max_attempts: 1` the reviewer's
verdict is the only thing that looked at the diff. The real fix, which needs the operator's
approval because it is a migration plus an ordering-contract change: give
`ticket_events` a monotonic `BIGSERIAL` and order by that instead of the random
UUID. Related: [[spec-given-claims-trap]], [[agent-ci-verification-stack]]
