---
name: phase5-6-freeze-final-test-refill-2026-11-03
description: "Spec-writer refill 2026-11-03 ~21Z — the 5.1 / 6.1 / 6.2 roadmap stubs replaced (same ids) + 5.4 freeze_cli / 6.5 final_test_cli; 6.6 (the hold-out run) HELD on decision:final-test-holdout; measured fixture numbers, design, traps"
metadata:
  node_type: memory
  type: project
  originSessionId: 2026-11-03-spec-writer-phase5-6
  modified: 2026-11-03T21:15:40.630Z
---

Refill 2026-11-03 20:43Z (runnable 5 < low water 6; no drafts, no new RESOLVED decision, every phone ask expired
'wait'). Source = brief item 1, the roadmap stubs (memory replay-driver-refill said 5.1 / 6.1 / 6.2 were next).
Dependencies 5.2 / 5.3 / 6.3 / 6.4 all PASSED, so the stubs were replaced in place (same ids, hold removed):

- TASK-5.1 fxplat.pipeline.freeze_run (deps []): load_freeze_spec(YAML: keys VARIANTS/CONFIG/CODE/DATA + optional
  exclude; sha256 recorded) -> FreezeSpec; run_freeze(root, out, spec, *, git: GitState, now_ms) = dirty-tree
  refusal, notes write-once check, collect_all, write_freeze, POST_FREEZE_NOTES.md (30-line Spanish template).
  The pattern CHOICE is the operator's YAML (rule 7), not a decision ask.
- TASK-5.4 fxplat.pipeline.freeze_cli (deps 5.1): freeze --spec (git_state, `git tag -l` refusal BEFORE writing,
  run_freeze, `git tag final-candidate-v1 <commit>`), verify --spec (exit 4 on drift). Tests use real tmp git repos.
- TASK-6.1 fxplat.pipeline.final_test (deps []): read_final_test_inputs(repo_root, code_patterns, exclude=,
  approvals_dir=, frozen_dir=) -> FinalTestInputs; files: approvals/APPROVAL_FINAL_TEST.txt, .<principal>.sig per
  signer, approvals/allowed_signers, FROZEN_CODE.sha256 at root; gate_final_test; lock_record / lock_text /
  read_lock (LOCK_KEYS approval_sha256, fecha_hora_pa, frozen_code_sha256, git_commit, holdout_end, holdout_start,
  started_ms); open_final_test claims the lock at OPEN time (*reading of §10.18).
- TASK-6.2 fxplat.pipeline.final_report_write (deps 6.1): write_final_report md write-once + docx via injected
  runner running `pandoc <md> -o <docx> --toc --toc-depth=3 -M lang=es` (prompt.txt §1); pandoc NOT installed.
- TASK-6.5 fxplat.pipeline.final_test_cli (deps 5.1, 6.1): check (exit 4 closed) / open (dirty tree refused 3).
- TASK-6.6 final_test_run HELD "needs operator decision" + decisions-pending section 'Final test: opening the
  sealed hold-out to the runner (TASK-6.6)' + ask ea95dab8 (decision:final-test-holdout, safe wait). Reason:
  sources.partition_roles refuses ranges after validation.end; LOCKED_HOLDOUT needs FXPLAT_FREEZE_TOKEN +
  approvals/freeze-<token>.json; research_run.ROLES = DEV / DEV_FULL only.

MEASURED fixture (shared by 5.1 / 5.4 / 6.1 / 6.2 / 6.5 tests; protos /tmp/proto51/p1.py p2.py): TREE a.py
b'print(1)\n', b.py b'x = 2\n', c.pyc, config/periods.yaml, config/variants.yaml, pyproject.toml, DATA_MANIFEST.csv,
notes.txt; spec sha256 06529a09...; manifest digests VARIANTS 3e3d29b0..., CONFIG a98b7821..., CODE
519cf0f8d39213258c021969de3a5ae24d0854ec84fd347ff4031046919de814, DATA 75720ed8...; counts 1/2/3/1; notes sha256
c2961e16... (commit 'f'*40, now_ms 1767225600000 -> '2025-12-31T19:00:00-05:00'); approval A (test_final_test_gate
wording with this D) sha256 514ce3c8ff7ac5d14d41b2df926efbe06b83003d71ac4b8caf6e6d7eca86ff0f; lock now_ms
1798761600000 -> '2026-12-31T19:00:00-05:00'; render_final_report with one EDGE V1 = 55 lines.

LANDED 21:15Z: 5.1 8515720, 5.4 2fd2059 (+7fea965 amend), 6.1 8b827fa, 6.6 held 4cb9e70, 6.2 bacd888,
6.5 9408f8b; queue 9 runnable after. Reviews (gemma4:31b): 5.1 / 5.4 / 6.1 OK first round; 6.2 / 6.5 BLOCKed ONLY
because the reviewer's worktree is based on main and could not see the uncommitted 6.1 / 5.1 drafts ("module does
not exist, stub says DISPUTED") -> commit the upstream drafts FIRST, then review the dependants; both OK after.
Real findings worth keeping: argparse refuses Path objects in argv (str() them in test lists); rerun_cli prints the
exception type only on exit 1 (say explicitly when a new CLI prints it on exit 3 too); an `open` that creates an
untracked lock makes the next dirty-tree check fail (3, not 4) - order the test accordingly; tmp git repos: strip
GIT_* from env and set GIT_CEILING_DIRECTORIES for the non-repo case.

TRAPS: tests/__init__.py does not exist - cross-test imports are RELATIVE (`from .test_x import`); tmp git repos
need user.email/name and their commit hashes are clock-dependent (never pin); git_state counts untracked files as
dirty (a freeze leaves the tree dirty with its own 5 files - documented); fecha_hora_pa is Panama UTC-5 fixed;
claim_final_test_lock needs the parent dir (open_final_test mkdirs it).

**Why:** the next writer must not re-derive the Phase 5/6 split nor re-measure the fixture; 7.2 / 8.4 stubs stay
(Nautilus IB adapter, operator-gated) and 6.6 waits for the ask.
**How to apply:** check `agent-ci status` for 5.1 / 5.4 / 6.1 / 6.2 / 6.5; if decision:final-test-holdout is
RESOLVED, specify 6.6 per the chosen option (a = 3 small tasks: sources role, research_run role, composer). See
[[replay-driver-refill-2026-11-03]], [[real-run-task-ids]].
