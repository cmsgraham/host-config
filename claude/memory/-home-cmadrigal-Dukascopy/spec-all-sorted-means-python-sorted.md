---
name: spec-all-sorted-means-python-sorted
description: "Spec \"__all__ = sorted [...]\" means Python sorted() (ASCII: CamelCase before SCREAMING_CASE when N<T etc.); builders write the listed order and the reviewer blocks"
metadata:
  node_type: memory
  type: project
  originSessionId: 7fa689e8-c7c8-4e4b-be2e-62494f026efe
  modified: 2026-11-06T17:36:07.887Z
---

A spec that says `__all__ = sorted ['TIMER_NAME', 'NodeStrategy', 'NodeStrategyConfig']` means the plain Python `sorted()` order, `['NodeStrategy', 'NodeStrategyConfig', 'TIMER_NAME']`. It does not mean the listed order, and it does not mean ruff RUF022's isort-style order (constants first). RUF022 is not enabled in pyproject, so lint is fine with the plain order. The precedent is node_host and its test, which asserts `== sorted([...])`.

**Why:** TASK-7.60 (2026-11-06): the builder kept the listed order and pinned it in the test. Every check passed, but the reviewer blocked it (F001/F002), and the task went to HUMAN_REQUIRED.

**How to apply:** when an escalation shows "__all__ not sorted", the reviewer is right. Fix the module and the owned test, and assert both `== sorted([...])` and the literal list. See also [[stale-reviewer-lint-findings]].

**Variant (TASK-3.240, 2026-11-11):** when the spec text literally writes `__all__ = sorted([...])`, the reviewer blocks a literal list even if it is already in sorted() order. It wants the call. A bare `sorted(...)` fails strict-lint-new with PLE0605, so write `__all__ = sorted(  # noqa: PLE0605` (the noqa goes on the `__all__ =` line) and pin the literal list in the test too.
