---
name: rejected-tool-use-still-ran
description: a "rejected by the user" tool notice can be SPURIOUS (seen alongside a /model switch); the user did not reject, and the command ran — verify state, do not attribute an interrupt to the user
metadata:
  type: feedback
---

2026-10-27: a Bash command that paused fxplat (`agent-ci stop` + stopping the watchdog timer) came
back as "The user doesn't want to proceed with this tool use. The tool use was rejected." I treated
it as a deliberate interrupt, told the user they were right to stop me, and reframed the plan. The
user then said: **"I didn't reject anything — looks like that was a mistake."** The notice was
spurious (it coincided with a `/model fable` switch); the command had run normally (STOP flag
written at that exact timestamp, loop halted).

**Why it matters:** I built a narrative ("good interrupt, here's why I was wrong") around a signal
the user never sent, and saved a memory with the wrong cause. The harness notice is not reliable
evidence of user intent.

**How to apply:**
1. A "rejected" notice is NOT proof the command did not run — re-check real state (processes,
   timers, flag files like state/STOP) before saying anything was untouched.
2. It is also NOT proof the user rejected it. Do not tell the user they interrupted or that they
   "were right to stop me" unless they actually said so. If the signal is ambiguous, say so and
   ask ("did you mean to stop that?") instead of narrating an interrupt.
3. Restore state that contradicts the user's clear intent; never re-run the command verbatim
   without diagnosing first.
Related: [[malware-lab-project]].
