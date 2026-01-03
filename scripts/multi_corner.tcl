# Multi-Corner Multi-Mode (MCMM) Signoff
# Corners: TT (Typical), FF (Fast-Fast), SS (Slow-Slow)
read_liberty -corner typical sky130_fd_sc_hd__tt_025C_1v80.lib
read_liberty -corner fast    sky130_fd_sc_hd__ff_n40C_1v95.lib
read_liberty -corner slow    sky130_fd_sc_hd__ss_100C_1v60.lib

# Check Setup (Max Delay) at Slow corner; Check Hold (Min Delay) at Fast corner
report_checks -corner slow -path_delay max
report_checks -corner fast -path_delay min