---
name: fondeo-wiring-refill-2026-11-01
description: "2026-11-01 17:10Z refill: 16.61 fondeo deploy wiring (compose.fun.yml fun-jobs one-off + ./fun/costs mount + fun-jobs-weekly.sh + Saturday root timer; fake-docker test), 16.62 export_fun_profiles card 'passprob', 16.63 fun_daily_report (I/O half of item 1, deps []); prototypes /tmp/p1661 (script + compose + units), /tmp/p1663 (daily report numbers); committer /tmp/sw1661/commit_when_clear.sh; next free 16.64 / 11.58 / 15.43"
metadata:
  node_type: memory
  type: project
  originSessionId: refill-20261101-171004
  modified: 2026-11-01T17:33:51.241Z
---

2026-11-01 17:10Z refill (runnable 16.57 / 16.58 BUILDING / 16.59 / 16.60; main dca8098, lint green; ops 0 cases; no
drafts; no new RESOLVED since 10-27; phone asks all unanswered). Wrote the three pieces earlier refills left open:
- 16.61 (deps 16.57 / 16.59 / 16.60; shows BLOCKED in `tasks` until they pass - deps, not review): fun-sim gains the
  6th mount `./fun/costs:/costs:ro`; NEW compose service `fun-jobs` (profiles [jobs], restart "no" QUOTED, entrypoint
  [env, -u, GPG_KEY], no command; mounts fun.json ro, ./fun/data rw, ./fun/costs rw, ./ctrader-ftmo-data/{hourly,symbols}
  ro - NEVER ctrader-ftmo-data itself, it holds tokens.json); redeploy-fun.sh writes fun.json cost_document
  /costs/ftmo-costs.json, `install -d ... fun/data fun/data/$OUT fun/costs` on one line, installs
  deploy/server/fun-sim/fun-jobs-weekly.sh, step 1 greps cost_document + cat-file's the two modules; the script runs
  `docker compose -f compose.fun.yml run --rm --no-deps -T fun-jobs python -m fxplat.execution.fun_ftmo_document build
  --hourly-dir /ftmo/hourly --symbols-dir /ftmo/symbols --out /costs/ftmo-costs.json`, restarts fun-sim ONLY on a
  'ftmo-costs: built' line and only if running (16.57 reads the document once at start), then fun_passprob_report
  --fun-json /etc/fxplat/fun.json --repo-dir /app; exit 0/1/3; root timer fxplat-fun-jobs.timer `Sat *-*-* 06:00:00 UTC`
  (FX closed), service oneshot WITHOUT TimeoutStartSec. Review r1 BLOCK: the header's `sudo install` text tripped the
  script's own 'sudo ' ban (write install steps as root commands, like regression-daily.sh); r2 OK.
- 16.62 (deps 16.58 / 16.60): card['passprob'] = <fun_dir>/<acct>/passprob.json when schema 'fun-passprob/1' AND
  account_id == acct, else None; bad copy -> skipped['<acct>/passprob.json'] += 1; LAST card key after 'cost_profile' ->
  16.58's `list(ag)[-5:]` assertion must become `[-6:]` (review r1 BLOCK caught it: a spec that extends a file another
  queued task pins by key order must name the one assertion it changes). publish.py glob data/*/*/* already watches it.
- 16.63 (deps []): fxplat.execution.fun_daily_report = I/O half of item 1 over the POLL marks (marks.jsonl per run; the
  fun_minute tape grid stays a later task - the tape is trimmed to 3 days anyway). Every run reported on its own, now_ms
  = last mark, fail closed on bad lines / marks out of order; document fun-daily/1 with per-run blocks + DayRow dicts;
  measured on Prague days around the 2026-10-25 DST switch (Sunday local day = 25 h = 90_000_000 ms; 9000.0 exactly on
  the max floor survives the max rule but breaches the daily floor). Prototype /tmp/p1663/proto.py (run with
  PYTHONPATH=src).
Reviews: 16.61 r1 BLOCK -> r2 OK (3 lows applied), 16.62 r1 BLOCK -> r2 OK (2 lows applied), 16.63 r1 OK (2 lows
applied). Holds lifted 17:33Z; finals in /tmp/sw1661/final/; a detached /tmp/sw1661/commit_when_clear.sh (log
commit_all.log) commits all three after the 16.58 merge gate (MERGING.json since 17:22:42Z).
Still unwritten after this: the exporter edit publishing daily.json (after 16.63 + 16.62 merge), the fun-jobs-weekly.sh
third step running fun_daily_report (after 16.61 + 16.63), the UI rendering (UI author), Binance 1b/2b/5b wiring, and
everything behind the expired phone asks. Next free ids: 3.148, 4.20, 9.12, 11.58, 12.20, 14.23, 15.43, 16.64.

**Why:** the next writer must not re-specify the fondeo wiring, must know the two review traps (sudo text in a
header vs a whole-file ban; a key-order assertion pinned by a sibling queued task) and the follow-ups left.

**How to apply:** `git log --oneline -5 -- tasks/` (16.61-16.63 committed? else rerun the committer with the three
messages from commit_all.log's script invocation); `git status --short tasks/`; review logs
logs/spec-review-TASK-16.6[123]-*.md. Related: [[judged-rekey-and-passprob-refill]], [[fondeo-rung-chain-refill]],
[[real-run-task-ids]].
STATUS 17:38Z: COMMITTED right after the 16.58 gate (db0c763): 16.61 30e5d47, 16.62 57ad9f5, 16.63 fabb41e; tasks/ clean; queue 6 runnable (16.57 building, 16.59 / 16.60 / 16.63 eligible, 16.61 / 16.62 deps-blocked).
