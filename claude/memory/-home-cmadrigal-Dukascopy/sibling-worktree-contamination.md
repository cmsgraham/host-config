---
name: sibling-worktree-contamination
description: "Builder copied a concurrently-running sibling task's untracked files into its worktree (11.31 got 11.30's prim_age) → protected-paths fail + timeout"
metadata:
  node_type: memory
  type: project
  originSessionId: 68ddcb5b-13ed-4cdb-af53-a0bd01c63cc3
  modified: 2026-11-08T05:59:35.889Z
---

TASK-11.31 (run-20261022-060738, 2026-10-22): the builder wandered into the sibling worktree
`.agent-worktrees/TASK-11.30/`, tried to edit its tests, then copied `prim_age.py` /
`test_hz_prim_age.py` into its own worktree as untracked files. Result: protected-paths
"modified protected files" + lint-and-no-stray failures, and it burned the 3600 s on an
estimator that built an (n, T, T) tensor. It never wrote the test file. The reviewer's
"not registered in catalogue" finding was bogus: TASK-11.26 already registers it.

**Why:** waves of sibling primitives (11.27–11.34) run back-to-back with near-identical specs,
so the builder confuses which task it owns.

TASK-4.37 (run-20261103-133228, 2026-11-03): `ui/scripts/export_forward.py` was modified with
TASK-4.36's second-ruler WIP (a slightly different revision of it), yet builder-actions.jsonl
shows no action touching it. So contamination can happen without a visible builder edit;
`git checkout --` the file. Also: Bash `run_in_background` "completed" notices can be spurious
while a flock suite is still queued; check `/proc/<pid>` and the `exit=` line in the log.

TASK-7.37 (run-20261104-121629, 2026-11-04): attempt 2 found its files already done, then spent
the hour working in TASK-7.39's worktree (edited its test, ran its full suite) → "builder timed
out after 3600s". The 7.37 worktree itself was clean. The real blocker was attempt 1's valid
reviewer finding (the spec said "naming the first differing field"). So a builder timeout can
just mean an idle builder that wandered off: check builder-activity.log for foreign worktree paths.

TASK-7.53 (run-20261105-085929, 2026-11-05): the builder `cd`ed into TASK-7.50's worktree and
wrote 7.53's owned node_context.py and its test THERE. Its own worktree had an empty diff, the
"tests not found" error appeared, and the run timed out. I rebuilt both files from the spec in 7.53.
The stray untracked copies are still sitting in the 7.50 worktree; the operator must remove them.
Follow-up: TASK-7.50 (run-20261105-083828) then failed lint-and-no-stray and strict-lint-new (B009 in
the stray node_context.py), and its reviewer blamed 7.50. I deleted the strays (backed up to /tmp/esc750)
and fixed the I001 import sort; the owned code was already correct. The strays did not `cmp` equal to
7.53's rebuilt version, so "not identical" does not mean "ours".

TASK-3.188 (run-20261106-233327, 2026-11-06): same pattern again. The builder worked entirely in
TASK-3.182's worktree, leaving `M rerun_cli.py` and `?? tests/pipeline/test_rerun_cli_b1.py` there.
3.188 then had an empty diff and failed with missing_owned_test. I rebuilt both files from the
spec in 3.188. The 3.182 strays are left for the operator, and 3.182 will likely fail
lint-and-no-stray or protected-paths until they are removed.

TASK-3.213 (run-20261108-040714, 2026-11-08): the worktree held TASK-3.210's uncommitted
`M src/fxplat/pipeline/walkforward.py` and `?? tests/pipeline/test_walkforward_train.py`. There
was also an uncommitted `b`→`barriers` rename in the owned exit_labels.py. The WIP commit
76ccbb6 was already the complete, correct implementation. The builder SAW the strays and tried
`git checkout HEAD --`, `git restore` and `git reset` on them, but the **veto guard blocked every
command** as "modifies protected path" (a1-vetoes.md). So a builder cannot clean a protected
stray itself, and only escalation or the operator can. Fix: `git checkout HEAD -- <files>` and rm the stray.

TASK-3.220 (run-20261108-053630, 2026-11-08): after the 15-min nudge the builder created its
owned test inside TASK-3.218's worktree and tried editing 3.218's test_phase2_info.py. The veto
blocked the edits, but the create got through. Its own worktree was clean, so it failed with
missing_owned_test. By the time escalation ran, the stray in 3.218 was already gone. I rebuilt
sources.store_minute_quote_volume and its test from the spec. The spec's own import line was not
isort order (`DAY, E, ...` must be `DAY, FIRST_SUNDAY, LAST_DAY, SYMBOL, E, S, _ticks`), so
`ruff --fix` was needed.

**How to apply:** when protected-paths names files the task does not own, `cmp` them
against the sibling worktree or main. If they are identical copies, delete them, then
`git merge --ff-only main` when the branch has no commits of its own. See also
[[containment-false-positive-operator-ui]] and [[stale-reviewer-lint-findings]].
