---
name: ui-no-ai-app-look
description: Cristian rejects the generic "AI-created app" look for fxplat; the UI must feel like a pro trading terminal (Bloomberg / TWS / thinkorswim / TradingView), v2 "instrument" language
metadata:
  type: feedback
---

2026-10-11: after seeing v1 (navy + single cyan accent, Inter, rounded cards with coloured top stripes, big KPI
tiles, icon sidebar) he said "still has the default AI create app face, we need to go away from it, way way far,
that's why I provided web UI interfaces as example" (his brief cites Bloomberg, IBKR, thinkorswim, TrendSpider,
TradingView). v2 "instrument" was accepted direction: graphite not navy, square panes on 1px seams with title bars,
numbered workspace tabs + bottom status bar with clocks, Barlow Semi Condensed + IBM Plex Mono, status glyphs not
coloured borders, 24px dense rows. Spec in ~/Dukascopy/docs/UI_DESIGN.md §8.

**Why:** the product must read as an enterprise instrument built by UI experts, not a templated AI dashboard.
**How to apply:** every new fxplat screen follows §8; never reintroduce rounded cards, gradient/glow, big centered
empty states, emoji, Inter/Space Grotesk, or accent-stripe cards. When in doubt, look at how a desk terminal does it.
