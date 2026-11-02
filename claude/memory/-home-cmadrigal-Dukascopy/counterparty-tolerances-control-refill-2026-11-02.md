---
name: counterparty-tolerances-control-refill-2026-11-02
description: "2026-11-02 13:08Z refill: 3.148 fxplat.validation.counterparty + config/counterparty.yaml (PHASE3_PLAN §6 counterparty hypothesis, flags NR7/NR4/INSIDE/SQZ/CUSUM) / 4.20 fxplat.pipeline.replay_tolerances + config/replay_tolerances.yaml (status unmeasured, require_fixed gate, measure_differences p99) / 9.14 UI-E1 fxplat.control.users (SQLite, last-admin rule, append-only audit triggers); asks sent decision:replay-tolerances + decision:c6-sharpe-variance; UI-E2/E4 are the next unwritten Python rows; next free 3.149 / 4.21 / 9.15 / 11.64 / 15.43 / 16.82"
metadata:
  type: project
  originSessionId: refill-20261102-130814
  modified: 2026-11-02T13:29:32.791Z
---

2026-11-02 13:08Z refill (runnable 11.62 / 11.63 / 9.12 / 9.13, low water 6). Every RESOLVED decision already
specified; grammar asks (family1 expired, family3, family4) + positioning-asof + fsv2-counting pending; UI-A exhausted
(9.12 / 9.13 committed earlier); R8 service is done by the operator (ui/scripts/replay_service.py); 11.12 is fully
decomposed (11.35/36/39/40/41) and keeps its operator hold; 2.21 already covers the §6 flow-in-time features; B-D1
lives in features/daily_bd1.py. NEW SOURCES found and used:
- 3.148 (deps []): PHASE3_PLAN §6 "Counterparty hypothesis (required, decided 2026-10-06)" was never registered or
  flagged. config/counterparty.yaml (owned, new) + fxplat.validation.counterparty: FAMILY_NAMES = tuple(FAMILIES) +
  ('CUSUM',) == attribution._KNOWN_FAMILIES; Story(counterparty|None, paid_in, cite, note), paid_in + cite mandatory
  with a counterparty; Registry(sha256 of bytes, content_sha256 = canonical_hash of typed content); flags() and
  flag_conclusions(df) appending 'counterparty' bool + 'flag' ('' | 'no_counterparty_story'). Review OK (3 low:
  canonical_hash is NOT 1-vs-1.0 agnostic - plain json.dumps; import it from fxplat.common.costs, not .hashing;
  source string 'registered with paid_in made explicit'). Prototype /tmp/p3148.
- 4.20 (deps 4.19): the §12.9 tolerance VALUES are still OPEN (2026-10-15) - shipped config/replay_tolerances.yaml
  with status 'unmeasured' (12 null values), load_tolerances (both states, content hash pinned 1f7bf299... for the
  unmeasured file, dc08291f... for the FIXED test fixture - hashes TYPED values: version int, float() per value, None
  blocks), require_fixed (fail-closed gate), measure_differences(ReplayCheck) -> 12 rows key/scope/n/max_abs/p99_abs
  (np.quantile linear). Review OK (1 medium = the same canonical_hash claim, fixed). Prototype /tmp/p420. The
  file-reading driver (run dir + StoreTicks + rate snapshot -> replay_check -> report) waits for the ask.
- 9.14 (deps []): UI_DESIGN §11 row UI-E1 (Python, decided 2026-10-10) was unwritten - fxplat.control.users over
  sqlite3: open_store(path, admin_emails=, now_ms=) bootstraps admins (existing rows untouched, no re-promotion),
  UserStore add_user/set_role/deactivate/reactivate (actor must be an active admin; last-admin rule counts admins),
  sign_in (no actor), audit newest first with BEFORE UPDATE/DELETE triggers RAISE(ABORT 'audit is append-only'),
  write_allowed_emails atomic (.tmp + os.replace), summary(now_ms) with stale traders > 90 d strictly. Every instant
  passed in; no env / clock / fxplat imports. Prototype /tmp/p914 (users.py 260 lines, scen.py = the hand scenario).
  Next Python rows there: UI-E2 fxplat.control.api (starlette is installed, fastapi is NOT), UI-E4 settings.
- Asks sent 13:20Z: decision:replay-tolerances (b replay p99+margin / a by hand / c loose+strict / wait) and
  decision:c6-sharpe-variance (c variants + registry column / b column only / a literal / wait); notes appended under
  both OPEN sections of state/decisions-pending.md.
- COMMITTED 13:28-13:29Z: 3.148 1e406af / 4.20 31c3c78 (via /tmp/p3148/commit_both.sh after the 9.12 gate) / 9.14
  611e7a6 (direct, gate clear). 9.14 review OK (4 low: sign-ins count as 'changes' *reading; test (g) on a separate
  store; actor normalised first; raw SQL only after close()). Tree clean, no untracked tasks/.

**Why:** the next writer must not re-derive these three modules, must know the counterparty/tolerance/control sources
are now used, and that UI-E2/E4 remain the only unblocked Python rows besides the asks.

**How to apply:** `git log --oneline -3 -- tasks/TASK-3.148.yaml tasks/TASK-4.20.yaml tasks/TASK-9.14.yaml`; a
missing one is finished from its /tmp/p<id> prototype + logs/spec-review-TASK-<id>-*.md. Related:
[[ui-a10-runs-pnl-refill-2026-11-02]], [[merge-gate-wipes-uncommitted-task-edits]], [[real-run-task-ids]].
