---
name: lint-new-counts-per-file-rule
description: "agent-ci lint-new compares ruff counts keyed by (file, rule), so it reports old violations too when a change adds one more of the same rule"
metadata:
  node_type: memory
  type: reference
  originSessionId: a5611ee5-dbbf-45ea-91e3-1b3fb7525a1a
  modified: 2026-10-12T11:46:05.019Z
---

agent-ci `lint-new` (strict-lint-new project check, `/home/cmadrigal/agent-ci/agent_ci/lint_new.py`) compares ruff finding COUNTS keyed by (file, rule code) between the base and the working tree. If a change adds even one more C901/PLR0912/PLR0915 in a file, it prints EVERY finding of that rule in the file, old ones included. So "label_events is too complex" in a report can mean a NEW complex function was added to the same file. It is not saying the old function changed.

**Why:** In TASK-3.78 (2026-10-12) the builder copied label_events' body into label_events_from_source. The report then listed both functions, which made the cause hard to see.

**How to apply:** When strict-lint-new names an untouched function, look for a new function in the same file that trips the same rule. Usually the fix is to make the new code delegate to the existing function rather than copy it.
