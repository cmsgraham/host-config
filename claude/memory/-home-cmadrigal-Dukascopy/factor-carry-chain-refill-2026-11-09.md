---
name: factor-carry-chain-refill-2026-11-09
description: "Spec-writer refill 2026-11-09 ~23Z: decision factor-carry RESOLVED (a) -> 3.236 carry_factor / 3.237 rerun_factors / 3.238 rerun_factors_stage / 3.239 rerun_cli --factors queued (all review OK); next free 3.240"
metadata:
  node_type: memory
  type: project
  originSessionId: 68bd2009-ff5a-42bb-b5b7-e018cce6f6f8
  modified: 2026-11-09T23:46:34.648Z
---

Continues [[variants-baselines-flip-and-factor-ask-2026-11-09]]. Decision factor-carry RESOLVED 2026-11-09 "Carry + cablear" = (a).
Chain (commits 4160080..48d1aab): 3.236 fxplat.validation.carry_factor (carry_differentials via carry_events.differential at
17:00 NY of the row date; carry_factor = B6x top-3 |diff| sign/3 portfolio, factor_series rebalance rows) -> 3.237
fxplat.pipeline.rerun_factors (session_days NY date of t+7h Sat/Sun->Mon; exits roll forward to next common factor row;
factor_regression dol+carry+trend + volatility_loading; factor_summary one line, alpha annualised x261) -> 3.238
rerun_factors_stage (store_bars D1 of 7 majors, session_date index, inner join, FACTOR_WARMUP_DAYS 420, load_factor_rates
independent of cost model) -> 3.239 rerun_cli --factors (rates loaded after preflight; (7c) after rulers on rc.trade.trades;
provenance['factors']; ValueError -> 'DATO NO DISPONIBLE: ...'; no report-module change).

Traps: unquoted heredoc executed a backticked `top` in a YAML comment (use quoted 'EOF' + sed for HEAD sha); isort puts
rerun_factors before rerun_facts; real store read crossing 2019-01-01 hits the validation guard; read_bars filters
ts_open >= start so the start session is never read. Real-archive sanity run 2013-2018: 7 s.
Reviewer noted docs/PHASE3_PLAN.md §7 still says carry deferred — operator should record the decision there.

**Why:** next writer must not re-specify the factor regression.
**How to apply:** sources were exhausted before this ask; check decisions-pending / asks first; next free id 3.240.
