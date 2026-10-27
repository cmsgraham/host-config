---
name: snoopyfrog-linode-deploy
description: "SnoopyFrog v3 live at https://snoopyfrog.com on a fresh Linode via deploy/linode; TLS, Google, AI (OpenAI gpt-4.1-mini) on; LinkedIn worker exits via the user's PC through the chisel relay + SnoopyFrog Connector"
metadata: 
  node_type: memory
  type: project
  originSessionId: 3a95969f-0700-4e5c-ad17-66cac7a14b11
  modified: 2026-09-12T03:01:33.541Z
---

SnoopyFrog v3 runs on a NEW Linode built by the `deploy/linode` terraform module
in the v3 repo: instance 104869066, firewall 163155772, IPv4 172.238.203.34,
us-mia, g6-standard-2 (4 GB; user chose "stay on 4 GB, measure first"). Fresh
server — the user dropped the old Oracle VPS and `scripts/vps.sh`.

State as of 2026-09-11 ~14:50Z:
- LIVE at https://snoopyfrog.com (www and http redirect to it). Let's Encrypt
  cert for snoopyfrog.com + www, expires 2026-12-10; systemd timer
  snoopyfrog-certbot.timer renews twice a day. TLS_DOMAINS lives in the host's
  /opt/snoopyfrog/.env; WEB_APP_URL/CORS_ORIGINS are https.
- Google sign-in ON (server and local demo): client
  355626163998-5tu6ugv97sr3fsr3mu35nmbm1re97f21 (the 535026276902-mhmb… one is
  retired); secret in ~/.config/snoopyfrog/google.env. Redirect URIs
  https://snoopyfrog.com/auth/google/callback and
  http://localhost:8081/auth/google/callback. User signed in with Google locally.
- DNS: GoDaddy (ns71/ns72.domaincontrol.com). The zone import ADDED the A record
  beside the Website Builder one; after deleting that row GoDaddy kept serving a
  cached Website Builder answer until its TTL ran out (it counts down ON the
  authoritative servers). Apex A 172.238.203.34 TTL 600, www CNAME @.
- Demo workspace seeded (demo@example.com; login in
  ~/.config/snoopyfrog/demo-172.238.203.34.env). Inert by construction.
- The user's OWN Google workspace ('cristian.madrigal workspace') was seeded
  too (seed_demo.py --token-env, token minted inside the api with the app's
  create_access_token; commit c8a4258), and its CFO campaign was Requalified so
  leads carry real gpt-4.1-mini scores. Google sign-ups get their own empty
  workspace; there is no workspace switcher. The seed refuses to run twice.
  Rodrigo (rodrigo.murillo.herrera@gmail.com, Google, signed in 2026-09-14
  17:37Z into his own 'rodrigo.murillo.herrera workspace') was seeded the
  same way on 2026-09-15 and now holds the identical demo set. Recipe:
  mint a token inside the api container with create_access_token(
  get_settings(), user_id=, email=, organization_id=, role=) -- org and
  role come from org_members, NOT from users -- export it, then run
  scripts/seed_demo.py --api https://snoopyfrog.com --psql '<ssh ... psql>'
  --token-env NAME.
- LinkedIn worker ON (profiles linkedin,relay), exiting through the user's own
  PC, NOT Decodo (Decodo blocks LinkedIn). chisel relay behind nginx at
  https://snoopyfrog.com/relay/ (`deploy.sh relay init|add <name> <port>`);
  connector 'owner-cristian' owns port 10001, creds in
  ~/.config/snoopyfrog/relay-owner-cristian.env + connector-owner-cristian.env.
  Worker proxy = relay:10001, geo Costa Rica. Proven 2026-09-11: worker exit IP
  == this PC's IP (143.255.29.93). Connector source ~/snoopyfrog-connector (Go);
  CONNECTING A REAL LINKEDIN ACCOUNT IS DEFERRED (2026-09-12): Rodrigo does it
  at a release candidate, after Phase 12 ships the pairing flow. Do not ask the
  owner to run the remote-desktop login; the accounts sitting in `error` are
  expected. The production steps that switch connector mode on (CONNECTOR_SECRET,
  widening OPERATOR_PROXY_PORTS, re-pairing) belong to that release, not before.
  Windows build + connector.json in C:\Users\crist\SnoopyFrog\. The WINDOWS
  connector was proven end to end at 20:28Z: relay session owner-cristian, the
  worker's exit IP was the user's home IP, and account li_8e1435de3d96 reached
  waiting_login. Source imported into v3 as connector/ (65c0c85). The Windows
  "mDNS" firewall prompt seen during that test came from the Arduino IDE's
  mdns-discovery.exe; the connector has no firewall rules. When the
  connector is off the worker fails closed (no proxy -> no LinkedIn traffic).
