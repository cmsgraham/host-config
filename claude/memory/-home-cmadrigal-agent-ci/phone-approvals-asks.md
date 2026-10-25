---
name: phone-approvals-asks
description: agent-ci asks (2026-10-25) - pipeline-stopping decisions go to the operator's phone as ntfy buttons; fxplat.trade page; use `agent-ci ask` instead of asking in chat
metadata:
  type: project
---
Built 2026-10-25 on the operator's ask: "any decision that stops the pipeline, we cannot waste time"; safe default on
silence; page on fxplat.trade (decided over WireGuard).

- agent-ci 5ca662f: agent_ci/asks.py; `agent-ci ask --key --title --question --option ID=LABEL=ACTION ... --safe ID
  [--decision HEADER]`; actions noop | retry:T | phase_ack:N | usage_until_reset:f | write:i | resolve_decision:h
  ('decision' expands with --decision). Poll: agent-ci-asks@Dukascopy.timer every minute. Approvers:
  ~/.config/agent-ci/approvers.env (never in a repo). Clock starts at delivery (quiet hours hold it).
- fxplat e5abfc9: request service /app/api/ask/<id>; server needs deploy/server/redeploy-requests.sh run BY THE
  OPERATOR (prod deploys are theirs) - it installs compose.yml, /etc/fxplat/approvers.env, requests/asks/.
- Wired: usage pause (falls back to plain alert if the ask can't be delivered), phases gate, TRIAGE.md case 4,
  SPEC_WRITER.md operator decisions.

**How to apply:** when I (interactive) need the operator's decision on something blocking, use `agent-ci ask`
(options mapped to real actions) rather than only asking in chat; still use the question prompt when they're at the
keyboard. Related: [[agent-ci-ops-triage]], [[reporting-style-decisions-first]].
