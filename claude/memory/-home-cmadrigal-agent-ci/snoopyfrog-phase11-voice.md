---
name: snoopyfrog-phase11-voice
description: "Phase 11 of SnoopyFrog v3 -- \"train the AI's voice\" for the operator's partner; scope and the operator's decisions"
metadata: 
  node_type: memory
  type: project
  originSessionId: 3a95969f-0700-4e5c-ad17-66cac7a14b11
  modified: 2026-09-12T00:28:55.429Z
---

The operator's partner repeatedly asks where he can "train the model to talk and
answer how he likes". As of 2026-09-11 the app only STEERS the AI (Settings ->
Business & voice: business, ideal customer, voice and tone, Calendly; per-step AI
prompt; conversation objective/stop rules; Lab approve/edit/regenerate). Nothing
learns: Lab edits are stored (campaign_step_runs.edited_body) and never shown to
the model again.

Phase 11 was scoped and queued (tasks/TASK-11.1..11.7, commit after c8a4258):
voice memory (examples + notes, redacted, removable) -> examples in the prompt of
WRITING calls only -> learn from every Lab edit -> playground (try + thumbs) ->
coaching chat API -> "Train this voice" screen -> Coach tab.
PHASE 11 COMPLETE 2026-09-12 00:21Z: all 7 merged (11.1 0c757b8 … 11.7
b581b20) and RELEASED to production the same night (see
[[snoopyfrog-linode-deploy]]). Six of the eight stalls on the way were agent-ci
or host faults, not code -- snapshot file modes, ENOMEM read as a code error,
the merge-pending race, containment blaming another task's staged merge, an
exception-name substring match, and per-task docker stacks never torn down (see
[[snapshot-filemode-trap]], [[enomem-classifier-trap]], [[merge-pending-race]],
[[docker-pool-slot-leak]]). Each has a fix with a test that fails on the old
code. 11.7's strong tier cost $5.86.

PHASE 12 queued 2026-09-12 00:33Z (b4686c0), 20 specs in the id order that
drives the build: connector pairing 12.1-12.9 (a pairing code replaces the
hand-made connector.json; migration 037), staff support desk 12.10-12.15
(migration 038), trusted devices + cookie sessions 12.16-12.20 (migration 039).
Operator steps that the pipeline may not do are in the scratch
phase12/final/operator-steps.md: relay authfile dir, nginx /downloads/,
building and publishing the connector binaries, granting staff, and turning
CONNECTOR_SECRET on.

Operator's decisions (do not re-ask):
- Learning from edits is AUTOMATIC, every edit (not opt-in). The mitigation built
  in is visibility + removal (examples library) and redaction of the prospect's
  name/company to {{first_name}}/{{company}}.
- The chat does BOTH: interview first (one question at a time -> suggested
  profile text, applied only on confirm), then rehearse (he plays the prospect);
  every AI turn gets thumbs up/down + optional "why".
- Knowledge base and guardrails are DEFERRED to a later phase.

**Why:** the partner's buy-in depends on seeing the AI adopt his voice.
**How to apply:** keep examples inside the persona block (it is FIRST for
prefix caching); never feed examples to qualification scoring. Related:
[[snoopyfrog-linode-deploy]], [[agent-ci-failure-modes]]
