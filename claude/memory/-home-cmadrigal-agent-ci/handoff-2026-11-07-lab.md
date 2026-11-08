---
name: handoff-2026-11-07-lab
description: Calibration lab state at the 2026-11-07 20:30 CST reboot - fix 22 clean batch 1 (9/9), clean batch 2 (b19) paused
metadata:
  type: project
---
Lab: ~/fxsynth/lab (PLAN.md = full log; lab_scan.py, queue.sh, judge.py, cache/). Branch
claude/scan-view-calibration in ~/Dukascopy-claude, head dc6f659 (fix 22). Fixes 7-22 this
session; fix 22 passed ALL 9 lab seeds (2101 2202 2303 2404 2505 2606 2707 2808 2909) = clean
batch #1. Clean batch #2 = b19 (fix22 x NEW seeds 20263010 20263111 20263212 20263313), PAUSED at
19:48 because the user's PC was slow (WSL held 37 GB cache; Windows starved - see [[wsl-disk-exhaustion-crash]]).
Resume after reboot, ideally at night: `systemd-run --user --unit=fxlab-queue-b19 -p Nice=19
~/fxsynth/lab/queue.sh b19 1 fix22:20263010 fix22:20263111 fix22:20263212 fix22:20263313`
(rm/recreate runs/b19 first; cache keeps finished work). Drop caches first (sudo -n).
Then, if 4/4 pass: full worlds seeds 20262101/20262202, then report to the user. NOT merged;
S2 v3 NOT launched; nothing to merge without the user.
Decisions: on-target = max(0.02/0.05 R, se); unpowered edges kept + reported not counted.
Pipeline: `agent-ci stop` requested 20:30 CST for the reboot (TASK-3.213 reviewing); after
reboot run `agent-ci auto` or let the watchdog restart it once STOP is cleared (agent-ci resume).
Open: refill deadlock fix ([[refill-deadlock-empty-queue]]); E-B sentinel design look.
