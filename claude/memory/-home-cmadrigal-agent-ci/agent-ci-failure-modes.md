---
name: agent-ci-failure-modes
description: "The three recurring ways agent-ci tasks fail (bad builder tests, reviewer blindness, integration conflicts) and the guards now in place"
metadata: 
  node_type: memory
  type: project
  originSessionId: d4d5e3c0-0561-47b1-94a1-24f753f10ea0
  modified: 2026-09-13T19:07:06.628Z
---

2026-09-01/02 dogfood on x-scraping-project (TASK-1.3 .. 2.6, all now PASSED
and merged). Every stall traced to one of three causes, none of which was a
broken implementation:

1. **The builder writes a test that contradicts the task's `requirements:`,
   and the reviewer sides with the test.** On TASK-2.3 the reviewer instructed
   the builder to delete a `completed = FALSE` filter to satisfy a wrong test,
   violating "Completed tasks must not be leased again". Guard: the reviewer
   prompt now says REQUIREMENTS are the specification and outrank any test in
   the diff; a contradicting test is itself the bug.
2. **The reviewer could not see new files.** `Repo.diff()` covered tracked
   paths only, so a builder creating whole new modules produced an empty diff
   while `changed_files` still listed names. Guard: untracked content is
   included in the diff. These two compound — a contradictory test can only be
   caught if the diff shows it.
3. **Integration conflicts invisible to any acceptance check**, because each
   task validates alone in its own worktree with its own venv: TASK-2.4
   pip-installed fastapi and never declared it; TASK-2.5 and TASK-2.6 both
   implemented `orchestrator.providers`, one a package and one a module (git
   merged both cleanly, Python shadowed one). Guard: `git.verify_merge`
   (default on) stages the merge `--no-commit --no-ff`, re-runs the task's
   required checks against the MERGED tree, and commits only if they pass.

**Why:** these repeat because a task is only ever proven in isolation, and the
reviewer's evidence was incomplete. **How to apply:** when a task stalls, check
the transcript for a repair instruction that would violate a requirement before
assuming the implementation is wrong; when a merge fails, suspect two tasks
that branched from the same base and claimed the same name. Related:
[[agent-ci-build-progress]], [[docker-wedge-issue]].

**Added 2026-09-05 (branch pipeline-revision, learned from live runs):**
4. **The harness itself can be the failure.** Three times in one day a
   pipeline change broke validation before any test ran: TMPDIR placed inside
   a /mnt/c worktree (pytest capture cannot truncate there); exporting
   COMPOSE_PROJECT_NAME (Docker honours it implicitly, so a second Postgres
   fought the first for port 5434); a classifier needle ("no tests ran") that
   turned a tooling crash into a "spec" stop and fired an escalation. Rules
   now enforced by tests: the isolation env exports nothing a tool honours
   implicitly (all opt-in under AGENT_CI_*); tmp dirs live on the system tmp;
   a traceback confined to site-packages is `tooling_failure` (environment,
   never escalated); every category routed to `human` needs a live-output
   fixture in tests/test_classify.py.
5. **A post-escalation re-run must judge the escalation's tree first**
   (validate_first=True); a fresh builder on top of it destroyed a passing
   fix (snoopy TASK-2.4).
6. **Acceptance side effects are not drift**: tests leave markers, caches
   and reports in the tree; tree-drift only counts builder-touched or new
   source files.
