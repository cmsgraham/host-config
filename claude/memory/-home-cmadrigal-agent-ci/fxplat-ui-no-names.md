---
name: fxplat-ui-no-names
description: No personal names (Rodrigo, Cristian) in fxplat UI text, hints, help or sample data; neutral roles instead
metadata:
  type: feedback
---
2026-10-12 Cristian: "remove any rodrigo reference in the hints or page". UI copy uses neutral wording ("the registered FichaSenalFX format", "signed approval of the owners", "a written review", "users sign in"). The only place a name may appear is functional data: the Admin access list (emails) and the signed-in user's own email in the status bar.

**Why:** the dashboard is shown to others (and may become a product); people are not part of the methodology's text.
**How to apply:** before publishing UI text, `/usr/bin/grep -rniI "rodrigo\|cristian" ui/src ui/scripts ui/public/fixtures` (system grep: `grep` is ugrep here) and keep hits only in admin.json / code comments. Related: [[ui-no-ai-app-look]], [[fxplat-ui-css-prefix]].
