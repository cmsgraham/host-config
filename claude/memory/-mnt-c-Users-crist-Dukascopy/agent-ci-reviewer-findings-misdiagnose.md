---
name: agent-ci-reviewer-findings-misdiagnose
description: "HUMAN_REQUIRED reviewer findings/repairs can be confabulated; trust the traceback, re-derive from the spec"
metadata:
  node_type: memory
  type: project
  originSessionId: 0ac0c8c0-b90a-48a1-9b71-012a283df689
  modified: 2026-10-05T12:10:59.030Z
---

TASK-2.2 (2026-10-05): the reviewer blamed np.roll axis / Signal type hints / int dtype for a TypeError
whose real cause was the builder's *test* calling every family as `f(h, l, c)` although the spec gives
MA200X/MRZ/RSI2/RSI14 a `(c, ...)` signature (l landed in the window arg → `_check_n` TypeError).
The reviewer also missed real spec violations (rsi14 crossing direction inverted, np.roll wrap-around
breaking truncation safety, FAMILIES empty unless core imported first).

**Why:** the reviewer reasons from findings text, not the trace, and its "repairs" would not have fixed anything.
**How to apply:** read the traceback frame-by-frame and diff the implementation against the spec's
requirement lines yourself; treat reviewer findings as hints only. Related: [[agent-ci-spec-hand-vector-contradiction]].
