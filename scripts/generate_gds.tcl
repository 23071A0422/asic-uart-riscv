# GDSII Export Script
gds read $::env(PDK_ROOT)/sky130A/libs.ref/sky130_fd_sc_hd/gds/sky130_fd_sc_hd.gds
load uart_riscv
gds write designs/uart_riscv/gds/uart_riscv.gds