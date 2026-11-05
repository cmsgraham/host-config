---
name: reviewer-pep701-fstring-false-positive
description: "Reviewer flags nested same-quote f-strings (PEP 701) in redeploy-binance.sh verdict() as syntax errors; its single-quote \"repair\" would break the bash python3 -c '...' quoting"
metadata:
  node_type: memory
  type: feedback
  originSessionId: 2d3a8a4c-98d7-4e6a-abeb-54c8019f9be0
  modified: 2026-11-05T14:46:03.218Z
---

The reviewer flagged `print(f"... {st.get("cycles")} ...")` inside redeploy-binance.sh's `python3 -c '...'` verdict block as a syntax error (TASK-14.4 F001, 2026-10-23). It is valid on Python 3.12+ (PEP 701). The host python3 is 3.12.3, and the pre-existing `sim` branch on main uses the same idiom.

**Why:** the suggested repair (inner single quotes) would end the bash single-quoted string and break the script.

Second variant (TASK-7.57 F001, 2026-11-05): `f'...{T - 5_000}}}'` (expression + escaped literal `}`) was flagged as an "extra closing brace". The test auditor called it a contradiction, and the task stalled. Fix: pin the spec's literal string as a plain constant, not an f-string.

**How to apply:** don't apply that repair. To clear the finding safely, bind the values to locals first, then use a plain f-string. Related: [[stale-reviewer-lint-findings]], [[reviewer-misreads-error-path-tests]].
