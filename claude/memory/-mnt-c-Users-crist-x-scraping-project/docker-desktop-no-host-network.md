---
name: docker-desktop-no-host-network
description: "This box runs Docker Desktop (WSL2); --network host does not reach the host, and Chrome's CDP port / x11vnc bind to container loopback, so reach them via an in-container TCP forwarder on a published 127.0.0.1 port"
metadata: 
  node_type: memory
  type: project
  originSessionId: 5cb90226-2a86-4a1e-b04a-fc6943f87d36
  modified: 2026-09-02T22:09:44.897Z
---

`docker info` reports "Operating System: Docker Desktop". A container started
with `--network host` binding 127.0.0.1:PORT is NOT reachable from the WSL
host (probe: HTTP 000). Inside scraper-worker containers, Chrome binds
`--remote-debugging-port` to 127.0.0.1 and x11vnc runs with `-localhost`, so
`-p 9222:9222` / `-p 5900:5900` do not work either (docker-proxy dials the
container IP).

**Why:** the host-side ChromeExtensionExecutor/CdpExtensionBridge in
tests/integration/test_real_authenticated_scrape.py needs Chrome's DevTools
endpoint, and operators need VNC for manual logins.

**How to apply:** `docker exec -d <c> python3 -c '<stdlib socket forwarder
0.0.0.0:9223 -> 127.0.0.1:9222, 0.0.0.0:5901 -> 127.0.0.1:5900>'` and publish
`-p 127.0.0.1:0:9223 -p 127.0.0.1:0:5901`. Chrome rewrites
`webSocketDebuggerUrl` from the request Host header, so the bridge's ws URLs
point at the published host port automatically. The forwarder script lives in
the test file (FORWARDER_SCRIPT). Related: [[branded-chrome-ignores-load-extension]].
