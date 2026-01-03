# FPGA Hardware Signoff: AXI4-Lite UART IP
**Target Platform:** Xilinx Artix-7 (CERN Evaluation Grade)
**Clock Frequency:** 100 MHz (Target)

## 1. Post-Synthesis Resource Utilization
This report details the FPGA real estate occupied by the AXI4-Lite interface and the internal 16550-standard register bank.

| Resource | Used | Available | Utilization % |
| :--- | :--- | :--- | :--- |
| **Slice LUTs** | 142 | 20800 | 0.68% |
| **Slice Registers**| 186 | 41600 | 0.45% |
| **BRAM (FIFO)** | 0.5 | 50 | 1.00% |
| **Bonded IOB** | 5 | 106 | 4.72% |

## 2. Timing Closure Analysis
The design was constrained with a 10ns period clock. All paths met timing requirements.

- **Worst Negative Slack (WNS):** 2.418 ns (**PASS**)
- **Worst Hold Slack (WHS):** 0.124 ns (**PASS**)
- **Max Achievable Frequency:** 131.8 MHz

## 3. Reliability Features for Detector Logic
- **CDC Synchronizers:** Implemented 2-FF synchronizers on the asynchronous `uart_rx` input to prevent metastability during high-speed data capture.
- **AXI Backpressure:** Supports `s_axi_ready` de-assertion to prevent FIFO overflow during burst RISC-V writes.