---
name: agent-ci-conventions
description: "How to work on agent-ci - native WSL session, gateway quirks, long-run and smoke-test conventions"
metadata:
  node_type: memory
  type: feedback
  originSessionId: af68436e-152c-4293-ae08-7e6fae3e429b
  modified: 2026-09-12T17:00:21.456Z
---

VS Code now runs as a Remote-WSL session (moved 2026-09-01), so Claude Code is
native inside Ubuntu: run git/python/test commands directly, and edit files at
normal Linux paths (`/home/cmadrigal/agent-ci/...`). The old `wsl -d Ubuntu -e
bash -lc '...'` wrapper and `\\wsl.localhost\...` UNC paths are OBSOLETE — do
not use them. The committed `.gitattributes` (`* text=auto eol=lf`) stays, since
the repo is still touched from both sides. Long runs (docker builds, real-LLM
tasks) must still be launched detached with nohup, because the Bash tool caps at
10 minutes. Real-LLM smoke tests remain opt-in via `AGENT_CI_SMOKE=1`. Resolve
the gateway dynamically: `http://$(ip route show default | awk '{print $3}'):11434/v1`.

**Why:** the Windows->WSL editor move invalidated the old execution conventions;
the remaining items are friction points found while building phases C..L.
**How to apply:** run commands natively in WSL; nohup for anything long; see
[[agent-ci-build-progress]] and [[wsl-migration-recovery]].

## Never leave a tracked file dirty in the integration tree

The merge gate re-runs the task's own acceptance checks on the MERGED tree, and
those checks include shapes like `no-stray-files` /
`git status --porcelain | grep '^??'`. Any uncommitted tracked change that
belongs to neither the task nor the supervisor fails them, and **every merge is
refused until the tree is clean** — the refusal names the file:

    the integration tree has uncommitted changes that belong to neither this
    task nor the supervisor: config.yaml

Cost it caused on 2026-09-09: TASK-7.7 passed its validation and could not land,
because a `config.yaml` edit (raising `escalation.timeout_seconds`) was left
uncommitted in the project root while the loop ran.

**How to apply:** when tuning a project's `config.yaml` mid-run, COMMIT it
immediately. `state/` and `logs/` are gitignored, so notes and hand-edits to
`unvalidated.json` / `escalations.json` are safe; anything tracked is not.
See [[open-threads-2026-09-08]].

## Never run `scripts/test_db.sh` bare while the pipeline is running

`scripts/test_db.sh` picks its compose project and port from the AGENT_CI_*
slot vars. With none set it falls back to the historic pair — project
`snoopyfrog-v3-test`, **port 5434** — and 5434 is exactly what the MERGE GATE
uses, because the gate runs in slot 0.

So a bare `bash scripts/test_db.sh reset` in the main tree leaves a container
squatting on the gate's port. The gate's own `agentci-main-postgres-test-1`
then starts and never goes healthy:

    error: test database did not become healthy within 60 s

and the merge is refused as `post-merge verification failed: the merged tree
fails ['db-up', ...] — passes in its own worktree but not once combined with
main`. That reads exactly like a real integration conflict and is not one.
It cost TASK-7.13 a refused merge on 2026-09-09; the container had been up for
seven hours after a manual verification run.

**Related leak:** per-task containers (`agentci-task-<id>-postgres-test-1`) are
never torn down — five were still running hours after their tasks merged. That
is open-threads item 6, and it also starves the gate's database of the memory
it needs to pass its health check inside 60 s.

**How to apply:** to poke the test DB by hand while the loop runs, export the
slot vars first, or accept that you are taking slot 0 and clean up after:
`docker rm -f snoopyfrog-v3-test-postgres-test-1`. Check for leaks with
`docker ps -a --filter name=postgres-test` before blaming a refused merge on
the diff. See [[open-threads-2026-09-08]], [[docker-wedge-issue]].

## A REBASE invalidates a migration checksum, and the error lies (2026-09-12)

`db-up` failed on snoopy_frog TASK-12.16 with
`error: 039_auth_devices.sql was modified after it was applied
(recorded 7aabe27a399fba1f, on disk f974c9122ed4493d)`. **Nobody modified it.**

`scripts/migrate_local.py:43` is
`file_checksum = hashlib.sha256(path.read_bytes()).hexdigest()[:16]` — RAW
BYTES. This repo runs `core.autocrlf=true` (DEC-005), so a checkout writes
CRLF while the index holds LF. `worktrees.refresh` REBASED the branch onto the
new master, the rebase re-checked-out the file, and the bytes changed without
the content changing. Proven by computing all three variants:

    on-disk (CRLF) 2568 bytes -> f974c9122ed4493d  == the reported "on disk"
    LF-normalised  2518 bytes -> 7aabe27a399fba1f  == the RECORDED value
    difference: exactly 50 bytes = the file's 50 line endings

`git status` stays clean throughout, because git compares normalised content.

**The trigger is NOT editing a migration.** docs/FAILURES.md already had an
entry for this error and named the wrong cause — it said the trap fires when an
escalation REWRITES an applied migration. It also fires when nobody touches
anything: any branch carrying a new migration breaks its own slot's `db-up` as
soon as master moves and the branch is rebased. It took three checks down at
once on 12.16 (`db-up`, plus `test_harness.py::test_rerun_is_noop` and
`test_status_format`, which shell out to migrate_local and assert returncode 0).

