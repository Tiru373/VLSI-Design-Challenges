# 📝 FIFO Design Challenge


## 📌 Problem Statement
You are asked to design a **parameterizable synchronous FIFO**.  
The FIFO must:  
- Support configurable **depth** and **data width**  
- Correctly generate **full** and **empty** flags  
- Prevent **overflow** and **underflow**  
- Provide **occupancy logic** (number of words currently stored)  
- Be efficient in both **area** and **timing**  

---

## 🎯 Why This Challenge?
FIFO is a **classic real-world problem** in VLSI design.  
It is used in:  
- Buffers between **producer-consumer systems**  
- Network-on-Chip (NoC) routers  
- DMA controllers  
- Any interface with **rate mismatch**  

Every chip uses FIFOs, so **mastering this design is crucial** for freshers aiming to be industry-ready.  

---

## 💡 Key Questions to Think About
1. Should you use **pointers** or **counters** for occupancy?  
2. How do you **detect full/empty conditions** reliably?  
3. How to ensure **no overflow or underflow** happens?  
4. How to scale the FIFO to **asynchronous (dual clock)** in the future?  

---

## 🛠️ Hints for Implementation
- Maintain **write pointer (wr_ptr)** and **read pointer (rd_ptr)**.  
- **Empty** when `wr_ptr == rd_ptr`.  
- **Full** when `(wr_ptr + 1) % DEPTH == rd_ptr`.  
- Occupancy = `(wr_ptr - rd_ptr) mod DEPTH`.  
- Decide if you want **extra logic** for `almost_full` and `almost_empty`.  

---

## 📂 Folder Contents
- `fifo.v` → RTL implementation (Verilog)  
- `fifo_tb.v` → Testbench with sample cases  
- `README.md` → This document  
- `notes.md` → Interview-style Q&A for FIFO design  

---

## 🧑‍💻 Interview Tip
❓ *Why not just use a counter for FIFO occupancy?*  
- Counter = **easy to code**, but needs **extra hardware** and can cause sync issues.  
- Pointers = **lightweight, industry-preferred** solution.  
👉 A good designer knows **both methods** and their trade-offs.  

---

## 🚀 Next Step
🔹 Extend this FIFO to **dual-clock asynchronous FIFO** with metastability-safe synchronizers.  
🔹 Add **error detection** flags.  
🔹 Optimize for **low power** in mobile/IoT designs.  

---

✨ Part of the [VLSI Design Challenges](../..) Repository.  
