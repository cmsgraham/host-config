---
name: reviewer-literalizes-spec-reads-clause
description: "Reviewer demands a docstring edit that the spec forbids (\"for a block X reads Y - no other docstring line changes\"); keep the spec's one-line edit, pin it in the test"
metadata:
  node_type: memory
  type: feedback
  originSessionId: b322e290-092c-400c-8a88-8cb691f68e6e
  modified: 2026-11-22T08:19:49.357Z
---

TASK-11.82 (2026-11-22): the spec said the _re_result docstring's first line changes and that "the seven majors" in the rest of it "reads 'its member pairs'" for a block, with "no other docstring line changes". The reviewer took "reads" as an edit instruction (F002). The builder was right. The real blocker was F001 (the test file was 208 lines, over the 200-line cap).

**Why:** the reviewer turns interpretive notes in a spec into edit orders, the same way it does with error-path tests ([[reviewer-misreads-error-path-tests]]).

**How to apply:** never apply that kind of repair. Leave the code exactly as the spec registers it, add a one-line `__doc__.startswith(...)` pin in the owned test, and fix only the findings that are real. To trim a test under a line cap: use walrus mkdir/write_text, build the cell_id constants with a generator, and build the parquet rows in a comprehension.
