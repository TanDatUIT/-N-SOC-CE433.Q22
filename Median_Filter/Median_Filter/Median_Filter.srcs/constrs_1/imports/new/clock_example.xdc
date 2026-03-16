## -------------------------------------------------------------------------------
## Timing Constraints -
## -------------------------------------------------------------------------------

# Ð?nh ngh?a chu k? clock 100MHz (10ns)
create_clock -period 10.000 -name sys_clk_pin [get_ports clk_in]

# Thi?t l?p ð? tr? Input/Output (I/O Delay)
set_input_delay -clock [get_clocks sys_clk_pin] -min 2.000 [get_ports btn_in]
set_input_delay -clock [get_clocks sys_clk_pin] -max 5.000 [get_ports btn_in]