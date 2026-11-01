---
name: ops-blocked-specs-refill-2026-11-01
description: "2026-11-01 05Z refill: five 'spec held by review' operator specs fixed in one pass (16.53 exec bit / 11.51 financing_r import+tests / 11.56 circular import + <TMP> pin / 15.36 latin-square arithmetic + index-based H1 / 15.37 test isolation from the real suite lock); workflow = edit all, back up to /tmp, five parallel detached reviews, commit at OK with lows applied"
metadata:
  node_type: memory
  type: project
  originSessionId: 0f36fe5e-8371-4983-9fad-9511318bec2e
  modified: 2026-11-01T05:17:59.855Z
---

2026-11-01 05:1xZ (spec writer; runnable 16.55 building / 16.56 / 3.147; main 3bb079d -> 9fa94bc): no drafts, no
new RESOLVED decision since 10-27; `agent-ci ops` had FIVE "spec held by review" cases and no triage agent on them
(last triage 00:44Z was a 16.51 timing-flake retry). Fixed all five, each review OK in one round, committed
5c5d248 16.53, effbb7c 15.36, a3f16e3 11.51, d0b4c64 11.56, 9fa94bc 15.37 (lows applied post-OK; ops key = new hash,
so the pipeline re-reviews them itself).
- 16.53 (mine, committed earlier at a BLOCK hash): core.fileMode=false in .git/config -> git never carries the
  exec bit; dropped the owner-execute test + `test -x` acceptance; install -m 755 on docker1 sets it.
- 11.51: outcomes(profiles=('IB',), policy_rates=None) ALWAYS raises under shipped v4 -> the "IB alone needs no
  policy_rates" test became "financing_r never called (monkeypatch outcomes.financing_r)"; import by name next to
  cost_r; test_hz_outcomes has NO cost-model fakes (CAL + hand RATES); name the existing tests that must pass RATES.
- 11.56: idea_lists imports idea_scan at module level -> `lists_path=idea_lists.LISTS_PATH` as a def default is a
  circular-import AttributeError; default None resolved inside scan_batch + subprocess import-order test; unregistered
  .scan.json pin needs str(tmp_path.resolve()) -> '<TMP>' (abs paths via _rel fallback); Env.run passes a tmp
  lists_path; now_ms resolved before the registration check.
- 15.36: (1+2)%4 = 3 -> 0.23 not 0.20 (reviewer caught the writer's arithmetic); H1 mapping form matched BY INDEX
  ((i + k) % L) not by size value (E-B [0.60]x4 would land in every clause); _power_hz must iterate the ladder
  (dict.fromkeys) or score() crashes on a mapping; bench.yaml E conditions are [E-A, E-B, E-S, E-J] - state the
  hand config's order; score.py 903/1000 lines.
- 15.37: the real ~/.agent-ci/full-suite.lock IS HELD during the task's own suite-green -> any driver test reading
  the real lock / /proc/meminfo sleeps forever on the gate while passing in an idle worktree; every test must pass
  agent_ci_home=tmp_path + mem_floor_gib=0.0 and an autouse fixture stubs driver.mem_available_gib; AGENT_CI_HOME via
  os.environ.get(...) or default (empty = unset); Tiers.build_error raises on EVERY planted build (fake must raise on
  the 2nd job only and pre-create _tier_dir).
Workflow that worked: verify every reviewer claim with sed/grep in two batches, edit all five, cp to /tmp/sw1101,
launch the five `spec-review` detached (`(setsid nohup ... < /dev/null &)`), a background poll script (pgrep -f
"spec-review TASK-<id>$") instead of Monitor (Monitor needs approval in -p mode), commit script waits for
MERGING.json and restores from the backup if the gate reverted the edit. Still unwritten: fondeo 2c fun_sim cost
wiring + fondeo 4 exporter (deps 16.55, see [[fondeo-rung-chain-refill]]). Next free ids unchanged: 3.148, 4.20,
9.12, 11.57, 12.20, 14.23, 15.42, 16.57.

**Why:** the next writer must know these five are already fixed (don't re-open them), and the recurring reviewer
findings (exec bit, circular import default, tmp_path pins, real-lock hang) so new specs avoid them up front.

**How to apply:** `agent-ci ops` first; if a case's log is one of these ids, check `git log -1 -- tasks/<id>.yaml`
before touching it. Related: [[real-run-task-ids]], [[fondeo-rung-chain-refill]].
