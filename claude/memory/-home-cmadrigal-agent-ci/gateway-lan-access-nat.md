---
name: gateway-lan-access-nat
description: "LAN access to the gateway needs a portproxy plus an IP Helper restart, because this box runs WSL on NAT; mirrored mode does not work here"
metadata: 
  node_type: memory
  type: project
  originSessionId: 3a95969f-0700-4e5c-ad17-66cac7a14b11
  modified: 2026-09-09T12:49:30.329Z
---

Reaching the gateway dashboard from a phone on the wifi. Fixed and verified
2026-09-09; the fix is `~/ollama-gateway/contrib/publish-on-lan-nat.ps1`, run
elevated with `-Install`.

**This box runs `networkingMode=NAT`, and must.** Mirrored networking was tried
on 2026-09-06 and could not pass ANY Windows -> WSL traffic — :11434, :11500 and
:8765 all timed out from Windows while answering in ~3 ms inside WSL, with the
Hyper-V VM firewall fully permissive and on a fresh boot. Suspected VMware /
Surfshark filter drivers. The reasoning is in `%USERPROFILE%\.wslconfig`.
**So `contrib/publish-on-lan.ps1` (which switches to mirrored) is wrong for this
machine — use the `-nat` one.**

On NAT, `localhostForwarding=true` binds wslrelay to **127.0.0.1 only**, so the
gateway is invisible to the LAN however permissive the firewall is. The bridge
is a portproxy from the host LAN IP to the WSL VM IP.

**Two things break it, and the second is the non-obvious one:**

1. The WSL VM gets a **new IP on every `wsl --shutdown`**, so a portproxy's
   `connectaddress` goes stale.
2. The `vEthernet (WSL)` adapter is **recreated** on restart, which silently
   stops existing portproxy listeners from binding *even when their target is
   still correct*. On 2026-09-09 the :11500 rule pointed at the right IP and
   still refused connections; `netstat` showed nothing listening on
   192.168.1.119. **`Restart-Service iphlpsvc` is what rebinds them.** No amount
   of re-adding rules helps without it.

The firewall was never the problem — `agent-ci gateway (LAN)` already allowed
TCP 11434 from 192.168.1.0/24.

**How to apply:** after any `wsl --shutdown`, if the phone cannot reach the
dashboard, run the script elevated (`-Install` registers a logon task so it
self-heals). Diagnose in this order: `netstat -ano | findstr :11434` on Windows
(look for a listener on the LAN IP, not just 127.0.0.1), then
`netsh interface portproxy show all`, then whether iphlpsvc has been restarted
since the adapter came back. Dashboard URL is
`http://192.168.1.119:11434/?t=<token>`, token in
`~/ollama-gateway/lan-token.txt`. See [[unified-dashboard-preference]],
[[agent-ci-conventions]].
