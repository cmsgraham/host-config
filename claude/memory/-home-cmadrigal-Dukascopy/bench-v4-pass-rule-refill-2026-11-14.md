---
name: bench-v4-pass-rule-refill-2026-11-14
description: "2026-11-14 ~10-11Z refill after RESOLVED bench-v4-pass-rule (a) 'Total sube': 15.59 score H7 row, 15.60 bench-v4.yaml H7 + gate [H1, H3, H7] (hash 960bf2d9...); bench v4 chain fully specified; next free 3.244 / 11.74 / 15.61 / 16.98"
metadata:
  node_type: memory
  type: project
  originSessionId: a62d2bac-2f27-4a22-9be4-6e7b93f902e2
  modified: 2026-11-14T10:27:50.840Z
---

Refill 2026-11-14 ~10Z (main be21c1f; 15.56 in merge gate, 15.58 building). Only source left: the pass-rule ask
(RESOLVED (a) "no group falls + total strictly rises + null confirmed <= 0/40").

- 15.59 (deps 15.57): score._h7(config, plan, res, rare) appended after the _CRITERIA rows only when cfg criteria has
  H7 (not in _CRITERIA: other signature); `rare = _rare(...)` moved up right after _load. Clauses "no group falls" /
  "total rises" / _count "confirmed (null)" with criteria H7 null_confirmed. PENDING via _missing_row when any rare
  row has missing > 0 or a null world lacks hz (have = edges - max(missing) + nulls present). score.py 940 lines in the
  proto (cap 960 to absorb 15.57 drift).
- 15.60 (deps 15.58, 15.59): bench-v4.yaml header lines 12-13 rewritten, H7 entry after H6, gate [H1, H3, H7]
  (*reading: joins v3's gate); canonical_hash 960bf2d9...; amends 15.58's test_bench_v4_yaml.py (pin + pop H7/gate).
- Prototype /tmp/p1559 = main + 15.56 branch + 15.57 ported onto the split score.py + 15.58's yaml + this change.

After this the bench v4 chain is complete; the S2 v4 run needs approvals/SYNTHETIC_BENCH_S2_V4 (operator).
See [[refill-log]], [[bench-v4-scorer-and-forward-ui-refill-2026-11-14]].
