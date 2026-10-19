---
name: gateway-usage-card
description: "2026-09-27 rebuild of the gateway's Saved-vs-cloud/Tokens cards into one period card; daily buckets only start after a gateway restart"
metadata: 
  node_type: memory
  type: project
  originSessionId: 9a51435e-4271-433a-aaba-ac31cf3fb017
  modified: 2026-09-28T02:05:09.080Z
---

On 2026-09-27 the two Overview tiles ("Saved vs cloud" pager + "Tokens") in ~/ollama-gateway
were replaced by ONE usage card: cost and tokens of the same period side by side, delta vs the
previous month (per-day rate first, since Aug covers only Aug 19–Sep 3), blended $/Mtok, output
share, $/req, month-end projection, a per-day bar chart (per-month bars on the all-time page)
with a tooltip carrying both figures, and a "By month" table on Overview (also in Settings).

**Why:** the user could page through monthly cost but never see the tokens behind it, compare
months, or see progression. Research (OpenRouter, OpenAI, GCP billing, FinOps tokenomics) agreed
on: tile+delta+sparkline, bars per period, cost+tokens in every tooltip/row, $/Mtok, run-rate.
A dual-axis tokens-over-cost chart was rejected on purpose.

**How to apply:** gateway.py gained `days` buckets (`_usage["days"]`, DAYS_KEPT=400), month
`start/end/days/remaining_days` spans and `days`/`today`/`daily_since` in compute_savings().
The gateway was restarted 2026-09-27 21:34 CST, so daily buckets collect from that moment;
September's earlier spend shows as a single "before daily detail" amount in the card.
Keep the embedded DASHBOARD_HTML in sync with dashboard.html (see [[gateway-dashboard-live-file]]).
The gateway repo also carried a large UNCOMMITTED diff (months, reliability, policy) before this;
nothing was committed.
