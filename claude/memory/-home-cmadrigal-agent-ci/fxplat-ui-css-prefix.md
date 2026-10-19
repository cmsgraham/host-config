---
name: fxplat-ui-css-prefix
description: fxplat UI CSS is global; every view's classes need a unique prefix - two clashes on 2026-10-11/12 broke Riesgo and Help
metadata:
  type: feedback
---
All `ui/src/**/*.css` files load globally. A generic class name in one view silently restyles another: Signals' `.sw` collapsed Riesgo's K1-K17 rows (2026-10-11) and the Help page's `.help` inherited the shortcut dialog's 560px box (2026-10-12).

**Why:** both shipped to the user before being caught; he found the first one himself.
**How to apply:** prefix every new view's classes (`bt-`, `fw-`, `hp-`, `sys-`, `adm-`...), and before publishing run the duplicate-selector scan (classes leading selectors in more than one .css file) — it was clean after 2026-10-12 except intentional shared ones in components.css. Related: [[ui-no-ai-app-look]].
