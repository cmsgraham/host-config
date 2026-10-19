---
name: user-timezone-costa-rica
description: "The user wants all times reported in Costa Rica time (UTC-6, no daylight saving); the WSL system clock is already set to it"
metadata: 
  node_type: memory
  type: user
  originSessionId: 29d5414b-faf8-42b4-a2dd-34f618e19471
  modified: 2026-09-12T14:59:11.315Z
---

Stated 2026-09-05: "please continue using Costa Rica time". Costa Rica is
UTC-6 year round (no DST). The WSL host's local clock is set to it (ps and
docker timestamps show -0600), while agent-ci's own logs, run ids and events
are stamped in UTC.

**How to apply:** report times to the user in Costa Rica time; when quoting
a UTC timestamp from logs or run ids, convert (subtract 6 hours) and say
which zone is meant when it matters. Related: [[user-goal-autonomous-devinfra]].

**THE MIXED-ZONE INSTRUMENT TRAP, 2026-09-12.** The two clocks do not just
affect reporting -- they silently break measurement tools. `find -newermt`
parses its argument as LOCAL time. I read `14:05:17Z` out of an agent-ci state
file and passed it straight through as `find logs -newermt '14:04'`, which
means 14:04 CST = 20:04Z -- six hours in the FUTURE. It matched nothing, and
"no files newer than that" is indistinguishable from "nothing was written".
I reported a live merge gate as writing no logs at all on that basis. The
filter could not have matched anything on disk.

**How to apply:** never hand a UTC reading to a local-time parser. Prefer a
RELATIVE threshold (`-newermt '-5 minutes'`), or state the zone explicitly
(`-newermt '2026-09-12 14:04 UTC'`), or skip the filter and read mtimes with
`ls -la --time-style=+%H:%M:%S` / `date -r <file> -u +%H:%M:%SZ` (the `-u`
is what makes that one trustworthy). General rule from the same family: when
an instrument returns EMPTY, prove it can return non-empty before believing
the absence.

**A PIPE HIDES THE EXIT STATUS, so `||` after one is unreachable.**
`ps -o pid,etime -p <pid> | tail -n +2 || echo "EXITED"` can NEVER print
"EXITED": the shell takes the status of the LAST command in the pipeline, and
`tail` succeeds on empty input, so the fallback is dead code and a live process
and a dead one look identical (both print nothing). Measured 2026-09-12 while
checking whether an escalation had exited; `pgrep -f '[p]attern' | wc -l` gave
the real answer. Same family as the two traps above: the check could not report
the negative it was written to detect. **How to apply:** never put `||` after a
pipe to handle "not found" -- test the thing directly (`kill -0 <pid>`,
`[ -e path ]`, a counted `pgrep`), or capture into a variable and test that.
Related: [[spec-given-claims-trap]], [[agent-ci-conventions]].
