---
name: fondeo-daily-report-wiring-refill
description: "2026-11-01 18:41Z refill: 16.64 export_fun_profiles card 'daily' (fun-daily/1 copied as is; changes 16.62's [-6:] -> [-7:] and the two [-3:] pins) + 16.65 fun-jobs-daily.sh + daily root timer 00:20 UTC via the 16.61 fun-jobs service; fondeo item 1 now fully specified (poll_s 15 s makes the fun_minute tape grid redundant); review traps: 'restart' substring ban vs 'restarted' in a header, test-file line caps stacked on queued siblings; next free 16.66 / 11.58 / 15.43"
metadata:
  node_type: memory
  type: project
  originSessionId: refill-20261101-184051
  modified: 2026-11-01T18:54:34.780Z
---

2026-11-01 18:41Z refill (runnable 16.60 REVIEWING / 16.61 / 16.62 / 16.63; main 25a9888, lint green but for the
exporter's pre-existing E501 (now at line 347); no drafts; no new RESOLVED since 10-27; phone asks all expired 'wait').
Wrote the two fondeo item-1 follow-ups the 17:10Z refill left open:
- 16.64 (deps 16.62 / 16.63): export_fun_profiles DAILY_NAME 'daily.json' / DAILY_SCHEMA 'fun-daily/1' /
  daily_block(fun_dir, acct, skipped) in the exact passprob_block shape; card['daily'] LAST after 'passprob' -> changes
  THREE queued-sibling assertions (16.62's `list(ag)[-6:]` -> `[-7:]`, and test_passprob_published's two `[-3:]` ->
  `[-4:]`); test constant DAILY = 16.63's measured run-2 block (one Prague day, failed_max at 8990.0); caps script
  < 580 / test < 800 lines. Review r1 OK (2 lows applied: say THREE assertions change, not 'EXACTLY ONE ... and others';
  raise the cap). COMMITTED f9d089c 2026-11-01 ~18:58Z.
- 16.65 (deps 16.61 / 16.63): NEW deploy/server/fun-sim/fun-jobs-daily.sh (<= 50 lines) + fxplat-fun-daily.{service,
  timer} (OnCalendar `*-*-* 00:20:00 UTC`: Prague midnight is 23Z CET / 22Z CEST; never the weekly Saturday 06Z slot,
  so the two cleanups never race for each other's one-off container) running fun_daily_report through 16.61's fun-jobs
  compose service, no restart (fun_sim never reads daily.json); redeploy-fun.sh gains a cat-file check for
  fun_daily_report.py, the tar path and a SEPARATE `install -m 755 ... fun-jobs-daily.sh` line; prototype /tmp/p1665
  (measured: rc 0 / 1 / 3, log [DAILY_RUN, LEFT]; a BASE dir that does not exist -> `cd` fails exit 1, so the test
  helper always creates base/). *reading: its own daily timer rather than a third step of the weekly script (a daily
  report refreshed weekly lags 7 days). Review r1 BLOCK: the header wording 'nothing is restarted' contains the banned
  substring 'restart' (whole-file ban incl. comments) -> reworded 'left running untouched'; test cap 680 -> 720 with
  ONE parametrize table. r2 OK (1 low: cite state/decisions-pending.md, applied). COMMITTED 0b39690 ~19:05Z.
Fondeo precision item 1 is now fully specified: 16.34 pure, 16.63 I/O, 16.64 exporter, 16.65 timer; fun.json poll_s
defaults to 15 s (fun_guard._POLL_S), so the poll marks are already finer than minute equity - the fun_minute tape grid
is redundant for item 1, do not spec it. Still unwritten after this: Binance 1b/2b/5b wiring (needs a transport design),
the UI rendering of passprob / daily (UI author), everything behind the expired phone asks (fondeo-floor-equality,
family1-grammar, feature-set-v2-count, positioning-asof-ns). Roadmap stubs 4.4 / 5.1 / 6.1 / 6.2 / 7.2 / 8.4 remain
(Phase 4-8 chain, too big for a 27b builder as stubs). Next free ids: 3.148, 4.20, 9.12, 11.58, 12.20, 14.23, 15.43, 16.66.

**Why:** the next writer must not re-specify item 1 or the fun_minute grid, and must know the two review traps (a
whole-file substring ban catches its own header wording; a line cap stacked on a queued sibling's cap needs headroom).

**How to apply:** `git log --oneline -4 -- tasks/` (16.64 f9d089c; 16.65 committed? else rerun
`bash /tmp/sw1664/commit_when_clear.sh TASK-16.65` once its hold is lifted and the final copy is in /tmp/sw1664/final/);
`git status --short tasks/`; review logs logs/spec-review-TASK-16.6[45]-*.md. Related: [[fondeo-wiring-refill-2026-11-01]],
[[judged-rekey-and-passprob-refill]], [[real-run-task-ids]].
