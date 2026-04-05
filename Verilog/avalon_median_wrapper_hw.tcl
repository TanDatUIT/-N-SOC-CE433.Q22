# ============================================================
# Qsys/Platform Designer Component: Switching Median Filter
# File: avalon_median_wrapper_hw.tcl
# Dat file nay cung thu muc voi cac file .v
# ============================================================

package require -exact qsys 13.1

# --- Thong tin component ---
set_module_property DESCRIPTION "Switching Median Filter 3x3 - Avalon-MM Slave"
set_module_property NAME avalon_median_wrapper
set_module_property VERSION 1.0
set_module_property GROUP "Image Processing"
set_module_property AUTHOR "SoC Project"
set_module_property DISPLAY_NAME "Switching Median Filter 3x3"
set_module_property INSTANTIATE_IN_SYSTEM_MODULE true
set_module_property EDITABLE true

# --- File list ---
add_fileset QUARTUS_SYNTH QUARTUS_SYNTH "" ""
set_fileset_property QUARTUS_SYNTH TOP_LEVEL avalon_median_wrapper
add_fileset_file avalon_median_wrapper.v VERILOG PATH avalon_median_wrapper.v TOP_LEVEL_FILE
add_fileset_file median_filter_top.v     VERILOG PATH median_filter_top.v
add_fileset_file window3x3.v             VERILOG PATH window3x3.v
add_fileset_file median_filter.v         VERILOG PATH median_filter.v
add_fileset_file sort3.v                 VERILOG PATH sort3.v
add_fileset_file swap.v                  VERILOG PATH swap.v
add_fileset_file max3.v                  VERILOG PATH max3.v
add_fileset_file min3.v                  VERILOG PATH min3.v

add_fileset SIM_VERILOG SIM_VERILOG "" ""
set_fileset_property SIM_VERILOG TOP_LEVEL avalon_median_wrapper
add_fileset_file avalon_median_wrapper.v VERILOG PATH avalon_median_wrapper.v
add_fileset_file median_filter_top.v     VERILOG PATH median_filter_top.v
add_fileset_file window3x3.v             VERILOG PATH window3x3.v
add_fileset_file median_filter.v         VERILOG PATH median_filter.v
add_fileset_file sort3.v                 VERILOG PATH sort3.v
add_fileset_file swap.v                  VERILOG PATH swap.v
add_fileset_file max3.v                  VERILOG PATH max3.v
add_fileset_file min3.v                  VERILOG PATH min3.v

# --- Parameters ---
add_parameter IMG_WIDTH INTEGER 256 "Chieu rong anh (pixel)"
set_parameter_property IMG_WIDTH ALLOWED_RANGES {16:4096}
set_parameter_property IMG_WIDTH HDL_PARAMETER true

add_parameter IMG_HEIGHT INTEGER 256 "Chieu cao anh (pixel)"
set_parameter_property IMG_HEIGHT ALLOWED_RANGES {16:4096}
set_parameter_property IMG_HEIGHT HDL_PARAMETER true

add_parameter FIFO_DEPTH INTEGER 256 "Do sau FIFO output"
set_parameter_property FIFO_DEPTH ALLOWED_RANGES {16 32 64 128 256 512}
set_parameter_property FIFO_DEPTH HDL_PARAMETER true

# --- Clock interface ---
add_interface clock clock end
set_interface_property clock ENABLED true
add_interface_port clock clk clk Input 1

# --- Reset interface ---
add_interface reset reset end
set_interface_property reset ENABLED true
set_interface_property reset associatedClock clock
add_interface_port reset reset_n reset_n Input 1

# --- Avalon-MM Slave interface ---
add_interface avalon_slave avalon end
set_interface_property avalon_slave ENABLED true
set_interface_property avalon_slave associatedClock clock
set_interface_property avalon_slave associatedReset reset
set_interface_property avalon_slave addressUnits WORDS
set_interface_property avalon_slave readWaitTime 1
set_interface_property avalon_slave writeWaitTime 0

add_interface_port avalon_slave address   address   Input  2
add_interface_port avalon_slave write     write     Input  1
add_interface_port avalon_slave read      read      Input  1
add_interface_port avalon_slave writedata writedata Input  32
add_interface_port avalon_slave readdata  readdata  Output 32

# --- Interrupt sender ---
add_interface irq interrupt end
set_interface_property irq ENABLED true
set_interface_property irq associatedClock clock
set_interface_property irq associatedReset reset
add_interface_port irq irq irq Output 1
