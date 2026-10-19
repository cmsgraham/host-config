---
name: agent-ci-escalation-pattern
description: "Recurring stall causes in the SnoopyFrog v3 agent-ci pipeline (TASK-1.4, 1.6, 1.7, 2.1, 2.2, 2.3, 2.4, 2.5, 3.1, 3.2, 3.6, 4.1, 4.3, 5.2, 6.1, 7.1): a stale worktree branch failing on a spec defect master already fixed, MagicMock fakes that make 'missing attribute' untestable, specs whose requirements name protected files, grep-count acceptance gates that fail on the pristine baseline, fixture/loop-scope wiring, invented fixtures/factory kwargs/endpoints/columns, a new package shadowing an existing module, tests that simulate the code instead of calling it, assert the opposite of the spec, or contradict each other so no implementation can pass, edits to the shared conftest, migration up/down markers dropping the table, hallucinated reviewer diagnoses, false spec premises blocked by protected paths, a spec's 'verified' router/module inventory gone stale because a later task merged in between, WSL2 clock 401, a preflight 'conventions' block that hides the api/auth fixtures so the builder invents an HTTP client, and a test importing a package (aiohttp) that is in no requirements file — what to check first as escalation engineer, plus the env vars for running a worktree's tests by hand"
metadata:
  node_type: memory
  type: project
  originSessionId: 0eb063ba-92d5-4ba4-87fa-aef9a7de3662
  modified: 2026-09-12T14:57:19.983Z
---

Four escalations so far, all stalled on test plumbing or invented scope the 30B builder cannot see:
- TASK-1.4 (2026-09-04): fixtures never re-exported into tests/conftest.py. See [[task-1-4-escalation-api-deviations]].
- TASK-1.6 (2026-09-05): new tests/db/test_api_limits.py used bare `@pytest.mark.asyncio` while
  `api`/`db_pool` fixtures run on the session loop -> every test died with asyncpg
  `ConnectionDoesNotExistError`. The builder spent attempts 2-3 wrapping queries in transactions.
  Every tests/db file MUST carry `pytestmark = pytest.mark.asyncio(loop_scope="session")`.
  Also in 1.6: `account_id` on /linkedin/accounts routes is the `li_…` account_key, but
  account_limits/counters key on the linkedin_accounts UUID; resolve with an org-scoped
  SELECT before touching those tables. Builder also removed `PreflightCap` from types.ts
  (typecheck is a merge gate via full_suite_cmd, but not a task acceptance check).
- TASK-1.7 (2026-09-05): builder invented `create_user(db, organization_id=...)` (users has no
  such column; membership is org_members) and `*_factory` aliases, passed the asyncpg
  connection where maintenance_pass wants the pool, and patched `_is_due` instead of
  `random.randint`. The reviewer then recommended a bogus migration adding
  users.organization_id. It also inverted the requirement (withdraw pre-empting scan/sync).
  Fix was rewriting the tests against the real factories + restoring priority order.
  The withdraw knobs live in scheduler.py as WITHDRAW_* (env SCHEDULER_WITHDRAW_*).
- TASK-2.1 (2026-09-05, tags): real errors were an asyncpg placeholder off-by-one in the PATCH
  (`$2` reused for organization_id and the first SET column) and a test calling GET
  /tags/{id}, an endpoint the spec never asked for (405). The reviewer's report instead
  described a ForeignKeyViolationError that appears NOWHERE in the logs — it hallucinated a
  cause from the migration text. Builder attempt 2 also deleted `from app.services import
  linkedin_session` from inbox.py (still used by the reply endpoint) and no test caught it.
  Builder's migration had no seed for existing orgs and English prompts; tests skipped
  everything requiring a thread row. Rewrote service/router/tests against the requirements.
  **The intermittent 401 is the WSL2 clock, not truncation.** Every 401 in logs/ has body
  `{"detail":"Invalid or expired token"}` (JWT decode), never "User or organization not
  found". PyJWT >= 2.10 rejects `iat` in the future with leeway 0, and a 100 s probe showed
  the WSL2 wall clock stepping back 0.5–0.7 s every ~29 s under load. Fixed in
  tests/db/api_client.py (`jwt_clock_leeway` fixture patching jwt.decode with leeway=60,
  pulled in by `api`). Production follow-up outside any task's owned paths: pass `leeway` in
  app/auth/tokens.decode_access_token. The docs/FAILURES.md "truncate on setup" story is wrong.
- TASK-2.2 (2026-09-05, auto-tagging): same loop-scope mistake as 1.6 (bare `@pytest.mark.asyncio`
  on tests/db), but this time the builder "fixed" it by flipping tests/conftest.py `db_pool`/`db`
  to `loop_scope="function"` — pytest-asyncio 1.4 then raises a bare `AssertionError` at setup
  of EVERY db test (158 errors), which the reviewer read as "loop_scope misconfigured" and
  recommended reverting. Attempt 3 `cd`'d into the MAIN repo (/mnt/c/.../v3, not the worktree),
  saw no tag_pass there and concluded its own work was missing. Implementation had
  `outreach_messages.outreach_thread_id` (column is `thread_id`), FOR UPDATE SKIP LOCKED via
  `pool.fetch` outside any transaction, and tests passing the `db` connection as the pool.
  Fix: `git checkout -- tests/conftest.py`, rewrite pass + both test files against the spec.
  `TAG_MIN_MINUTES` is a per-thread debounce on tag_evaluated_at (tests set it to 0).
  Same-transaction thread_tag_events rows share created_at, so "latest event is human" needs a
  tie-break (`ORDER BY created_at DESC, (source='human') DESC`).
- TASK-2.3 (2026-09-05, review_service extraction + inbox drafts): loop-scope mistake a THIRD
  time (bare `@pytest.mark.asyncio` + `db_pool.acquire()` in the test body, never `db`), plus
  tests with invented string ids/columns and no truncation, so they also polluted
  test_api_review_golive in the full run. The reviewer blamed "pool.acquire() in the service"
  (wrong — the service takes a conn). Worse, the builder gutted the "verbatim behaviour"
  extraction: changed GET /approvals from `{runs,counts}` to `{total,approvals}`, dropped
  `FOR UPDATE OF sr` entirely (to satisfy the grep-count acceptance check), rejected runs as
  'skipped' instead of 'rejected', and made decide() 422 on a missing persona. An acceptance
  check that greps a router for a clause is satisfiable by deleting the clause — verify the
  clause moved. Fix: `git checkout HEAD -- routers/review.py routers/inbox.py`, rewrite the
  service from the HEAD router text, and rewrite both test files on `api`/`auth`/`db`/factories.
  Full suite tripped once on test_scheduler_quota (claimed 0): same WSL2 clock step, the row's
  next_action_at is Python utcnow vs Postgres now(). Passed on rerun.
