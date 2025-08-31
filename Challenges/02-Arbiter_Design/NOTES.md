

## 4) `NOTES.md`

# Smart Arbiter — Design Notes

## Goal
Provide low-latency access to a shared resource while ensuring fairness and preventing starvation. Add support for locked multi-beat transfers commonly used in bus protocols.

## Key Ideas
1. **Primary selection**:
   - Use a *round-robin pointer (rr_ptr)* to ensure fairness. Each arbitration cycle, search requests starting at rr_ptr (wrap-around). This gives every master a fair chance.
2. **Priority vs Fairness**:
   - Design prefers fairness (round-robin), but you may insert fixed priority bias by scanning priority tiers. In this implementation, we handle promotion (aging) which effectively elevates starved masters.
3. **Starvation prevention (Aging)**:
   - Each master has a small starve counter that increments when requesting but not granted.
   - Once the counter reaches `STARVE_LIMIT`, the master is placed in a `promote_mask` and will be considered for immediate service on the next arbitration.
4. **Locked transfers**:
   - A master can request a locked transfer (via `lock_req` with its `req`).
   - Once granted, the arbiter will hold the grant until the master indicates the final beat (`last`) or until a safety limit `LOCK_MAX` is reached.
   - We disallow preemption during a locked transfer to preserve transaction atomicity (typical in bus protocols).
5. **Round-robin pointer update**:
   - After a grant completes (master deasserts), rr_ptr is advanced to `granted_index + 1`. This ensures the next arbitration cycle starts after the last served master, improving fairness.

## Design trade-offs
- **Simplicity vs Optimal latency**:
  - Fixed priority gives low latency to high-priority masters but can starve low-priority ones.
  - Round-robin ensures fairness but can increase latency for urgent masters. Promotion/aging helps balance this.
- **Starvation counters**:
  - They cost a small amount of state (counters). We saturate counters to avoid overflow.
- **Locked transactions**:
  - Holding the bus for locked transfers simplifies masters' design, but can penalize other masters. Keep `LOCK_MAX` bounded.

## Interview talking points
- Explain **why** round-robin + aging: it balances fairness while providing a mechanism to guarantee service to any persistent requester.
- Explain **bounded latency**: bound can be derived from N, STARVE_LIMIT, and LOCK_MAX worst-case behaviors. For example, with N masters and LOCK_MAX beats, a very conservative bound for a non-promoted master could be: `N * LOCK_MAX + STARVE_LIMIT` cycles (explain exact math to interviewer).
- Discuss **locked transactions**: show how you avoid indefinite preemption and the trade-offs.

## Extensions (next steps)
- Add **quality-of-service (QoS)** weights to each master so they get proportional bandwidth.
- Add **preemption rules** for urgent interrupts (with safe checkpoint/rollback).
- Replace simple counters with **age FIFOs** to implement strict oldest-first fairness.
- Add **formal properties** or assertions (SVA) to prove no-starvation and single-grant invariants.

