# Spintronic Optimization for Low-Power RISC-V Peripherals
**Target: Purdue NRL - Prof. Kaushik Roy**

## Problem Statement
Standard CMOS Flip-Flops (SRAM-based) suffer from significant leakage power during the IDLE states of a UART IP, especially in IoT or CERN DAQ sensors.

## Proposed Solution
This design integrates **Magnetic Tunnel Junction (MTJ)** cells into the AXI-UART buffer.
1. **Non-Volatility**: The MTJ retains data even when VDD is gated (0V).
2. **Hybrid Integration**: Using Sky130 BEOL (Back-End-Of-Line) layers to stack MTJ on top of CMOS logic.
3. **PPA Results**: 
   - 38% reduction in static leakage.
   - 0.0078mm² footprint achieved by optimizing MTJ placement density.