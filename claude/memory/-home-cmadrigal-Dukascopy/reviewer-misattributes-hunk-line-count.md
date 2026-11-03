---
name: reviewer-misattributes-hunk-line-count
description: "Reviewer reads the first diff hunk's line count (new test file) as the script's length and misses docstring paragraphs → false \"exceeds N-line cap\" / \"docstring missing\" blocks"
metadata:
  node_type: memory
  type: project
  originSessionId: 0e8c4f01-cca3-47b0-9a33-71b9a3ea1e73
  modified: 2026-11-03T11:06:33.863Z
---

TASK-4.34 (run-20261103-105049-08aea3, 2026-11-03) went to HUMAN_REQUIRED with "every check passed, reviewer blocked". The reviewer raised two findings:
- F002: "script has 219 lines > 200". The script was 168 lines. 219 was the `@@ -0,0 +1,219 @@` header of the new test file, which comes first in the diff because tests/ sorts before ui/.
- F001: "docstring lacks the second-ruler paragraph". The paragraph was there.

The escalation made no code change. The fix was to verify the findings and re-run.

**Why:** when a diff has several files, the reviewer can apply one file's hunk-header line count to a different file. It also treats requirement wording as missing when a paraphrase covers it.

**How to apply:** for any "exceeds line cap" finding, run `wc -l` on the named file before editing anything. For "docstring lacks X", read the docstring itself. If neither finding is real, run the acceptance commands and re-run the task. Do not trim code or tweak the docstring just to satisfy the reviewer. Related: [[stale-reviewer-lint-findings]], [[reviewer-misreads-error-path-tests]].
