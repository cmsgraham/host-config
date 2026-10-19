---
name: fxplat-ib-connector-server
description: 2026-10-14 IB Gateway hidden (Xvfb :99) at home, then prepared to move to fxplat-server (shared with snoopyfrog) as containers; redeploy-ib.sh does the cutover; home mirror + publisher SERVER_OWNED
metadata:
  type: project
---
- Home (interim): fxplat-xvfb.service (Xvfb :99) + fxplat-ib-gateway DISPLAY=:99 -> no windows on the desktop.
- Cristian chose the SAME Linode as snoopyfrog (2 vCPU, ~4 GB, ~2 GB free) over a new Linode. Compose services
  ib-gateway (ghcr.io/gnzsnz/ib-gateway:10.50.1f, paper, read-only, mem 1200m, network fxplat_ib, creds in
  /opt/fxplat/ib.env 600 from ~/ibc/config.ini) and ib-market (ui/scripts/ib_market.py, IB_HOST=ib-gateway,
  IB_PORT=4004 paper relay - assumed from the image docs, verify) writing web/current/app/bundle/market-live.json.
- publish.py SERVER_OWNED = {market-live.json}: never pushed from home (2123a58). Home mirror
  ~/.local/bin/fxplat-live-mirror -> ~/.cache/fxplat/live/market-live.json (simulator TASK-7.23 config must point
  there). fxplat-health follows whichever setup is enabled.
- Cutover = `bash ~/Dukascopy/deploy/server/redeploy-ib.sh` (user runs; prod deploys are classifier-blocked for me);
  it rolls back to the home units if no fresh quotes within 5 min.

**Why:** the user wants the connector off the desktop and off the PC.
**How to apply:** if quotes go stale after cutover, check `docker logs fxplat-ib-gateway` and the 4004 port;
watch snoopyfrog memory. Related: [[snoopyfrog-linode-deploy]], [[fxplat-health-timer]].

**Cutover DONE 2026-10-14 14:36 CST** (Cristian ran redeploy-ib.sh): containers up, gateway ~512 MiB, server ~2.4 GB available, mirror fresh, home IB units disabled. Check server state before telling him it is pending.
