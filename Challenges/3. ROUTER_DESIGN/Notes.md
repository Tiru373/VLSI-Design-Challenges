

```markdown
# 📖 Notes: 1×4 Router Design

### 🌍 Real-world Link
Routers in SoCs and NoCs act like **traffic cops**, deciding where packets go.
This design models **flow control** and **resource arbitration**.

### 🔑 Key Design Points
1. **Handshake logic** ensures no data is lost.
2. **Stall mechanism** → if target output isn’t ready, input is held.
3. **Scalability** → design can extend from 1×4 to 1×N.

### ⚖️ Trade-offs
- ✅ Simple & efficient for small systems
- ❌ For larger routers, may need buffers (FIFOs) and advanced arbitration

### 🚀 Extensions
- Add packet headers (start, length)
- Support multiple inputs (crossbar switch)
- Implement round-robin arbitration for fairness
