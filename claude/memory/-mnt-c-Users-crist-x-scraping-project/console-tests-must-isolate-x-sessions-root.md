---
name: console-tests-must-isolate-x-sessions-root
description: "~/x-sessions exists on the dev box with real profiles; console tests that render /ops or /api/ops/accounts must set X_SESSIONS_ROOT to a temp dir or discovered profiles leak into \"empty DB\" assertions"
metadata: 
  node_type: memory
  type: project
  originSessionId: d46c2da7-2b1c-48d1-84f0-5c1be75c4f85
  modified: 2026-09-04T02:06:52.719Z
---

Since TASK-15.7 (2026-09-03) the console roster (`GET /api/ops/accounts`,
the accounts fragment, `GET /ops`) also lists saved profiles under
`X_SESSIONS_ROOT` (default `~/x-sessions`). On this machine that directory
exists with real `profile/`, `session-1/`, `session-2/` entries.

**Why:** tests asserting "no `<table` on an empty DB" or exact roster
contents fail nondeterministically on this box unless the env var is
pointed at an empty temp dir (test_console_ui.py has an autouse fixture;
test_console_accounts_and_progress.py builds its own root).

**How to apply:** any new console test that renders the page or roster
should `monkeypatch.setenv("X_SESSIONS_ROOT", str(tmp_path / "x-sessions"))`.
Related: [[failed-validation-runs-leak-worker-containers]].
