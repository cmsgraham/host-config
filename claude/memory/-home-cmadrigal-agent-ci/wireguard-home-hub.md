---
name: wireguard-home-hub
description: "Cristian's WireGuard hub (Linode 172.233.190.28) reaches the home LAN from the office; Rodrigo already has a peer (rodri.conf, 10.6.0.14) - use it for remote access to home services"
metadata:
  node_type: memory
  type: reference
  originSessionId: cc48b68a-726f-4a75-82ee-bb627b7e7f1c
  modified: 2026-10-09T13:23:24.431Z
---

Cristian connects home from the office through WireGuard. Hub = Linode
172.233.190.28:51820, tunnel subnet 10.6.0.0/24, split-tunnel profiles route
10.6.0.0/24, 192.168.1.0/24 (home LAN; the PC is 192.168.1.119) and 192.168.20.0/24.
Profiles live in C:\Users\crist\vpn_setup (repo cmsgraham/vpn_setup; the .conf files hold
private keys - read only Address/Endpoint/AllowedIPs lines): client1 10.6.0.12,
phone 10.6.0.13, rodri 10.6.0.14, ipad 10.6.0.15; `-exit` variants are full tunnel.
The same repo also provisions separate VPN exit nodes (Toronto) - different servers.

**How to apply:** when someone remote (Rodrigo) needs a service on the PC, prefer this VPN
plus a portproxy (see [[gateway-lan-access-nat]]) over a public tunnel. rodri.conf's
AllowedIPs opens the WHOLE home LAN to him; restrict per service on the hub (FORWARD rules),
since client-side AllowedIPs is under the client's control. Unverified: whether the hub or
the home router NATs the source address (that decides if a Windows firewall rule can
filter on 10.6.0.14).
