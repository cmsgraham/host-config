---
name: fxplat-in-wsl
description: fxplat repo moved 2026-10-05 from C:\Users\crist\Dukascopy into WSL ext4 ~/Dukascopy; what was repointed and what is left
metadata:
  type: project
---

2026-10-05 ~22:10 CST fxplat (Dukascopy) moved into WSL ext4 at `/home/cmadrigal/Dukascopy` (user chose it after the
measurement: pytest collection 17.9 s -> 1.5 s, full suite 250 s -> 102 s). Market data stays on D: (`/mnt/d/DukascopyData`).

Repointed: config.yaml/docs path (commit eff34cc in fxplat), state/history.json + lessons.json, all 64 worktree links
(.git files and .git/worktrees/*/gitdir rewritten by hand -- `git worktree repair` follows the OLD repo while it exists),
counterfactual `.venv` symlinks, watchdog via drop-in `agent-ci-watchdog@Dukascopy.service.d/wsl-path.conf` (the
template still says /mnt/c/Users/crist/%I for other projects), `/etc/systemd/system/agent-ci-dashboard-fxplat.service`.
Worktree venvs of finished tasks were NOT copied (broken shebangs); agent-ci reuses an existing worktree without
re-running worktree_setup, so a resumed old task needs its .venv rebuilt by hand.

The hourly data update moved from the Windows task "Dukascopy update" (now DISABLED, not deleted) to the user timer
`fxplat-update.timer` (:38) -> `~/.local/bin/fxplat-update.sh`. The store's `.lock` holds a PID and dukascopy takes over
a lock whose PID is dead; a Windows PID looks dead from Linux, so the script checks it with tasklist.exe first.

Done 2026-10-05: second C: sweep (temp>7d, adobeTemp, old installers, npm-cache, DeepFaceLive, TV episodes) -> C: 440 GB free; Cline globalStorage 10.3 GB kept by choice. The 65 Linux .venv dirs in the C: copy deleted (23 GB, C: 409.9 GB free). Left: rename `C:\Users\crist\Dukascopy` to a `.pre-wsl` backup once the last Windows update run (pid 33268, started
21:38) exits -- it runs from that folder.

**Never leave uncommitted edits in fxplat's integration tree (~/Dukascopy on main).** 2026-10-07: four lint fixes sat
uncommitted ~15 min and the merge gate (correctly) refused TASK-3.5's merge. Edit and commit in one step, or work in a
scratch worktree.
