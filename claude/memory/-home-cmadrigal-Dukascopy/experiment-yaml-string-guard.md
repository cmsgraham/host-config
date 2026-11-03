---
name: experiment-yaml-string-guard
description: "tests/common/test_config.py fails if any src module other than config.py contains the literal text \"experiment.yaml\" — even in a docstring"
metadata:
  node_type: memory
  type: project
  originSessionId: cf394b95-2ed1-46be-b49b-4758dac575e8
  modified: 2026-11-03T18:36:39.398Z
---

`tests/common/test_config.py::test_only_config_module_reads_experiment_yaml` greps every `src/fxplat/**/*.py` except `config.py` for the substring `experiment.yaml`. A docstring or comment that mentions it fails the full suite. Task specs sometimes put "(experiment.yaml)" inside a registered *reading, as TASK-7.23's risk-size reading did on 2026-10-19.

**Why:** it only shows up in suite-green (the run takes about 20 min), not in the task's own tests or in lint.

**How to apply:** when you copy spec wording into a module docstring, write "the typed config" (or `load_config().risk`) instead of the file name. Related: [[full-suite-runtime-over-10-min]].

Reviewer false positive (TASK-4.42, 2026-11-03): when the spec's requirement says "must not contain the string 'experiment.yaml'", the reviewer blocked on "the docstring contains it" even though grep found 0 matches in the module and in both attempt diffs. It picked the string up from the requirement text. Fix: grep first, then pin the rule in the owned test, with the needle built as `"experiment" + "." + "yaml"` so the literal never appears in the diff. Related: [[stale-reviewer-lint-findings]].