- Web export trap (fixed ad9ff5c): Metro's shared /tmp/metro-cache made a later
  mktemp export reuse a deleted temp dir as the expo-router app root -> zero
  routes, no index.html, site 403. cmd_web now uses a private TMPDIR and refuses
  to sync a dist without index.html; rsync also forces D755,F644 (umask 077).
- State 2026-09-12 ~00:25Z: PHASE 11 RELEASED. API image
  snoopyfrog-api:b581b20b2383 (master b581b20), 36 migrations, web bundle 65
  pages. Carries all of Phase 11 (voice memory, learning from edits, playground,
  coach, the two new screens), migration 036, the ticket.created history fix
  (4ad3c0c), the PageHeader phone wrap (457fd8c) and the sign-out fixes
  (3a995d5 + c58dd8f), each proven live with Playwright. A gzip DB dump is taken
  before every release: /opt/snoopyfrog/backups/snoopyfrog_v3-<ts>.sql.gz.
  Health step 4 now reads the scheduler's whole log (b68fd7e).
  Web-only deploys (`./deploy.sh web`) are safe mid-Phase: master has no other
  web changes; wait for the pipeline to be out of a merge before deploying.
- CONNECTOR PAIRING TURNED ON 2026-09-15 (commit 11b9da9 in v3). Phase 12's code
  was already live, but every 12.x task listed deploy/ as protected, so the
  three operator steps were never built. Now: `deploy.sh relay configure` mints
  CONNECTOR_SECRET once (rotating re-keys every paired machine) and records
  RELAY_PUBLIC_URL + RELAY_FINGERPRINT -- POST /api/v1/connector/pair answers
  404 instead of 503; `deploy.sh connector` cross-builds the Go connector in a
  golang container (no Go toolchain in WSL) and publishes binaries + manifest
  to the host's downloads/. ALL THREE targets must be built even when only
  Windows is wanted: isManifest() in apps/web/lib/api/connector.ts requires
  windows + macAppleSilicon + macIntel, and a manifest missing one reads as
  "not published yet", killing the Windows button too. The Mac builds are
  cross-compiled, unsigned and never run on a Mac. docker-compose.server.yml
  now mounts secrets/relay rw into the SCHEDULER with RELAY_AUTHFILE -- without
  it TASK-12.3's sync pass had nothing to write and no paired connector could
  ever have dialled in. Proven: the pass rewrote users.json and kept the
  operator's hand-issued owner-cristian entry.
  Turning CONNECTOR_SECRET on RETIRES the hand-made connector.json: in
  connector mode the worker takes the port only from an account with a live
  connectors row and derives the credential, so the old file on the Windows PC
  is dead and cristian must re-pair with the published binary too.
  STILL OPEN: OPERATOR_PROXY_PORTS on the host is the single port 10001, and
  li_8e1435de3d96 already holds it -- Rodrigo's pairing fails with no free port
  until it is widened to 10001-10010 (`deploy.sh env` with that one line).
- AI ON via the user's OpenAI key (not OpenRouter): OPENROUTER_BASE_URL=
  https://api.openai.com/v1, key under OPENROUTER_API_KEY (the setting the app
  reads), LLM_MODEL_QUALIFY/MESSAGE/CONVERSATION=gpt-4.1-mini, merged from
  ~/.config/snoopyfrog/ai-openai.env. Needed commit 7dd1a0b (llm.py sends the
  OpenRouter-only `usage` field to OpenRouter hosts only -- OpenAI rejected it on
  every call). gpt-5/o-series would also need max_completion_tokens, so stay on
  4.1-class models unless llm.py changes. OpenAI returns no per-call cost, so
  the Usage screen shows tokens with $0. Running image snoopyfrog-api:7dd1a0bec2fd.