- TASK-2.4 (2026-09-05, notifications): builder invented fixtures `api_auth` and `test_factory`
  (neither exists; the real ones are `api`/`auth`/`second_org`/`db`/`db_pool` + tests/db/factories),
  and every "producer" test just called notify() directly. Two silent bugs under that: the
  migration carried `-- migrate: up` / `-- migrate: down` markers, and scripts/migrate_local.py
  runs the WHOLE file in one transaction, so the DOWN section dropped the table right after
  creating it — schema_migrations said "applied", the table did not exist. And the producers
  referenced names not in scope (`organization_id`, `thread_id`, `lead['name']`) so the approval
  gate would have raised NameError; notify passed a dict for a JSONB column (asyncpg wants a
  json.dumps string) and swallowed the error, returning None every time. Fix: no down sections,
  `RETURNING id` on the step-run insert for the dedupe key, notify wraps the insert in
  `async with conn.transaction()` (a SAVEPOINT inside the engine's transaction) so a real DB
  error cannot abort the caller. asyncpg also rejects a bound `$n` the SQL never references
  ("server expects 3 arguments, 4 were passed") — only append params you use. Template merge
  fields are snake_case (`{{first_name}}`), and pydantic lax mode coerces "yes" to True: use
  StrictBool when a test expects 422.
- TASK-2.4 second escalation (2026-09-05, run-20260905-211500): attempt 1 did the insert on the
  engine conn with NO savepoint (its docstring said savepoints "risk deadlock"), so the
  NOT-NULL-violation test aborted the engine transaction. The reviewer's repair instruction was
  "use a separate connection from the pool" and the builder obeyed: `notify(pool, ...)` acquired a
  second connection while the engine still held the enrollment/thread FOR UPDATE, and the
  notification's FK onto that row waited on the lock forever -> both pytest checks TIMEOUT
  (misfiled as "deadlock or unbounded wait", which was literally right). It also broke every
  test that passes the `db` Connection (no `.acquire`). Fix: back to the spec's `notify(conn,…)`
  with `async with conn.transaction()` (SAVEPOINT when nested) and all three producers pass
  `conn`; pause endpoint does its UPDATE + notify in one acquired transaction. **A reviewer
  "use a separate connection" fix for anything inside a FOR UPDATE transaction is a self-deadlock.**
- TASK-2.5 (2026-09-05, default inbound campaign, run-20260905-221906): the visible error was
  `NameError: pytest_asyncio` in tests/db/conftest.py (builder added fixtures there without the
  import; conftest is shared, so ALL of tests/db failed to collect). Underneath: the adoption
  tests never called the endpoint — they INSERTed the enrollment themselves and asserted it
  existed; no test for alerts, 422, or claimability. The adoption code referenced
  `newest_inbound` before assignment and a Python `now()` that does not exist, and the INSERT
  omitted NOT NULL organization_id; campaigns.py was never touched (archive still 400, no
  DELETE route). Attempt 2 concluded conftest was "outside owned_paths" and quit. Fix:
  `git checkout HEAD -- tests/db/conftest.py`, rewrite service (acquire a conn from the pool
  so notify's savepoint works), adoption helpers, `_archive` shared by POST archive and a new
  DELETE /{id}, tests through the real inbox-snapshot endpoint. Web reads `detail.problems[0]`
  so keep that shape on 422.
- TASK-3.1 (2026-09-05, nested follow-ups, run-20260906-015012): loop-scope mistake a FOURTH time
  (bare `@pytest.mark.asyncio` on tests/db/test_followups.py -> asyncpg "attached to a different
  loop"), plus factories called with invented signatures (`create_organization` returns a UUID,
  not a dict; `create_enrollment` needs organization_id + linkedin_account_id) and a `counts(conn,
  db)` helper that in test_scheduler_dispatch takes **kwargs. The reviewer's F001 ("early return
  before dispatching the main message") described code that did not exist. Real engine gaps:
  the follow-up branch never set status back to 'active' from 'in_flight'; dry-run/approval
  step-run INSERTs had no step_index; dispatch_due re-sent a due follow-up even after a reply
  (the spec only checks silence in advance_enrollment, so the gate had to be added at dispatch);
  the cold-open guard on ai_conversation bounced every follow-up back to 'conversing'; the
  validator rejected followUps on view_profile. Fix: rewrote the branch (followup_index in every
  transition UPDATE, invite predicate applied to the branch too), carried `e.followup_index` +
  `replied_at` on the claim row, `step_follow_ups()` helper in enrollment.py, both test files.
  ai_conversation follow-ups ride conversation_pass's no-reply timer -> advance_enrollment.
- TASK-3.2 (2026-09-05, interact_post pipeline stubbed, run-20260906-024424): loop-scope mistake a
  FIFTH time, plus factories called with string ids (`organization_id="org1"`, `campaign_id=
  "campaign1"`), `.id` on the returned UUID, tuple-unpacking `quota_remaining` (returns a dict),
  and a jsonb `config` passed as a dict (asyncpg wants json.dumps). The builder's own unit test
  asserted the OPPOSITE of the spec (that the gated kind is "not actually rejected") and gave
  the meta `body_field="commentPrompt"` where the spec said None, so the generic body rule
  double-reported. The reviewer's three P0s ("early return bypassed", "seed via NOT EXISTS")
  were fiction. tests/test_step_kinds.py iterates STEP_KINDS expecting `{}` valid for every
  kind -> must branch on UNAVAILABLE_KINDS when a gated kind is added. **A spec premise was
  false**: "quota_remaining returns the 20/10 default for an unknown kind" — it returns
  {day:0,hour:0} because account_caps iterates enrollment.ACTION_KINDS (protected path), so
  the 15/4 test patches ACTION_KINDS and a tripwire test pins the 0/0 reality for TASK-3.2b,
  which must add 'interact' to ACTION_KINDS (and routers/linkedin.py's limit validation) when
  it lifts the gate. Acceptance `! grep 'run_in_session|page\.'` also matches DOCSTRINGS.

- TASK-4.1 (2026-09-07, events log, run-20260907-071337): loop-scope mistake a SIXTH time, worst
  form yet — both new test files used bare `@pytest.mark.asyncio` AND `db_pool.acquire()` in the
  body (never the `db` fixture), so nothing truncated and every test died "attached to a different
  loop". They also imported `from services.api.app.services.events import emit` (pythonpath is
  services/api, so it is `app.services.events`), passed literal UUID strings for organizations
  that were never created, and asserted nothing about the emitters the spec names. The reviewer's
  P0 ("emit uses the string 'now()' as a placeholder") was fiction — no such string existed.
  Real bugs, all of them KeyError/SQL errors that also broke test_entry_mode and test_api_internal:
  `qualify_pending` emitted with `first["organization_id"]` but its SELECT never selected it;
  `_conversation_job_landed` read organization_id/campaign_id off an enrollment row that has
  neither; and invite_snapshot added `JOIN campaigns c ON c.id = e.campaign_id` inside an
  `UPDATE … FROM` (Postgres: "invalid reference to FROM-clause entry for table e") purely to reach
  organization_id, which campaign_enrollments already has. Fix: rewrite events.py on the
  notifications.py pattern (savepoint via `conn.transaction()`, `json.dumps` for jsonb, `$n::uuid`
  casts so str or UUID both work, COALESCE($n, now()) for the stamps), emit message.sent from a
  `RETURNING id, step_index` on every step-run write including the dry-run branch, move
  conversation.ended/meeting.booked into `_end`, and rewrite both test files on `db`/`api`/factories.

- TASK-5.2 (2026-09-07, silent-account health_pass, run-20260907-093513): a NEW failure mode —
  the implementation was roughly right and the TESTS were internally contradictory. The builder's
  test_health_pass.py asserted `ok == 1` for a fixture with two healthy accounts, and asserted
  `ok == 1` for a never-connected one; no assignment of semantics to health_pass could satisfy
  them all, so all three attempts rewrote working scheduler code. It also computed staleness
  against `datetime.now()` while requesting the `clock` fixture (pinned to 2030), left
  `test_threshold_boundary()` as a bare `pass`, and dropped a scratch `test_logic.py` at the repo
  root that failed `no-stray-files`. The six P0 reviewer findings were all restatements of the
  same "counts are hardcoded" claim about code that had already been fixed. Fix: rewrite BOTH test
  files from the requirement text (requirements outrank tests in the diff), classify every account
  through one pure `account_health(row, has_running_campaign=…, stale_hours=…, now=…)` shared by
  the pass and the accounts API, and `rm test_logic.py`. Campaign statuses are draft/running/
  paused/completed/cancelled — the spec's "archived" does not exist in this schema.

- TASK-6.1 (2026-09-07, suppression write path, run-20260907-105902): another NEW failure mode —
  the builder created a PACKAGE that shadowed an existing module. It put the shared predicate in
  `services/api/app/db/suppression_predicate.py`, and the new `app/db/__init__.py` shadowed
  `app/db.py`, so `from app.db import get_pool` (auth/deps.py, every router) raised ImportError
  and tests/conftest.py failed to load — the whole suite, exit 4. The supervisor has a
  `module-collision` check for exactly this. Fix: `rm -rf app/db/` and put the constant in
  campaigns.py, which the requirement named first and which is inside owned_paths anyway.
  Under it, the router was unrunnable regardless: `_get_suppression_predicate()` undefined in
  suppressions.py, the predicate (a whole `SELECT 1 FROM suppressions s WHERE …`) interpolated
  where a boolean was needed, and an INSERT with TWO `ON CONFLICT` clauses (Postgres allows one —
  pick the arbiter that matches the identifier being written, since the table has two partial
  unique indexes). The tests were pure fiction again: `create_organization` treated as returning
  a dict, a nonexistent `api.auth(api, email=…, password=…)`, factories handed `db_pool`.
  Compose the shared predicate as a bare `SELECT 1 … WHERE …` so it works as
  `NOT EXISTS ({P})` in the enrollment filters and `EXISTS ({P} AND s.id = $n)` for stop-active.
  Bulk "one transaction, one bad row must not fail the batch" = outer `conn.transaction()` with a
  nested `conn.transaction()` (SAVEPOINT) per entry.

- TASK-3.6 (2026-09-07, rescore after enrichment, run-20260907-184337): loop-scope mistake a
  SEVENTH time plus fictional factory calls (`create_linkedin_account(db_pool, linkedin_id=…)`,
  factories handed `db_pool`, kwargs `organization_id=` on positional helpers). The builder never
  touched scheduler.py at all — it copied the scoring block into campaigns.py, called
  `qualify_many(leads, persona_dict, settings=None)`, zipped model results to rows by index, and
  registered the route as `@router.post("/campaigns/{id}/…")` under a router already prefixed
  `/api/v1/campaigns` (so the endpoint the tests hit did not exist). Its `scoreBuckets` also broke
  `test_campaign_stats_keys`, which asserts the stats dict by EQUALITY — a task that adds a stats
  key must update that test. **New trap: the acceptance check
  `test "$(grep -c 'qualify_many' scheduler.py)" -le 2` fails on the PRISTINE baseline** (import +
  call + one prose mention in tag_pass's docstring = 3, and the extraction adds a fourth);
  grep-count gates count comments, so check the count on HEAD before assuming the implementation
  is at fault — the fix is to reword the prose. Fix: extract `score_batch(rows)`
  into scheduler.py (qualify_pending calls it; campaigns.py calls `scheduler.score_batch` through
  the module so one monkeypatch covers both), reword the two prose mentions, rewrite both test
  files. Existing tests patch `scheduler.qualify_many`, which still works through the helper.

- TASK-4.3 (2026-09-07, LLM usage + cost, run-20260907-220053): two NEW failure modes, neither in
  the code. (1) **MagicMock as a fake completion is self-defeating**: the builder's
  test_llm_usage_capture.py did `completion.usage = MagicMock(); usage.prompt_tokens = 100` and then
  asserted `completion_tokens == 0` "because the field is missing" — a MagicMock invents every
  attribute, so the test asserted the opposite of what it said and no `_usage_of` could pass it.
  Build fake responses with `SimpleNamespace` (what test_llm_classify.py already does) so an absent
  attribute is genuinely absent. (2) **The spec required editing protected files**: requirement 3
  says the CALLERS (scheduler.py, conversation.py) call `record_usage`, but both are in
  protected_paths and `diff-limited-to-owned-paths` rejects them. The builder resolved it by making
  llm.py return tuples anyway, which broke every caller and test_llm_classify. The way through is
  the requirement's own alternative — "attach it to the existing result objects": pydantic
  subclasses (`LeadQualificationWithUsage(_WithUsage, LeadQualification)`, with `usage` an
  `exclude=True` field so model_dump/response_format are untouched) and a `str` subclass
  `GeneratedMessage` carrying `.usage`, so `body.strip()` and every caller keep working.
  Also: asyncpg refuses a float for NUMERIC — pass `Decimal(str(value))`; and db tests that INSERT
  with literal UUID strings hit the organizations FK, use `org_of(auth)`.

- TASK-7.1 (2026-09-08, tickets table + state machine, run-20260908-023022): **the branch was stale
  and `suite-green` was failing on a defect master had already fixed.** `tests/test_task_specs.py::
  test_migration_numbers_are_unique` failed because TASK-6.3 and TASK-7.1 both claimed
  `db/migrations/026_*`; master commit 0bc1603 ("split TASK-6.3, and move its migration off a number
  I collided with") had moved 6.3 to 035, but the worktree branched at ea7931c, before it. **Check
  `git log --oneline <branch-base>..master` FIRST when a task-spec / repo-hygiene test fails —
  those tests read tracked files the task never touches.** `git merge master` fast-forwarded and
  fixed it. That then exposed a second, real bug in `tests/test_task_specs.py::diff_scope_regex`:
  it returns the regex of the FIRST acceptance check containing `git diff --name-only` + `grep -vE`,
  including a **pathspec-scoped** one (`git diff --name-only HEAD -- db/migrations`), whose regex is
  about filenames in that directory, not repo paths — so TASK-7.8 "rejected its own owned paths".
  Most specs dodge it only by accident, spelling the migration check `grep -v` (no -E). Fixed the
  helper to skip any check with ` -- ` in the command (tests/ is owned, so no spec edit needed).
  Third: the builder shipped `services/api/app/routers/tickets.py` + a `main.py` include, which
  **TASK-7.11 owns** — 7.1's own requirement header says "The HTTP surface is TASK-7.11. This task
  owns the table and the state machine ONLY", even though the title/objective say "CRUD" and the
  `diff-limited-to-owned-paths` regex whitelists the router. Deleted it and put the org-scoped CRUD
  in the service instead. Its own test file was unrunnable anyway: a `@pytest_asyncio.fixture(
  scope="session")` depending on the function-scoped `db` (ScopeMismatch x6), `org.id` on factories
  that return bare UUIDs, and DB tests asserting a plain `UPDATE tickets SET state='resolved'`
  stamps `resolved_at` — the exact opposite of the requirement that only the service writes those
  three columns.

- TASK-7.11 (2026-09-08, ticket HTTP endpoints, run-20260908-053312): **the preflight's own
  "conventions" block lied, and the builder obeyed it.** preflight.md says "a fixture or helper that
  is not listed here does not exist, so do not invent one" and then lists only
  `tests/conftest.py: db_url, db_pool, db` — because the supervisor's scanner reads `@pytest.fixture`
  DEFINITIONS per file, and `api`/`auth`/`second_org`/`fake_redis`/`jwt_clock_leeway` are *defined*
  in tests/db/api_client.py and only re-exported by tests/conftest.py. With no HTTP client on the
  approved list the builder invented `from tests.db.api_client import ApiClient` (+ `ApiClient(db)`,
  `.create_token(org, user)`), and the single ImportError collected-error killed all three pytest
  checks at once. **When escalating an API-router task, expect the preflight to have hidden the
  `api`/`auth` fixtures; the real harness is `api` (httpx.AsyncClient over the app) + `auth` /
  `second_org` (registered OWNERS) from tests/db/api_client.py.** For a non-owner role there is no
  HTTP route that adds a second person to an org — mint the token directly with
  `app.auth.tokens.create_access_token(get_settings(), user_id=…, email=…, organization_id=…,
  role=…)` over a `factories.create_org_member(db, org, user, role="member"|"admin")` row.
  Under the ImportError the router was unrunnable anyway: it passed `conn=user.organization_id`
  (a UUID) as the asyncpg connection to every service call, read `request.subject`/`request.body`
  off a model with no such fields, counted the list by re-running `list_tickets(limit=1_000_000)`,
  and set `prefix="/tickets"` on the APIRouter while main.py mounted it at `/api/v1/tickets`, so
  every real URL was `/api/v1/tickets/tickets`. Two FastAPI facts worth keeping: `Query(alias=…)`
  REPLACES the wire name rather than adding one, and pydantic `AliasChoices` in a `Query` is
  ignored outright (verified on fastapi 0.141 / pydantic 2.13) — to answer to both `assignee_id`
  and `assigneeId` you must declare two parameters and coalesce. Also: never run two pytest
  processes against one worktree's test DB — the second run's truncation gives the first
  `401 {"detail":"User or organization not found"}`, which looks exactly like the WSL2 clock flake
  but is not (that one says "Invalid or expired token").

- TASK-10.4 (2026-09-08, tenancy audit, run-20260908-202734): **the spec's own "Verified
  2026-09-07 — take as given" preamble was stale.** It lists the routers to cover and omits
  `tickets` (and `metrics`), because TASK-7.11 mounted /api/v1/tickets after the spec was
  written. The builder covered exactly the listed routers, and the coverage test the SAME spec
  demands ("inventory derived from the route table, not hand-listed") correctly failed on five
  unprobed ticket routes. Nothing was broken — the fix was just the missing probes plus fixture
  rows (two tickets per org: the owner's, with a reply and a ticket_attachments row keyed by
  `storage.attachment_key`, and one the member opened). Notes: POST /tickets/{id}/attachments is
  the only MULTIPART route in the API (a JSON probe 422s in the parser and proves nothing — the
  Probe tuple needs a `files` field); the attachment read signs a URL, so the file must
  `monkeypatch.setattr(storage, "_store", InMemoryObjectStore())`. Real (small) leak found:
  `create_ticket_message` refuses a member's internal note BEFORE looking the ticket up, so a
  foreign ticket answered 403 instead of 404 — routers/tickets.py now resolves the ticket in the
  `except InternalNoteForbidden` branch. **When a spec header states a "verified" inventory,
  diff it against the live code first: later-numbered tasks merge in between.**

- TASK-6.4 (2026-09-08, webhook management API, run-20260908-233608): **the double-prefix bug from
  TASK-7.11, verbatim, one task later** — `APIRouter(prefix="/webhooks")` while main.py already
  mounts at `/api/v1/webhooks`, so every route served `/api/v1/webhooks/webhooks` and all six tests
  failed on `404 {"detail":"Not Found"}`. main.py was correct; only the router was wrong.
  **A uniform 404 on EVERY verb of a new router is the prefix, not the handlers** — the four
  reviewer findings all diagnosed handler logic (rotate "checks existence twice", delete "may not
  remove rows", scoping "returns 403") and were fiction; not one route had been reached. Under it:
  `create_endpoint(url: str, event_types: list[str], enabled: bool)` as bare params, which FastAPI
  reads as QUERY parameters, so the JSON body would have 422'd even once mounted — a router taking
  a body needs a pydantic model (`extra="forbid"`, camelCase fields, per suppressions.py).
  Two things the builder missed entirely: the wire convention is **camelCase** (its tests asserted
  `secret_prefix`/`event_types`; nothing in the repo speaks snake_case over HTTP), and a newly
  mounted router must be added to TASK-10.4's tenancy matrix in tests/db/test_tenancy_isolation.py
  or `test_route_table_coverage_leaves_nothing_unprobed` fails — that test was ALSO red in the
  report and is not a flake. Also re-confirmed: two concurrent pytest processes on one worktree's
  DB give `401` + spurious cross-org failures (see TASK-7.11); I did it to myself by backgrounding
  the full suite while running a subset, and it cost a confusing 3-failure detour.
  `hashing-is-not-reimplemented-here` greps the router for `sha256|hmac` including DOCSTRINGS.

- TASK-7.12 (2026-09-08, SMTP e-mail channel, run-20260909-023532): **the first escalation where
  every deterministic check passed and the reviewer was RIGHT.** failure class was
  "review-blocked, judgement call" — and the judgement is: believe the reviewer when its finding
  is "the test is vacuous", even when its *repair* instruction is wrong. Every test in the
  builder's file asserted `callable(x)` / `hasattr(x, 'send')`; not one called `send()`. Under
  that cover sat a guaranteed runtime crash — `smtplib.SMTP(host, port, timeout=30,
  context=ctx)`; `context` is an `SMTP_SSL` kwarg, so the TLS path TypeErrors on the first real
  delivery — plus a module-level `smtp_channel = SmtpEmailChannel()` resolving settings at import
  (the storage.py docstring already records that exact mistake taking the suite down). **The
  counterfactual check proves nothing when the tests are vacuous**: a1-counterfactual.log's only
  finding was `ModuleNotFoundError`, i.e. the tests prove the module EXISTS. Requirement 5
  ("tests use an in-memory EmailChannel and must never open a socket") had simply not been
  implemented, and that requirement is the one that would have caught all of it. Fix: rewrite
  both files on the `app/services/storage.py` shape (ABC + real + `InMemory*` + lazy
  `get_/set_*` singleton), `asyncio.to_thread` for blocking smtplib, and a scrub-and-reraise —
  every failure leaves as `EmailDeliveryError(scrub(...)) from None`, because `drain_queue`
  writes `str(exc)` into `outbox_messages.last_error` and `SMTPAuthenticationError` quotes the
  server's reply back at you. `from None` matters as much as the scrub: a chained `__cause__` is
  rendered in full by every traceback formatter. Tests enforce "no socket" with an autouse
  fixture breaking `socket.create_connection` + `socket.socket.connect` (leave `socketpair`
  alone — the asyncio self-pipe needs it). Two repo facts: `secret_policy.py` is neither owned
  nor protected and only `protected_paths` is enforced (supervisor.py:823), so adding
  `smtp_password` to `OPTIONAL_SECRET_FIELDS` is the sanctioned one-line way to get Settings
  redaction; and `scripts/gen_secrets.py` only PRINTS optional fields as commented hints, so
  adding one there generates nothing. Full suite on this box: 1414 passed / 25 skipped in 799s.

- TASK-7.14 (2026-09-09, WhatsApp channel, run-20260909-145631): **a NEW class — the builder
  imported a package the project does not depend on.** `tests/test_whatsapp_channel.py` and the
  adapter both `import aiohttp`; the worktree venv (and the gate's root venv) install only
  `requirements-dev.txt` -> requirements.txt, and aiohttp is in neither, so ONE collection
  ImportError reddened all three pytest checks at once. **The fix is never `pip install` — it is
  the repo's existing client, `httpx`** (already in services/api/requirements.txt, already used by
  llm.py and webhooks.py). Adding the dep would also have to survive a merge gate that reinstalls
  from the file. Under the ImportError the file was the TASK-7.12 pattern again: seven vacuous
  tests, and the ONE safety-critical requirement ("a number with no opt-in is NEVER messaged")
  covered by a bare `pass` — note that a `pass` stub makes `-k opt_in` exit 0, where deselecting
  everything would at least exit 5. Also invented scope: two provider implementations (Twilio +
  Facebook) where the requirement says "one implementation", and a `ValueError` at construction
  for missing credentials, which makes `get_whatsapp_channel()` explode for a deployment that
  simply has the channel off (make it a `WhatsAppDeliveryError` at send time instead — the outbox
  then records and retries it like any other failure). Techniques worth reusing: **`httpx.MockTransport`
  behind a one-line `_build_client()` seam** asserts the real `httpx.Request` (URL, Basic auth
  header, form body) with no socket; and a DB-gated requirement can still be tested in a
  socket-free file with a `FakeGate` connection that transcribes `delivery._MESSAGEABLE_NUMBER_SQL`
  plus a test pinning that SQL's two conditions, so the fake cannot drift from the query
  tests/db/test_whatsapp.py runs for real. Do NOT write the email-channel's "the real channel hits
  the socket guard" test for an httpx channel: httpx resolves DNS before it connects, so the guard
  does not catch it and the test does a real lookup. Suite here: 1667 passed / 23 skipped in 1049s.

- TASK-7.10 (2026-09-09, agent ticket queue, run-20260909-194305): **the first WEB task escalation,
  and the reviewer was right again — all five checks green, five findings, all true.** The 30B
  builder burned its 692 s wandering into `services/` (it edited the `list_tickets` ORDER BY,
  broke `test_list_is_newest_first`, then `git checkout`'d it) and shipped a placeholder: two
  screens, `+294/-0`, with a literal `<Text>History will be shown here (from TASK-7.3)</Text>`
  and no filters, no controls, no composer. **`npm run typecheck` cannot catch this class.**
  Everything was `useState<any[]>`, so the screens read `item.sla_breached` / `item.created_at`
  (the API serializes camelCase — `slaBreached`, `createdAt`) and typechecked green; live it
  would render a queue where nothing is ever breached and every date is "Invalid Date". The
  detail screen also took `{ route }: { route: any }` and read `route.params?.id` — React
  Navigation's API, not expo-router's `useLocalSearchParams()` — so it could only ever show
  "Invalid ticket ID". **When a web task stalls, grep the diff for `: any` before reading the
  reviewer's findings; the acceptance set has no runtime check at all** (there is no JS test
  runner in this repo — root package.json has only `typecheck`, and `tests/` is pytest).
  What I added as the durable guard: `tests/test_ticket_web_contract.py`, a pytest that
  `ast`-parses the router's `_serialize_*` return dicts and regex-parses
  `apps/web/lib/api/tickets.ts`, asserting the TS field names match the API's exactly (both
  directions) plus the mirrored constants (states/kinds/priorities, ALLOWED_TRANSITIONS,
  MESSAGE_BODY_MAX, MANAGER_ROLES). Verified it fails on the real bug by reintroducing
  `sla_breached`. **This pattern generalises to every future web task.**
  API facts for the ticket screens: `GET /tickets` is newest-first with NO sort parameter, so
  "breached, then priority, then oldest" must be client-side; the `assignee_id` filter has no
  value meaning "unassigned" (absent = no filter); and **no endpoint lists `org_members`**, so an
  assignee picker can only be built from ids the ticket payloads carry. Kit gotchas: `SkeletonText`
  is ONE line (no `lines` prop), and `Icon`'s `className` only styles a wrapper `View` — an icon
  font needs `color={C.mute}`, since NativeWind never registered the vector-icon families.
  Suite here: 1695 passed / 24 skipped in 1086s.

- TASK-6.7 (2026-09-10, blacklist/security/webhooks settings screens, run-20260910-134851):
  **a NEW class — MASTER was already red, so `suite-green` was unwinnable before the builder
  started.** Only one failure was the task's own: `const router = useRouter()` missing in
  `settings/index.tsx` (3x TS2304). The other 939 errors were the slot-port collision (see
  [[shared-test-db-migration-collision]]) and the remaining **5 failures were pre-existing on
  the base commit**, from the TASK-7.9 merge colliding with TASK-7.10: 7.10 put the ticket
  types AND an agent client (PATCH, `visibility: 'internal'`) in `apps/web/lib/api/tickets.ts`;
  7.9 then moved the types to `lib/api/types.ts` and wrote its CUSTOMER client into the same
  file, while its own `tests/web/test_help_centre_contract.py` asserts no customer-facing
  source mentions PATCH/`visibility`/`'internal'`. Each branch was green alone; merged, the two
  contract tests contradict. **When `suite-green` fails on files the diff never touches, check
  whether the failing files changed on master — `git log --oneline -5 -- <failing file>` — before
  touching the diff.** Fix (in the escalation worktree, since nothing else can go green):
  split the customer half into `apps/web/lib/api/helpcenter.ts` and point 7.9's
  `customer_facing_sources()` at it; point 7.10's `_ts_type_fields` at `types.ts`. Both
  assertions keep their exact meaning — the guarantee "the customer surface has no visibility
  parameter" is only checkable if the agent client is not in the same file.

- TASK-9.2 (2026-09-10, Google account linking, run-20260910-231608-9a49c5): top layer was an
  ImportError on an INVENTED rate-limit dependency (`limit_oauth_link`); the reviewer's repair
  ("add it to rate_limiting.py") would have been invented scope too. Under it: tests calling
  `db.acquire()` on the `db` connection plus three bare `pass` stubs. Real design traps, none
  visible to the builder: (1) **owned_paths had routers/oauth.py but NOT main.py**, while
  TASK-9.4 (built concurrently) owns both, so mounting a new router means editing a file another
  live task owns — the way through is routes in routers/auth.py (already mounted at
  /api/v1/auth, so `/oauth/google/link` gives the spec URL with no main.py edit). (2) Req 2
  (auto-link a verified, exact address) contradicts TASK-9.1's
  `test_an_email_that_already_has_an_account_is_refused_not_linked` and TASK-9.4's requirement 5
  ("REFUSED here") — changed the 9.1 test to a case-differing address; **9.4 may go red at its
  merge gate if it asserts a verified exact match is refused.** (3) "recorded so the user can
  see it" had no sink without a migration: notifications' `type` CHECK admits 3 engine types,
  events.EVENT_TYPES is in a protected file → used the outbox (`delivery.enqueue`, e-mail).
  (4) `test_api_auth::test_auth_me_returns_registered_user` asserts /me by EQUALITY, so any
  task adding a /me field must update it; new routes need TASK-10.4's EXEMPT/probe entry.
  Route-test technique: `monkeypatch.setattr(get_settings(), "google_oauth_client_id", …)`
  works (Settings is not frozen), and `app.dependency_overrides[oauth.get_google_keys]` /
  `[oauth.get_google_http]` feed the real exchange FakeGoogle's RS256 keys + an
  httpx.MockTransport token endpoint. Slot env was 66 / 26600 / agentci_task_9_2.

- TASK-9.4 (2026-09-10, Google session issuance, run-20260910-231608-c24e69): **a PLACEHOLDER
  implementation, not plumbing.** The router passed a hardcoded `code_verifier="test-verifier"`,
  stored no state anywhere, and "issued" tokens by calling `login_user` with `password=""` (can
  never succeed); its test called `register(api, email=…)` (real signature: `register(api, tag)`,
  it generates the email). The reviewer's F001 repair ("compare with a value stored in a session
  or cache") pointed at storage that did not exist. Two things the builder could not see:
  `resolve_user` creates a user with NO organization, but every access token carries `org_id`, so
  the first Google sign-in must create a workspace exactly as register does (tags + presets +
  owner row); and registration issues a session of its own, so a password user has TWO sessions
  after login. Fix: per-attempt state + PKCE verifier in a signed, HttpOnly, SameSite=Lax cookie
  path-scoped to /api/v1/auth/oauth/google (the SPA and the API share an origin via nginx, and a
  cookie is what stops login CSRF — a Redis store keyed by state would not), tokens via
  `app.auth.service._issue_tokens` (service.py is not in 9.4's owned_paths), and a new tenancy
  EXEMPT entry. Merge risk with 9.2 (built concurrently): both add `get_google_keys` /
  `get_google_http` seams, and the 409 test uses a case-differing address so it survives 9.2's
  exact-match auto-link. Suite: 1838 passed in 210s.

- TASK-9.3 (2026-09-10, Google button + settings panel, run-20260911-001304-dd77f8): **placeholder
  again, reviewer right** — every handler was `console.log`, all four tests `pass`, and the
  button sat BELOW the form (req says above). Traps found: (1) **TASK-9.4 PASSED but never merged**
  (state/unmerged.json: conflict in tests/db/test_tenancy_isolation.py), so `/oauth/google/start`
  and `/callback` are NOT in master — the preflight still lists 9.4 as "delivered". Client was
  written against 9.4's spec; the start/callback test pins the paths to tasks/TASK-9.4.yaml and
  checks the live route table only once they are mounted. (2) routers are mounted lazily: a flat
  `app.routes` scan for APIRoute returns an EMPTY set — walk `route.original_router` +
  `include_context.prefix` like test_tenancy_isolation's `iter_routes`. (3) test_design_tokens'
  raw-hex rule scans COMMENTS in apps/web/{app,components}; a brand asset with fixed colours goes
  in apps/web/assets/*.svg (metro assetExts has svg; RN `require()` types fine). (4) kit index.ts
  is frozen by test_design_kit — new kit controls are imported by path and added to CONTROLS.
  (5) AuthContext's redirect effect bounces any route outside `(auth)` when signed out and any
  inside when signed in; an OAuth return route visited in both states needs an exemption
  (`segments[0] === 'auth'`). apps/web/context is unowned but not protected (only protected is
  enforced). (6) link needs the verifier in the POST body but /start keeps its verifier in an
  HttpOnly cookie → the settings flow does client-side PKCE and rewrites /start's URL.

- TASK-9.4 second escalation (2026-09-10, run-20260911-011010-494bf4): **the first run passed
  but its merge conflicted, so it was rebuilt on top of master (8e20e5a merged 9.2 + 9.3 in), and
  a /me EQUALITY assertion in 9.4's OWN test went stale** — 9.2 made /me return
  `{**user, "identities": [...]}`. The builder's one attempt did nothing (empty activity log), and
  the reviewer's P0 ("_session_for hardcodes role='owner'") was fiction: the code reads
  org_members first. Fix: pop `identities`, assert the single google identity, compare the rest
  by equality. **Any test comparing /me by equality breaks when a concurrent task adds a /me
  field; grep `me.json() ==` after merging master.** Slot env: agentci_task_9_4 / base 20800 /
  slot 0 (port 20834). Suite: 1880 passed / 33 skipped in 209s.

- TASK-11.1 (2026-09-11, voice memory, run-20260911-161036-11e4d8): **the supervisor filed it
  "environment / database — not a defect in the diff" and did NOT escalate; it WAS the diff.**
  db-up died on `constraint "llm_usage_purpose_check" … already exists` because migration 036 did
  `ADD CONSTRAINT` under the name 024 already uses. Widening a CHECK is always
  `DROP CONSTRAINT IF EXISTS` then `ADD` (008/010/012/017/020/021 all do it). **When the failure
  class says "environment" but the error text quotes SQL from a new migration, read the migration
  first.** The other four red checks: (1) `test_task_specs::test_scope_pattern_accepts_every_owned_path`
  red for ALL of TASK-11.1..11.7 (on master too): `diff_scope_regex` took the `grep -vE` from the
  `git status --porcelain | grep -vE '^\?\? (…)'` half of a `&&` chain as if it filtered diff
  paths — fixed the helper to read only the `&&` segment holding `git diff --name-only`.
  (2) protected-paths: `deploy/linode/deploy.sh` 100755→100644 — NOT the builder, see the
  TASK-11.1 second escalation below.
  (3) new routes missing from the tenancy PROBES (needs seeded example/note rows + `example_id`/
  `note_id` ids). (4) test file: session-scoped fixture over function `db` (ScopeMismatch),
  `org["id"]` on bare-UUID factories, and a redact test demanding "John Smith" become
  `{{first_name}} {{full_name}}` (contradicts the requirement). Also: the GET list must include
  switched-OFF rows (TASK-11.6 switches them back on) and `originalBody` (11.6 shows the draft
  beside the edit); `source_ref` uniqueness is a partial unique index (11.3 keys it by run id).
  redact = one regex pass, alternatives longest-first, `(?<!\w)…(?!\w)` not `\b` (handles
  "Acme Inc."/"AT&T"). Slot env: agentci_task_11_1 / base 24400 (port 24434). Suite: 1925
  passed / 40 skipped in 195s.

- TASK-11.1 second escalation (2026-09-11, run-20260911-170523-1fed31): **the supervisor itself
  failed the task — every acceptance check was green and the builder changed nothing.** The only
  red was protected-paths on `deploy/linode/deploy.sh` 100755→100644. Cause:
  `agent_ci/git/repository.py::write_tree` snapshots through an EMPTY temp index (`add -A`), and
  with `core.fileMode=false` git gives every file with no prior index entry mode 0644. So every
  executable file flips in every snapshot. 65e8c17 (2026-09-10 22:03) made deploy.sh the repo's
  ONLY 100755 file, and all 68 task specs protect `deploy/`. From then on EVERY task fails
  protected-paths, whatever its diff (the 161036 run had the same flip). Reproduce:
  `GIT_INDEX_FILE=$tmp git add -A && git write-tree` then `git diff-tree --summary HEAD <tree>`.
  The tree matched the supervisor's snapshot event exactly. Fix (outside any worktree, so
  escalation cannot make it): `git read-tree HEAD` into the temp index before `add -A`. Verified
  that gives a tree identical to HEAD's. **When protected-paths names a file the builder never
  opened, and the only change is a mode change, reproduce the snapshot before blaming the diff.**

- TASK-11.2 (2026-09-11, voice memory in the prompt, run-20260911-181931-9555ed): **review-blocked,
  reviewer right about the tests (`assert True` x2) but it missed the real defect: the feature was
  never wired.** The builder added `conn/organization_id/persona_id=None` kwargs to generate_message
  and conversation_reply that NO call site passed, so voice memory never reached a prompt, and it
  omitted the "don't copy verbatim / never leave a {{placeholder}}" framing. The reviewer's repairs
  (assert strings in client.calls) would have passed with the feature still dead. **A new optional
  kwarg defaulting to "do nothing" is a placeholder: grep the call sites for it.** Fix: Persona
  gets `voice_examples/voice_notes: tuple[str, ...] = ()`, `_voice_lines` renders after Voice and
  tone (nothing when empty = byte-identical block), `voice.persona_for_writing(conn, row)` (voice
  imports llm, not the reverse) used inline at all 4 writing call sites; requirement "a test fails
  if a call site skips it" = an `ast` scan of services/api/app for every generate_message/
  conversation_reply call whose persona arg is not `await persona_for_writing(...)`, plus a db test
  per real path. Mutation-checked both. The source files are CRLF: sed `$` anchors miss — edit
  via Python bytes. Slot env: agentci_task_11_2 / base 29600 (port 29634).

- TASK-11.3 (2026-09-11, edits teach the voice, run-20260911-190433-fbc71d): **review-blocked,
  reviewer WRONG (F001 claimed redact() misses a first name inside full_name — it does not), but
  the diff was still defective in ways no check saw**: `edited != rendered.strip()` is not the
  required "whitespace collapsed" compare; no `ON CONFLICT` although 036 has a partial unique index
  on (persona_id, source_ref), so a re-approval would 500 AND roll the approval back; the "twice"
  test only proved the 404. **New trap: the worktree was cut from master BEFORE its dependency
  (11.2) merged** (run start 19:04Z, 11.2 merge 19:12Z; preflight still said "delivered"), and
  both branches add a `from app.services.voice import …` on the same line — the supervisor's
  refresh rebase would have hit a conflict and left the branch untouched. Check
  `git merge-base HEAD master` vs `git log master` first; I WIP-committed, rebased onto master,
  resolved, and amended into one commit. Also dropped the builder's bare-`git stash` leftover
  (it stashes/pops in a shared stack). Slot env: agentci_task_11_3 / base 27600 / slot 76.

- TASK-11.4 (2026-09-11, voice playground, run-20260911-191334-0be29e): **state/HUMAN_REQUIRED.md
  was ALREADY OVERWRITTEN by a later run (TASK-11.3's)** — it is one global file; go by
  `logs/<run>/events.jsonl` + `logs/<run>-a1/*.stdout.log`. Top layer: `mode: Literal[...]` in a
  router with `from __future__ import annotations` and NO `Literal` import -> the body model never
  resolves, so every request raises `PydanticUserError: TypeAdapter[...VoiceTryBody...] is not
  fully defined` (the counterfactual log's 404s are the PRISTINE baseline, not the diff). Under
  it, the tests contradicted each other: with no LLM fake, one demanded 503 and the rest 200 +
  redacted text. Also unimplemented: no record_usage('playground'), reply via generate_message
  instead of conversation_reply, no redaction before storing. Design chosen: /try returns the
  text AS WRITTEN; /rate takes optional `sampleLead` + `mode` and redacts (text and comment)
  before insert — "redacted before it can become an example". A down note without comment =
  `Do not write like this: "<redacted quote clamp 200>"`. Test seam: fake at `llm._client`
  (`.create` for generate_message, `.parse` returning a ConversationDecision for
  conversation_reply), `no_key` = `_client=None` + `llm.get_settings -> Settings(openrouter_api_key="")`.
  The api fixture's FakeAsyncRedis.rpush raises, so "enqueues nothing" is enforced for free.
  **No production code calls metrics.record_usage** (only defined + docstrings) — the playground
  is its first caller. Slot env: agentci_task_11_4 / base 23800 / slot 38 (port 23834).

- TASK-11.5 (2026-09-11, coaching chat, run-20260911-203040-3d2c3a): **worktree cut before its
  dependency merged, a SECOND time in Phase 11** (base 65c0c85; TASK-11.4 = a1caab4/d54de77 only on
  master), so the builder never saw /voice/rate, the playground's 503/usage/fake-model pattern, or
  test_voice_playground.py. `git log HEAD..master` first; master..HEAD was empty, so dropping the
  builder's uncommitted diff (kept in refs/agent-ci/attempts/…) + `git merge --ff-only master` was
  enough. The builder's code was a placeholder (hardcoded interview questions picked by
  `len(transcript)`, rehearse had the AI play the PROSPECT, `generate_message(client, prompt=…)`),
  its tests used a nonexistent `app.test_client()` and `.id` on factory UUIDs. Reviewer F002
  ("_own_persona_id undefined") was fiction — it exists. The 5th suite failure,
  test_llm_voice_prompt's AST scan, flags ANY new generate_message/conversation_reply call whose
  persona is not `await persona_for_writing(...)`. Design: rehearse = conversation_reply +
  persona_for_writing, with the "never deny being an AI" rule in its existing `objective=` slot;
  interview/suggest = new structured calls in llm.py (§5) that do NOT take the persona block;
  the interview rules (topic not in model-reported `covered`, summary only once all four are
  covered, at most one "?") are checked server-side and a violation is sent back as a correction
  turn; suggest returns PersonaPatch field names and replaces a blank field with the current text,
  because PATCH treats "" as CLEAR. Slot env: agentci_task_11_5 / base 23100 / slot 31 (port 23134).

- TASK-11.3 second escalation (2026-09-11, run-20260911-210646-f8f18c): **workspace-containment
  was a FALSE POSITIVE from the parallel runner — another task's merge gate, not the builder.**
  The builder only viewed files and wrote nothing. The four "escaped" files (test_coach.py,
  personas.py, llm.py, test_tenancy_isolation.py) were byte-identical to agent/TASK-11.5, whose
  re-run (210629-773a66) ran alongside and whose gate did `merge --no-commit --no-ff` in the ROOT
  at 15:17:13 local (ORIG_HEAD mtime); 11.3's `_quarantine_escapes` diffed root `git status`
  across the build window at 15:18:01 and blamed the staged merge on the builder. Its "revert"
  (`git checkout -- path`) restores from the INDEX, so on staged files it was a no-op, and the
  11.5 merge landed intact (b9c598c, 15:26:34). `_root_dirt` is not coordinated with
  `_MERGE_LOCK` (cli.py); fix in ~/agent-ci: skip the escape check while the merge lock is held,
  or ignore entries whose worktree column is clean (`M ` / `A ` = staged by the gate; a builder
  writes `' M'` / `??`). **Tell: escaped files hash-equal to a sibling agent/* branch + root
  `git status` showing them STAGED.** Worktree needed no change (acceptance green on 54304ef).

- TASK-11.6 (2026-09-11, Train-this-voice screen, run-20260911-215431-b1b01b): **two independent
  blockers, and the reviewer was right about both of its findings.** (1) db-up died with
  `asyncpg.exceptions.InvalidCatalogNameError: database "agentci_task_11_6" does not exist`, which
  reads like a migration/env fault and is not: slot 38 (port 23834) had been handed to TASK-11.4
  hours earlier and `agentci-task-11-4-postgres-test-1` was STILL UP on that port, so 11.6's own
  container came up with NO published port (`docker ps` shows bare `5432/tcp`) and migrate_local
  connected to 11.4's database. **Tell: `docker ps` shows your container healthy but portless while
  a finished sibling holds your port.** Fix: `docker rm -f agentci-task-11-<sibling>-postgres-test-1`,
  then `docker compose -f docker-compose.test.yml down` + `bash scripts/test_db.sh up`. See
  [[shared-test-db-migration-collision]]. (2) Under it the task was simply NOT BUILT: `train.tsx`
  was an EMPTY file and `tests/test_voice_ui.py` was four `assert True` stubs, so `suite-green`'s
  1069 errors were all collateral from (1). Phase 11 shipped the whole voice BACKEND (11.1 memory,
  11.3 edits, 11.4 playground, 11.5 coach) and ZERO web — 11.6 is the first screen for any of it,
  so there was nothing to copy from. Wrote `apps/web/lib/api/voice.ts` + two panels under
  `components/screens/settings/` + the route, added a labelled "Train this voice" Button to the
  row in `settings/personas.tsx`, and added `thumbs-up`/`thumbs-down` to kit `Icon.tsx` FEATHER
  (additive; test_design_kit freezes only index.ts's EXPORT names, not the icon set).
  Test technique for any future web task, following test_sso_ui.py: read the .tsx as TEXT and ask
  the API for real. Reusable bits — `from tests.test_sso_ui import api_routes` (the lazy-router
  walker; a flat APIRoute scan returns 0 routes, so ALWAYS assert the table is non-empty or the
  rule passes vacuously); a `code(path)` that strips `//` and `/* */` FIRST, because a docstring
  explaining "never render `{err}`" trips its own no-raw-error rule; and an INDENTATION-based
  `block(source, marker)` (scan to `^<indent>[}\])][)}\];,]*$`) rather than brace counting, since
  `function Foo(` opens its parameter list before its body and a `}: {` line at the same indent
  ends the params, not the block. `Path.read_text()` normalises CRLF, so these survive
  core.autocrlf=true. Slot env: agentci_task_11_6 / base 23800 / slot 38 (port 23834).
  Suite: 2033 passed / 40 skipped in 226s.

- TASK-11.7 (2026-09-11, coaching chat on screen, run-20260911-233312-3b736e): **the reviewer's
  12 findings were all TRUE and all shallow — the real blocker was that the builder wrote its
  test file against the WRONG LAYER.** `tests/test_coach_ui.py` re-tested TASK-11.5's API routes
  (already covered by tests/db/test_coach.py) instead of the screen, and did it with invented
  plumbing: `create_user(db, organization_id=org)` (users has no such column — the SEVENTH time
  this exact invention has stalled a task, see TASK-1.7), `create_persona(db, org)` against a
  `personas` table that does not exist (it is `campaign_personas`), `api.get(...)` on a POST
  route, and unmocked LLM calls asserting Spanish text. Rewrote it as a UI contract file on
  TASK-11.6's pattern — `from tests.test_voice_ui import block, code, read, rel, api_routes, …`
  rather than a second copy of the helpers — asserting the source against live API objects
  (`get_args(CoachTurnBody.model_fields["mode"].annotation)`, `VoiceRateBody.source`, migration
  036's CHECK, the route's own `"…": suggestion.` return keys) plus six real API calls that stop
  at a guard BEFORE the model (400/422/404/503 + a /voice/rate round-trip), with a `no_model`
  fixture whose `.parse` raises so a regression cannot reach the network.
  **Also a requirements-vs-merged-test contradiction:** 11.6's
  `test_the_screen_has_the_examples_and_try_it_tabs` asserts `labels == ["Examples", "Try it"]`
  by EQUALITY, and 11.7's first requirement is a third tab — relaxed to `labels[:2] == [...]`
  (requirements outrank a test in the tree, and that is still a real regression guard).
  The component itself compiled against a kit that does not exist: `toast.show` (it is
  ok/error/info/dismiss), `<Modal visible>` (it is `open`/`onClose`/`title`/`footer`),
  `Chip variant="secondary"` (variant is solid|outline, tone is neutral|amber|blue|green),
  `bg-surface2` (no such token — `bg-line2`), EmptyState `action={<Button/>}` (it is
  `actionLabel`/`onAction`), and `voiceErrorMessage` imported from `@/lib/api/coach` when it
  lives in voice.ts. **Check the kit's own .tsx prop types before trusting a 30B builder's JSX.**
  Its Apply handler was a placeholder ("would be handled by the parent component") with a
  `toast.show('Suggestion applied')` — the requirement is a real `patchPersona`, and the
  shared-profile guard means sending `confirmSharedEdit: false` first and turning the 409
  `persona_shared` (branch on `ApiError.code`, never the prose) into a second question.
  Interview and rehearsal need SEPARATE client transcripts: the rehearse route maps `user` →
  inbound, so replaying an interview through it feeds his own answers back as prospect messages.
  Slot env: agentci_task_11_7 / base 29500 / slot 95 (port 29534). Suite: 2055 passed / 40
  skipped in 229s.

- TASK-12.1 (2026-09-12, connector pairing code, run-20260912-002859-4031cc): **`ApiClient` invented
  again** (the TASK-7.11 signature, verbatim — `from tests.db.api_client import ApiClient`, one
  ImportError reddening all three pytest checks), plus factories treated as dict-returning and a
  session-scoped fixture over function `db`. Under it the diff was fabricated in three ways worth
  remembering: (1) it **deleted `import uuid`** from routers/linkedin.py while line 331
  (`create_account`) still calls `uuid.uuid4()` — no test caught it because its own file never
  collected; grep the diff's removed imports for names the untouched code still uses. (2) The
  migration defined a plpgsql `ensure_proxy_port()` **duplicating the Python service** the spec
  names (`services/linkedin_session.ensure_proxy_port`) and re-ADDed `proxy_port`, which 011 already
  owns. (3) Routes looked accounts up by `WHERE id = $1` with the `li_…` account_key — the
  eighth-ish recurrence of the key-vs-UUID confusion; `_account_uuid` in that router is the pattern.
  Real design notes: `ensure_proxy_port` returns None when pinning is simply UNCONFIGURED
  (OPERATOR_PROXY_HOST is empty in the suite), so "no free tunnel slot" must be
  `port is None and proxy_pinning_enabled(settings)`, and tests turn pinning on with
  `monkeypatch.setattr(get_settings(), "operator_proxy_ports", "10001")`. The quarantine is one
  extra `NOT EXISTS (SELECT 1 FROM connectors c WHERE c.port = t.p AND c.port_released_at IS NULL)`
  in that function's pick CTE. A new role gate needs its own test in test_tenancy_isolation.py
  (this one refuses with 404 on BOTH sides, unlike the ticket gate's 403/404) and its routes in
  PROBES with a VALID body, or the probe passes on a 422. **Editing an already-applied migration
  means `scripts/test_db.sh reset`** — migrate_local.py checksums the file and aborts db-up
  otherwise. Slot env: agentci_task_12_1 / base 24600 / slot 46 (port 24634). Suite: 2147 passed /
  59 skipped in 250s.

- TASK-12.4 (2026-09-12, connector presence / owner_offline, run-20260912-012208-e23ad9): top layer
  was the usual missing factory (`create_connector`), but the real blocker was that **a protected
  migration contradicted a requirement**: the spec says "accounts without a connector keep
  connector_online NULL" while TASK-12.1's 037 declares it `BOOLEAN NOT NULL DEFAULT false`, and
  `db/migrations/` is protected AND excluded by the scope-respected check. So the raw column reads
  `false` for every account that never paired a machine. Resolution that satisfies both: readers
  derive the NULL (`CASE WHEN EXISTS(live connector) THEN … END` in HEALTH_COLUMNS and in the
  health_pass query, nulling connector_online AND connector_checked_at together so a REVOKE also
  clears it), and account_health gates on BOTH columns — `connector_checked_at is not None and
  connector_online is False`. The second half matters because `tests/db/test_account_health.py`
  does `SELECT *` and would otherwise turn every account owner_offline; **when a new NOT NULL
  boolean feeds a pure classifier, find the tests that pass a raw `SELECT *` row before choosing
  the rule.** Also: adding a key to health_pass's counts breaks the 8 `assert counts == {...}`
  equality assertions in test_health_pass.py — pre-existing tests, so add `"owner_offline": 0`
  rather than redesigning. The builder's own diff was a placeholder: probing `127.0.0.1` instead of
  `settings.operator_proxy_host`, UPDATEing `connectors.connector_online` (no such column), the
  10-minute stuck-port warning on the `not reachable` branch (inverted), owner_offline computed
  inline in the scheduler instead of in `account_health`, and nothing touching
  `_apply_pg_facts`/`_POSTGRES_OWNED_KEYS` so `connectorOnline` never reached the API response. It
  was cheaper to `git checkout -- scheduler.py` and rebuild from master than to repair. **Editing
  a CRLF test file from Python: `read_text()`/`write_text()` silently normalise — split/join on
  `\r\n` over `read_bytes().decode()` or you get a blank line between every inserted line.** Slot
  env: agentci_task_12_4 / base 28300 (port 28334). Suite: 2183 passed / 59 skipped in 275s.

- **TASK-12.2** (pairing exchange): two independent blockers, neither an implementation problem.
  (1) The builder hung the *unauthenticated* `POST /connector/pair` off `routers/linkedin.py`,
  whose router carries `dependencies=[Depends(get_current_user)]` and a `/api/v1/linkedin`
  prefix — so the spec's path 404'd and the tenancy EXEMPT entry read as stale. Fix: its own
  `routers/connector.py` mounted at `/api/v1/connector` in main.py (owned_paths covered
  services/api/app, so main.py was mine). (2) It added `connector_secret` to
  `secret_policy.REQUIRED_SECRET_FIELDS`, which drags `.env.example` **and**
  `scripts/gen_secrets.py` — both protected — into the diff and reds three
  tests/test_config_safety.py tests. Rule: if a requirement says the feature answers 503 while
  its secret is empty, the secret is OPTIONAL_SECRET_FIELDS (still redacted via SECRET_FIELDS),
  never REQUIRED. Also: a stray `backup_linkedin.py` at the repo root was the whole of
  `scope-respected`, and 037 makes `connector_online` NOT NULL DEFAULT false while the spec says
  "sets connector_online NULL" — same contradiction as TASK-12.4; spell unknown as
  `connector_online = false` + `connector_checked_at = NULL` rather than touching db/migrations.
  Slot env: agentci_task_12_2 / base 22500 (port 22534). Suite: 2179 passed / 59 skipped in 264s.

- TASK-12.3 (2026-09-11, relay authfile follows the DB, run-20260912-032116-9143bb): **the builder
  invented the FILE FORMAT and then wrote tests that agreed with it.** The spec header says the
  authfile is a JSON object `{"user:pass": [anchored pattern]}` (what `deploy.sh relay add` writes);
  it shipped line-based `user:password` text. It also INVERTED the managed/operator rule —
  requirement says keep every user NOT starting with `sfc-`, and 037 CHECKs `relay_user ~
  '^sfc-[0-9a-f]{12}$'`, i.e. `sfc-` IS the managed half — so its render preserved exactly the
  entries it was supposed to rewrite. Visible error was `UndefinedColumnError: column c.remote_port
  does not exist` (the column is `connectors.port`). The three reviewer findings were all one
  fiction ("must write the file even when nothing changed"), which is the opposite of the
  requirement: chisel watches the DIRECTORY and reloads on every write, so the second call must
  leave bytes AND mtime alone — `json.dumps(..., sort_keys=True)` is what makes "unchanged"
  reachable. **Also: `settings.relay_authfile` did not exist in config.py at all** — the spec says
  "the path arrives as settings.relay_authfile", and nobody added the field; non-secret, so no
  secret_policy/.env.example fallout. Fix: rewrote the service around JSON + `^R:0\.0\.0\.0:<port>(:.*)?$`,
  mkstemp+fsync+os.replace in the same dir under a sibling `.lock` flock, ValueError from `render`
  on an unparseable file so sync logs and skips, and rewrote both test files from the requirements
  (the pattern test compiles every rendered regex and attacks it with the neighbour port, the
  `100010` prefix trick and an `evil-` prefix). Slot env: agentci_task_12_3 / base 27200 / slot 72.
  Suite: 2243 passed / 59 skipped in 286s.

**To run a worktree's tests by hand**, export the slot env the harness had — the container name
carries it: `docker inspect agentci-task-6-1-postgres-test-1` gives POSTGRES_DB and the port.
For TASK-6.1: `AGENT_CI_DB_NAME=agentci_task_6_1 AGENT_CI_COMPOSE_PROJECT=agentci-task-6-1
AGENT_CI_PORT_BASE=24300 AGENT_CI_SLOT=1` (port = base+34). Without them tests/conftest.py falls
back to the shared 5434 database, which belongs to the main tree. See
[[shared-test-db-migration-collision]].

**Why:** the failure report blames "connection handling", "missing migration" or FK
constraints; the real cause is test plumbing, invented endpoints, or the host clock. Reviewer
"evidence" quoting an exception must be grepped in the a*/ stdout logs before believing it.
**How to apply:** when escalated, first read `logs/<run>-a<N>/<check>.stdout.log` for the
real traceback (HUMAN_REQUIRED.md only shows the tail), diff the new test file's header
against a passing sibling in tests/db, run `.venv/bin/python -m pytest` (never system
python), run the FULL suite at least twice because of the clock flake, and run
`npx tsc --noEmit` in apps/web even if the task yaml does not list it. Docker for
scripts/test_db.sh (port 5434) is the sanctioned local test Postgres; the "no Docker" rule is
about the VPS stack.

- TASK-12.5 (2026-09-11, owner-offline pause, run-20260912-025748-96b63b): **the escalation and the
  ORIGINAL builder ran in the same worktree at the same time.** The run was moved to
  HUMAN_REQUIRED at 22:23 and handed to me at 22:25:37, but nothing reaped the builder: its shells
  live in a detached `tmux -Lopenhands` server whose parent is /init, not the supervisor. It kept
  a ~6-minute `git stash` -> test -> `git stash pop` cycle in my cwd, so twice my five edited
  source files reset to HEAD and came back, and my UNTRACKED new test file was taken by `stash -u`
  and never returned (stash@{0..3} were all "WIP on agent/TASK-12.5", none mine). **Tell:
  `git status` clean when you just edited, four files with mtimes one second apart, and WIP
  stashes on a branch you never stashed. Fix: COMMIT to agent/TASK-12.5 immediately** — a commit
  survives stash and `reset --hard`, and the supervisor commits the escalation tree itself
  anyway (supervisor.py builds "TASK-N.M: <title>" + add_all_and_commit). Never pop/drop the
  stashes; they are the live builder's. Peer agent-ci sessions are reachable via ListAgents /
  SendMessage and diagnosed this faster than I could.
  The task itself: the builder's diff added `AND (a.connector_online IS TRUE OR a.connector_online
  IS NULL) AND a.connector_online IS NOT FALSE` to dispatch_due and maintenance_pass. Migration
  037 declares `connector_online BOOLEAN NOT NULL DEFAULT false`, so NULL never occurs and every
  account that never paired a machine reads false -> the whole fleet stopped (45 suite failures).
  The REVIEWER's repair was worse ("change it to `a.connector_online IS TRUE`"): it quoted the
  STALE copy of the spec inside the worktree ("NULL behaves exactly as today"), while the root
  `$AGENT_CI_TASK_FILE` had already been corrected to key on `connector_checked_at IS NOT NULL AND
  connector_online IS FALSE`. **When a reviewer quotes requirement text you cannot find in
  tasks/<id>.yaml, diff the worktree's copy against the root's.** Right rule = one
  `linkedin_session.owner_offline_sql(alias)` shared by dispatch_due, maintenance_pass and
  conversation.CLAIM_SQL, narrowed to a LIVE connector exactly as CONNECTOR_COLUMNS is, so a
  revoked connector does not freeze the account forever on its last probe. CONNECTOR_OFFLINE is
  handled in routers/internal.py job_event AHEAD of the ACCOUNT_FATAL_CODES branch (stamp both
  connector columns, close the step run, enrollment back to 'active' on the SAME step now()+10min,
  no pause / no needs_reconnect / no job.failed) and is deliberately not in ACCOUNT_FATAL_CODES.
  Committed 9827df0. Slot env: agentci_task_12_5 / base 26400 / slot 64 (port 26434).
  Suite: 2198 passed / 59 skipped in 274s.

- TASK-12.6 (2026-09-12, worker connector mode, run-20260912-043055-0588dd): **the ONLY red check
  was an unrelated pre-existing flake, so "does a plain re-run help? yes" was true and would have
  merged a 37-line stub.** suite-green's single failure was
  `tests/db/test_ticket_history_api.py::test_the_endpoint_returns_the_timeline_oldest_first`
  (`'ticket.message_added' != 'ticket.created'` at index 0) — `list_ticket_events` orders
  `occurred_at ASC, id ASC` where occurred_at is `clock_timestamp()` and id is
  `gen_random_uuid()`, so any tie is a coin flip. It did not reproduce in three full runs. Protected
  path (services/api) and the real fix is a BIGSERIAL migration + an ordering-contract change, so
  leave it. **The lesson: when the only failing check is unrelated, read the reviewer's P0 findings
  before concluding the task is done** — here all five were accurate. The diff was
  `build_connector_proxy_url()` that nothing called, importing
  `services.api.app.services.connector_credentials` (services/api is NOT on the worker image), plus
  three tests, one a bare `pass`; requirements 2-5 had no implementation at all. A peer agent-ci
  session reached the opposite conclusion from the same report for exactly this reason.
  What the task needed: `modules/connector_credentials.py` as a deliberate COPY of the API's
  derivation (worker image has no services/api) kept honest by a parametrized parity test over all
  ten pool ports importing both modules; `build_proxy_url` deriving `sf-<port>` when CONNECTOR_SECRET
  is set; `resolve_port` dropping ALL SIX ladder rungs in connector mode and reading
  linkedin_accounts.proxy_port joined to an unrevoked connectors row, uncached, every launch (the
  rungs exist to route an unpinned account onto SOME port, which here is a stranger's house);
  `ConnectorOfflineError(ProxyUnavailableError)` with one probe not three; per-account
  geo_country/geo_timezone/geo_locale read in `launch_persistent_context` off `user_data_dir.name`
  (the only place that knows which account is launching — 8 call sites otherwise), field-by-field
  fallback, invalid values dropped before Chromium (it accepts an unknown `timezone_id` silently,
  which is a worse fingerprint than a wrong-but-real one); `_GEO_BY_COUNTRY` 2 -> 19 countries.
  **`pinning_enabled()` must return True in connector mode regardless of OPERATOR_PROXY_HOST**, or a
  deployment with the secret but no host falls through to the legacy Decodo gateway branch — the
  exact leak the mode prevents. Also added an autouse `delenv("CONNECTOR_SECRET")` to
  tests/test_proxy.py so a deployment .env cannot flip the standard-mode file.
  12.5 merged to master (455330a) AFTER this worktree was cut, and its
  `enrollment.py:41 CONNECTOR_OFFLINE_CODE = "CONNECTOR_OFFLINE"` is consumed in
  routers/internal.py:498 — the worker half emitting `result.error_code` is all that was missing, and
  CONNECTOR_OFFLINE is correctly NOT in ACCOUNT_FATAL_CODES. **Rebase onto master before declaring
  green when a sibling task merged mid-run** (`git diff --stat <base> master` showed zero overlap
  here). Slot env: agentci_task_12_6 / base 29400 / slot 94 (port 29434).
  Suite after rebase: 2328 passed / 59 skipped / 0 failed in 262s. Tip f2d405a.

- **TASK-12.7 — a trivially-failing check hiding the real defect, and hallucinated reviewer findings.**
  The ONLY red check was `scope-respected`, and it was one forbidden directory (`downloads/`, an
  invented manifest the spec says twice not to create). Deleting it would have gone green over a
  screen that satisfied almost none of its four requirements, because
  `connector-ui-tests-green` reported "3 passed" on three `pass` stubs. **A vacuous test file makes
  the deterministic checks lie; read the reviewer P0s before trusting a green run** (same lesson as
  TASK-12.6, opposite direction).
  The reviewer was ALSO partly hallucinating: it filed two P0s about "React Native in a Next.js web
  app" and "SSR crash from `navigator`/`Intl` outside useEffect". `apps/web` is **Expo Router +
  react-native-web** (package.json: expo-router 57, react-native-web) — `react-native` imports are
  the house style, every screen does it. Check the platform before acting on a framework finding.
  The other seven findings were real: raw `fetch` (no auth token, no `ApiError`, so no server
  sentence), `console.warn`, a read-only `<Text>` where a country picker belongs, Disconnect/Pair
  rendered regardless of `canPair`, no Intel link, no "not published yet".
  Shape of the fix: a new `apps/web/lib/api/connector.ts` (apiFetch+json for all three routes;
  bare `fetch` + shape-check for the static `/downloads/connector.json`, because the SPA fallback
  answers it with index.html so a 200 proves nothing), and `CONNECTOR_COUNTRIES` mirroring
  `_GEO_BY_COUNTRY`. Put the privileged controls in their own `PairingActions` component so
  "hidden when canPair is false" is a structural fact a source-reading test can assert.
  Test technique: `from modules.browser import _GEO_BY_COUNTRY` WORKS under pytest (pyproject
  pythonpath has services/linkedin-worker) — import the truth instead of re-typing it. Two traps in
  the borrowed `block()` helper from test_voice_ui: it closes on a bare bracket at the marker's
  indent, so it runs past `] as const;` (use a dedicated array parser) and never closes on a
  self-closing JSX `/>` (slice to `/>` instead). Always mutation-check a source-reading test —
  breaking the canPair gate and dropping one country proved both rules bite.
  Slot env: agentci-task-12-7 / port 25034. Suite: 2374 passed / 59 skipped / 0 failed in 268s.

- **TASK-12.10 — editing an already-applied migration breaks `db-up` itself, and "widening" a
  CHECK by retyping the column silently drops it.**
  `scripts/test_db.sh up` records a HASH per migration file. Rewrite a migration the builder
  already applied and the next db-up dies with
  `error: 038_staff_desk.sql was modified after it was applied (recorded <a>, on disk <b>)` —
  not a diff problem, the volume's `schema_migrations` row. Fix: `bash scripts/test_db.sh reset`
  on your OWN slot container (down -v + up replays everything, ~1 min). Do this the moment you
  touch a migration, before wondering what you broke.
  The builder's 038 "widened" `ticket_messages.visibility` with
  `ALTER COLUMN visibility TYPE VARCHAR(32)`, which removes the inline CHECK instead of adding a
  value to it — the tests all passed because nothing asserted the CHECK still refused garbage.
  Assert both directions: the new value inserts AND an unknown one raises `CheckViolationError`.
  Stub tell of the night: two of four tests were bare `pass` with a comment ("verifies the design,
  not implementation"), and the fixtures called `app.settings` / `app.test_client`, which do not
  exist on this FastAPI app — the reviewer only reported the ScopeMismatch (session-scoped fixture
  requesting conftest's function-scoped `db`), so fixing exactly the reviewer P0s would have merged
  four green vacuous tests.
  A staff/admin-only route belongs in NEITHER `PROBES` (demands an org owner can read it) nor
  `EXEMPT` (a written excuse for not checking): give it its own `STAFF_PROBES` matrix and OR it
  into `covered` in the coverage test. Make the expected refusal a live control — request a
  genuinely unmounted path under the same prefix and compare status AND body — instead of
  hard-coding 404: that is what catches `detail="Not found"` vs FastAPI's `"Not Found"`.
  Also make the guard 404 the UNAUTHENTICATED caller too (resolve the user inside the dependency
  and catch HTTPException), or a 401 from /api/v1/staff/* next to a 404 from /api/v1/nonsense maps
  the hidden surface from outside.
  Slot env: agentci-task-12-10 / port 29034. Suite: 2425 passed / 59 skipped / 0 failed in 272s.

- **TASK-12.11 — the reported ImportError was the smallest of four problems; the reviewer's
  single P0 would have merged the leak the task existed to close.**
  HUMAN_REQUIRED said only "test imports non-existent factory `create_ticket`" (it is a SERVICE
  function, `app.services.tickets`; the factories return BARE UUIDs, so the builder's `user.id`
  was a second AttributeError waiting behind it). Adding the factory as the reviewer's repair
  suggested would have collected a test that asserted the WRONG behaviour — it passed
  `author_role="member"` for a staff author and never touched the HTTP surface the requirement
  names. Rewrite the whole file against the requirements, not against the reviewer's repair.
  The three real defects, all in already-"green" source: the read filters were still DENY-lists
  (`$3 OR visibility <> 'internal'`), so a member saw the staff note's `ticket.message_added`
  and every owner/admin saw the note itself — a new CHECK value is readable by everyone the day
  it exists unless the WHERE names what each viewer MAY see; the builder had "fixed" the events
  filter by adding `'staff'` to that module's INTERNAL_ROLES mirror, which widens the wrong set;
  and it had widened the router's `Literal["public","internal"]`, which the spec explicitly says
  to keep closed (that Literal IS the whole HTTP defence — `AuthUser.role` comes from org_members
  and can never be 'staff', so a 422 from FastAPI is the refusal the test must assert).
  Allow-list shape that keeps the pre-existing source-contract test green
  (`test_ticket_messages.py` asserts `"visibility = 'public'" in getsource`): per-visibility OR
  terms — `m.visibility = 'public' OR (m.visibility = 'internal' AND $3) OR (m.visibility =
  'staff' AND $4)` — not `= ANY($3::text[])`.
  "Behaves exactly like an agent" needs a role set of its own: `AGENT_ROLES = INTERNAL_ROLES |
  {STAFF_ROLE}` for the mail rule; INTERNAL_ROLES must stay `{'owner','admin'}` or the note leaks.
  And a source-scanning test matches its own docstring — mine failed on the prose EXPLAINING
  `<> 'internal'`; strip `func.__doc__` and `#` lines before the scan (cf. TASK-11.6).
  Slot env: agentci-task-12-11 / port 20434. Suite: 2453 passed / 59 skipped / 0 failed in 272s.

