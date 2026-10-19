---
name: strict-lint-plr0402-module-alias
description: "Specs that dictate `import fxplat.pipeline.X as X` fail strict-lint-new (PLR0402); use `from fxplat.pipeline import X`"
metadata:
  node_type: memory
  type: feedback
  originSessionId: 3fe45d1f-23a5-4e35-8abd-a15e8aeb64a6
  modified: 2026-10-19T06:46:52.980Z
---

Task specs sometimes say "import fxplat.pipeline.policy_snapshot as policy_snapshot; never a from-import" so the conftest's monkeypatch of `policy_snapshot.snapshot_path` applies. strict-lint-new selects PL, and PLR0402 flags that alias form. `from fxplat.pipeline import policy_snapshot` binds the same module object, so the redirect still applies, and symbol_stage.py and __main__.py already use it. Seen on TASK-3.132 (2026-10-19).

**Why:** the requirement is about calling the function through the module attribute, not about the import syntax. strict-lint-new is a hard gate.

**How to apply:** use the from-module import, and mention the deviation in the summary. A related spec trap: "abs 1e-12" on USD notionals like 25000 x 1.1 can't hold in float64, because 27500.000000000004 is D45's own value. Add rel=1e-15 to the tolerance. See [[lint-new-counts-per-file-rule]], [[strong-direct-escalations]].
