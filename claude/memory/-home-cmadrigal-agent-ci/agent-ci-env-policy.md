---
name: agent-ci-env-policy
description: "Tasks get an allow-listed environment (agent_ci/env_policy.py); the builder's slot vars only reached its prompt, never its shell"
metadata: 
  node_type: memory
  type: project
  originSessionId: 025cf55b-64c5-455a-bf92-9d6edbbd538b
  modified: 2026-09-08T17:18:11.136Z
---

Landed 2026-09-08 (commits 5f2dbf4, fa25de4) as item 1 of the response to the
architecture feedback. Two findings, one security and one a plain bug.

**Measured, not theoretical.** A loop started from an interactive terminal was
handing every builder subprocess the operator's live session handles:
`CLAUDE_CODE_MESSAGING_SOCKET` + `CLAUDE_CODE_MESSAGING_TOKEN` (a socket into
the operator's own Claude Code session, with its bearer token),
`VSCODE_IPC_HOOK_CLI`, `DBUS_SESSION_BUS_ADDRESS`, `WSL_INTEROP`,
`SSH_AUTH_SOCK`. 40 of 63 variables are now withheld.

**Allow-list, never deny-list.** None of the dangerous names above matches
`*TOKEN*`/`*SECRET*`/`*KEY*` in a way a pattern reliably catches, and the next
dangerous variable will be named something nobody predicted. Groups: CORE,
TOOLCHAIN, NETWORK (TLS/proxy — dropping those breaks builds and reads as a
model outage), OWN (`AGENT_CI_*`). Slot vars are applied AFTER the filter so no
policy can drop them. `agent-ci doctor --explain-env` lists what is withheld.

**The bug worth remembering.** The builder runs OpenHands *inside* the
supervisor process and spawns its shell from a worker thread, so the env dict
every other stage receives never reached it. Its slot variables arrived in the
PROMPT as text and in its shell not at all — a builder running the project's own
`db-up` got the default port, not its slot's. `env_policy.patched_environ`
wraps the builder run. Smoke-tested: `$AGENT_CI_PORT_BASE` in the builder's
shell is now its slot's value.

**Verified before landing** (the rule: never enable a policy that can break
every build without proving the build still works): headless `claude -p`, git,
pytest, node, uv, docker, and a real OpenHands builder run against the gateway.

**How to apply:** this is NOT a sandbox and README §17 says so — it removes what
the environment hands over, not what the filesystem exposes (`~/.ssh`, the
Docker socket, reached by path). A real boundary needs a container runtime.
See [[agent-ci-feedback-response]], [[contour-and-watchdog-redesign]].
