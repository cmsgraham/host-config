---
name: fxplat-deploy-plan
description: "2026-10-09 decided - fxplat dashboard on its own Linode (Docker, Google login via oauth2-proxy, pull-based CI/CD from GHCR); plan in Dukascopy docs/DEPLOY_PLAN.md"
metadata:
  node_type: memory
  type: project
  originSessionId: cc48b68a-726f-4a75-82ee-bb627b7e7f1c
  modified: 2026-10-09T13:32:18.553Z
---

Plan: ~/Dukascopy/docs/DEPLOY_PLAN.md (commits cfb4bfc + follow-up). Decided by Cristian 2026-10-09:
public HTTPS + Google login (oauth2-proxy allowlist: cristian.madrigal@gmail.com,
rodrigo.murillo.herrera@gmail.com); domain fxplat.trade (own domain since 2026-10-12; was fx.snoopyfrog.com) (GoDaddy DNS) on a NEW Linode
separate from snoopyfrog; private GitHub repo under Cristian's account (cmsgraham), Rodrigo
collaborator; deploy every green merge, pull-based (server timer follows ghcr :prod, auto
rollback on failed health), SSH only from the WireGuard hub ([[wireguard-home-hub]]).

**Why:** Rodrigo must use fxplat without loading the home PC; fxplat needs no AI/GPU.
**How to apply:** the server gets only an allowlisted summary bundle pushed hourly from home -
never ticks, never validation/sealed_holdout/forward (CHARTER §12.2). Paper/live trading
(Phases 7-8) on the same host needs its own review and two-person deploy approval.
State 2026-10-09: repo pushed to github.com/cmsgraham/fxplat (branch main, HTTPS via Windows GCM; WSL has no GitHub SSH key, no gh); steps 1-3 are
agent-ci tasks not yet specified.
Secrets: ~/Dukascopy/.env (git-ignored, 600; structure in committed .env.example: AI, sign-in, deploy;
IB creds never there - Docker secrets). OpenAI + Anthropic API keys added and tested OK 2026-10-10 (model
list only); image spend capped at US$15, price-check before any paid call. UI plan: docs/UI_DESIGN.md
(full terminal, built LAST, static web app, ES/EN, custom SVG identity, no emoji).

2026-10-12 decisions: host = the snoopyfrog Linode (172.238.203.34; snoopy may be shut down if fxplat needs room); domain fxplat.trade; Google OAuth client created in GCP project `fxplat` (number 791980972410), Testing mode, test users Cristian + Rodrigo, id+secret in ~/Dukascopy/.env. Snoopy's nginx owns 80/443 -> fxplat.trade = second server block. Remaining before Rodrigo can log in: DNS A record, control service (UI-E1/E2), deploy pipeline.
2026-10-12 server hardened (DEPLOY_PLAN §10): admin user `cristian` (alias `ssh fxplat-server`), key-only SSH, root key-only (snoopy deploy.sh), ufw 22/80/443, fail2ban on ssh.service. Open: WireGuard-only SSH, PermitRootLogin no. Repos backed up hourly to GitHub by user timer git-backup.timer (fxplat main + agent-ci master, never force).
2026-10-12 DEPLOYED (manual): https://fxplat.trade = snoopy nginx (conf.d/fxplat.conf, copy in deploy/server/) -> container fxplat-oauth2-proxy (/opt/fxplat/compose.yml, project "fxplat", network snoopyfrog_default, no ports) serving /opt/fxplat/web/current (the dist-fixtures build). Secrets /opt/fxplat/oauth2.env (root 600); allowlist /opt/fxplat/emails.txt (watched, no restart). Redeploy = deploy/server/redeploy-ui.sh ONLY (swaps /opt/fxplat/web/current inside the mounted parent; mounting the swapped dir itself caused a 2026-10-12 outage). Health: /favicon.svg is the one public file (200), / must be 302. UI identity from /oauth2/userinfo + role from admin.json; "preview" on claude.ai.
2026-10-12 sessions stage 1 (Zentra model, inkflow/apps/api/src/modules/auth/routes.ts: 30-min access, 60-day rolling rotating refresh, logout revokes server-side): oauth2-proxy --cookie-expire=1440h --cookie-refresh=1h, Redis session store (container fxplat-redis, internal network, no internet), Sign out -> /oauth2/sign_out?rd=/ (landing). Stage 2 DEFERRED by Cristian 2026-10-12 ("we dont need stage 2 at this moment"): control service with "remember this device", devices list, revoke per device/all, admin sees all sessions, audit log (UI-E1/E2).
2026-10-12 layout: / = public landing (ui/landing/, fonts copied by redeploy-ui.sh), /app/ = dashboard behind login; public skip-auth routes: / index.html landing.js fonts/*.woff2 favicon.svg.
2026-10-12 IB: Cristian requested an IB PAPER account (created instantly in Client Portal) but the Gateway login said "no paper user configured" -> not provisioned yet (IB overnight). IB Gateway 10.50 in ~/Jts/ibgateway; read-only test ~/ib-test/check_ib.py 4002 in its own venv (ib_async; NOT in fxplat's venv). PASSED 2026-10-12 23:55 UTC (paper DU…33); FX quotes need an API data subscription shared with paper (error 10089); paper balance should be reset to US$5,000. Never put IB credentials in chat or .env.
2026-10-13 IB: paper balance reset to US$5,000; API data acknowledgement signed (Non-Professional). IB rule found: shared market data streams to ONE session; a live login (portal/mobile) cuts the paper session's quotes (error 10197). Phase 7 must use a second live username or another price feed for the bot.
2026-10-13 IB auto-login: IBC 3.24.2 in ~/ibc (TradingMode=paper, ReadOnlyApi=yes, port 4002, TrustedTwsApiClientIPs=127.0.0.1, AutoRestartTime 11:45 PM); paper creds in ~/ibc/config.ini (600, typed by Cristian; never read/print them). Start ~/ibc/start-paper-gateway.sh; stop by killing the gateway's java PID (not pkill -f). ~/Jts/ibgateway/1050 is a symlink to ~/Jts/ibgateway for IBC's layout. Verified: logs in alone, US$5,000, live EURUSD quote.
