---
name: suite-timeout-is-test-db-fsync
description: "A suite-green TIMEOUT with no failing test is usually the throwaway Postgres fsyncing, not the diff"
metadata: 
  node_type: memory
  type: project
  originSessionId: 812c0054-d96b-415d-85d3-7a982e92d291
  modified: 2026-09-10T16:06:06.055Z
---

When `suite-green` times out mid-run with only dots and no failure, measure the
`db` fixture's setup before reading the diff. `tests/conftest.py` TRUNCATEs every
table on the SETUP of each database test, and TRUNCATE fsyncs the new relation
files at commit regardless of `synchronous_commit`. On this WSL2 host one fsync
is ~0.22 s, so truncation cost 0.85 s per test x ~994 db tests.

Fixed 2026-09-10 (TASK-6.7 escalation) by running the throwaway test Postgres
with `fsync=off synchronous_commit=off full_page_writes=off` in
`docker-compose.test.yml`. Whole suite: >1288 s (timeout) -> 194 s.

**Why:** the timeout was classified as "code / persistent / route to builder"
and blamed a UI diff that never touches Postgres. Nothing in the diff was wrong.

**How to apply:** for a timeout with no failing test, time one db test file with
`--durations` first. If `setup` dominates, it is the truncate, not the code.
Related: [[agent-ci-escalation-pattern]], [[shared-test-db-migration-collision]].
