---
name: strict-lint-1000-line-cap
description: strict-lint-new fails any touched module past 1000 lines; research_run.py has a TIGHTER non-owned test cap of 950 (test_research_helpers::test_line_caps; 919 on 2026-11-03), research_helpers 400, synthetic/storm_day.py 979 near 1000
metadata:
  node_type: memory
  type: project
  originSessionId: 36faa55b-5aef-456f-9870-f694921aa5ce
  modified: 2026-11-03T07:33:19.797Z
---

agent-ci `lint-new` (strict-lint-new) also enforces a 1000-line module cap: "X.py: N lines (limit 1000; it was M)". Ruff is clean in that case; only the line count fails.

`src/fxplat/pipeline/research_run.py` was 996 after TASK-3.131 (2026-10-18), then the helpers split moved code to `research_helpers.py`; since then `tests/pipeline/test_research_helpers.py::test_line_caps` (NOT owned by research_run tasks) pins research_run.py <= 950 and research_helpers.py <= 400, `test_research_run_contract_unchanged` pins `research_run.__all__`, and research_helpers must not import research_run. On 2026-11-03 research_run.py is 919 (31 lines headroom), research_helpers 232.

**Why:** TASK-3.131's builder added 57 lines and got stuck on the 1000 cap; TASK-4.25's spec (2026-11-03) said "under 1000" and the spec review BLOCKed it because 45-60 registered lines do not fit under 950. Fix applied: new owned module `fxplat.pipeline.cost_profiles` re-exported by name into research_run (`from ... import (  # noqa: F401`, the research_helpers pattern), so `research_run.<name>` still resolves for dependents.

`src/fxplat/synthetic/storm_day.py` was built at 979 lines by the TASK-15.2 escalation (2026-10-24).

**How to apply:** a spec that adds more than ~15 lines to research_run.py must put the new code in its own owned module and have research_run re-export it (and never extend `__all__`); state the cap as "<= 950 (test_line_caps)", not 1000. Same recipe as scan.py's 985 cap ([[scan-internals-positional-callers]]). Related: [[lint-new-counts-per-file-rule]].
