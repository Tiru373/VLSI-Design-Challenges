# 📝 FIFO Design Challenge

## 📌 Problem Statement
Design a **First-In First-Out (FIFO)** memory with the following requirements:  

- **Synchronous FIFO** (single clock domain)  
- Parameterizable **data width** and **depth**  
- Correctly generate **full** and **empty** flags  
- Prevent overflow and underflow conditions  
- Provide **occupancy logic** (number of words stored)  

---

## 🎯 Learning Objectives
By solving this challenge, you will learn:  
1. How to manage **pointers (read/write)** in circular memory.  
2. How to detect **boundary conditions** (full, empty).  
3. How to implement **occupancy logic** without using counters.  
4. Trade-offs between **counter-based** vs **pointer-based** approaches.  

---

## 🛠️ Design Approach
- Maintain **write pointer (wr_ptr)** and **read pointer (rd_ptr)**.  
- Use pointer difference to calculate **occupancy**.  
- Full condition:
  (wr_ptr + 1) == rd_ptr
- Empty Condition:
  wr_ptr == rd_ptr
