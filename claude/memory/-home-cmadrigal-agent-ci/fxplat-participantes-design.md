---
name: fxplat-participantes-design
description: 2026-10-23 "Participantes del mercado" — who trades FX/commodities/crypto (COT, FFAJ, MoF, Binance positioning) as conditions + structured counterparty; design ecfa843, 16 drafts unqueued, P1-P9 pending
metadata:
  type: project
---
Operator 2026-10-23: "to understand the market we need to go deep and understand who is trading"; also "we haven't included commodities".
Design: ~/agent-ci/docs/research/2026-10-23-participantes-del-mercado-design.md (ecfa843). Drafts TASK-14.1..14.16 in ~/Dukascopy/state/proposals/participantes/ (gitignored), NOT queued.
Findings: no names, only groups. Free + backtestable: CFTC COT (FX TFF/Legacy 2006+, commodities disaggregated: WTI/gold/silver/copper 2006+, Brent 2011+; no release-date field -> compute release instant conservatively), FFAJ Japanese retail month-end (2008-12+), MoF interventions, Binance futures positioning (data.binance.vision 2020-09+, NOT just 30 days). Excluded: CME (ToS/403), Dukascopy SWFX sentiment (ToS: no database), CLS (paid). Literature: positioning predicts weakly; robust use = crash risk when crowded (Brunnermeier/Nagel/Pedersen 2008), extremes; no peer-reviewed support for retail contrarian or crypto funding. Copper price on Dukascopy only ~2016+.
Capture-now (no tries): 14.1 COT snapshots, 14.4 Binance positioning container on docker1, 14.5 archive backfill, 14.6 FFAJ/MoF/TFX raw copies.
FLAG raised: Dukascopy website ToS bans building "a database of any kind" — check what licence covers fxplat's tick downloads.
Related: [[fxplat-contexto-del-dia]], [[fxplat-stock-indexes-exploration]], [[fxplat-hallazgos-caleidoscopio]].