**How to apply:** `bash scripts/test_db.sh reset` in the TASK'S OWN WORKTREE
with the AGENT_CI_* slot vars exported re-applies everything and re-records the
checksum over the bytes now on disk. Do NOT edit the migration to "fix" it —
that makes the content difference real and invalidates the checksum in every
other slot, the gate's included. The durable fix needs the operator: either
normalise line endings before hashing in `migrate_local.py`, or add
`db/migrations/.gitattributes` with `*.sql text eol=lf` (the same remedy as
`connector/.gitattributes` for `gofmt`) — but the second rewrites every
migration's on-disk bytes and invalidates recorded checksums in every existing
slot at once, so it wants a deliberate reset, not a quiet commit.

## Never run `git commit` in the project root while the loop is running

Worse than the dirty-tree problem above, and it happened TWICE on 2026-09-09
after the first one was understood:

The merge gate stages its merge with `--no-commit` and then spends ~15 minutes
running the suite on the merged tree. During that window `.git/MERGE_HEAD`
exists. **A `git add <file> && git commit -m "..."` in that state commits the
STAGED MERGE plus your file, under your message.**

* TASK-7.8: a commit made 57 s into the gate's suite completed the merge early.
  The pipeline's own commit then found nothing to commit and recorded a merge
  refusal that never happened.
* TASK-7.13: the same, but the swallowed merge carried a whole feature —
  `46a3bdd` is a two-parent merge of agent/TASK-7.13 whose message reads
  "name the real reason the 60 s wait failed" and which also contains
  routers/inbound.py and 382 lines of its tests.

Both trees were correct and gate-verified; what broke was the history's label
and the state files. `unmerged.json` needed the false entry cleared by hand
both times.

**How to apply:** before ANY git write in a project the loop drives:

    ls .git/MERGE_HEAD 2>/dev/null && echo "GATE IS MID-MERGE — do not commit"
    pgrep -f "agent_ci\.cli .*auto"    # and check nothing is running

Checking `validation.json` looks complete is NOT enough: the task's own checks
finish before `full_suite_cmd` does, so the gate is still live. If a project
file must change while the loop runs, stop the loop first
(`agent-ci stop`, wait for the boundary), or wait for the gate to finish.
See [[open-threads-2026-09-08]].

## `agent-ci validate` checks the MAIN tree, not a task's worktree (2026-09-11)
`cmd_validate` calls `run_validation(spec, cwd=cfg.root, env=cfg.isolation_env("main", ...))`.
Pointed at a task whose fix sits uncommitted in `.agent-worktrees/TASK-X`, it
tests master instead -- a new test file reports pytest exit 4 ("file or
directory not found"), which reads like a broken fix. To check a worktree the
way the merge path will, call the API with the worktree:
`run_validation(spec, cwd=<worktree>, logs_dir=cfg.logs_dir(), run_id=...,
env=cfg.isolation_env(spec.id, <worktree>))`.

## Gate logs are SIBLINGS of the run dir, not inside it (2026-09-12)

Measured while watching snoopy_frog TASK-12.13's merge gate. Three separate
locations, and looking in the first one alone makes a live gate look dead:

* `logs/<run>/` — the BUILD artifacts only: `a1-builder.diff`,
  `a1-counterfactual.log`, `preflight.md`, `events.jsonl`, `transcript.jsonl`.
  Nothing is written here once the gate starts.
* `logs/<run>-a<attempt>/` — the TASK's own validation, one
  `<check>.stdout.log` + `.stderr.log` per acceptance check plus a
  `validation.json`. This is where a failing task's real output lives
  (`logs/<run>-a1/web-typecheck.stdout.log` held the seven tsc errors that
  explained TASK-12.15's attempt 1). Same sibling trick as the gate: it is
  NOT inside `logs/<run>/`.
* `logs/<run>-merge/` — the GATE, one `<check-name>.stdout.log` +
  `.stderr.log` per acceptance check (`db-up`, `suite-green`,
  `tenancy-audit-green`, ...). These append LIVE, and pytest's `[ NN%]`
  progress lines make a real completion meter.
* `logs/<run>-merge-full-suite.log` — a sibling FILE holding
  `git.full_suite_cmd`, the whole-tree run.

So **a gate runs the suite twice**: the task's own `suite-green` check inside
`-merge/`, then `full_suite_cmd` afterwards. Budget for both.

Baselines from five consecutive gates that night: full suite 260-288 s each,
the pass count growing per task (2404 -> 2425 -> 2453 -> 2471 -> 2509), and
~11 min of total gate wall time (TASK-12.14: 07:53 -> 08:04 local).

**How to apply:** to watch a gate, `ls -la --time-style=+%H:%M:%S
logs/<run>-merge/` and tail the per-check stdout files -- do NOT conclude a
gate is hung from an empty `logs/<run>/`. For liveness independent of logs,
`ps --ppid <supervisor-pid>` shows the `sh -c .venv/bin/python -m pytest`
child and its accumulated CPU time (~54% of elapsed is a healthy DB-bound
suite). Distinguishing a real hang still needs the byte-identical-partial
test from [[agent-ci-failure-modes]] item 8. See [[merge-pending-race]].
