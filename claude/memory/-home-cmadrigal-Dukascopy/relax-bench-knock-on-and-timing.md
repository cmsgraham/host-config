---
name: relax-bench-knock-on-and-timing
description: "TASK-15.20 relax_bench facts — RLX4 knock-on entries break a literal \"(d) entries beyond BASE all carry relaxed_by\", same-instant entry order, test timings"
metadata:
  node_type: memory
  type: project
  originSessionId: 66acb215-475a-4365-b289-34f61149ea1c
  modified: 2026-10-25T12:13:26.808Z
---

TASK-15.20 (relax_bench, built 2026-10-25 as a strong_direct build; see [[strong-direct-escalations]]):

- On RLX-NULL-0 short world (relax_worlds.SHORT), only episode 2015-06-14 21:00Z (release+stress,
  unmerged 48 h) has an RLX4-relaxed entry (USDCHF, 3R USD). Its changed loss path avoids a BASE
  K17 pause, so 2 later entries (BASE refused with K17:fired) enter WITHOUT relaxed_by ->
  the literal spec line "(d) RLX4 entries beyond BASE all carry relaxed_by ['RLX4']" is false.
  Test asserts it up to the first relaxed entry + knock-on refused by path-dependent switches only.
- Several candidates at one decision instant: the decisions file order is NOT the portfolio
  evaluation order (AUDUSD listed after relaxed USDCHF but admitted before it). Check USD
  exposure per instant, not per record order.
- Ground-truth usd_stress session != facts_at stress (episode 2015-05-31 stress in days.parquet,
  facts_at never fires).
- Timings (loaded box, nice 19): short world write 13 s; one 48-h episode run_schedule ~23 s;
  storm-day run_schedule ~100 s each; test_relax_bench.py total ~6.3 min (8-min cap).
- relax_bench.py is capped at 400 lines; it landed at 398.

**Why:** a reviewer may flag (d) as weaker than the spec text; the data shows the literal form cannot hold.
**How to apply:** if 15.20 comes back from review on (d), point to the knock-on evidence; for follow-ups
(15.26/15.27 S2/S3) expect knock-on in any variant-vs-BASE entry comparison.
