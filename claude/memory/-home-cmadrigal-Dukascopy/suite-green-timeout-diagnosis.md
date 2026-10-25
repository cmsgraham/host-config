---
name: suite-green-timeout-diagnosis
description: "How to diagnose a suite-green TIMEOUT - full validator logs live in logs/<run_id>-a1/, stdout mtime = last finished test; discovery-motif tests stall under machine load"
metadata:
  node_type: memory
  type: reference
  originSessionId: 19a1e6f3-2795-4853-afd3-c980688cbfdd
  modified: 2026-10-25T12:32:54.477Z
---

Full validator output is NOT in `logs/<run_id>/` but in `logs/<run_id>-a<N>/<check_id>.stdout.log`
(merge gate: `logs/<run_id>-merge/`). pytest flushes per test, so the stdout file's mtime is when the
last test finished; compare it with the run's start (stderr.log mtime) and the kill (validation.json
mtime) to tell "stalled on one test" from "slow throughout". Map the dot count to a test with
`pytest tests --collect-only -q` (per-file counts).

2026-10-12 (TASK-3.78): two suite-green TIMEOUTs at 1800 s were environmental, not the task's code.
The tree passed in ~16 min; main normally takes ~13 min. One run stalled 23.5 min on
`test_discovery_motif_search.py::test_planted_candidates_confirm` (normally 62 s); the other crawled
the whole way. The discovery-motif tests (TASK-3.33/3.54) are the heaviest in the suite: ~5.5 min
total, ~8M minor page faults per file (64×k×m einsum blocks), and numba's OpenMP pool spins after
`test_stumpy_matches_oracle` (164% CPU vs 107% with NUMBA_THREADING_LAYER=workqueue). They are the
first place to look when the suite times out under load.

2026-10-12 (TASK-3.79): the same stall recurred, at dot 3285 = 2nd test of test_discovery_motif_search.py
(the `planted0` fixture setup, normally ~64 s). One escalation rerun stalled there again for >4 min. The next
rerun passed it in ~60 s and the whole suite in ~14.5 min. The file alone, or run after the task's new test
file, is normal. So it is intermittent and load-dependent, not the task's code. If it repeats, re-validate
rather than change code. Note that `ps -L` %CPU is a lifetime average, so sample /proc/<pid>/task/*/stat
deltas instead. Also, the pyproject addopts `-q` plus `-q` on the command line hides the pytest summary
line, so judge the run by the exit code.

2026-10-12 18:00 (triage): the re-validation stalled there again (4th of 5 runs). Root signal: host memory
pressure. `/proc/pressure/memory` full avg ~24%, swap 7.3/8 GB, the pytest main thread at 1 core and ~13k minflt/s.
The hog was a runaway `bfs / -name playwright-core` (14 h, 3.8 GB swap). Check PSI and swap before blaming code.

2026-10-12 19:20 (triage): the bfs was still alive (15 h). The 18:04 retry stalled at dot 3285 again (5th of 6).
Retrying does not help while the hog runs. Report NEEDS YOU (kill the hog) rather than retrying again.

2026-10-12 19:30 (escalation of run-20261012-183447-1c3a77): the a1 suite-green TIMEOUT crawled throughout,
not stuck on one test. The last dot was 50 s before the kill, at 29 min. The bfs was still alive (15.5 h, 4.3 GB of
swap, swap 8.0/8.0). It disappeared during the escalation rerun (not killed by the agent) and swap fell to 4.0 GB.
On the same tree the suite then passed in 783 s, all 4142 tests. Confirms: environment, not code.

2026-10-16 (triage, TASK-3.113 merge gate): a timeout at 84% with 0 failures (normal runtime ~1110-1160 s). The hog was two
out-of-pipeline full suites in /tmp/claude-1000/costv4-* (another session), ~7 cores each. Check `ps --sort=-pcpu` + cwd.

The same run's `workspace-containment` failure was a false attribution: an interactive session was
editing `ui/` in the main tree while the builder ran (ui/ is hand-built, see config.yaml merge_gate_ignore).

2026-10-24 (TASK-15.3 escalation): the full suite took ~33 min (exit 0), the last ~20 min on one xdist worker with numba
loaded at ~24k minflt/s. Host: PSI memory full ~42%, swap 7/8 GB; the big consumers were an ollama llama-server (7.4 GB RSS)
and a defunct python at 105% CPU (3.5 h). Same environmental pattern: wait it out (background, timeout 7200000), don't change code.

2026-10-24 (triage, TASK-15.14 merge_refused): the post-merge full suite timed out at 3600 s. Gate suite-green had passed in 530 s
just before. The stall was on one xdist worker in the motif tests (motif0 05:20, then nothing until 05:59). PSI full ~47%, swap 7/8.
Find the worker's progress through the gate's TMPDIR (`tr '\0' '\n' < /proc/<pytest pid>/environ | grep TMPDIR`), then
`$TMPDIR/pytest-of-*/pytest-N/popen-gwK/`, where the dir mtimes are per-test timestamps. py-spy needs sudo, so it doesn't work.
The timed-out pytest tree was left running as an orphan after the timeout (reported NEEDS YOU, because only the operator may kill it).

2026-10-25 (TASK-15.24 escalation): a1 suite-green TIMEOUT at 3600 s, at 99% + 37 dots. Host swap 8/8, PSI mem avg300 ~10%,
plus rsync backup, ollama and a concurrent escalation. The rerun on the unchanged tree passed in ~11 min (exit 0). The "99% + 37 dots" tail
is just where the last xdist workers (motif, storm_day, build_is_deterministic) finish, NOT a deterministic hang — it shows on green runs too.
No code change was needed.
