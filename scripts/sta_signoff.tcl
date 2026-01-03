# OpenSTA Signoff Script
read_liberty $::env(PDK_ROOT)/sky130A/libs.ref/sky130_fd_sc_hd/lib/sky130_fd_sc_hd__tt_025C_1v80.lib
read_verilog $::env(DESIGN_DIR)/results/synthesis/uart_riscv.v
link_design uart_riscv
create_clock -period 10.0 clk
set_input_delay -clock clk 2.0 [all_inputs]
set_output_delay -clock clk 2.0 [all_outputs]

report_checks -path_delay max -format full_clock_expanded
report_checks -path_delay min -format full_clock_expanded