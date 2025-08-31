# Smart Arbiter — Design Challenge

## Problem Statement
Design a **smart arbiter** that grants a single master access to a shared resource (bus) among multiple masters.

Key requirements:
- Priority-aware arbitration with **round-robin fallback** for fairness.
- **Starvation prevention** via promotion/aging (temporary promotion after STARVE_LIMIT cycles).
- Support **locked transfers**: master can request exclusive multi-beat access.
- Parameterizable number of masters (default N=4).
- Single-clock synchronous design.

## Files
- `arbiter.v`  — RTL implementation (this file)
- `arbiter_tb.v` — Testbench demonstrating scenarios (simulatable with iverilog/vcs)
- `NOTES.md` — Design notes and interview talking points

## How to run simulation (Icarus Verilog)
```bash
iverilog -o arbiter_sim arbiter.v arbiter_tb.v
vvp arbiter_sim
# optionally view waveform:
gtkwave arbiter_tb.vcd
