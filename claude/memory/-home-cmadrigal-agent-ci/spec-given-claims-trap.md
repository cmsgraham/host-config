---
name: spec-given-claims-trap
description: "Phase 12 stalls traced to false \"Verified against master -- take as given\" claims in the task specs I write; audit those preambles mechanically before the builder reaches them"
metadata: 
  node_type: memory
  type: feedback
  originSessionId: 3a95969f-0700-4e5c-ad17-66cac7a14b11
  modified: 2026-09-12T17:02:21.447Z
---

Two Phase 12 tasks burned an escalation each on claims I had written into the
spec preamble as verified fact:

- TASK-12.3 stated "the path arrives as `settings.relay_authfile`". That field
  never existed in `services/api/app/config.py`, so the pass could only ever
  have been dead code. The escalation had to add the field before it could fix
  anything (it also found the builder had invented the file format and inverted
  the `sfc-` managed/operator rule).
- TASK-12.5 stated that `connector_online` NULL means "no connector, or not
  probed yet". `db/migrations/037_connectors.sql` declares it
  `BOOLEAN NOT NULL DEFAULT false`, so NULL never occurs and the boolean alone
  cannot tell "the PC is off" from "never paired a PC". The builder followed the
  wording literally (`connector_online IS NOT FALSE`), which would have stopped
  dispatch for every account in the fleet -- `tests/db/factories.py`
  `create_linkedin_account` pairs no connector, so every db test account carries
  the default. Corrected in v3 commit 4b64506 to key on
  `connector_checked_at IS NOT NULL AND connector_online IS FALSE`, the same
  distinction `services/api/app/services/linkedin_session.py` already makes.

A sweep of the remaining 14 Phase 12 specs afterwards (62 existence claims, ~15
semantic ones) found no further defects, so the trap is in how the preamble is
written, not in one bad spec.

**Why:** an escalation cannot repair a false given -- the spec itself demands the
wrong behaviour, so the strong model either fights the requirement or implements
the fleet-halting rule. Each one costs ~$6.50 and 40-80 minutes, and the next
tasks in the chain inherit the same assumption.

**How to apply:** before a phase starts, machine-check every concrete identifier
in each spec's "take as given" block (file exists, symbol present -- cheap to
script in one bash pass) AND every semantic claim separately: column NULLability
and defaults, the exact SQL a reader filters on, what a helper actually keys on. THIRD CLASS, found on TASK-12.7 2026-09-12: a
spec can CONTRADICT ITSELF -- its preamble described a `/downloads/` manifest
without saying the server publishes it, and its own `scope-respected` rule
rejects any untracked path outside `tests/` and `apps/web/`, so the builder
created `downloads/connector.json` (inventing the shape) and failed the only
check it could not pass. Audit for it by extracting each spec's scope-rule
prefixes and every path its requirements name, then flagging any path the rule
would reject. Doing that across the other 11 Phase 12 specs found no second
case, so it is worth one scripted pass per phase rather than constant worry.
FOURTH, AND THE WORST: DO NOT TRUST YOUR OWN AUDIT'S SCORE. On 2026-09-12 I
reported "62/62 claims present" for Phase 12 and used it to call the specs
sound. TASK-12.8's escalation then found that my preamble's "the Account type
already carries health and proxyPort" was false -- master's `Account` in
apps/web/lib/api/types.ts had neither, and neither word appears anywhere in
that file. The claim was in my NARRATIVE of what I would check and never in the
script I actually ran, so it could not have failed. A clean audit score only
covers the assertions literally executed: print the checklist the script
contains, count it against the claims in the spec, and treat any claim you
described but did not execute as UNCHECKED. Related: a file-wide grep for a
symbol also does not prove the symbol is on the right TYPE.

FIFTH, AND IT IS ABOUT ADVICE, NOT SPECS: VERIFY A PRESCRIPTION AT LEAST AS
HARD AS A DIAGNOSIS, AND SAY WHICH YOU ARE OFFERING. Over one night briefing
seven escalation sessions on snoopy_frog Phase 12, every DIAGNOSIS I checked
against source held up; all three PRESCRIPTIONS I sent without checking were
wrong:
- TASK-12.6: "the failing check is a known flake, re-run the suite and report
  green" -- true about the check, but the task was a 37-line stub and that
  advice would have merged it. I had not read the reviewer's findings.
