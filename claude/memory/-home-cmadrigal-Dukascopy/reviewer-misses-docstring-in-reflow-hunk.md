---
name: reviewer-misses-docstring-in-reflow-hunk
description: "Reviewer reports a required docstring paragraph \"missing\" when the builder re-wrapped old docstring lines so the new paragraph sits inside a big rewrite hunk"
metadata:
  node_type: memory
  type: feedback
  originSessionId: 64995f87-54de-4482-a6ad-1537215029b7
  modified: 2026-11-03T12:51:09.269Z
---

TASK-4.33 (2026-11-03): the reviewer blocked twice (F001) because the "second ruler" docstring paragraph was missing, but it was there both times. The builder had re-wrapped the unchanged docstring paragraphs (E501 is ignored for that script), so the new paragraph was buried in a 19→26-line rewrite hunk.

**Why:** in a noisy rewrite hunk, the reviewer doesn't spot the new paragraph, and a builder retry can't fix a "missing" finding when nothing is actually missing (no_progress → HUMAN_REQUIRED).

**How to apply:** for docstring-paragraph findings, first grep the file. If the paragraph is present, restore the old lines verbatim from `git show main:<file>` so the diff becomes a pure `+` addition. Also put the spec's rule phrase on one line, word for word. Related: [[stale-reviewer-lint-findings]], [[reviewer-blocks-on-audit-uncovered-items]].
