---
name: vitest-css-raw-blank
description: "In ui/ vitest, `import css from './x.css?raw'` (and import.meta.glob ?raw on .css) is \"\" — specs that prescribe it make CSS-selector tests vacuous"
metadata:
  node_type: memory
  type: project
  originSessionId: 0be61ea0-b040-47ac-80ce-458d64075cfe
  modified: 2026-10-25T15:26:18.450Z
---

ui/vite.config.ts has no `test.css`, so vitest's `vitest:css-disable` plugin turns EVERY .css module id
(query included: `?raw`, `?inline`) into `export default ""`. A spec telling the builder to read a view's css
with `?raw` (TASK-16.28 perfiles.css) yields an empty string; a "every selector starts with .pj-" check then
passes vacuously (or fails a non-empty guard). vite.config.ts is protected (ui/), so the fix lives in the test:
keep the `?raw` import, fall back to a computed `await import(/* @vite-ignore */ "node:fs")` typed with a local
interface (tsc has only vitest/globals types, so a literal `node:fs` import fails typecheck) and
`(import.meta as unknown as { dirname: string }).dirname`. `.tsx?raw` works fine. jsdom XHR on
`new URL(f, import.meta.url)` goes to http://localhost:3000 — network, don't.

**Why:** 16.28 escalation (2026-10-25); the spec said "?raw ... not node:fs" on a false premise.
**How to apply:** any UI task whose test reads css text — expect this; add a non-empty guard on the selector list.
Also seen in that run: the merge gate's temporary `/ui/**` block in .git/info/exclude hides new untracked ui
files from `git status` while another task merges (transient, restored by `_hide_foreign_untracked`). See [[owned-inside-protected-dir]].
