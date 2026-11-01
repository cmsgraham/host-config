---
name: fondeo-rung-chain-refill
description: "Fondeo chain state (2026-11-01 13:30Z refill): 16.54/16.55/16.56 MERGED; drafts 16.57 (2c fun_sim cost wiring), 16.58 (fondeo 4 exporter), 16.59 (2d document build CLI) written from a prototype in /tmp/p1657 - measured numbers live inside the specs; unwritten: deploy wiring (compose.fun.yml mount + fun.json cost_document + a timer running 16.59); FTMO recorder files are NOT mirrored home (only brokers/ctrader = IC Markets)"
metadata:
  node_type: memory
  type: project
  originSessionId: 1672ea80-bed5-4a35-91f3-5aba823063a2
  modified: 2026-11-01T13:53:03.751Z
---

2026-11-01 (refills 00:22Z, 03:39Z and 13:30Z; main 23a21cb at the third):
- 16.54 (fondeo 2a), 16.55 (fondeo 3, fun_sim challenge wiring, root status 'fondeo'), 16.56 (shipped rung fondeo_ftmo,
  six-rung re-pins) are all MERGED on main. 16.43 / 16.44 / 16.49 / 16.50 passed too, so every fondeo dependency is in.
- FTMO grounding: the Artifact tool READS the operator's report https://claude.ai/artifact/3h4CdKki4oQNoJ22FaQsfW
  (2-Step Swing: +10 % then +5 %, daily 5 % vs the 00:00 CE(S)T balance on equity, max 10 % static, 4 trading days per
  phase, 1:30, smallest account US$10,000). FX commission unconfirmed -> 16.43 measured costs.
- Third refill (13:30Z) wrote, from a prototype in /tmp/p1657 (src copy + config symlink; scenario script output is the
  spec's MEASURED block): 16.57 fondeo 2c = fun_sim._load_cost_document (read once in build_context; FileNotFoundError
  -> present False; anything else FunGuardError exit 2), FunContext LAST fields measured / cost_document (own
  test_fun_sim_helpers.py for the MOVED['FunContext'] sha + n_sim <= 880 re-pins; fun_sim was 847 lines in the
  prototype), _mark passes broker_profile=ctx.measured for challenge rungs only, root status key 'costs' = {document,
  profiles} inserted BEFORE 'fondeo' (test_fun_sim_fondeo pins list(status)[-1] == 'fondeo' and BLOCK_C1 exactly),
  per-run status.json 'cost_profile' after 'broker'; measured name 'measured:' + doc.broker. Test doc: 7 majors, floors
  3.0 except (EURUSD, 13) = 1.0, commission 3.0/100k/side -> fill mark 9983.099999999986, stop net -115.15926499999844,
  happy net 190.01846499998962 (IB: 9988.2 / -110.059265 / 195.118465). 16.58 fondeo 4 = export_fun_profiles card
  'fondeo' / 'cost_profile', payload 'cost_document' (path dropped), statuses fase_superada / reprobada; lenient on an
  old status.json; the script has a pre-existing E501 at line 295 -> lint step ignores E501 on it. 16.59 fondeo 2d =
  fxplat.execution.fun_ftmo_document (I/O half: newest 30 dates by file name, --until truncation, symbols <= last hourly
  date, idempotent atomic write, build/check CLI, exit 2); WEEK fixture split by date = 4/48/48/48/48/44 lines, shas
  322efa31... (week) / fc6c7132... (two weeks) / ebef2a0b... (second week only).
- COMMITTED 2026-11-01 ~14:10Z after one OK review round each (low findings applied): 16.58 230bd49, 16.59 3c74842,
  16.57 3a7f8b3; queue went 5 -> 8 runnable.
- NOT written: the deploy wiring (compose.fun.yml read-only mount of a costs dir + fun.json cost_document key + a timer
  running 16.59 on the server or the home mirror; 16.42 pattern). The FTMO recorder's files are NOT mirrored home:
  ~/.cache/fxplat/brokers has only ctrader (IC Markets), ib, binance*. UI side: PerfilesForward.tsx status union is
  closed ('activa' | 'arruinada' | 'detenida_k3'); the new codes need the UI author's i18n keys (not spec-writer work).
- Other refill sources checked and EMPTY 2026-11-01: phone asks (feature-set-v2-count, positioning-asof-ns,
  family1-grammar, fondeo floor equality) all expired 'wait'; roadmap stubs 4.4 / 5.1 / 6.1 / 6.2 / 7.2 / 8.4 depend on
  unbuilt chains (4.4's deps passed but it is the Nautilus full replay on real data - not a 27b task).
Next free ids: 3.148, 4.20, 9.12, 11.57, 12.20, 14.23, 15.42, 16.60.

**Why:** the next writer must not re-derive or re-measure the fondeo chain and must know the only piece left (deploy
wiring) and which refill sources are exhausted.

**How to apply:** `git log --oneline -6 -- tasks/` first (16.57-16.59 committed?); `git status --short tasks/`
(untracked drafts?); `ls -t logs/spec-review-TASK-16.5[789]-*`; review logs in /tmp/sw1657/. Related:
[[binance-item6-wiring-refill]], [[real-run-task-ids]], [[fun-sim-split-and-binance-regression]].