- **TASK-12.12 — a "1837-second build" that produced a service nothing could call and a
  test file that never ran.**
  The reported `AttributeError: 'Connection' object has no attribute 'acquire'` was real but
  shallow: every function in the new `services/support_desk.py` took a *Pool* and did
  `async with pool.acquire()` inside itself, while the `db` fixture is a single asyncpg
  Connection — and every sibling service in this repo takes a `conn` and lets the ROUTER
  acquire (20 routers use `pool: asyncpg.Pool = Depends(get_pool)`; the builder invented
  `request.app.state.db_pool`, used nowhere else). Behind it: OR-ed filter values each got a
  placeholder numbered `len(params)+1` *before* the extend, so all N shared `$n`; the page was
  re-sorted in Python AFTER SQL's LIMIT had already cut it; responses were snake_case pydantic
  models when the requirement says `_serialize_ticket`'s camelCase shape plus four names; no
  422 for an unknown state/priority, and `uuid.UUID(ticket_id)` 500ed on a malformed id.
  The test file asserted only its own hand-written SQL (`SELECT count(*) FROM tickets`), never
  the HTTP surface, and could not execute (undefined `conn`, `create_ticket_message` missing
  `organization_id`/`author_role`). Rewrite both against the requirements.
  Two harness traps, both mechanical: the tenancy audit's `_call` does
  `probe.path.format(**ids)`, and the two staff tests pass `{}` — so the moment a STAFF_PROBES
  entry has a `{ticket_id}` they `KeyError`. Pass `tenants["alpha"]["ids"]` (the fixture already
  carries `ticket_id`); alpha's own ids are the *stronger* negative control, and for the staff
  positive control they are another organization's ticket, which is the point of the desk.
  And TASK-12.10's `test_the_staff_route_is_mounted_where_the_web_app_will_look` pins the
  mounted set to `{("GET","/api/v1/staff/me")}` by EQUALITY — any staff route added later reds
  a file the task does not name. Requirements outrank it; extend the set.
  Reuse `routers/tickets.py`'s `_serialize_ticket` / `_serialize` / `_serialize_event` /
  `_ticket_uuid` by import rather than re-spelling them — the requirement names that shape.
  Suite: 2471 passed / 59 skipped in 284s. `tests/db/test_ticket_events.py::
  test_a_failed_emit_does_not_take_the_ticket_write_down_with_it` failed once in a full run and
  passed alone and in two later full runs — an intermittent, not the diff.

