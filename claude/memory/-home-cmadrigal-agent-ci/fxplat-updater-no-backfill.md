---
name: fxplat-updater-no-backfill
description: "The hourly fxplat-update (`fxplat.data ingest update`) resumes from each symbol's LATEST stored day and never fills holes; AUDUSD/USDCHF 2020-2021 sat missing 3 days unnoticed"
metadata:
  node_type: memory
  type: project
  originSessionId: 0c1852ef-3212-4405-b486-5cda3eb63786
  modified: 2026-10-18T02:05:16.874Z
---

Found 2026-10-17: validation (2019-2021) had AUDUSD only to 2020-02-07 and USDCHF to 2020-10-05; no validation
day had completed since 10-14, while the hourly job spent its time re-fetching sealed 2022+ holdout days that the
quality gate rejects (monotonic_ts) every run. Cause: `ingest update` resumes from the latest stored day across
partitions (2026 forward data), so an older gap is invisible.

Backfill (operator-approved 10-17): pause `fxplat-update.timer`, then per symbol
`nice -n 19 .venv/bin/python -m fxplat.data ingest update --data-dir ~/fxdata --symbols SYM --start YYYY-MM-DD`,
killed once ~/fxdata/validation/manifest.sqlite `days` reaches 2021-12-31 (there is no --end flag), then restart
the timer. Log: ~/fxdata/backfill-2026-10-17.log.

**Why:** the V1 re-run on 2010-2021 needs every major complete; "the download is slow" hid a gap, not throttling.
**How to apply:** before promising data-dependent dates, query the manifests per symbol (min/max complete day,
last updated_at) instead of reading update.log. Related: [[fxplat-cost-v4-migration]], [[fxplat-phase3-completion-2026-10-14]].

**2026-10-22 backfill (holes from the Datos grid):** ingest update --symbols X --start D refilled NZDUSD/USDCAD Nov-Dec 2018 (50 days each), USDCHF Jan 2010, XAUUSD Oct 2025, AUDUSD single days 2024-26; the hourly timer had to be PAUSED (back-to-back hourly runs held the store lock under throttling). TRAP: ticks filled != bars - rebuild derived bars per partition after a backfill: `python -m dukascopy bars --data-dir ~/fxdata/<partition> --symbol S --start D --end D` (NZD/CAD D1 then ran to 2018-12-28). Still missing at the source: USDJPY 2009-06-14..18 (warm-up), XAGUSD 2010-11-17..2011-01-19.
