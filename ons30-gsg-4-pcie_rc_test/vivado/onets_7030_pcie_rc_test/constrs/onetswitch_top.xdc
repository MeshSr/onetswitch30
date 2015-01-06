############################################################
## Timing Constraints
############################################################
#set_false_path -from [get_clocks clk_fpga_1] -to [get_clocks clk_fpga_0]
#set_false_path -from [get_clocks clk_fpga_1] -to [get_clocks clk_fpga_2]
set_false_path -from [get_cells {*ACTIVE_LOW_PR_OUT_DFF[0].peripheral_aresetn_reg[0]*} -hierarchical]
create_clock -period 10.000 -name gtx_pcie_clk_100m [get_nets gtx_pcie_clk_100m_p]