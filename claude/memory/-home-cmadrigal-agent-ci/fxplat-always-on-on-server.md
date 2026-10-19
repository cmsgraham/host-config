---
name: fxplat-always-on-on-server
description: "2026-10-16 decision - every always-on, non-GPU fxplat piece (7A paper simulator, broker quote recorders, IB feed) runs on fxplat-server, not the PC; server can be resized on request"
metadata:
  node_type: memory
  type: project
  originSessionId: 0c1852ef-3212-4405-b486-5cda3eb63786
  modified: 2026-10-17T02:24:41.778Z
---

Cristian, 2026-10-16: "if we dont need the gpus for this lets move it to the server ... definetly server is
the option"; more disk or capacity on the server is fine, just ask.

- Server: fxplat-server = the snoopyfrog Linode (2 vCPU, ~4 GB, ~2.2 GB available 2026-10-16). Cap every
  container's memory (IB gateway is capped at 1200m) so snoopyfrog is never squeezed; propose a resize before
  memory gets tight instead of trimming features.
- 7A simulator (TASK-7.21..7.23 paper_runner): the specs say a home systemd USER unit reading the home mirror
  ~/.cache/fxplat/...market-live.json. Go-live instead = a container beside ib-gateway / ib-market reading the
  server's own market-live.json, logs on the server, mirrored home for dashboard and research; config paths
  only, no code change. Update state/proposals/phase7a/README-runner-unit.md when doing it.
- Broker recorders (cTrader IC Markets demo 10126462, Dukascopy JForex demo): server containers too,
  read-only, creds copied root-only (like /opt/fxplat/ib.env) from ~/.config/fxplat-brokers.ini by a deploy
  script the user runs (prod deploys are classifier-blocked for me).
- The PC keeps the GPU / data work: build pipeline, research runs, Dukascopy download.

**Why:** always-on pieces must survive PC reboots, Windows Update and the WSL GPU freezes.
**How to apply:** any new always-on fxplat service defaults to the server. Related: [[fxplat-ib-connector-server]],
[[fxplat-broker-costs]], [[fxplat-phase3-completion-2026-10-14]].
