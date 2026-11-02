---
name: control-settings-wiring-and-attribution-runner-refill
description: "2026-11-02 19:10Z refill: 9.17 users.log_event (EVENT_ACTIONS ('settings',), ACTIONS 7-tuple, test_users pins re-owned) / 9.18 api settings routes GET /api/settings (trader+admin) + POST /api/admin/settings (deps 9.17; injected g8_check fail closed; FXPLAT_CONTROL_SETTINGS optional; constructor must NOT call the clock) / 3.152 fxplat.pipeline.attribution_runner (per-family C14 stability on taken rows, flag_conclusions, JSON payload); T5 bench world NOT specified (bench.yaml 'T5 pending' is pre-registered config); next free 9.19 / 3.153 / 7.26 / 11.64 / 15.43 / 16.82"
metadata:
  node_type: memory
  type: project
  originSessionId: f5496fdd-5b17-4faa-9d35-9967fc4fb7b2
  modified: 2026-11-02T19:27:26.987Z
---

2026-11-02 19:10Z refill (runnable 3.151 / 7.24 / 7.25; low water 6). No drafts; every phone ask expired at
'wait' except decision:c10-externals (pending since 16:36Z); no new RESOLVED decision; 9.14 / 9.15 / 9.16 all
merged (control-service wiring became writable). Sources used:
- 9.17 (deps []): fxplat.control.users gains EVENT_ACTIONS = ('settings',), ACTIONS = the six + EVENT_ACTIONS,
  UserStore.log_event(action, subject, detail, *, actor, now_ms, ip='') -> AuditRow (checks action, subject,
  detail, now_ms, ip, actor-is-active-admin in that order; subject/detail stored as given; cursor.lastrowid =
  seq). tests/control/test_users.py pins ACTIONS (line 52) and __all__ (line 79) -> owned + re-pinned.
- 9.18 (deps 9.17): api.py GET /api/settings outside the admin prefix (SETTINGS_ROLES trader+admin, viewer 403
  forbidden), POST /api/admin/settings (admin; {changes} dict; g8_check() consulted ONLY when
  changes['ib_account_mode'] == 'LIVE'; SettingsError -> 400 refused; written -> store.log_event('settings',
  'revision <n>', applied.detail)); 503 settings_unavailable without a path; 500 settings_corrupt on GET of a
  bad file (POST -> 400 refused, apply_changes loads first). api_from_env: ENV_SETTINGS optional, clock() ONCE
  (started) reused as service_started_ms; env passed through. test_api.py pins __all__ (18 names) and an ast
  rule "fxplat imports start with fxplat.control.users" (line 575) -> owned + widened. Test (g) builds
  ControlApi with bad clocks and expects the error only at handle(): the constructor must not call the clock.
- 3.152 (deps []): attribution() (validation/attribution.py) is called by NO pipeline/publish module and needs a
  `stable` mapping nothing computes -> runner: family_stability = regimes.c14(...).passed per family on the
  TAKEN rows (families without taken rows absent), run_attribution(inp, result, *, registry, stable=None,
  c14_subperiods=None, n_boot, global_seed) -> AttributionRun(attribution, stable, conclusions(flagged), payload);
  payload records NaN -> None, json.dumps allow_nan=False. Numbers from tests/validation/test_attribution.py's
  _design(600) at n_boot 200: 19 cells / 12 reportable, LONDON q_by 0.0309, unconditional lo 0.13325 hi 0.26008,
  design(500,50) with enter False at i%3==0 -> n_taken 366, 38 cells, lift DON20 333/167, RSI2 33/17.
- Checked and NOT specified: bench T5 world (bench.yaml 'T5: pending the C10 runner' + score.py PENDING clause are
  pre-registered config / protected - P1 says any change after S1 is bench v2 -> operator); 7.26 K13 marks in
  bench_sim_switches needs the sim to consume marks first (7.24/7.25 only add the input); K13 runner wiring
  touches config/ (PaperConfig exact keys).
- Prototypes: /tmp/p917 (src/fxplat/control/{users,api}.py patched copies, scen_users.py, scen_api.py,
  review-*.log), /tmp/p3152 (attribution_runner.py, scen.py).

**Why:** the next writer must not re-derive the control-service wiring split or the attribution runner, and
must know the T5 world is the operator's.

COMMITTED 2026-11-02 19:3xZ: 9.17 c7ac4d0 / 9.18 e51bd32 / 3.152 21733dd (all reviews OK first round; 9.17
medium finding = test_module_is_pure pins doc.count('  * ') == 3 in test_users.py -> the *reading goes in prose,
not a bullet; the others low, applied). Tree clean after the commits.

**How to apply:** `git log --oneline -3 -- tasks/TASK-9.17.yaml tasks/TASK-9.18.yaml tasks/TASK-3.152.yaml`;
reviews in /tmp/p917/review-TASK-*.log and logs/spec-review-TASK-*.md; finals in /tmp/p917/<id>.final.yaml. Related: [[k13-extraordinary-and-f2-c1-mde-refill]],
[[control-service-api-settings-refill-2026-11-02]], [[merge-gate-wipes-uncommitted-task-edits]], [[real-run-task-ids]].
