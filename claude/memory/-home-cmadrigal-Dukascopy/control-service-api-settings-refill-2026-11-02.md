---
name: control-service-api-settings-refill-2026-11-02
description: "2026-11-02 14:39Z refill: 9.15 UI-E2 fxplat.control.api (framework-free ControlApi.handle(Request)->Response over the 9.14 store; stdlib http.server adapter like deploy/server/requests; proxy-network trust, X-Forwarded-Email, one sign_in audit line per 12 h session) / 9.16 UI-E4 fxplat.control.settings (hash-validated JSON, revision, Change list, G8 rule) - both deps [9.14] so BLOCKED until 9.14 merges; UI-E Python rows now all written; next free 9.17 / 3.149 / 4.21 / 11.64 / 15.43 / 16.82"
metadata:
  type: project
  originSessionId: refill-20261102-143905
  modified: 2026-11-02T14:57:17.408Z
---

2026-11-02 14:39Z refill (runnable 11.63 / 4.20 / 9.13 / 9.14, low water 6). No drafts, no new RESOLVED decisions
(asks pending: c6-sharpe-variance, replay-tolerances, fsv2-counting, family3/4-grammar, positioning-asof-fix; the
rest expired at 'wait'); `agent-ci ops` 0 cases; roadmap stubs 4.4 / 5.1 / 6.x / 7.2 / 8.4 still blocked on deps or
the tolerance ask; UI-A, PHASE3 §3/§6, CHARTER §12 all covered. Used the last two Python rows of UI_DESIGN §11:
- 9.15 fxplat.control.api (UI-E2): NO web framework (fastapi absent; starlette 1.7 is only streamlit's transitive
  dep, undeclared) -> pure ControlApi(store, trusted=, allowed_emails_path=, clock=).handle(Request(method, path,
  headers lower-cased, body, client_ip)) -> Response(status, body dict); checks in order 405 / 403 untrusted_client
  / 401 no_identity / 403 inactive_user / session sign_in (last_seen None or now - last_seen >= 12 h, BEFORE
  routing) / routes (/api/me; /api/admin/users GET+POST, users/<email>/role|deactivate|reactivate POST, audit
  ?limit (re.fullmatch [0-9]+, keep_blank_values), summary; 403 forbidden for non-admin before route lookup; store
  ControlError -> 400 refused detail). api_from_env validates trusted_networks BEFORE open_store; make_handler =
  http.server adapter tested socket-free as tests/deploy/test_replay_requests.py:67-86 (Content-Length non-digit
  -> 0). Prototype /tmp/p915 (api.py, scen.py, extra.py). Review OK (1 medium: 9.14 pins 'unknown user' only for
  set_role -> deactivate case relaxed to 'unknown'; 3 low applied).
- 9.16 fxplat.control.settings (UI-E4): FIELDS data_dir_posix/windows/server (default None - not hard-coded),
  ib_host 'ib-gateway', ports 4002/4001, client_id 17, account_mode PAPER, account_id None (= the
  ui/scripts/make_settings_fixture.py keys); file {kind control-settings/1, revision, updated_by, updated_at_ms,
  sha256 of the values, values} atomic .tmp+os.replace; checks in order kind/keys/fields/cross/revision/
  updated_by/updated_at/sha LAST; PAPER->LIVE needs g8_approved; pending_restart strict >. content_sha256(DEFAULTS)
  = aa78233b...d909d1. Prototype /tmp/p916 (settings.py, scen.py). Review OK (2 low applied: fixture account_id
  not marked default; corrupt-file tests recompute sha + strip the path prefix - tmp_path contains the test name).
- Both depend on 9.14 (the package __init__ and tests/control are 9.14's), so `tasks` shows them BLOCKED, not
  runnable: they add nothing to the low-water count until 9.14 merges. Committer /tmp/p915/commit_when_clear.sh
  waited for the 4.20 gate (started 14:49:30Z) and committed 9.15 then 9.16 with `git add -f`.
- LEFT for the control service: the wiring task (route /api/admin/settings + audit line) needs users.py to gain a
  public event method (ACTIONS lacks a settings action, _log is private) - spec it only after 9.14/9.15/9.16 merge
  so the givens are verifiable on main. Deploy side (compose upstream /api/ -> control service, cookie lifetime) is
  the operator's. No third deps-[] task source exists right now.

**Why:** the next writer must not re-derive the two control modules or try starlette/fastapi, must know both specs
wait on 9.14, and that the UI-E Python rows are exhausted.

**How to apply:** `git log --oneline -3 -- tasks/TASK-9.15.yaml tasks/TASK-9.16.yaml`; a missing one is restored
from /tmp/p915/TASK-9.15.final.yaml or /tmp/p916/TASK-9.16.final.yaml (review-OK content, hold removed) and
committed with `git add -f`. Related: [[counterparty-tolerances-control-refill-2026-11-02]],
[[merge-gate-wipes-uncommitted-task-edits]], [[real-run-task-ids]].
