# S+++ Power Distribution Network (PDN) Configuration
# Target: SkyWater 130nm 1.8V Metal Stack
set ::env(VDD_NETS) [list {vccd1}]
set ::env(GND_NETS) [list {vssd1}]

# Define standard cell rails on Metal 1
add_pdn_stripe -grid stdcell_grid -layer met1 -width 0.48 -pitch 5.44 -offset 0

# Define main power straps on Metal 4/5 for low IR-drop
add_pdn_stripe -grid stdcell_grid -layer met4 -width 1.60 -pitch 20.0 -offset 2