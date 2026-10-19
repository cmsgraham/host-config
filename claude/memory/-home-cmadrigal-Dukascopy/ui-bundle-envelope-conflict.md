---
name: ui-bundle-envelope-conflict
description: "UI fixtures use a different bundle envelope than TASK-9.1; RESOLVED 2026-10-12 as (c): 9.1 envelope, payloads numbers + codes only, wording in UI i18n"
metadata:
  node_type: memory
  type: project
  originSessionId: 2de2d19d-d544-4074-936f-af4602f18b5f
  modified: 2026-10-12T22:27:36.221Z
---

ui/public/fixtures/*.json use {"schema_version": "<kind>/1", "source_commit", "fixture", ms generated_at} and
bilingual display strings (text_en, value / threshold / ci); TASK-9.1 registers {kind, int schema_version, commit,
whole-second generated_at}. Logged as NEEDS DECISION in state/decisions-pending.md on 2026-10-12, RESOLVED the
same day as option (c): TASK-9.1's envelope is the contract, and payloads carry numbers and registered codes, never
prose. All wording (ES/EN, value/threshold/CI strings) comes from the UI's i18n tables. The UI client accepts both
envelopes during the transition. UI-A4 is TASK-9.4 (verdict exporter).

**Why:** an exporter spec written before the decision would have locked in one side of the contract.

**How to apply:** UI-A3..A9 exporter specs may now proceed under (c). When reviewing one, check that its
"no prose" test does not search the JSON for short fixture strings: placeholder details like "x" or "y" appear
inside key names such as "extra" and "slope_R_per_year", so the check fails (TASK-9.4 review). Related:
[[real-run-task-ids]].
