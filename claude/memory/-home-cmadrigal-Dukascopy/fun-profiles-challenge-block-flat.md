---
name: fun-profiles-challenge-block-flat
description: "fun_profiles `challenge:` YAML is FLAT (8 rule keys + entry), builders nest it under rules: → FunProfileError; fun_challenge distances are rounded to cents"
metadata:
  node_type: memory
  type: project
  originSessionId: 8bec88b1-1ebe-488b-a71c-9f1c75a4feec
  modified: 2026-11-01T06:13:48.655Z
---

A rung's `challenge:` block in a fun_profiles YAML holds the eight ChallengeRules keys directly plus `entry:` — NOT `{rules: {...}, entry: {...}}` (that nested form is only the profile *hash* doc). The TASK-16.55 builder nested it and every fixture died with "challenge: missing key(s) version, …", then timed out (2026-11-01). fun_challenge's to_target/to_daily/to_max are rounded to cents (389.94, not 389.940735).

**Why:** cost a full builder attempt on 16.55; the same ladder helper pattern will recur in fondeo 4 / 16.56 tests.

**How to apply:** when a fondeo task fails on FunProfileError in a test ladder helper, check the block shape first; compare distances to the cent values. Related: [[fondeo-rung-chain-refill]], [[strong-direct-escalations]].
