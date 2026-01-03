# Design name and Source files
set ::env(DESIGN_NAME) "uart_riscv"
set ::env(VERILOG_FILES) [glob $::env(DESIGN_DIR)/src/*.v]

# Clock Constraints (Target: 100MHz for CERN/Purdue specs)
set ::env(CLOCK_PORT) "clk"
set ::env(CLOCK_PERIOD) "10.0"

# S+++ Synthesis & Placement Strategy
set ::env(SYNTH_STRATEGY) "DELAY 0"
set ::env(FP_CORE_UTIL) 35
set ::env(PL_TARGET_DENSITY) 0.45

# Timing Closure & Signoff
set ::env(QUIT_ON_TIMING_VIOLATIONS) 1
set ::env(QUIT_ON_LVS_ERROR) 1