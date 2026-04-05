# GUI waveform - chay tu ModelSim GUI (File -> Do)
vlib work
vlog -work work swap.v sort3.v median_filter.v window3x3.v median_filter_top.v tb_image_median.v
vsim work.tb_image_median

add wave -divider "Control"
add wave -radix binary   sim:/tb_image_median/clk
add wave -radix binary   sim:/tb_image_median/rst_n
add wave -radix binary   sim:/tb_image_median/valid_in
add wave -radix binary   sim:/tb_image_median/valid_out

add wave -divider "Input window"
add wave -radix unsigned sim:/tb_image_median/in1
add wave -radix unsigned sim:/tb_image_median/in5
add wave -radix unsigned sim:/tb_image_median/in9

add wave -divider "Output"
add wave -radix unsigned sim:/tb_image_median/median

run 2000ns
