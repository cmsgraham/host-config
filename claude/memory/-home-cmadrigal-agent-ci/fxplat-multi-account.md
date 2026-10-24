---
name: fxplat-multi-account
description: 2026-10-24 operator plan: multi-account (several REAL accounts, different owners e.g. each partner) + risk profiles (fun simulated ladder); owner can adjust risk and disable kill switches; process = design -> independent challenge -> build
metadata:
  type: project
---
Operator 2026-10-24: multiple accounts at same/different brokers; real accounts per owner (e.g. him and his partner) with same or different rules; owner may adjust risk and SHUT DOWN kill switches on own account (his call - don't forbid it; make it owner-only, confirmed, audited, alerted). Fun risk profiles (crazy/risky/med/best) for simulated accounts. Deployment: one container per real account (credential isolation), signals computed once, one simulator container for fun profiles, fxplat aggregates (operator suggested containers-per-account). Proposed never-disableable rails (guard bugs not taste): K11, K4, K6, K9, K12 - operator decides. Off-protocol accounts never count as protocol evidence.
PROCESS: design (agent, doc agent-ci docs/research/2026-10-24-multi-account-risk-profiles.md, drafts state/proposals/multi-account/TASK-16.x) -> independent challenge review (fresh agent given the doc, not my conclusions) -> operator decisions -> build. Do not queue before the challenge.
VISIBILITY (operator 2026-10-24): a user sees ONLY their own accounts; only admin sees all. Server-side filtering; the static fxplat.trade bundle must not carry other owners' data.
Related: [[fxplat-live-start-plan]], [[fxplat-always-on-on-server]].