- **TASK-12.14 — a UI task's test file written as an HTTP integration test, for the THIRD time
  (cf. TASK-11.7), and the import error hid a placeholder screen underneath.**
  `ImportError: cannot import name 'TEST_USER' from 'tests.db.conftest'` reddened both pytest
  checks at collection, so nothing in the diff ever ran. Repairing line 14 would have merged a
  stub: requirement 2 says "tests/test_support_desk_ui.py reads both sides as text, the way
  tests/test_ticket_web_contract.py does" — a SOURCE-CONTRACT test — and the builder wrote
  `httpx.AsyncClient` calls asserting `status_code in [200, 403]`. **When a web requirement names
  a contract test by file, the genre is the requirement; a green HTTP test over the wrong genre
  is the failure mode, not the fix.**
  Under it: `useStaff` caught `error instanceof Response` (lib/client.ts `json()` throws
  `ApiError`, so the 404 branch NEVER fired) and had no retry at all; filters in `useState`, not
  the URL; `Alert.alert` from react-native (a no-op on web) instead of the server's sentence;
  `StaffTicket`'s four added fields optional; rows `console.log`ing instead of pushing.
  **Reviewer finding F002 was flatly WRONG and would have destroyed the diff**: "React Native
  primitives, not web DOM elements … incompatible with a Next.js web app". This app is Expo
  Router + NativeWind — `View`/`Text`/`Pressable` IS the house idiom in every screen. Check what
  the app actually is before obeying a "use div/input" repair.
  Two reusable facts. (1) **`qs` in lib/client.ts cannot express a multi-select**: it builds with
  `URLSearchParams.set`, which keeps the LAST value, so "urgent AND high" silently arrives as
  "high". A repeatable-`Query(default=None)` filter needs an `append`-based builder
  (`deskQuery` in lib/api/support.ts). (2) The not-found refusal must import the app's own
  `@/app/+not-found` default export rather than re-render an EmptyState — and the staff answer
  has to be THREE-valued (`unknown | staff | not-staff`), because since c5e3aea `apiFetch`
  answers a synthetic 503 when a refresh fails for a non-session reason, so collapsing failure to
  `false` tells a staff member on a flaky connection that their own page does not exist.
  Test-writing notes: `indent_block` on `key: 'support-desk',` fails (the marker sits mid-object
  at a deeper indent than the closing line) — use `re.search(r"\{[^{}]*key: 'x',[^{}]*\}")`;
  a template path `` `/x${f({...})}` `` needs a GREEDY `\$\{.*\}` strip, not `[^}]+`; and a
  `String(err)` ban must exempt `new Error(String(err))`, which is the opposite of the defect.
  Mutation-checked four rules (404-only, retry, required fields, row href) before believing them.
  Slot env: agentci_task_12_14 / base 27200 / slot 72 (port 27234).
  Suite: 2509 passed / 59 skipped in 286s. None of the three known intermittents fired.

