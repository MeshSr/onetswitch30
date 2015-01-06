############################################################
## Timing Constraints
############################################################
set_false_path -from [get_clocks clk_fpga_1] -to [get_clocks clk_fpga_0]
## set_false_path -from [get_clocks clk_fpga_1] -to [get_clocks clk_fpga_2]
