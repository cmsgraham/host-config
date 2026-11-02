---
name: family3-intermarket-refill-2026-11-02
description: "2026-11-02 08:37Z refill: trader-concepts family 3 (intermarket) bricks 11.58 prim_index (fxdata-idx twin of prim_commodity + risk_regime count) / 11.59 prim_rates (BIS WS_CBPOL differential, UTC day-1, integer bp) / 11.60 scan_intermarket loaders (14.19 pattern; scan.py at 976/985); family3-grammar ask sent (held for quiet hours); gate exclude hides untracked tasks/ -> git add -f; next free 11.61 / 15.43 / 16.82"
metadata:
  node_type: memory
  type: project
  originSessionId: refill-20261102-083649
  modified: 2026-11-02T09:07:26.981Z
---

2026-11-02 08:37Z refill (runnable 16.78-16.81; no drafts / stubs worth taking: roadmap stubs 4.4 (tolerances
decision pending since 10-15) 5.1 / 6.x / 7.2 / 8.4 all chained behind it; every other RESOLVED decision is either
fully specified (Binance, fondeo, mi_perfil stop dial) or waits on a phone answer / the web (fondeo floor, family-1
grid, perps liquidation tiers, CME note)). Sources found: trader-concepts family 3 (decision 2026-10-25) had NO
primitive for "risk-on / off from ~/fxdata-idx" nor for "rate differentials" - but the rate source is already
registered (prompt.txt §3.1 BIS WS_CBPOL, fxplat.data.policy_rates, snapshot ~/fxdata/rates/WS_CBPOL_D_8ccy_snapshot.csv
sha 98e27b30..., needs policy_snapshot.RUN_REGISTERED_GAPS to parse (REGISTERED_GAPS fails on the JPY 1999 gap)).
- 11.58 prim_index (deps []): prim_commodity renamed onto ~/fxdata-idx (USA500IDXUSD / DEUIDXEUR / JPNIDXJPY writer
  dirs <SYM>-2012/-2017/-2022, ticks only, no bars/ yet - same state fxdata-cmd had at 14.10) + risk_regime {bars,
  min_indices 1..3, on|off} = count of indices with positive/negative b-bar D1 log move (prim_cross reading; an index
  without a usable bar does not vote). stale/BAR_MS re-exported from prim_commodity. Prototype /tmp/p1158 (285 lines,
  scen1.py). Review OK r1 (name the (i) fixtures; test cap 420 -> 460). Committed 04d0cb6.
- 11.59 prim_rates (deps []): rate_diff {ge|le pp, signed} / rate_diff_change {days, up|down}; known day = UTC day of
  t MINUS 1 (f1_costs' "in force the day before"); integer basis points (threshold round(x*100)); None/False outside
  [first_date, last_date]; PolicyRates passed in. Prototype /tmp/p1159 (152 lines, scen2.py). Review OK r1 (grid is
  the half-open np.arange to 2016-01-16 = 304 instants / 116 True; rate_bp called for BOTH currencies). Committed 055ec5b.
- 11.60 scan_intermarket (deps 11.58, 11.59): 14.19 twin - index_users / rate_users / index_needs (risk_regime ->
  all 3 D1) / lock_index_bars (ts_close < lock, sha unchanged) / load_index_context / lock_rates (entries dated <
  lock UTC day, last_date capped, RatesContext(rates, sha256 of locked rows, source_sha256)) / load_rates_context
  (currencies + registered_gaps pass-through; load_cbpol_csv needs ALL 8 currencies by default). Prototype /tmp/p1160
  (175 lines, scen3.py: 8-currency daily csv = 8769 lines). Review OK r1 (helper is _weekdays). Committed via
  /tmp/p1160/commit_when_clear.sh (gate 16.79 running at 09:04Z).
- Ask sent: decision:family3-grammar (a) minimal 10 cond 624 cells m 3156 z 4.484 / (b) wide 26 cond m 4692 z 4.577 /
  wait; section appended to state/decisions-pending.md (state/ is git-ignored: never shows in git status). "asked ...
  (held for quiet hours)" = queued, delivered later.
- Left for family 3: grammar task (after the ask) + scan.py half 3b (dispatch, _FrameCtx/_Job fields, --indices /
  --policy-rates, index_sha256 / policy_rates_sha256 stamps, approval gate for ~/fxdata-idx like PARTICIPANTES_DEV.txt;
  scan.py 976/985 lines - move something out first) + operator derive_bars on ~/fxdata-idx (DEUIDXEUR 2012-16 ticks
  still in the root ticks/ dir, not a <SYM>-<YYYY> dir).
- Trap: during a merge gate .git/info/exclude hides untracked tasks/ files (git status shows nothing, plain git add
  refuses) -> commit scripts must `git add -f`.
