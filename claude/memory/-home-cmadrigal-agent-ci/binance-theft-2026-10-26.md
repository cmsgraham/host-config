---
name: binance-theft-2026-10-26
description: 2026-10-26 08:21-08:23 CR the operator's main Binance account was emptied (0.00754778 BTC ~US$605) via web session confirmed by HIS passkey + face (QR "face setup" prompts); our keys cleared; IC3 filed; open items
metadata:
  type: project
---
Redeem 14:21:53 UTC (5 s after his Edge login on real binance.com), withdrawal 14:23:26 to
1H4hy3p38zJCkhU3ae2cnxTXUgw3FnCBuV (TxID d98adb02...6b8a84, withdrawal id 6d585b83c8fa4d42accbcce609dbbe64).
Binance support: web session, confirmed with passkey + face verification; logs only to police via Kodex.
Ruled out: our keys (no withdraw perm, never leaked before the theft), servers, extensions, proxy/hosts.
binance.bh (Google ad 14:17) is the REAL Binance Bahrain site. AnyDesk disabled + firewall-blocked (desktop
AnyDesk ON/OFF shortcuts); TightVNC installed but off; 5DDisplayer unsigned (ask).
My mistake: printed part of the [binance] read-only secret in a ps listing (it is in the session jsonl) ->
that key must be deleted and recreated. IC3 text on his Windows desktop (IC3-case-2026-10-26.txt).
Open: account-activity screenshot 08:21-08:24 decides whether his PC is compromised (if Windows/Edge/home IP ->
rotate every secret on this PC); Defender Offline scan; OIJ report; SAFU compensation asked; new read-only key;
address watcher (scratchpad watch-theft-addr.sh, dies on reboot). Never put secrets on a command line.
Related: [[binance-live-prep]].

Binance case ID 172523460; IC3 submission ID ac86d798bbfd46ed950a740ed996c0b4 (added to the Binance case).
Binance's finding (chat 10:45 CR): actions completed FROM HIS OWN recognised device, withdrawal confirmed with his 2FA
+ face; "device or session may have been compromised; the action you approved may have been presented differently".
=> treat the Windows PC / its Edge session as compromised until proven otherwise (he told support the opposite).
He said "most" device-list sessions are from the home IP - ask which are not. Chainabuse report suggested.

ROOT CAUSE FOUND 2026-10-26 ~13:15 CR: malicious unpacked Edge extension "Save to Google Drive" id
odlgnanjghijpjnmccjpnhleifjkdkob at C:\Users\crist\AppData\Local\KFWZRVJCqhsoNO (since 2025-07-14; all URLs, cookies,
webRequest, strips CSP/XFO, BTC-explorer C2 dead-drop bc1q9w9c3n4rrpmj2ufdgdw6m8f233phajsnyjv7sq, targets Gmail/Outlook).
My first browser audit MISSED it: it listed only the Extensions dir - unpacked extensions live elsewhere; always read
Secure Preferences extensions.settings (location 4/8). Quarantined (moved, not deleted - operator wants forensics) to
C:\Users\crist\QUARANTINE-2026-10-26; evidence + README on Desktop\EVIDENCE-edge-extension-2026-10-26. Dropper not yet
found (Secure Preferences MAC forgery implies native code). Operator: "do not delete anything, run the forensic".
