---
name: fxplat-phase3-specs-2026-10-05
description: fxplat Phase 3 fully specified 2026-10-05 night (3.1-3.10); governance self-tests A-D + k-fold ban; deps added; what is left for Phase 3 exit
metadata:
  type: project
---

On 2026-10-05 ~22:45-23:00 CST the user asked for Phase 3 specs so the loop runs all night. Landed on fxplat main:
- 99a6716 deps: scikit-learn 1.9.1 + lightgbm 4.7.0 (pyproject, requirements.txt, uv lock) -- builders cannot install.
- Specs (all contour 5.0-6.0, BUILD_LOCAL): 3.1 purged k-fold + CPCV, 3.3 PSR/DSR/FDR, 3.5 regimes, 3.7 PBO +
  stationary bootstrap, 3.8 trust gate, 3.9 currency effective-N have NO Phase-2 dependency (runnable at once);
  3.2 meta-label OOF LightGBM (needs 3.1), 3.4 OOF gate decisions + baselines (3.1, 3.8), 3.10 placebo + baseline
  report (3.2, 3.4), 3.6 verdict L1-L3 + report (2.14, 3.3, 3.5, 3.7, 3.9, 3.10). New ids 3.7-3.10 (split to stay local).
- [governance] cf68931 tests/statistical/test_selftests_multiple_testing.py (A-C) + tests/contracts/test_no_plain_kfold.py;
  05de297 tests/statistical/test_selftest_regime.py (D). Each skips until its module merges, then gates merges.
  Verified 23/23 against throwaway reference modules written to the spec'd API (scratch, not committed).
- Every numeric bound was MEASURED before being written (see [[spec-given-claims-trap]]): PBO noise 0.46-0.80 (a
  first draft band [0.25,0.75] would have failed 2/6 seeds), leak canary purged 0.47-0.50 vs unpurged 1.00, placebo
  p=0.05 planted / 1.0 noise, a segment-share concentration rule rejected for leave-best-out t>=2. Scripted audit 65/65.
- Caught in my own draft: a hand-case mean of 1/12 that was 0.25; zero-taken-trades would have crashed 3.6 (now a verdict).

**Left for Phase 3 exit:** wire DVC model/validation stages, move REGISTERED_PARAMS into config/ (freeze), run the
verdict on real DEV data (operator), optional end-to-end governance self-test through run_validation, and the
composition truncation test in tests/leakage once 2.14 merges (from [[fxplat-phase2-specs-2026-10-05]]).

**2026-10-06 morning — the specs above were NOT grounded in Rodrigo's methodology (prompt.txt §8-§10).** Divergences:
monthly purged walk-forward is the OFFICIAL OOS (I used purged k-fold); registered M2 LightGBM params differ (leaves 8,
depth 3, lr 0.03, 300 trees, min_data_in_leaf 100, monotone cost=-1); calibration = last chronological 20 % of each
training window (isotonic >= 1000 events else Platt); decision = EV_net = p*G_f - (1-p)*P_f (family-shrunk) > tau, tau
from an inner walk-forward over grid {0,.05,.10,.15,.20} R (my 3.8 Wilson gate is a different rule); baselines B1-B6,
B6x, B-D1 (§8); session clusters, DEFF n_eff, 10,000 session-block bootstrap seed 12345, DSR with T = n_eff (§10.4-10.5).
Commit 0b6db72 HOLDS 3.1/3.5/3.8/3.9 (temporary depends_on TASK-2.14); 3.3 (n_eff added) and 3.7 stay runnable.
Next: re-ground 3.1/3.2/3.4/3.6/3.8/3.10 on §8-§10, re-check 3.5/3.9 against §10.3/§10.11-12, and add the Phase-4
day-replay simulator the user approved (Rodrigo's §9.4 already defines the portfolio rules "simulador y vivo").
See [[spec-source-of-truth-fxplat]].

**2026-10-06 decisions (Cristian):** calibration = prompt §9.3 read literally as the HOLD-OUT pattern: model fit on the
first 80 % of each training window, calibrator on the last 20 % (purged), that model+calibrator pair predicts the test
month. Evidence: synthetic WF sim (M2 params, 3 seeds) -- under base-rate drift hold-out ECE 0.030 vs ~0.05 for
cross-fitted / OOF+refit; in the stable case raw LightGBM is already calibrated and hold-out costs ~0.003 ECE; in the
traded region all are 0.03-0.04 (< C11 0.05). Report raw vs calibrated ECE per window, informational only.
AFML audit (docs/research/2026-10-06-afml-audit.md, commit 7cd11aa) -> fix tasks 2.19 (merge look-ahead + level=h) and
2.20 (censored labels), 97316f7; 2.14 now depends on both. Governance leakage case with an intra-hour cut is to be
added AFTER 2.19 merges (adding it before would redden main and every task's suite-green).
