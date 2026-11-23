---
name: fxplat-auth-security
description: "fxplat.trade auth = oauth2-proxy (Google) behind snoopy nginx; security model for real accounts; 2026-11-22 dropped cookie-refresh to stop the consent-screen churn"
metadata:
  node_type: memory
  type: project
  originSessionId: 65592fdb-22b6-4529-9491-76c88746cc4c
  modified: 2026-11-23T00:40:55.261Z
---

fxplat.trade sign-in is `fxplat-oauth2-proxy` (quay.io/oauth2-proxy v7.7.1) in
deploy/server/compose.fxplat.yml, installed on the Linode as /opt/fxplat/compose.yml
(repo file -> compose.yml; server copy must match the repo sha). snoopy nginx
terminates TLS and proxies to it. Secrets in /opt/fxplat/oauth2.env (root 600).

**Security model (the controls that protect real accounts — verified 2026-11-22):**
- GATE = `--authenticated-emails-file=/etc/fxplat/emails.txt`, read PER REQUEST.
  Add/remove a real account = edit emails.txt; removal locks them out on the NEXT
  request, even mid-session. This is the revocation lever, not cookie settings.
- IDENTITY = `X-Forwarded-Email` the proxy injects; the app reads it
  (deploy/server/requests/replay_requests.py, src/fxplat/control/api.py EMAIL_HEADER).
  Un-spoofable: the proxy strips any inbound copy, and the only upstreams are static
  files + the internal-only fxplat-requests API (no published port, reachable only
  through the proxy on the docker network).
- COOKIE: Secure + HttpOnly(default) + SameSite=lax, 32-byte secret (len 44 b64),
  session-store-type=redis (server side; /oauth2/sign_out deletes the session).

**2026-11-22 change (commit b754bcf):** operator said it "logs in too often". The
server showed healthy long sessions (1 real callback/24h, redis TTLs 22-60 days);
the flood of "No valid authentication -> initiating login" log lines were ALL
internet scanners (Censys /favicon, wp-admin probes), not the user. The real pain
was Google's CONSENT screen on every re-login, forced by `--cookie-refresh=1h`
(hourly token refresh needs offline/consent tokens). Fix: removed --cookie-refresh,
added `--approval-prompt=auto`; kept --cookie-expire=1440h (60-day session). Deploy =
recreate oauth2-proxy only (`cd /opt/fxplat && docker compose up -d --no-deps
--force-recreate oauth2-proxy`); redis preserved so no one is logged out. Backup of
the old compose left at /opt/fxplat/compose.yml.bak.<ts>.

Trade-off noted: without cookie-refresh the Google token is not re-validated hourly,
so a session can live up to 60 days without a provider re-check — acceptable because
emails.txt (per-request) is the real gate. If per-account DATA isolation is ever
needed (multi-account, [[fxplat-multi-account]]), that is app-level work on top of
this (scope /app/ data by X-Forwarded-Email), not an oauth2-proxy setting.
Related: [[snoopyfrog-linode-deploy]] [[fxplat-deploy-plan]]
