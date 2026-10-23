---
name: preflight-ignores-cd-ui
description: "agent-ci preflight resolves acceptance test paths from repo root, ignores `cd ui` → false \"does not exist\" HUMAN_REQUIRED on UI tasks"
metadata:
  node_type: memory
  type: project
  originSessionId: 9c516da0-d5b7-4008-b1de-cc444b711d33
  modified: 2026-10-23T06:09:02.916Z
---

agent-ci preflight (`check_targets`) resolves every path in an acceptance command from the repo root and does not follow `cd ui &&`. So `cd ui && npx vitest run src/views/x.test.ts` gets an instant HUMAN_REQUIRED "unrepairable: names src/views/x.test.ts, which does not exist". Seen on TASK-11.14, 2026-10-23.

**Why:** vitest 5 filters do not substring-match a `ui/src/...` path when run from inside ui/, so you cannot just prefix the paths.
**How to apply:** for UI specs, write `ln -sfn .../ui/node_modules ui/node_modules && (cd ui && npm run typecheck) && ui/node_modules/.bin/vitest run --root ui ui/src/...test.ts; rc=$?; rm -f ui/node_modules; git checkout -- ui/tsconfig.tsbuildinfo; exit $rc` (fixed in f802bac).
