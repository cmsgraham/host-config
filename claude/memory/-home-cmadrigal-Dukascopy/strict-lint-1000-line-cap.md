---
name: strict-lint-1000-line-cap
description: strict-lint-new fails any touched module past 1000 lines; research_run.py has TWO non-owned test caps - 995 (test_research_helpers::test_line_caps) and the binding 975 (test_research_helpers_dataset_kwargs::test_line_counts; 973 on 2026-11-06), research_helpers 400, synthetic/storm_day.py 979 near 1000
metadata:
  node_type: memory
  type: project
  originSessionId: 36faa55b-5aef-456f-9870-f694921aa5ce
  modified: 2026-11-08T09:27:42.519Z
---

agent-ci `lint-new` (strict-lint-new) also enforces a 1000-line module cap: "X.py: N lines (limit 1000; it was M)". Ruff is clean in that case; only the line count fails.

`src/fxplat/pipeline/research_run.py` was 996 after TASK-3.131 (2026-10-18), then the helpers split moved code to `research_helpers.py`; since then `tests/pipeline/test_research_helpers.py::test_line_caps` (NOT owned by research_run tasks) pins research_run.py <= 950 and research_helpers.py <= 400, `test_research_run_contract_unchanged` pins `research_run.__all__`, and research_helpers must not import research_run. On 2026-11-03 research_run.py is 919 (31 lines headroom), research_helpers 232.

**Why:** TASK-3.131's builder added 57 lines and got stuck on the 1000 cap; TASK-4.25's spec (2026-11-03) said "under 1000" and the spec review BLOCKed it because 45-60 registered lines do not fit under 950. Fix applied: new owned module `fxplat.pipeline.cost_profiles` re-exported by name into research_run (`from ... import (  # noqa: F401`, the research_helpers pattern), so `research_run.<name>` still resolves for dependents.

`src/fxplat/synthetic/storm_day.py` was built at 979 lines by the TASK-15.2 escalation (2026-10-24).

**How to apply:** a spec that adds more than ~15 lines to research_run.py must put the new code in its own owned module and have research_run re-export it (and never extend `__all__`); state the cap as "<= 950 (test_line_caps)", not 1000. Same recipe as scan.py's 985 cap ([[scan-internals-positional-callers]]). Related: [[lint-new-counts-per-file-rule]].

**Update 2026-11-08 (phase2.py):** `src/fxplat/pipeline/phase2.py` reached 987 on main after TASK-3.214 added 64 lines; its spec had said "~20". So TASK-3.221's "at most 960" requirement was already broken before the task started, and its builder timed out at 1021. The escalation repacked the one-argument-per-line calls in phase2.py into fewer lines. The source-pinning tests (barrier_spec, latency, cusum_decay, feature_set) are AST-based, so packing is safe. This took the file to ~916 with V16 in it. When a spec states a line cap, `git show main:<file> | wc -l` first, because siblings that land in between move the base.

**Update 2026-11-06:** test_line_caps now allows 995, but TASK-3.180 added `tests/pipeline/test_research_helpers_dataset_kwargs.py::test_line_counts`, which caps research_run.py at **975** (research_helpers 400). On 2026-11-06 main is 973. The TASK-3.182 spec only knew the 995 cap, so its merge was refused (977 lines). Triage fixed it with a walrus and a docstring line that added nothing net (c283186). Before writing any cap into a spec, `grep -rn "research_run.py" tests/ | grep "<="` to see every cap. The merge_refused case text quoted test names from the warnings summary; the real FAILED line is at the bottom of the log.