- Local demo: API launcher ~/.config/snoopyfrog/demo-api.sh (not in /tmp any
  more), UI from ~/snoopy-demo; neither auto-starts after a reboot.

**Why:** the user wants something published so a v3 dev (FRojas1) sees real
change on login; backups, monitoring, healthchecks and deletion come after
publish, never straight onto production.

**How to apply:** never re-run `deploy.sh secrets` on this host (it refuses).
`env`, `google` and `tls` restart the api: expect ~6-20 s of 502, not a fault.
Read nginx/api logs before naming a cause. The user shuts the PC down when idle
(an unclean power-off on 2026-09-10 looked like a crash); `wsl --shutdown`
first avoids it. Deploys are human-triggered (DEC-003). Related:
[[reporting-style-decisions-first]], [[user-timezone-costa-rica]],
[[branch-drift-guard-trap]]

**2026-09-18 release (Phase 14 + 15 + prune).** `deploy.sh release` = ship →
web → up → migrate → health, and `up` deploys the tag of the CURRENT HEAD sha:
committing anything between ship and up (I fixed the web guard mid-release)
makes `up` pull a tag that was never shipped -- re-run `ship` first. The web
guard (`cmd_web`, "a local URL is compiled into the bundle") now ignores
`http://127.0.0.1:${...}` -- the Connector hand-off page's address (TASK-15.2).
Live now: migration 043 (rehearsal), Rehearse tab, /accounts/connect-pc,
connector 2026.09.17.f62f4c2 (Windows tray build, 9.7 MB, version info
embedded, published via `deploy.sh connector`; NOT yet run on a real Windows
PC), worker `init: true`. The never-connected prune deleted 5 accounts on its
first tick incl. Rodrigo's li_04999bcdf9d7 (he must add his account again).
Only li_deb95335c1c1 (cristian's, connected) remains.

**OFFLINE since 2026-10-24 (owner: "nobody is using it").** App containers stopped (api, linkedin-worker, scheduler, relay, redis, postgres; restart policy unless-stopped -> stay stopped after reboots); volumes snoopyfrog_pgdata + snoopyfrog_linkedin_sessions KEPT. snoopyfrog-nginx-1 STAYS UP: it terminates TLS for fxplat.trade (conf.d/fxplat.conf + certbot fxplat.trade cert; snoopyfrog-certbot.timer renews both). conf.d/default.conf rewritten to an offline 503 page (no api dependency); original at /opt/snoopyfrog/nginx/default.conf.bak-*. Verified: fxplat.trade 200, nginx survives restart without the app. Revive: restore the .bak default.conf + `docker compose -f docker-compose.server.yml up -d` in /opt/snoopyfrog. No home-side connector/chisel found running (WSL or Windows).

**2026-10-27 BACK ONLINE** (owner reversed the 10-24 parking). Two steps: (1) started the app stack
`cd /opt/snoopyfrog && sudo docker compose -f docker-compose.server.yml up -d` (api/postgres/redis/relay/
scheduler/linkedin-worker; data volumes intact); (2) the parking had replaced nginx conf.d/default.conf with a
hardcoded `return 503` "snoopyfrog is offline" page, so starting containers alone did NOTHING — restored the
real config from /opt/snoopyfrog/nginx/default.conf.bak-20261025001845, `nginx -t`, then `nginx -s reload`
(never restart: snoopyfrog-nginx-1 also serves fxplat.trade TLS). snoopyfrog.com + /health = 200, fxplat.trade
unaffected. The offline page is saved as conf.d/default.conf.offline-20261027195146 (one-line swap to re-park).
SSH as `fxplat-server` (user cristian + sudo); the `snoopyfrog` root alias is dead (hardening disabled root login).
