---
name: agent-ci-real-failure-records
description: "Where agent-ci keeps the real per-check output and reviewer findings when escalation evidence says \"failure now: none\""
metadata:
  node_type: memory
  type: reference
  originSessionId: 10a23a86-b738-4f1c-80aa-62ec4c84039c
  modified: 2026-10-04T23:34:34.262Z
---

When an agent-ci escalation evidence file (`logs/run-*-escalation-evidence.md`) or
`state/HUMAN_REQUIRED.md` gives no concrete failure, the real record is in
`state/history.json`: a list of run entries, each with `attempts[].validation_results`
(per-check command, exit code, stdout/stderr tails) and `findings` (reviewer F00x
with body and repair_instructions). `state/auto-phase0b.log` (grep the task id) has
the one-line timeline: validation_done failed-checks, review verdict, finding ids.

Also check `git log main -- tasks/<TASK>.yaml`: the user sometimes fixes a
spec/test contradiction after the failed run (TASK-0.12, commit 975aba1), so the
failure may already be resolved in the current tree. Reviewer repair instructions
can contradict requirements (TASK-0.12's said to rename the required `validation`
stage). Requirements win.