- TASK-12.13 (2026-09-12, desk write side, run-20260912-124710-9595e1): **the whole stall was the
  builder's OWN test inventing a fixture fact.** Two of the three red desk-write tests asserted
  `len(messages) == 2  # original + new` — but `services.tickets.create_ticket` writes NO
  ticket_messages row (the first description lives on `tickets.body`), so that count could never be
  1+1 and no implementation could pass it. Requirements outrank tests in the diff: rewrite the
  test, do not chase the code. The third, `test_staff_can_unassign_ticket`, was a real bug of the
  same family as `routers/tickets.py` already solves: **`assigneeId: null` and an absent
  `assigneeId` are different requests** — `update_ticket(assignee_id=None)` means "leave it alone",
  unassigning is `clear_assignee=True`, so the handler must read `"assignee_id" in
  payload.model_fields_set`, not the value. The builder's model also declared `assigneeId: str |
  None` and did its own `SELECT is_staff FROM users` in the router (requirement 4 forbids SQL
  there) and defined both pydantic models AFTER the decorated handlers.
  **Any new /api/v1/staff route must be added to THREE places or three checks go red**:
  `tests/db/test_staff_flag.py::test_the_staff_route_is_mounted_where_the_web_app_will_look`
  (an EXACT `staff_paths == {...}` set, and no spec mentions the file), `STAFF_PROBES` in
  tests/db/test_tenancy_isolation.py, and — for a write route — a probe BODY, since STAFF_PROBES is
  run twice: once expecting the unmounted-path 404 for every org role, once expecting < 400 for a
  staff user. Order the write probes so they are legal moves in sequence (PATCH `state: pending`
  on the fixture's open ticket, then a public reply, which leaves a pending ticket alone).
  Pattern for the desk's writes: everything through `create_ticket_message` / `update_ticket` /
  `transition_ticket` with the ticket's own organization_id and `actor_id=user.id`, priority and
  assignee first and state LAST (transition_ticket's FOR UPDATE + the three bookkeeping columns it
  alone writes must be the last word), the 422 assignee gate INSIDE `conn.transaction()` so a
  refused patch writes nothing at all, and the `is_staff` lookup added to `services/support_desk.py`
  (next to `list_agents`) so the router keeps zero SQL. `visibility: Literal["public", "staff"]`
  mirrors the org router's `Literal["public", "internal"]`. TASK-12.12's SQL scan
  (`test_the_cross_organization_module_never_writes`) parametrizes cleanly over
  `[SERVICE_FILE, ROUTER_FILE]`; its sibling `test_the_module_imports_no_writer` must NOT, because
  the router's whole job is importing those writers. Mail lands in `outbox_messages` (channel
  'email'); a staff public reply queues exactly one, a staff note none.
  Slot env: agentci_task_12_13 / port 24234. Suite: 2485 passed / 59 skipped in 297s, no
  intermittents.

- TASK-12.15 (2026-09-12, desk ticket screen, run-20260912-141745-d3ee11): **the UI test written as
  an HTTP integration test for a THIRD time** (after 12.14 and 11.7) — all 8 tests did
  `await client.get(f"/support-desk/{id}")` against FastAPI for a route that exists only as an Expo
  CLIENT screen, and the one visible error (`ImportError: cannot import name 'ticket_message' from
  tests.db.test_support_desk_writes`) hid it: that single collection error reddened BOTH pytest
  checks, so suite-green's "1 deselected, 1 warning, 1 error" was NOT a suite regression. The
  builder had also left an EMPTY `apps/web/app/support-desk/_id.tsx` — wrong directory (outside
  `(app)`, so outside the shell/session/gate) and wrong name (`_id` is not `[id]`); nothing in the
  acceptance set notices a stray route, so I added a rule asserting that path cannot exist.
  Real design facts, none visible to a 30B builder: (1) **`GET /staff/tickets/{id}` is a DIFFERENT
  shape from `GET /staff/tickets`** — the detail sends whole people (`organization {id,name}`,
  `requester`/`assignee` = `_person` = `{id, email, fullName}` with BOTH nullable), the list
  flattens `organizationName/requesterEmail/requesterName/assigneeName` onto each row. tsc's
  "Did you mean 'requesterId'?" hint points the wrong way; the code was right and the TYPE was
  missing. New types.ts entries: StaffPerson / StaffTicketWorkspace / StaffTicketDetail /
  StaffTicketMessage (= TicketMessage & authorName/authorEmail). (2) PATCH returns a BARE
  `_serialize_ticket`, not the detail shape — type it `Ticket` and re-read. (3) The desk's writes
  must NOT go in `lib/api/support.ts`: tests/test_support_desk_ui.py pins it to exactly four GETs
  and asserts `"method: '" not in source`, so the five single-ticket routes need their own module
  (`lib/api/deskticket.ts`). (4) `validate_transition` says **a move to the CURRENT state is legal
  and does nothing**, so `open→open` is a 200 — a 409 test must park the ticket in a state with
  narrower exits first (derive it from ALLOWED_TRANSITIONS, and `sorted()` the frozensets or the
  test is order-dependent). (5) Requirement "widen the visibility type to 'staff'" is safe because
  only TicketThread reads `.visibility` anywhere in apps/web — but widening it makes a staff note
  render as "Public reply" through the old `const internal = visibility === 'internal'` boolean, and
  TicketHistory's `message_added` says "replied publicly" from a loose payload no type can check.
  Make both three-way (`Record<TicketMessage['visibility'], Kind>` + a switch with a non-committal
  default) and keep the org narrow unions (TicketComposer, tickets/[id].tsx, postTicketMessage)
  ALONE — widening those breaks the org screen at typecheck, which is the safe direction to be
  wrong in. An optional `nameFor = personLabel` prop on TicketThread lets the desk show real names
  (its thread route sends them) with the org screen byte-identical in behaviour.
  Also: `useStaff().staff` already holds the StaffMe the gate fetched, so the screen needs no
  `/me` call for `currentUserId`; there is no `@/lib/api` index module; `file-text`/`shield` are not
  IconNames (`life-buoy` is); and `tests/test_responsive.py` polices `px-8` without `md:` and
  `w-[>343px]` in `app/**` ROUTE files only, not components.
  Slot env: agentci_task_12_15 / base 27300 / slot 73 (port 27334).
  Suite: 2555 passed / 59 skipped in 281s, no intermittents.

- TASK-12.16 (2026-09-12, devices own the refresh chain): the implementation was
  COMPLETE and good — 039, auth/devices.py, the `did` claim, the replay detector, 19 real
  tests. Two non-code blockers, and the reported one was the harmless half.
  (1) **db-up "039 was modified after it was applied" was a LINE-ENDING artifact.**
  `scripts/migrate_local.py` checksums `path.read_bytes()`, and the supervisor's
  `worktrees.refresh` REBASE re-checks-out the file, which `core.autocrlf=true` writes as
  CRLF — so the recorded LF hash and the on-disk CRLF hash differ by exactly one byte per
  line while `git status` stays clean (git compares normalised content). Fix is
  `test_db.sh reset` in the worktree WITH the slot vars exported; NEVER edit the migration
  (that would make the difference real in every other slot, including the gate's). The
  same error was the whole of suite-green's 2 failures — test_harness.py's `test_rerun_is_noop`
  and `test_status_format` shell out to migrate_local and assert returncode 0.
  One cause, three red checks.
  (2) **The real blocker: a test asserting a RESOLVED setting against the requirement's
  default.** `assert get_settings().refresh_token_days == 60`. `Settings.model_config` is
  `env_file=(".env", str(_REPO_ROOT / ".env"))`, a worktree has no `.env` and the PROJECT
  ROOT has a gitignored one carrying the pre-change `REFRESH_TOKEN_DAYS=<redacted> — so it passes
  in the worktree and fails at the merge gate, which runs in the root. That is another
  source of "passes in its own worktree but not once combined with main", and it is NOT a
  slot/port collision. **When a requirement names a DEFAULT, assert
  `Settings.model_fields["x"].default` (precedent: test_voice_ui.py, test_config_safety.py)
  and measure every duration against the live setting.** Each such test has TWO deps on the
  literal — the assertion and the `timedelta(...)` — so fixing only the assertion moves the
  failure one line down. Sibling settings the root `.env` does not mention yet
  (untrusted_session_hours, session_max_days, refresh_reuse_grace_seconds) pass by luck and
  are latent copies. Verify the gate's view with
  `set -a; . <root>/.env; set +a; unset DATABASE_URL; .venv/bin/python -m pytest ...` —
  never copy `.env` into the worktree (secrets + reds scope-respected).
  Slot env: agentci_task_12_16 / base 21300 / slot 13 (port 21334).
  Suite: 2575 passed / 59 skipped in 291s, no intermittents.

- TASK-12.17 (2026-09-12, the web session in HttpOnly cookies): the reported blocker was
  ONE LINE. `request: Request = Depends()` in `get_current_user` — `Depends()` with no
  argument makes FastAPI resolve the *annotation* as a request BODY model, so every
  endpoint behind that dependency demanded a body and every GET answered
  `422 {"loc":["body"],"msg":"Field required"}`. That was all 559 suite failures, all 25
  auth-regression failures, and most of the 7 named ones. **Take the request as a plain
  parameter: `request: Request`, no default.** A census of error types is the tell — 441
  bare AssertionErrors on status codes and no import errors means one broken signature,
  not many bugs.
- **The other half of TASK-12.17, and the one no check could ever have caught: the root
  `.gitignore` has `*cookies*` under "Env / secrets".** It is aimed at a browser cookie
  JAR (services/linkedin-worker writes those), and a gitignore pattern with no slash
  matches that basename at ANY depth — so it silently swallowed BOTH new files,
  `services/api/app/auth/cookies.py` and `tests/db/test_auth_cookies.py` (the file this
  task's own acceptance check runs BY NAME). Nothing in a worktree can show you this: the
  files are on disk, imports resolve, the suite is green, and `git status` simply does not
  mention them. Only the COMMIT is missing them, so the merge gate gets a branch whose
  every module raises ImportError and a check pointed at a file that is not there.
  **After any escalation, run `git diff --name-only master...HEAD` and confirm every file
  you wrote is in it** — `git status --porcelain --ignored=matching` names the culprit
  pattern. Fix it with a negation in a .gitignore inside an OWNED directory
  (`tests/db/.gitignore` → `!test_auth_cookies.py`), which wins over the shallower rule;
  do not widen the root secrets pattern, which is not the task's to loosen.
  Slot env: agentci_task_12_17 / base 27200 / slot 72 (port 27234).
  Suite after the fix: 2615 passed / 62 skipped in 323s, 0 failed.

- TASK-13.2 (2026-09-12, the scheduler dispatch tests, run-20260912-193434-6f3276): **a test
  asserting a state its own fixtures FORBID.** `test_account_busy_blocks_second_enrollment`
  demanded `deferred == 1`, but `account_busy()` counts only `status='in_flight'`, which is
  written after `enqueue_job` hands the worker a job — and the `no_enqueue` fixture makes any
  enqueue raise, so nothing in a dry-run test can ever be in_flight. `deferred == 0` was the
  CORRECT answer, and reviewer F001 ("dispatch_due is missing account-busy blocking; exclude
  accounts with an `active` enrollment") would have rewritten the serialisation rule for every
  real campaign to satisfy a fixture. **Establish the precondition (UPDATE … SET
  status='in_flight') instead of assuming it; scheduler.py was untouched.** Note
  `reserved_accounts`/busy defer returns counts(claimed=1, deferred=1), NOT ZERO — `claimed` is
  `len(due)`, counted before anything looks at the account.
- **The flake under it: `next_action_at` came from the CLIENT clock and due-ness is decided by
  the SERVER's.** `factories.create_enrollment` stamped `_utcnow()` while dispatch_due asks
  `e.next_action_at <= now()` (Postgres, transaction start). pytest runs in the WSL VM, the test
  Postgres in Docker Desktop's own VM. Measured margin through the real `seed_campaign` path:
  median **1.5 ms** (min 1.35). That is the whole budget — any moment the server sits >1.5 ms
  behind, a "due now" row is not due and dispatch_due truthfully returns claimed:0. That is the
  TASK-12.16 flake (1 failed / 2574 passed, tree does not touch the scheduler). A 2-minute
  offset probe on an idle box showed ±0.25 ms with 0.53 ms jitter — a third of the budget
  without an excursion, so the fix removes the dependency rather than proving the moment: the
  factory now defaults `next_action_at` to `SELECT now() - interval '1 minute'`. Seven existing
  test files already wrote `now() - make_interval(secs => 1)` by hand — that workaround IS the
  bug report. **Any db test that needs a row "due now" must take the timestamp from Postgres.**
  Slot env: agentci_task_13_2 / base 23000 (port 23034), db agentci_task_13_2.
  Suite after the fix: 2586 passed / 62 skipped in 323s, 0 failed.
- **TASK-12.19 (2026-09-12) — the builder WROTE the new test file the requirement asked for, and
  wrote it so no implementation could pass.** The requirement says the cookie branch is pinned in
  a NEW `tests/test_session_cookie_client.py`; the builder's version asserted
  `"getAccessToken()" not in CLIENT`, `"getRefreshToken()" not in CLIENT`, `"setTokens(" not in
  CLIENT` — flatly contradicting the same requirement's "with a cross-origin API_BASE or on
  native, everything works exactly as on master today" AND the 12 tests of
  `test_session_client.py` it was told to keep. It also asserted `refreshSession(` appears
  INSIDE `doCookieRefresh` (infinite recursion). **When the task tells the builder to author the
  pinning test, the test is part of the diff, not the contract — rewrite it, requirements
  outrank it.** The reviewer's lone P0 (a real `{token: string | null}` type error) was true but
  cosmetic next to that.
  Design that satisfied all four requirements: one exported `COOKIE_MODE = Platform.OS === 'web'
  && API_BASE === ''` every branch reads; `authInit()` for the four auth calls that cannot go
  through `apiFetch`; `doCookieRefresh` beside `doRefresh` under the SAME `refreshSession` +
  `withRefreshLock('sf-refresh')`, comparing `sf_session_epoch` (localStorage) where doRefresh
  compares tokens; `RefreshResult` widened to `{token: string | null}` so cookie success still
  matches `'token' in outcome`; module-level `cookieAccessExpiry` from `expiresIn` because the
  JWT is HttpOnly; one exported `adoptSession(tokens)` replacing every `setTokens` call site in
  AuthContext + the Google return (which also keeps `test_sso_ui`'s
  `test_no_token_is_ever_put_in_a_url` green by removing the token names entirely).
  Slot env: agentci_task_12_19 / base 22000 (port 22034). Suite: 2635 passed / 62 skipped / 314s.
- **TASK-13.2 #2 (2026-09-12, escalation 2 of 2) — the lone unrelated suite failure WAS the whole
  blocker, and its cause is the same host clock.** suite-green's only red was
  `tests/db/test_auth_devices.py::test_a_login_is_its_own_device`:
  `['Safari on iPhone','Chrome on Windows'] != ['Chrome on Windows','Safari on iPhone']` from
  `_devices_of`'s `ORDER BY d.created_at, d.name`, with the test naming a device by POSITION
  (`devices[1]`). **A "created_at tie broken alphabetically" theory is refutable on sight here**
  (a peer session proposed it): the name tiebreaker sorts Chrome first, which is the order the
  test expects, so a tie PASSES. The only way to get the observed order is
  created_at(login) < created_at(register) — and the failing run's own captured stderr shows it:
  register logged at `16:38:53,862`, the LATER login at `16:38:53,501`. **The WSL2 wall clock
  stepped BACKWARDS 361 ms mid-test** (already documented in tests/db/api_client.py as the cause
  of the intermittent 401), and the test Postgres is in Docker Desktop's VM off the same time
  source. Reruns pass — 2635/2635 twice — so it is intermittent, not deterministic, which is the
  second refutation of the tie theory.
  Fix, tests-only (`tests/` is owned): identify a row by the identity it CARRIES, not by where a
  clock put it in a list — new `_device_of_token(db, tokens)` joins auth_devices through the
  refresh_tokens row, which is the binding the product relies on. Also fixed the same latent
  flake in `test_a_shared_computer_lasts_twelve_hours` (took `[-1]`, and there BOTH devices are
  named "Chrome on Windows", so there is not even a name to fall back on). `auth_devices` has
  nothing monotonic to sort on: `id` is `gen_random_uuid()`.
  **This is direct corroboration for the 13.2 two-clocks diagnosis above** — the clocks on this
  box really do part, by hundreds of ms, not by the measured 1.5 ms margin. Requirement 1 wanted
  the "why" in the COMMIT MESSAGE, where the independent test audit structurally cannot read it
  and therefore always reports R1 uncovered; copying the argument into the module docstring of
  the test file it explains is additive and closes that loop.
  Suite: 2635 passed / 62 skipped / 324s. All five acceptance checks green.
- **TASK-12.20 (2026-09-12, escalation 1 of 2) — the builder REVERTED a merged sibling's screen,
  and the "unrelated" suite failure was that revert.** suite-green's two reds were
  `tests/test_session_cookie_client.py::test_the_security_screen_stops_sending_x_refresh_token`
  and a `tests/db/test_suppressions.py` filter test. The first was mine: rewriting
  `app/(app)/settings/security.tsx` from the PRE-12.19 shape renamed `sessionHeaders` →
  `deviceHeaders`, and 12.19's pin does `_function(SECURITY, "async function sessionHeaders(")`
  → `ValueError: substring not found`. **When a task rewrites a screen a merged task already
  pinned, diff `git show master:<file>` first and keep the pinned names.** The second (assert
  None == 'ACwAAAstranger') did NOT reproduce — a genuine flake; don't chase a db test when the
  whole diff is `apps/web/`.
  Everything else was a typecheck wall the builder never ran: `Switch` does not exist in the kit
  (it is `Toggle`, with `onChange` + REQUIRED `a11yLabel`), `Field` has no `autoFocus` and
  `label` is required, `EmptyState.icon` is the CLOSED `IconName` union ('device' is not in it),
  and `login`/`register` in AuthContext + client.ts had to be WIDENED for `rememberDevice` —
  the API has accepted it since TASK-12.16 (`app/auth/schemas.py`), the client never sent it.
  Test file was the usual placeholder (raw `INSERT INTO users/auth_devices` with `$1` and no
  args → `InterfaceError: server expects 1 argument, 0 were passed`, 5 setup ERRORs). Rewrote it
  in the house pattern: source-as-text + the API asked for real, reusing `code`/`ts_const`/
  `api_routes` from tests/test_sso_ui.py. Gotchas found writing it: `ts_const`'s regex is
  SINGLE-LINE (a wrapped `const X =\n  '…';` needs its own helper), `inspect.signature` on a
  router with `from __future__ import annotations` gives the STRING `'bool'`, and a `const f =
  useCallback(async () => {` does not match a plain arrow-body regex. Also `window.confirm` is
  not the kit — use `Modal` + a `Confirming` state; and "sign out everywhere" must `await
  logout()` before `router.replace('/login')` or AuthContext's redirect effect bounces the user
  back to `/` because `user` is still set.
  Slot env: agentci_task_12_20 / base 26300 (port 26334). Suite: 2679 passed / 62 skipped / 337s.
  All five acceptance checks green.

- **TASK-13.3 — the test POSTed to a GET-only route, and the second red was the cookie flake.**
  The implementation (`_revoke_every_session` → `devices.revoke_devices_except(keep_device_id=
  None, reason=REASON_SIGNED_OUT)`) was already correct and complete; the whole stall was the
  builder's test. It did `api.post("/api/v1/auth/oauth/google/callback", …)` → **405**, because
  the callback is a **GET** (`routers/oauth.py:305`, browser redirect); the automatic-link path
  has no POST route at all, and every other test in tests/db/test_oauth_linking.py drives it by
  calling `resolve_user(db, verified(email, sub=…))` directly. It also never asserted the thing
  the requirement named (the pre-link ACCESS token refused on its next request) — only
  `refreshes()`. Rewrote it: two live sessions answering `GET /auth/me` on access tokens alone →
  `resolve_user` → both refused 401 "Invalid or expired token" (get_current_user's existing
  revoked-device shape), both `auth_devices` rows revoked with `signed_out`, refresh tokens
  checked LAST because refreshing rotates them. Counterfactual-check a security test by
  `pass`-ing out the impl line and watching the third `/me` go 200.
  The suite's OTHER red, `test_auth_cookies.py::test_sessions_marks_the_cookie_session_as_current`
  (`[True, False]` off an `ORDER BY created_at DESC` over two sessions milliseconds apart), is the
  same WSL2-clock/position flake as TASK-13.2 — green on re-run and in the full suite, touched
  nothing. Slot env: agentci_task_13_3 / base 21000 (port 21034). Suite: 2659 passed / 62 skipped
  / 327s. All four checks green.

- **TASK-13.3 #2 — the whole stall was an untracked scratch file at the worktree root.**
  Second escalation on the same task. `scope-respected` was the ONLY red, and its second clause
  (`git status --porcelain | grep '^??' | grep -vE '^\?\? (tests/|services/api/)'`) was matching
  a `test_debug.py` the builder had written at the repo ROOT — an asyncio scratch script with a
  hardcoded absolute worktree path in `sys.path`. `pytest tests` never collects it, so every test
  check was green and only the scope check saw it. **When scope-respected is the lone failure,
  read `git status --porcelain` before reading anything else** — an untracked file outside
  `tests/` or `services/api/` is the entire bug, and `rm` is the entire fix.
  Two suite reds hid behind it, both the WSL2 backwards clock, neither from the diff:
  `test_auth_devices::test_a_shared_computer_lasts_twelve_hours` took `(await _devices_of(...))[-1]`
  off `ORDER BY created_at, name` — the clock stepped back 1.15 s between the register and the
  login (visible in the failure's own captured-stderr timestamps: login logged 20:16:16, register
  20:16:17), so the login's device sorted FIRST and `[-1]` returned the registration's *trusted*
  device. Same lesson as TASK-13.2 #2: reach the row through the binding it carries —
  `refresh_tokens.device_id` from `_token_row(db, tokens)`, keyed into a dict of the devices.
  And `test_api_withdraw.py` defines its OWN local `client` fixture that copies the shared `api`
  fixture but omits **`jwt_clock_leeway`**, so a token minted a moment before decodes as "not yet
  valid" and a `== 422` assertion sees a 401. `jwt_clock_leeway` lives in tests/db/api_client.py
  and is re-exported by tests/conftest.py, so any local client fixture can just request it by
  name — grep for fixtures that build an `httpx.AsyncClient` over `app` without it.
  Reviewer F001 was a misreading and needed no code change: it called the comment's "the device
  of the sign-in being served does not exist yet" false, but routers/oauth.py's callback runs
  `sign_in_with_google` (→ `_revoke_every_session`) BEFORE `_session_for` creates the device, so
  the comment is accurate and `keep_device_id=None` is right. Suite: 2680 passed / 62 skipped /
  329s. All four checks green.

## TASK-15.1 (connector browser hand-off, Go)
The "stall" was a non-compiling placeholder (unused imports, `loadConfig(savedConfigPath())` on a 2-value func), but fixing only the compile errors would have merged a security hole: CORS echoed any `Origin`, no 409, typed prompt queued *behind* the browser wait instead of racing it, and `createHandoffListener` was handed the pair *endpoint* instead of the server. Spec contradiction: req 1 says "400 on a missing nonce", req 2 says every request without the nonce is 403 — chose 403 (the security rule). "409 after success" vs "POST on a paired connector re-pairs" reconciled as one pairing per round (round = each time the connector needs a code; listener starts at process start so a file-paired connector can be re-paired).

## TASK-15.3 (2026-09-17): the builder wrote to the ROOT, so the branch was EMPTY
workspace-containment removed the builder's files from the root (copies in logs/<run>/escaped-files/),
leaving agent/TASK-N.M == master. The "failing build check" was just "no work at all". The escaped
copies were junk (imported a non-existent package), so the fix was implementing the task in the worktree.
**How to apply:** when containment fails, check `git log master..HEAD` first. An empty branch means build
it yourself; don't try to salvage escaped-files. Tray notes: fyne.io/systray has no notification API, so
balloons are NIM_MODIFY+NIF_INFO on its hidden "SystrayClass" window (ID 100), found via FindWindowExW + pid check.

**TASK-15.4 (2026-09-17) — containment fail = empty branch, again.** Same as 15.3: the qwen builder worked in `/mnt/c/Users/crist/snoopy_frog/v3/connector` (the ROOT), the supervisor deleted the 7 escaped files, branch == master. The escaped copies were unusable: the non-Windows `update.go` was an empty `updateCheck`, and nothing had been compiled because `go` isn't on the builder's PATH (it tried `go build`, got "Go not found", and finished anyway). Implemented from scratch in the worktree: pure `installTarget`, `autostartStore` interface, and updater in `update.go` tested against `httptest.NewTLSServer` with `srv.Client()`. **How to apply:** once the branch is empty, skip the escaped-files review and build it yourself; two in a row on phase 15 suggests the builder prompt's WORKSPACE section needs tightening in ~/agent-ci.

## TASK-15.2 (2026-09-18): the "environment" verdict hid a placeholder, again
- db-up "database agentci_task_15_2 does not exist": TASK-14.1's container held the slot port 23234 (both slots map to it) and ours was PORTLESS. 14.1 was not passed and its openhands tmux was still alive, so instead of `docker rm -f` on the sibling I re-homed OUR stack: `compose -p agentci-task-15-2 down`, then `SF_TEST_PORT=23299 test_db.sh up`, and ran the suite with `DATABASE_URL_TEST=...:23299/...`. The gate's own `test_db.sh up` will still collide while 14.1's container exists.
- Behind that, the diff was all placeholder: `@pytestmark =` (a SyntaxError) and ten `async def …: pass` DB tests for a UI task (the genre problem a FOURTH time), toast-only buttons, and the nonce sent as `Authorization: Bearer` when handoff.go reads `?nonce=`.
- A leak nobody had flagged: a page opened with a secret in its query string leaks that secret through the Referer header of every same-origin apiFetch. The fix is `referrerPolicy: 'strict-origin'` in apiFetch.
- Harness quirks: test_connector_ui's `code()` strips `//` comments, so it eats `http://`. Use read() for URL literals. Its indent-based `block()` cannot close a one-line `if (...) return;`.
- Every full suite run leaks one `x11vnc` restart-loop bash from test_x11vnc_is_restarted (dozens are accumulated in /tmp/pytest-of-cmadrigal). Kill only your own.
- TASK-14.2 (rehearsal/rate): the "reviewer findings" were all wrong-headed (STEP_KINDS import "missing" when it was imported). Real causes: the builder REMOVED `step_kinds` from `from app.services import ...` while `step_kinds.meta` is still used at campaigns.py ~2780 → NameError in test_upcoming/test_capacity/tenancy (a suite red that looks unrelated but is the diff); `rating: Literal[...]` gives 422 not the required 400; `detail={"detail": ...}` nests the 409; problems as a dict instead of the codebase's list; test asserted `resp.json()["problems"]` (it's under `detail`) and "Ana López" when factories' lead is "Ana Rodriguez". Spec ambiguity resolved via TASK-14.3's UI spec: plain thumbs-up sends no `original`; Correct sends one, so an identical-modulo-whitespace correction stores nothing (id null), matching _learn_from_edit. 'qualify' (rehearsal.QUALIFY_STEP_ID) is an accepted stepKind.
