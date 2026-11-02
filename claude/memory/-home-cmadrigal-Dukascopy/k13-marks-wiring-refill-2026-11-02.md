---
name: k13-marks-wiring-refill-2026-11-02
description: "2026-11-02 20:4xZ refill: 7.26 paper_store PaperConfig.marks_path + read_extraordinary (deps []) / 7.27 paper_runner K13 marks wiring (deps 7.26; status key 'extraordinary' ONLY with a marks_path because the 16.20 golden digests status.json; run_cycle is AT C901 15 -> helpers _read_marks / _add_marks_status) / 7.28 fxplat.execution.k13_marks operator CLI (deps []); no RESOLVED decision, all phone asks expired 'wait'; next free 7.29 / 9.19 / 3.153 / 11.64 / 15.43 / 16.82"
metadata:
  type: project
  originSessionId: refill-20261102-204132
  modified: 2026-11-02T21:23:12.216Z
---

2026-11-02 20:41Z refill (runnable 3.151 / 3.152 / 9.17 / 9.18; low water 6; escalation engineer on 3.152).
No drafts; ops 0 cases; asks c10-externals / family3-grammar / family4-grammar all expired 'wait'; no new
RESOLVED decision; UI-A / UI-E / R rows / PHASE3 map exhausted. Source = the runner wiring 7.24 / 7.25 left open.
- 7.26 (deps []): paper_store `_OPTIONAL_KEYS` + 'marks_path', PaperConfig trailing `marks_path: Path | None =
  None`, read_extraordinary(path) -> Marks strict (missing file IS an error; text.split('\n') so 'line i' = file
  index). Owns tests/execution/test_paper_store.py for the ONE _field_defaults entry
  (test_registered_files_and_docstring, line 135).
- 7.27 (deps 7.26): _Env gains trailing marks / marks_unreadable; _read_marks(cfg) -> (marks, unreadable,
  errors) replaces run_cycle's `errors = []`; _extraordinary(env, at_ms) -> None / dict.fromkeys(MAJORS,
  'extraordinary:marks-file-unreadable') / k13_details; _add_marks_status only when cfg.marks_path set
  ({'active': {sym: [ids]}, 'torn'}; unreadable -> {'active': {}, 'torn': None}). MEASURED with the Rig (proto
  /tmp/p726: patched src + `ln -s config`, scen/test_scen.py run with PYTHONPATH=/tmp/p726/src:tests/execution):
  mark marked T+10 s does not block the decision at T but shows at C1 (point in time); lift at T+10 s still
  blocks T. Inline code pushes run_cycle over mccabe 15 (strict-lint-new C901) - helpers required.
- 7.28 (deps []): fxplat.execution.k13_marks mark / lift / show; whole file + new line re-parsed; torn last line
  (parser torn, or no trailing newline) refused for ALL commands; missing file = empty for the CLI (first mark
  creates it) but an error for the runner; refusal indices = len(lines) after popping the trailing ''.
  Scenario script /tmp/p726/scen/cli_scen.py.
- Checked and NOT specified: C10 research_run wiring (ask expired), family 3/4 grammar (asks expired), attribution
  runner wiring (3.152 unmerged, in escalation), bench_sim_switches K13 marks recompute (needs 7.27 first), §10.8
  perturbation driver (needs build_dataset family-param hooks - large).

**Why:** the next writer must not re-derive the K13 wiring split, the golden/status-key constraint or the C901
trap, and should know which leads are still blocked and why.

COMMIT STATE 21:2xZ: all three reviews OK first round (lows applied: 7.26 local minimal()/repo_dir copies, 11 kwargs,
out_dir/marks.jsonl collision note; 7.27 `from fxplat.risk import extraordinary as ex` because paper_store.mark_line is
the EQUITY serialiser with the same bare name; 7.28 `text.isascii() and text.isdigit()`, '²' refused). Holds lifted,
hold-free copies in /tmp/p726/TASK-7.2x.final.yaml; detached /tmp/p726/commit_when_clear.sh chain (7.26 -> 7.28 ->
7.27, logs /tmp/p726/commit_7.2x.log) waits for the 9.17 merge gate (MERGING.json since 20:50Z) and commits with
`git add -f` (gate exclude hides tasks/). LANDED 21:22Z after the 9.17 gate: 7.26 a050fe4, 7.28 02cedab, 7.27
52bc39f; tasks/ clean.

**How to apply:** `git log --oneline -3 -- tasks/TASK-7.26.yaml tasks/TASK-7.27.yaml tasks/TASK-7.28.yaml`;
reviews in /tmp/p726/review-TASK-*.log + logs/spec-review-TASK-7.2*.md. Left for K13: deploy wiring (operator:
paper.json marks_path, install an empty /opt/fxplat/paper/marks.jsonl, UI line from status['extraordinary']) and
the bench S3 recompute with marks (7.29 candidate after 7.27 merges). Related: [[k13-extraordinary-and-f2-c1-mde-refill]],
[[real-run-task-ids]], [[merge-gate-wipes-uncommitted-task-edits]], [[strict-lint-1000-line-cap]].
