---
name: ctf-lab-project
description: ~/ctf-lab - reusable autonomous CTF solver (Claude headless + locked Docker sandbox + flag check + lessons); later own AI-probe challenges; built 2026-11-19 night under delegation
metadata:
  type: project
---

2026-11-19 ~23:30 CST operator (CTF the next day): wants something reusable "for this and many other and even in the
future and with the lessons learned build our own challenges AI probe". Then: "you need to be independent tonight,
I'm going to bed, you decide on design too".

**Why:** drop challenge text/files/images, solver starts automatically; lessons accumulate; later a known-flag challenge
bank to measure AI solvers (like the synthetic bench measures the scanner).
**How to apply:** design decisions are mine for that night; log them in ~/ctf-lab/docs/DECISIONS.md. Same safety
spirit as [[malware-lab-project]]: untrusted files only inside the sandbox, egress only to in-scope hosts.
Claude usage 50 % rule ([[claude-usage-50pct-rule]]) gates every launch.

State 2026-11-20 ~00:00 CST (commits fd0b10e..6c6a3a8): working. `ctf` on PATH (~/.local/bin/ctf). Image ctf-sandbox:2
(= :1 + headless Chromium). Solver = `claude -p --restricted --strict-mcp-config`, tools Read/Write/Edit/Glob/Grep +
MCP `sandbox_run` only (Bash dropped: `sbx echo a; whoami` ran whoami on the host under an allow rule). Self-tests
all solved: rsa small-e, png metadata, nc service via scope firewall, stripped crackme, drawn-text image (~$0.05-0.12
each, ~20 s). Hint/resume tested. Phone notify path NOT exercised (tests ran with CTF_NO_NOTIFY=1). Not yet: headless
Ghidra, AI-probe bank (docs/DESIGN.md roadmap), backup remote for ~/ctf-lab.
