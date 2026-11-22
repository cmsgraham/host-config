---
name: refill-2026-11-22-r2-followups
description: "2026-11-22 ~04:30Z refill: R2 follow-ups - 15.76 catalogue-bench-v5, 11.83 block_value, 11.84 block_value_report, 15.77 driver guard, 15.79 repower re_k; 15.78 bench-v5.yaml held on ask decision:bench-v5-baseline; next free 11.85 / 15.80"
metadata:
  node_type: memory
  type: project
  originSessionId: ec61e57d-8989-4ea8-8db9-b5cbcf0a73a7
  modified: 2026-11-22T04:38:23.179Z
---

Refill 2026-11-22 ~04:30Z (supervisor-launched, runnable 11.79 / 11.82 / 15.75). The three R2 stubs left by
[[refill-2026-11-21-r2-block-pools]] were specified:

- 15.76 config/synthetic/catalogue-bench-v5.yaml = v4 + ", COMMODITY, HAVEN" on the three RE7 pairs lines
  (sha 6c8072aa..., hash dbbede6f..., 3,504 cells) + tests/synthetic/test_bench_catalogue_v5.py.
- 11.83 fxplat.synthetic.block_value (pure: group_rows / m_cost / h3_cost / kind_value / kind_value_markdown).
- 11.84 fxplat.synthetic.block_value_report (reads result_hz.json of S2 edge + null worlds, writes
  KIND_VALUE.json / .md, CLI). Separate module on purpose: 11.83's test scans block_value.py for "no I/O".
- 15.77 driver.plant_mismatches: block cell judged like RE7 over bench_hz.members (the stub's driver half).
- 15.79 repower._power_cell passes re_k=len(bench_hz.members(pair) or MAJORS) (the stub's repower half).
- 15.78 bench-v5.yaml HELD "needs operator decision": baseline scan = catalogue v1 (a) or v4 = v1 + RE7 (b, rec.);
  ask key decision:bench-v5-baseline (sent, held for quiet hours). When RESOLVED: write the spec (8 header lines +
  bench-v4 with the scan block changed; option (a) canonical hash df3b13c3... measured; re-measure for (b)).

Next free ids 11.85 / 15.80.

**Why:** the next writer should not re-derive these, and 15.78 is the only R2 piece still open.

**How to apply:** check state/decisions-pending.md "2026-11-22 - NEEDS DECISION bench v5" for a RESOLVED mark first.
Facts worth keeping: driver.json pins a bench root to its catalogue sha256 and world stores are deleted after
scoring, so bench-v7 cannot be re-run in place (a v5 run = fresh root, 56 worlds rebuilt). A dependency still
BUILDING can be prototyped from its worktree's src file (15.75's bench_hz) plus the spec's registered edits; check
it against the dependency spec's MEASURED values before measuring on top. The shell's TMPDIR may point into a
builder's tmp dir (/tmp/agent-ci/task_*): set TMPDIR to the scratch folder for measurements. `git diff --quiet
HEAD -- config` in an acceptance fails in the merge gate when the task ADDS a config file - list the unchanged
files explicitly (see [[acceptance-git-status-codes-merge-gate]]).
