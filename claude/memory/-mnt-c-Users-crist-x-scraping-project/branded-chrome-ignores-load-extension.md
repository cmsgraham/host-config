---
name: branded-chrome-ignores-load-extension
description: "google-chrome-stable 137+ silently ignores --load-extension; the scraper-worker image must use Chrome for Testing for the collector extension to load (fix lives in the TASK-1.5 branch Dockerfile, NOT on main as of 2026-09-02)"
metadata: 
  node_type: memory
  type: project
  originSessionId: 5cb90226-2a86-4a1e-b04a-fc6943f87d36
  modified: 2026-09-02T22:09:37.324Z
---

Found on 2026-09-02 while building TASK-5.3 (ChromeExtensionExecutor): the
worker image's `google-chrome-stable` (152.x) logs
"--load-extension is not allowed in Google Chrome, ignoring." and the
x-timeline-collector-chrome extension never loads. The
`--disable-features=DisableLoadExtensionCommandLineSwitch` override no longer
works either. Chrome for Testing (same version, zip from
storage.googleapis.com/chrome-for-testing-public) honours the switch.

Status 2026-09-02 (TASK-1.5 session): the Chrome-for-Testing Dockerfile block
only existed on the unmerged `experiment/TASK-5.3-claude` branch; `main` and
every agent/TASK-* branch still installed branded Chrome, so
`scraper-worker:test` built by the pipeline had NO extension. The TASK-1.5
worktree ported the block into scraper-worker/Dockerfile (ARG CHROME_VERSION,
default `stable`, pin e.g. 152.0.7977.75 to match a stored profile) and rebuilt
`scraper-worker:test`. If a later task rebuilds the tag from a branch without
that block, the extension silently disappears again.

**Why:** every earlier image build "passed" while the canonical pipeline
(DEC-001) was not actually present in the browser, so anything that assumes
the extension is loaded (executor, batch mode over VNC) was dead on arrival.

**How to apply:** never assume `--load-extension` worked; check
`docker run --rm IMAGE google-chrome-stable --version` prints "Google Chrome
for Testing", and verify via CDP that a `chrome-extension://<id>/` service
worker target exists (id for `/opt/x-collector/extension` is
`mjgbcobpkkddbdlcdgbbgjanhpgojagk`). Also: a logged-out X session sent to
`/home` lands on bare `https://x.com/`; run-worker.sh's initial
`https://x.com/login` lands on `/i/jf/onboarding/web?mode=login` when logged
out and on `/home` when logged in. See [[docker-desktop-no-host-network]].
