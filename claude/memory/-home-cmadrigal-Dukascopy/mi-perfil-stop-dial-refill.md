---
name: mi-perfil-stop-dial-refill
description: "2026-11-02 refills: mi_perfil stop dial chain 16.78 fun_book stop_scale / 16.79 fun_profiles ATR_MULT_RANGE / 16.80 fun_dials optional atr_mult (to_raw + hash omit it at 2.0 so SHA_D0 and the request-service byte-identical lines hold) / 16.81 request service copy (committed 07:18Z) = chain COMPLETE, only the UI control (operator) left; Binance and fondeo chains fully specified; perps liquidation/fees still need web (denied); no other spec-able source; next free 16.82 / 11.58 / 15.43"
metadata:
  type: project
  originSessionId: refill-20261102-053539
  modified: 2026-11-02T07:19:13.401Z
---

2026-11-02 05:35Z refill (runnable 16.73-16.77, low water 6; 16.73 attempt 1 REVIEWING then its gate MERGING at 23:55 local).
Sources: no drafts, no roadmap stub worth taking (4.4/5.1/6.1/6.2/7.2/8.4 are live/freeze/final-test = operator),
no new RESOLVED since 10-27, all phone asks still 'wait' (fondeo-floor-equality, family1-grammar, feature-set-v2-count,
positioning-asof-ns). Binance (16.45-16.77) and fondeo (16.31-16.65) chains complete. Perps (decision 2026-10-25 futures
item 1): only 16.67 funding exists; liquidation tiers + fee schedule need web (denied) - still blocked.

CHOSEN: the stop dial follow-up the 2026-10-27 phone decision (a) explicitly deferred ("later as its own task once
fun_book has an exit path of its own"). Key finding: the labeller's whole geometry is a function of atr_h (stop 2 x atr,
target spec.m x stop, size risk/(stop x upu); atr_h used nowhere else in label_events), so a stop of m x ATR == the
protocol's walk on atr_h x m / 2. No new first-touch walk needed.
- 16.78 fun_book: public stop_scale(profile) = atr_mult / STOP_ATR_MULT (1.0 for stop 'none'; ValueError on None/bool/
  non-finite/<= 0), applied in size_for (atr rescaled after validation), mark (nominal sim_book.Position atr_h x scale),
  pyramid_add. Bit-identical at 2.0 (x * 1.0). *reading: target keeps the family's R multiple of the new stop. Tests via
  dataclasses.replace(prudente, atr_mult=3.0) (frozen dataclass bypasses fun_profiles). NEW test file
  tests/execution/test_fun_book_atr_mult.py. Prototype /tmp/p1678 (fun_book.py 636 lines, scen.py prints every number).
- 16.79 fun_profiles (deps 16.78 - ordered so a 3.0 rung never validates while the book still trades at 2.0):
  PROTOCOL_ATR_MULT 2.0 + ATR_MULT_RANGE (1.0, 3.0) replace _ATR_MULT; float(mult) stored; shipped shas unchanged.
  Owned test = existing test_fun_profiles.py (test_refuses_atr_mult_other_than_two renamed). Prototype /tmp/p1679.
- 16.80 fun_dials (deps 16.79): atr_mult OPTIONAL key (absent = 2.0), Dials last field default 2.0; to_raw adds the key
  only when != 2.0; hash_document drops it at 2.0 -> SHA_D0 91670346... / PROFILE_D0 / LESSON_D5 pins in NON-owned
  tests/publish/test_export_fun_profiles_dials.py and the byte-identical journal lines of tests/deploy/
  test_replay_requests.py all hold; describe_es inserts ", stop a {m:g} x ATR" only when != 2.0. Prototype /tmp/p1680.
- TRAP: deploy/server/requests/replay_requests.py has its OWN copy of parse_dials/MP_RANGES/dials_sha256 (stdlib) and
  refuses unknown keys -> 16.81 = add atr_mult there (deploy/ protected; mirror the same omit-at-2.0 rule) + the UI
  already renders params.atr_mult (pj.d.stopAtr).
- TRAP: a draft whose depends_on names a not-yet-written id makes `agent-ci tasks` INVALID for the whole loader -
  write the dependency file first (16.80 was invalid for ~1 min until 16.79 existed).
- The merge gate stages the merging task's owned files in MAIN's index (git status showed `A ...oco_glue.py` while
  16.73's MERGING.json existed) - not a stray; commit specs only with `git commit -- tasks/<id>.yaml`.
Reviews 23:55 local, all three OK in one round (16.78: fun_book cap is 650 not 660 - test_fun_book_measured pins it,
applied; 16.79: fun_book docstring names _ATR_MULT - applied in 16.78; 16.80: test cap 360 -> 380 + docstring must avoid
'open(' / 'read_text' - applied). COMMITTED 2026-11-02 ~06:3xZ after 16.73's gate cleared: 2a86a4b (16.78) / 7316abe (16.79) / bac5e38 (16.80), one file
each, tree clean. The committer used `git add -f` (the gate's .git/info/exclude ignores /tasks/** while MERGING.json
exists - plain `git add` fails then). 16.78 ELIGIBLE, 16.79 / 16.80 BLOCKED on their deps as designed.
Next free ids: 16.81, 11.58, 15.43, 3.148, 4.20, 9.12, 12.20, 14.23.

2026-11-02 07:06Z refill (runnable 16.75/16.77-16.80, low water 6; 16.75 in gate, cleared ~07:1xZ): wrote + committed
16.81 (ec623df) = the request service copy: MP_RANGES['atr_mult'] (1.0, 3.0), MP_OPTIONAL, MP_ATR_MULT 2.0; parse_dials
drops atr_mult at 2.0 from the normalised dict (so the line == to_raw) and dials_sha256 adds it iff present -> bytes and shas
== /tmp/p1680 fun_dials on D0 / 3.0 (6c452bac) / 1 (d575eca4) / D5+1.5 (bf038007...); deps [16.80]; owns replay_requests.py
(cap 450) + test_replay_requests.py (cap 440 - reviewer round 1 BLOCK: 340 too tight, its draft was 367; round 2 OK asked
440; fresh() helper must set APPROVER_EMAILS 'Boss@Example.com, ops@example.com', not (h)'s single boss). Prototype
/tmp/p1681 (replay_requests.py, scen.py, review-*.log). WebFetch is permission-denied in this session (perps liquidation
tiers / futures fees still blocked; ~/cryptodata/futures has only fundingRate + metrics, spot klines only). STOP DIAL CHAIN
COMPLETE (16.78-16.81); only the UI control is left (operator). No other spec-able source found: asks fondeo-floor-equality /
family1-grammar / feature-set-v2-count / positioning-asof-ns all still 'wait'; 4.4/5.1-8.4 stubs operator; proposal sets all
in tasks/. Next free ids: 16.82, 11.58, 15.43.

**Why:** the next writer must not re-derive the atr-rescaling trick or the omit-at-2.0 compatibility rule, must know
16.81 (request service) is the only unwritten piece of the stop dial, and must avoid the dangling-depends_on trap.

**How to apply:** `git log --oneline -4 -- tasks/`; if 16.78/79/80 are missing, read /tmp/sw1678/review-*.log and
finish from the drafts (hold "draft, under review"). Related: [[mi-perfil-dials-export-and-funding-refill]],
[[binance-final-wiring-refill-2026-11-02]], [[real-run-task-ids]].
