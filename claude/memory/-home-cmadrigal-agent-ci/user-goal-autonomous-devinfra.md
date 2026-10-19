---
name: user-goal-autonomous-devinfra
description: "The user's stated goal for agent-ci: automated, very high quality and reliable software development infrastructure, resilient and self-adjusting, minimal human intervention, frontier AI tools and models"
metadata: 
  node_type: memory
  type: user
  originSessionId: 29d5414b-faf8-42b4-a2dd-34f618e19471
  modified: 2026-09-05T21:18:07.419Z
---

Stated 2026-09-05: the goal is "automated, very high quality and reliability
software development infrastructure, resilient, smart and auto adjustable on
the fly, minimal human intervention and frontier AI tools and models."

**Why:** agent-ci is meant to run unattended across the user's projects
(x-scraping, snoopy_frog, more later); every design choice is judged by
whether it removes a reason for a person to step in without lowering the
deterministic bar for PASS.
**How to apply:** prefer mechanisms that classify, retry or route a failure
automatically over ones that report it; when a human step is unavoidable,
make the required action explicit (reporting/actions.py); keep the
invariant "a model may veto, only a deterministic gate may pass"; measure
with `agent-ci stats` before and after. Related: [[pipeline-revision-branch]],
[[agent-ci-is-a-product]].
