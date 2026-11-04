---
name: containment-false-positive-operator-ui
description: "workspace-containment can blame a builder for the operator's own concurrent ui/ commits in the project root"
metadata:
  node_type: memory
  type: project
  originSessionId: 86c0aa9a-0e27-4105-baf3-9a42f44a8bf7
  modified: 2026-11-04T03:12:19.477Z
---

On 2026-10-12, TASK-3.78 failed workspace-containment because of ui/ files that came from the operator's own commit 7baad2d, made in the root while the run was going. The builder did not write them.

It happened again on 2026-10-14 with TASK-9.10. The flagged `config/variants.yaml` was the operator's draft, committed later in root `de14bf4`. The builder transcript never touched it. The builder also timed out because it re-ran the full suite (about 17 minutes each run) 3 times. The code was already complete and nothing needed to change.

It happened a third time on 2026-10-22 with TASK-12.14. The flagged path was `experiments/observations/`, the operator's observation-days DB work from another session (committed later in root `2a309fb`). The supervisor moved those files to `logs/<run>/escaped-files/`, but the operator's commit still holds them. The reviewer findings on that run (missing `turnover`/`name`/`q`) were also wrong: they were stale or did not match the spec.

It happened a fourth time on 2026-10-23 with TASK-13.1. The flagged path was `experiments/hallazgos/ideas.jsonl` (untracked), which the operator's live hallazgos ideate batches append to (commits 470c4b8/b36abea fall in the run window). The builder never mentioned it. Nothing was lost: every escaped line was still in the root file, which kept growing.

A fifth case came on 2026-10-25 with TASK-16.30. The flagged paths were deploy/server/compose.fun.yml, deploy/server/ib-watchdog/, redeploy-ib-watchdog.sh and tests/deploy/test_{fun_deploy,ib_watchdog}.py, all from the operator's ops commit 572d47d (IB watchdog plus fun-sim GPG_KEY fix), merged in b506a62. The builder's diff was already complete and correct: all acceptance checks and strict-lint-new passed with no edits.

A sixth case came on 2026-11-04 with TASK-5.4. The flagged path was `experiments/registro.csv`, from operator commit 410e8aa (KRONOS-001 registro row) made 16 s after the run started. The quarantined copy in escaped-files/ was byte-identical to the committed HEAD version (fast check: `diff <(git show HEAD:path) logs/<run>/escaped-files/path`). The builder code was correct; only spec item (c) needed tightening (the DATA_MANIFEST deletion is cumulative on top of the a.py change, not a separate repo).

**Why:** the supervisor treats any root change made during a run as the builder's. It also says it "removes" those files, which could throw away the operator's uncommitted edits.
**How to apply:** when triaging a containment failure, compare the flagged paths with `git log` commits made during the run window before you blame the builder. If they match, the failure is environmental, so retry. Related: [[suite-green-timeout-diagnosis]].
