# 🚦 1×4 Router Design Challenge

## 📌 Problem
Design a **1×4 Router** in Verilog:
- Routes input data (`din`) to one of four outputs (`dout0..dout3`)
- Based on 2-bit `addr`
- Uses **valid/ready handshake** for safe transfer
- Supports backpressure when output is not ready

## 🛠 Features
- Parameterizable `DATA_WIDTH`
- Graceful stall handling
- Extensible to 1×N routers

## 📂 Files
- `router.v` → RTL code
- `router_tb.v` → Testbench
- `NOTES.md` → Design insights
- `run_router.sh` → Helper script

## ▶️ Run Simulation
```bash
# With Icarus Verilog
iverilog -o router_tb router.v router_tb.v
vvp router_tb
