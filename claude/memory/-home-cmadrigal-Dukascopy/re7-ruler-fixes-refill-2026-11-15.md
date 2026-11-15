---
name: re7-ruler-fixes-refill-2026-11-15
description: "2026-11-15 ~17Z refill: decision 'RE7 ruler fixes' -> 15.66 bench_hz RE7 tau^2 power / 15.67 bench_hz re_spillover / 15.68 score RE7_unverified / 15.69 repower; next free 3.244 / 11.74 / 15.70 / 16.98"
metadata:
  type: project
---

Refill 2026-11-15 16:40Z (main a2ef602, runnable 0). Only new source: decisions-pending "RESOLVED 2026-11-15 (operator,
question prompt 'Launch now, fix ruler alongside'): RE7 ruler fixes, re-score bench-v7 after S2". All four review OK
(low findings applied, --accept-amended), committed a51954e / cc953d4 / b818204 / 74beebe:
- 15.66 bench_hz: RE_K, re_tau2 (statistics.pvariance over the 7 majors - *reading population variance), _term
  (tau2 0 -> old expression bit-identical), power(..., *, tau2_disc, tau2_conf), _power_tau2 (true RE7 only). Owns
  test_bench_hz_re7.py (test_a pinned REH 0.98421 / REK 0.04205 -> 0.31134 / 0.00589).
- 15.67 (dep 15.66) bench_hz.re_spillover(scored cells, edge_world): members = per-pair MAJORS cells with same
  (condition from cell_id, frame, direction, exit) and spillover_checked; any 'spillover' member -> spillover, d = sum/7;
  checked-none-moved -> verified null; no members -> null + spillover_unverified. run_world scores all rows first.
- 15.68 score._reported gains RE7_unverified {cells, confirmed, confirmed_cells, counted False} (edge worlds only);
  score.py 951 -> ~962 (cap 965).
- 15.69 (dep 15.67) repower calls re_spillover + passes _power_tau2; POWER_RULE string gains "RE7 random-effects SE".

**Why:** next writer must not re-spec this. **How to apply:** after 15.69 merges, re-running repower + score on
bench-v7 is operator work. Prototype tip: `git archive HEAD src tests config pyproject.toml | tar -x -C /tmp/protoX`
+ PYTHONPATH=src works for module tests, but hallazgos promote / bench_v1 main tests fail there (no .git /
experiments/) - environment, not the change. `pkill -f` with a bracket pattern still kills the calling shell if the
same command line contains the literal path elsewhere. See [[refill-log]], [[confirmation-power-refill-2026-11-14]].

Repeat 2026-11-15 18:34Z (main 705d0de, runnable 15.68 building + 15.69): nothing queued. decisions-pending mtime
16:39Z (= the source of this chain), no new RESOLVED / approvals / drafts / ops cases / open asks; 12.6 NOTE still
unanswered; stubs 4.4/7.2/8.4 skipped as always. ~8 tool calls.
