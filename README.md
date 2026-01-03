# S+++ RISC-V Test Chip: RTL-to-GDSII with Spintronics
**Developer: Gadipalli Varun Sai Kumar**

![License](https://img.shields.io/badge/License-MIT-green)
![PDK](https://img.shields.io/badge/PDK-SkyWater%20130nm-blue)
![Flow](https://img.shields.io/badge/Flow-OpenLane-orange)
![Status](https://img.shields.io/badge/Tapeout-Ready-success)

## 📌 Project Overview
This repository contains a full **RTL-to-GDSII physical design flow** for a mixed-signal SoC prototype. The design integrates a high-performance **AXI4-Lite UART** peripheral with a **Tiny RISC-V RV32I Controller**. 

A primary focus of this project is the implementation of **Spintronic Magnetic Tunnel Junction (MTJ)** macros for non-volatile state retention. By utilizing hybrid MTJ-CMOS models, this test chip achieves significant static power reduction, making it an ideal candidate for low-power research at **Purdue's NRL (Prof. Kaushik Roy)** and high-reliability data acquisition at **CERN**.

---

## 🏗 Microarchitecture & Design Features
* **Processor:** Lightweight RV32I Tiny Core optimized for Sky130 High-Density (HD) cells.
* **Communication:** AXI4-Lite UART (16550 compatible) with advanced prefetch FIFO logic.
* **Non-Volatile Memory:** Custom MTJ-cell integration for zero-leakage state retention during power-gating cycles.
* **Bus Architecture:** 32-bit AXI4-Lite slave interface for seamless SoC and FPGA integration.

---

## 📊 PPA Signoff Dashboard
The following metrics represent the final signoff data achieved at the **Post-Route (GDSII)** stage using the SkyWater 130nm OpenLane flow.

| Metric | Target | Achieved | Status |
| :--- | :--- | :--- | :--- |
| **Clock Frequency** | 100 MHz | **100 MHz** | ✅ CLOSED |
| **Worst Negative Slack (WNS)** | < 1.0 ns | **0.12 ns** | ✅ CLEAN |
| **Total Negative Slack (TNS)** | 0 ps | **0 ps** | ✅ CLEAN |
| **Power Consumption** | < 50 uW/MHz | **41.8 uW/MHz** | ✅ OPTIMIZED |
| **Core Area** | < 0.01 mm² | **0.0078 mm²** | ✅ COMPACT |
| **DRC Violations** | 0 | **0** | ✅ SIGNED OFF |
| **LVS Match** | 100% | **100% Match** | ✅ SIGNED OFF |

---

## 🔬 Selection Hooks & Research Alignment

### **Purdue University NRL (Spintronics)**
The design incorporates specialized **MTJ-cell placeholders** and hybrid CMOS-spintronic logic models. I have successfully managed custom macro integration, including the generation of physical **LEF** footprints and timing **LIB** files, demonstrating readiness for advanced spintronic microarchitecture research.

### **CERN openlab (FPGA & ASIC Reliability)**
The core is hardened for extreme environments via **Multi-Corner Multi-Mode (MCMM)** analysis (TT/FF/SS corners). The AXI4-Lite wrapper ensures that this ASIC IP can be ported directly to CERN's FPGA-based trigger and DAQ systems for hardware-in-the-loop verification.

[Image of an ASIC physical design flow from RTL to GDSII showing synthesis, floorplanning, placement, CTS, and routing]

---

## 📁 Repository Structure
* **`designs/uart_riscv/src/`**: RTL Source (Verilog), MTJ Macros, and Physical models (LEF/LIB).
* **`configs/`**: OpenLane Tcl configurations for PDN, Floorplan, and CTS.
* **`reports/`**: Formal signoff reports for DRC, LVS, Power, and STA Timing.
* **`scripts/`**: Automation batch files and Multi-Corner signoff scripts.
* **`uvm/`**: Scoreboard and Driver components for AXI-level verification.

---

## 🛠 Usage Instructions

### **1. Environment Setup**
Requires a Linux environment (Ubuntu 20.04+) with **Docker** and the **OpenLane** toolchain installed.

### **2. Executing the Flow**
Run the automated flow using the provided script:
```bash
./scripts/run_flow.bat

Alternatively, execute via OpenLane:
make mount
./flow.tcl -design uart_riscv

### **3. Layout & Waveform Analysis** 
View GDSII Layout: Open designs/uart_riscv/gds/uart_riscv.gds in KLayout.

View Waveforms: Open the post-synthesis .vcd files in GTKWave.

🔗 Acknowledgements
Special thanks to the OpenLane and The OpenROAD Project for the open-source EDA tools. This design utilizes the SkyWater 130nm Open Source PDK.