- TASK-12.11: "rewrite the filter as `m.visibility = ANY($3::text[])`" -- would
  have reddened a passing check, because tests/db/test_ticket_messages.py:353
  pins the literal SQL spelling with `inspect.getsource`.
- TASK-12.12: "add a ticket_id to the tenants fixture's ids" -- the fixture
  already had one (test_tenancy_isolation.py:378); the KeyError came from two
  staff tests calling `_call(api, probe, {}, headers)` with an empty dict.
The asymmetry is structural: a diagnosis describes something already on disk and
can be read, while a prescription describes code that does not exist yet, so
there is nothing to read and the checking step feels optional. It is not. Grep
for the tests that pin what you are about to change, and label advice as
"verified" or "untested" so the reader can weigh it.

**AND A PRESCRIPTION THAT LOOKS LIKE A FAITHFUL GENERALISATION CAN STILL
HARD-CODE THE ASSUMPTION IT WAS MEANT TO REMOVE (2026-09-12, TASK-12.16).** The
task's ceiling test set a device's `created_at` to 364 days ago and asserted
`timedelta(days=1)` remained. Generalising it away from the literal 365, I
prescribed `timedelta(days=get_settings().session_max_days - 364)` — which is
correct ONLY while the ceiling is 365. Lower it to 90 and my version computes a
NEGATIVE window and the test fails for a reason having nothing to do with the
code. The escalation I sent it to fixed it better: derive the device's AGE as
`session_max_days - 1` and keep expecting one day left, which holds at any
ceiling. **How to apply:** after writing a prescription that replaces a literal
with a setting, substitute two or three other plausible values for that setting
and check the arithmetic still means what you intended. A generalisation that
only works at the current default is the same bug wearing a variable.

**A trap no audit of mine would have caught:** one task's test can pin an EXACT
set that a later task must widen, in a file the later spec never mentions.
tests/db/test_staff_flag.py:221 (TASK-12.10) asserts
`staff_paths == {("GET", "/api/v1/staff/me")}`, so every route TASK-12.12 added
reds it. Before adding a route, grep tests/ for equality assertions over the
route table -- not just the probe lists.
Read the whole function before believing a claim about it -- I misread
`limit_refresh` as IP-only from its first line and its docstring, when it does
resolve the body's `refreshToken` to a user and keys on that.

SIXTH, AND IT CUTS THE OTHER WAY: A SELF-CORRECTION CAN BE WRONG TOO, SO VERIFY
THE RETRACTION BEFORE SENDING IT. 2026-09-12, auditing my own TASK-12.15
briefing. I had the claim "only a 404 sets `not-staff`" in `useStaff`. A
`grep -nF "not-staff"` printed line 17 of apps/web/lib/hooks/useStaff.ts as
`404 leaves the status unknown and is RETRIED with backoff`, and I read that as
proof my claim was INVERTED -- I was one message from retracting a correct
statement and telling an escalation the opposite of the truth. Reading the file
showed the sentence STARTS ON LINE 16 with "Every failure that is not a", so
line 17 is its second half; line 8 states "only a 404 means \"not staff\"" as
the hook's central rule and lines 109-113 implement it. The grep did not lie --
it printed one line of a WRAPPED SENTENCE, and a fragment that begins
mid-clause reads as a complete claim with the polarity reversed.
**How to apply:** `grep -n` output is a POINTER, never evidence about semantics.
Before acting on a matched line, read the surrounding sentence (`grep -B2 -A2`
at minimum, the file for anything you will tell someone else). And apply the
same bar to a retraction as to the original: the impulse to correct yourself
feels like rigour, so it skips the checking step the same way a prescription
does. Related: [[agent-ci-failure-modes]], [[snoopyfrog-phase11-voice]],
[[merge-pending-race]]
