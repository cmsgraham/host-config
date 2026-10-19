---
name: dashboard-charts-expected
description: For dashboard/card work the user expects a comparison chart (bars per period) without asking; numbers alone are not enough
metadata: 
  node_type: memory
  type: feedback
  originSessionId: 9a51435e-4271-433a-aaba-ac31cf3fb017
  modified: 2026-09-28T02:23:59.219Z
---

When rebuilding dashboard cards or tiles, include a per-period bar chart for comparison
even if the user only asks for "cost and tokens by month". On 2026-09-27 the user said the
bar chart "was a must" and that they had left it to me on purpose.

**Why:** the user reads progression and month-vs-month visually; a pager of numbers was the
original complaint (see [[gateway-usage-card]]).

**How to apply:** default to tile + delta + bars per period (per day inside a month, per month
across months) with a tooltip carrying every figure, following the dataviz skill rules
(single hue, ≤24px bars, no dual axis). Do not ask whether a chart is wanted.
