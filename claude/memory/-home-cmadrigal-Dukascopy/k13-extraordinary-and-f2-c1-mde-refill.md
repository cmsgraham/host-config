---
name: k13-extraordinary-and-f2-c1-mde-refill
description: "2026-11-02 17:40Z refill: 7.24 fxplat.risk.extraordinary (K13 'evento extraordinario marcado' marks file, pure) / 7.25 kill_switches.SwitchInputs.extraordinary wiring (deps 7.24) / 3.151 f2_budget MDE at C1's alpha 0.025 (bench P8); sources found: prompt.txt §13 K13 fifth trigger unimplemented, bench design §13 L3 / P7 / P8; attribution() is wired nowhere (counterparty flag render has no home yet); next free 7.26 / 3.152 / 9.17 / 11.64 / 15.43 / 16.82"
metadata:
  type: project
  originSessionId: refill-20261102-174011
  modified: 2026-11-02T18:50:17.387Z
---

2026-11-02 17:40Z refill (runnable 3.149 / 3.150; low water 6). No drafts; all phone asks still 'wait'
(c10-externals pending until ~20:36Z); `agent-ci ops` 0 cases; no new RESOLVED decision. Sources used:
- prompt.txt §13 K13 lists five triggers; the fifth "evento extraordinario marcado" has NO input anywhere
  (kill_switches._k13 passes only `thin` from paper config thin_dates). The bench design (agent-ci
  docs/research/2026-10-23-synthetic-known-answer-bench.md §13 item 4 / §17 P7) records the gap. Specified
  as 7.24 (pure marks file: 'mark' / 'lift' JSON lines, operator-log torn-line rule, point-in-time
  `active` on marked_ms, k13_details -> 'extraordinary:<ids>') + 7.25 (SwitchInputs trailing field
  `extraordinary`, _k13 calendar-first, _k13_relaxed never relaxes a mark; kill_switches must NOT import
  the new module). Prototype + hand scenario: /tmp/p724/extraordinary.py. LEFT: the runner / paper-config
  wiring (where the marks file lives, health line) - PaperConfig uses exact-key checks (paper_store), so a
  new config key touches config/ too; and bench_sim_switches' independent K13 recomputation ignores marks.
- Bench design P8 "The V1 MDE is 0.085 R, not 0.0755 R" (C1 = two-sided 95 % CI lower bound > 0 -> one-sided
  0.025; ratio 1.1267297580970221) -> 3.151 adds mde_c1 / c1_alpha / schema_version 2 to f2_budget next to
  the registered §10.16 numbers (flags unchanged). export_g3 reads only f1.cost_model_version; its test is
  tests/publish/test_ui_dash_exporters.py (there is NO test_export_g3.py).
- Checked and NOT specified: counterparty flag rendering (3.148 follow-up) - fxplat.validation.attribution.
  attribution() is called from no pipeline module, so there is no attribution block to render into; a
  §10.15 attribution runner would come first. PHASE3 §6 daily track (B-D1) already exists
  (sampling.daily_events, f2_budget D1 rows). The §17 P-items of the bench doc are RECOMMENDATIONS (column
  'Recommendation'), not operator RESOLVED entries; P11 was taken by 3.149, P7 / P8 here.

**Why:** the next writer should not re-derive the K13 gap or re-check the attribution wiring, and must
know the bench P-items are recommendations.

COMMIT STATE 18:50Z: all three spec-reviews OK (second round; low findings applied); a 3.149 merge gate
(MERGING.json 18:38Z) blocked the commit, so the detached committer /tmp/p724/commit2.sh (setsid nohup; log
/tmp/p724/commit2.log) copies /tmp/p724/TASK-<id>.final.yaml (hold-free) into tasks/, validates and commits
7.24 -> 7.25 -> 3.151 once the gate clears (`git add -f`: the gate exclude hides tasks/). 7.25 depends_on
7.24, so the order matters.

**How to apply:** `git log --oneline -3 -- tasks/TASK-7.24.yaml tasks/TASK-7.25.yaml tasks/TASK-3.151.yaml`
and `cat /tmp/p724/commit2.log`; a missing one is restored from /tmp/p724/TASK-<id>.final.yaml and committed
with `git add -f` when state/MERGING.json is absent. Review logs: /tmp/p724/review2-*.log. Related: [[c10-runner-refill-2026-11-02]], [[real-run-task-ids]],
[[merge-gate-wipes-uncommitted-task-edits]].
