# Timing constraints - DE2, Cyclone II EP2C35F672C6
# CLOCK_50 = 50 MHz oscillator
# PLL c0 = 100 MHz system clock
# PLL c1 = 100 MHz -3ns for DRAM_CLK

create_clock -name CLOCK_50 -period 20.000 [get_ports {CLOCK_50}]

derive_pll_clocks

derive_clock_uncertainty

# False path cho JTAG
set_false_path -from [get_ports {KEY[0]}]