7. **The reviewer invents findings.** THREE TIMES in snoopy_frog Phase 12 (2026-09-12)
   `qwen3-coder-next:80b` raised P0 findings that were factually false about the
   codebase. TASK-12.3: it blamed `sync_authfile` for "not writing the file when
   there are no connectors" -- a rationale for a failure it never diagnosed,
   since all three tests died at `UndefinedColumnError: column c.remote_port
   does not exist`. TASK-12.7: findings F002/F003 claimed the screen was on the
   wrong platform, raising Next.js SSR concerns, when `apps/web` is expo-router
   57 + react-native 0.86 + react-native-web 0.21 with no `next` dependency at
   all, and `react-native` imports are the house style. Implementing that one
   would have broken a working screen. Both escalations disputed them correctly,
   and in both cases the other findings were real. **How to apply:** the repair
   prompt's DISPUTED path exists for exactly this -- check a P0 finding against
   the actual file and `package.json` before implementing it, and treat a finding
   that cites no line number as suspect. A hallucinated finding is not harmless:
   it competes for the escalation's attention with the real defect.
   **THE PLATFORM PRIOR IS THE RECURRING ONE, and I traced it.** Third instance:
   TASK-12.14 F002 ("uses React Native components instead of web equivalents...
   incompatible with a Next.js web app and will cause runtime errors") and F007
   ("logs to console instead of using Next.js navigation"). Acting on either
   breaks a working screen; two escalations rejected the identical claim
   independently. DO NOT REPEAT MY TWO WRONG GUESSES about the cause: it is NOT
   in the reviewer prompt (no "Next.js" anywhere in `agent_ci/prompts/*.py`) and
   NOT from repo docs -- `build_review_prompt` (reviewer.py:69) assembles only
   id/title/objective/requirements/acceptance, validation results and diff
   sections; `decisions_file` is read by `phases.py` for the ARCHITECT alone;
   and DECISIONS.md DEC-001 correctly records v3 as "Expo web + FastAPI +
   Patchright" (it is v2 that was Next.js). Proven by reading the transcript row
   `kind='verdict' from='reviewer' to='supervisor'`: the phrase lives in the
   model's own `blocking_issues[].evidence`. It is a MODEL PRIOR, so the only
   fix is naming the platform in the reviewer prompt.
8. **A test that scans the repository passes in its worktree and HANGS AT THE
   GATE.** snoopy_frog TASK-12.7 (2026-09-12) had its merge refused twice with
   `connector-ui-tests-green` and `suite-green` both TIMEOUT and zero stderr.
   Cause: `REPO.glob("**/connector.json")`, whose `node_modules`/`.git` filters
   applied to the RESULTS while the traversal stayed unpruned. A task's `REPO`
   is its worktree; the GATE's `REPO` is the project root, which contains
   `.agent-worktrees/` -- 76 worktrees, 76 with a `.venv`, 67 with
   `node_modules`, on a /mnt/c mount. Measured: never returned in 45 s from the
   root, 10.5 s inside one worktree, and `git ls-files` covers all 702 tracked
   files in 0.019 s. Fixed by asking the index instead (also semantically
   exact: "checked in" is a git question and `.agent-worktrees/` is gitignored);
   46 tests went from 7.63 s to 0.86 s.
   **The tell, and I missed it twice:** the partial output was BYTE-IDENTICAL
   across both refusals -- exactly 12 dots (the 13th collected test) and exactly
   53%. A transient stalls somewhere new each time; a deterministic hang stalls
   in the same place. Compare partial sizes before calling a gate failure
   transient, and remember the gate is the only place a root-rooted path walk
   is unbounded.

**Shell pitfall:** `pgrep -f "<text>"` matches the bash running it; use the
`[b]racket` trick or the waiter/killer hits itself (cost one relaunch today).
**And the bracket trick is NOT enough** (2026-09-12): the long-running phase
MONITOR's own command line contains the very patterns you grep for, because its
script text includes `pgrep -f 'agent_ci.cli.*auto'`. So
`pgrep -f '[a]gent_ci.cli.*auto'` returned the MONITOR's pid (725847), I
reported it as the supervisor, and inspected the wrong process's children -- its
`sleep 60` rather than the gate's pytest. The real supervisor was 1052476, named
in `state/MERGING.json`. **How to apply:** get the supervisor's pid from the
state files that record it (`MERGING.json`, `ESCALATING.json`) rather than from
a pattern match, and when you must match, check the hit's own cmdline before
believing it -- a process whose job is to watch for a pattern will always
contain it.

**A LOG-FILE GLOB IS NOT A LIVENESS SIGNAL** (2026-09-12 22:5xZ). I ran
`ls -1t logs/auto-*.log`, got `auto-20260912-002759.log` last written 15.8 HOURS
earlier, whose tail was an end-of-run stats summary, and was one step from
reporting the overnight loop dead while it was running two escalations. The loop
was alive: pid 1468396, `agent_ci.cli --config .../v3/config.yaml auto`, started
15:42 CST. **A loop the WATCHDOG restarts writes to a different filename
pattern** -- `logs/auto-watchdog-<ts>.out`, not `logs/auto-<ts>.log` -- so the
glob that matches a hand-started loop silently misses every watchdog-started
one, and an empty/stale glob result looks identical to a dead pipeline.
**How to apply:** prove liveness from the PROCESS, not from a filename. The
cheapest sound check is that the escalation pids in `state/ESCALATING.json` have
the supervisor as their PPID -- both of tonight's reported PPID 1468396, which
identifies the live loop and confirms it owns them in one reading. To find any
process's real log, read `/proc/<pid>/fd/1` rather than guessing the name. And
`state/watchdog.jsonl`'s last rows ("the pipeline is working", every ~15 min)
are an independent, timestamped liveness witness that costs one `tail`.
This is the same family as the `pgrep` trap above and as the UTC/local
`find -newermt` error: THREE times in one night an absent or stale reading from
a mis-aimed instrument became a positive claim about the world. Absence of
evidence from a tool you have not validated is evidence of nothing.

**IN A LINKED WORKTREE `.git` IS A FILE, SO `.git/<state>` TESTS ARE ALWAYS
FALSE** (2026-09-13, the fourth of the family in one night). Resolving a rebase
conflict in `.agent-worktrees/TASK-13.3`, my loop guarded on
`[ -d .git/rebase-merge ]`. In a linked worktree `.git` is a 67-byte FILE
holding `gitdir: /.../.git/worktrees/TASK-13.3`, so that test is false even
mid-rebase: the loop broke instantly, resolved nothing, and left the rebase
half-applied with `UU tests/db/test_auth_devices.py`. The tell was `ls` saying
"**Not a directory**" rather than "No such file". **How to apply:** never build
a path under `.git` by hand in a worktree -- ask git:
`git rev-parse --git-path rebase-merge` (also `--git-dir`, `--git-common-dir`).
The same applies to MERGE_HEAD, CHERRY_PICK_HEAD and any other state file.

**A REVIEWER `FIX` BLOCKS A TASK WHOSE CHECKS ARE ALL GREEN, AND THERE IS NO
MERGE COMMAND.** `final_result` (`agent_ci/agents/reviewer.py:195-199`) is
`if not validation_passed: return False` then
`return not outcome.failed and outcome.verdict.approved` -- so the verdict is a
hard gate, and `_move(run, TaskState.PASSED)` (supervisor.py:543) is what the
merge path keys on. The CLI has NO `merge` subcommand (init/doctor/models/
status/tasks/run/next/auto/logs/validate/review/dashboard/phases/phase-review/
phase-ack/watchdog/lessons/stats/resume/stop), so when the reviewer refuses a
green task AND escalation budget is spent, the only routes are a re-run (which
re-rolls the reviewer, since it is a model sample) or a hand merge -- i.e. it
becomes the operator's decision, every time. A refused MERGE is different:
`stall_kind: "integration"`, which `cli.py:1098` deliberately does NOT escalate.
**Two more absence-reasoning refusals to add to point 7:** TASK-13.2's
F001/F004 claimed `reserved_accounts` and a `deferred` counter were
unimplemented (both present, scheduler.py:1300 and :1371-1373) and F002/F003
merely echoed a test-audit flag that the SPEC caused by asking for a diagnosis
in the commit message, where no auditor can read it; TASK-13.3's F001 called a
`test_ticket_events` failure "a new failure introduced by this diff" when the
diff touches no ticket file and the test passes on master. The cluster is
diffs that are test-only or that leave the named file unchanged.

**A DEAD `auto` LOOP LEAVES ITS PER-TASK TEST CONTAINERS RUNNING.** After the
loop exited, `agentci-task-13-2-postgres-test-1` and
`agentci-task-13-3-postgres-test-1` were still up with no supervisor. That is
the port-squat condition in [[docker-pool-slot-leak]]. Check `docker ps` after
any loop death and remove the containers of tasks that have merged.

**A HAND MERGE LEAVES THE TASK `ELIGIBLE` FOREVER, BECAUSE THE STORE NEVER SAW
A PASS.** After the operator told me to hand-merge TASK-13.2 (green checks, a
false reviewer FIX, escalation budget spent), its work was on master but
`agent-ci tasks` still printed `ELIGIBLE  TASK-13.2` -- 90 PASSED, 1 ELIGIBLE.
`cmd_tasks` (cli.py:474) derives status from `_store(cfg).passed_task_ids()`,
and `state/history.json` is a LIST of run records (308 of them; keys run_id/
task_id/status/attempt/...). TASK-13.2 had five `HUMAN_REQUIRED` rows and no
`PASSED` row, so the loop would have picked it up again on the next `auto` and
run a task whose work was already merged -- and since a re-run after a plain
stall is NOT an escalation handoff, a fresh BUILDER goes first and can invent
changes on a task with nothing left to do. **How to apply:** after any hand
merge, either run the task once so the pipeline records a genuine pass (its
branch is already an ancestor, so `_integrate` short-circuits on "added no new
commit" at cli.py:862-868), or expect a wasted run later. Do NOT hand-edit
`state/history.json` to fake a pass: that is falsifying the pipeline's own
record, and the ledger is the only evidence of what was actually proven.
**Also check the merged task's worktree for uncommitted work:** 13.2's held a
stray 14 KB `ys` file (ANSI `git log` output from a botched redirect, which is
what failed `scope-respected`) AND a correct one-line comment fix that had
never been committed, because the run died before committing. The garbage and
the gem sit side by side -- read the diff before discarding either.

**CAVEAT ON THAT ADVICE: the "record the pass" re-run gets a REAL validation
and a VACUOUS review.** `_review_base` (supervisor.py:747-772) returns
`merge-base(integration_head, HEAD)`, which exists precisely to stop a review
on an empty diff when a branch already carries its work. It cannot help here:
after a hand merge, `worktrees.refresh` fast-forwards the branch to equal
master, so the merge-base IS master and there is no earlier point to reach back
to. The reviewer is shown nothing. Measured on TASK-13.2's re-run: a 3655-char
review prompt against 13.3's 13458, and the docstring's own precedent is
snoopy_frog TASK-10.4 (2026-09-08), "reviewed twice on a 2.7 KB prompt with no
diff in it at all, and approved -- the reviewer was not wrong; it was shown
nothing." So the PASSED row such a run writes rests entirely on the
deterministic checks, which is consistent with this repo's rule that validation
is the ONLY completion authority, and those checks are real (2680 tests green,
including the task's own). But do NOT describe the resulting pass as
"reviewed": a builder also runs first in that window (no escalation handoff, so
no `builder_skipped`), and on TASK-13.2 it correctly wrote nothing --
`git status --porcelain` empty, no commits in `master..HEAD`, no
`a1-builder.diff` artifact at all. **And do not read that missing artifact as
proof of an empty diff:** grep on a nonexistent path returns nothing whatever
the truth is; prove "the builder changed nothing" from the worktree and the
branch, which are real objects.
**CONFIRMED, not predicted:** that run then returned
`review_done {verdict: APPROVE, duration: 85.6}` on the 3655-char prompt, with
`counterfactual {status: NOT_APPLICABLE, tested: []}`, and certification listed
db-up / scheduler-tests-green / scheduler-tests-are-deterministic / suite-green
as AUTHORITATIVE and only scope-respected as evidence. So the ledger reads
PASSED and the census went to 91 PASSED with nothing eligible, `_integrate`
short-circuited without touching master, and the whole exercise cost a
702.7 s builder that wrote nothing plus 466.5 s of validation. Budget that
honestly when choosing it: it buys a clean queue and a real re-verification of
the merged tree, not a second opinion. It also LEAKS ITS SLOT CONTAINER again
(`agentci-task-13-2-postgres-test-1` was up after exit), so pair it with the
`docker ps` check above.
**2026-10-06, three more (all fixed same day):** (1) yaml.safe_load dropped the comment notes under `requirements:`
that hold every spec's verified facts / registered definitions -- no prompt had ever shown them (ff0b523 keeps them
as TaskSpec.requirement_notes). (2) An unfinished build's "file not found" checks were spec-class and routed the
escalation to the read-only diagnosis cell (ff0b523: origin "model" -> repair). (3) OpenHands' LLM default timeout
300 s x 5 retries cut every module-sized generation (8/29 requests dropped on TASK-2.8); builder client now 1500 s x 2.
Diagnose with gateway telemetry.db `requests` (status 'drop' = client hung up) before blaming model speed.
