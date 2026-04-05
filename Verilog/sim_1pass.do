vlib work
vlog -work work swap.v sort3.v max3.v min3.v median_filter.v window3x3.v median_filter_top.v tb_image_median.v
vsim -c work.tb_image_median -do "run -all; quit -f"
