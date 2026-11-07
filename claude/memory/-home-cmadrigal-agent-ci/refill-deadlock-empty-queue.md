---
name: refill-deadlock-empty-queue
description: agent-ci queue refill only fires inside the auto loop; empty queue + exited loop = nothing restarts it (2026-11-07)
metadata:
  type: project
---
2026-11-07: fxplat queue sat at 0 runnable for ~7 h. The 02:58 CST refill correctly found every
remaining variant waiting on 6 phone asks (sent only after quiet hours) and exited. The auto loop
had exited too (nothing eligible), and the watchdog only starts the loop when something is
eligible - while `queue_refill.check()` is only called from inside the loop. So answering the asks
did NOT trigger a new refill: deadlock. Unblocked by calling `queue_refill.check(cfg, store,
cli._load_specs(cfg))` by hand (same path the loop uses; started refill pid 3745425).

**Why:** idle GPUs for hours with an answered queue is exactly what queue_refill exists to prevent.
**How to apply:** the durable fix is for the watchdog (or the asks poller after applying an answer)
to call queue_refill.check when no loop is running and the queue is low - not yet built; ask the user
before changing agent-ci. Until then, after answering asks, run the check by hand. See [[queue-refill-autostash]], [[phone-approvals-asks]].
