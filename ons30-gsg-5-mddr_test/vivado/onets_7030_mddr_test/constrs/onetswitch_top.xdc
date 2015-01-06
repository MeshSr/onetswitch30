############################################################
## Timing Constraints
############################################################
#set_false_path -from [get_clocks clk_fpga_1] -to [get_clocks clk_fpga_0]
#set_false_path -from [get_clocks clk_fpga_1] -to [get_clocks clk_fpga_2]
set_false_path -from [get_pins {i_onets_bd_wrapper/onets_bd_i/proc_sys_reset_0/U0/ACTIVE_LOW_PR_OUT_DFF[0].peripheral_aresetn_reg[0]/C}] -to *

#set_false_path -from [get_pins i_onets_bd_wrapper/onets_bd_i/mig_7series_0/u_onets_bd_mig_7series_0_0_mig/u_memc_ui_top_axi/mem_intfc0/ddr_phy_top0/u_ddr_mc_phy_wrapper/u_ddr_mc_phy/ddr_phy_4lanes_1.u_ddr_phy_4lanes/ddr_byte_lane_A.ddr_byte_lane_A/phaser_out/OCLK] -to [get_pins {i_onets_bd_wrapper/onets_bd_i/mig_7series_0/u_onets_bd_mig_7series_0_0_mig/u_memc_ui_top_axi/mem_intfc0/ddr_phy_top0/u_ddr_mc_phy_wrapper/u_ddr_mc_phy/ddr_phy_4lanes_1.u_ddr_phy_4lanes/ddr_byte_lane_A.ddr_byte_lane_A/ddr_byte_group_io/output_[*].oserdes_dq_.sdr.oserdes_dq_i/RST}]
set_false_path -from [get_pins i_onets_bd_wrapper/onets_bd_i/mig_7series_0/u_onets_bd_mig_7series_0_0_mig/u_memc_ui_top_axi/mem_intfc0/ddr_phy_top0/u_ddr_mc_phy_wrapper/u_ddr_mc_phy/ddr_phy_4lanes_1.u_ddr_phy_4lanes/ddr_byte_lane_B.ddr_byte_lane_B/phaser_out/OCLK] -to [get_pins {i_onets_bd_wrapper/onets_bd_i/mig_7series_0/u_onets_bd_mig_7series_0_0_mig/u_memc_ui_top_axi/mem_intfc0/ddr_phy_top0/u_ddr_mc_phy_wrapper/u_ddr_mc_phy/ddr_phy_4lanes_1.u_ddr_phy_4lanes/ddr_byte_lane_B.ddr_byte_lane_B/ddr_byte_group_io/output_[*].oserdes_dq_.sdr.oserdes_dq_i/RST}]
set_false_path -from [get_pins i_onets_bd_wrapper/onets_bd_i/mig_7series_0/u_onets_bd_mig_7series_0_0_mig/u_memc_ui_top_axi/mem_intfc0/ddr_phy_top0/u_ddr_mc_phy_wrapper/u_ddr_mc_phy/ddr_phy_4lanes_1.u_ddr_phy_4lanes/ddr_byte_lane_C.ddr_byte_lane_C/phaser_out/OCLK] -to [get_pins {i_onets_bd_wrapper/onets_bd_i/mig_7series_0/u_onets_bd_mig_7series_0_0_mig/u_memc_ui_top_axi/mem_intfc0/ddr_phy_top0/u_ddr_mc_phy_wrapper/u_ddr_mc_phy/ddr_phy_4lanes_1.u_ddr_phy_4lanes/ddr_byte_lane_C.ddr_byte_lane_C/ddr_byte_group_io/output_[*].oserdes_dq_.sdr.oserdes_dq_i/RST}]
set_false_path -from [get_pins i_onets_bd_wrapper/onets_bd_i/mig_7series_0/u_onets_bd_mig_7series_0_0_mig/u_memc_ui_top_axi/mem_intfc0/ddr_phy_top0/u_ddr_mc_phy_wrapper/u_ddr_mc_phy/ddr_phy_4lanes_1.u_ddr_phy_4lanes/ddr_byte_lane_D.ddr_byte_lane_D/phaser_out/OCLK] -to [get_pins {i_onets_bd_wrapper/onets_bd_i/mig_7series_0/u_onets_bd_mig_7series_0_0_mig/u_memc_ui_top_axi/mem_intfc0/ddr_phy_top0/u_ddr_mc_phy_wrapper/u_ddr_mc_phy/ddr_phy_4lanes_1.u_ddr_phy_4lanes/ddr_byte_lane_D.ddr_byte_lane_D/ddr_byte_group_io/output_[*].oserdes_dq_.sdr.oserdes_dq_i/RST}]
set_false_path -from [get_pins i_onets_bd_wrapper/onets_bd_i/mig_7series_0/u_onets_bd_mig_7series_0_0_mig/u_memc_ui_top_axi/mem_intfc0/ddr_phy_top0/u_ddr_mc_phy_wrapper/u_ddr_mc_phy/ddr_phy_4lanes_0.u_ddr_phy_4lanes/ddr_byte_lane_A.ddr_byte_lane_A/phaser_out/OCLK] -to [get_pins {i_onets_bd_wrapper/onets_bd_i/mig_7series_0/u_onets_bd_mig_7series_0_0_mig/u_memc_ui_top_axi/mem_intfc0/ddr_phy_top0/u_ddr_mc_phy_wrapper/u_ddr_mc_phy/ddr_phy_4lanes_0.u_ddr_phy_4lanes/ddr_byte_lane_A.ddr_byte_lane_A/ddr_byte_group_io/output_[*].oserdes_dq_.ddr.oserdes_dq_i/RST}]
set_false_path -from [get_pins i_onets_bd_wrapper/onets_bd_i/mig_7series_0/u_onets_bd_mig_7series_0_0_mig/u_memc_ui_top_axi/mem_intfc0/ddr_phy_top0/u_ddr_mc_phy_wrapper/u_ddr_mc_phy/ddr_phy_4lanes_0.u_ddr_phy_4lanes/ddr_byte_lane_B.ddr_byte_lane_B/phaser_out/OCLK] -to [get_pins {i_onets_bd_wrapper/onets_bd_i/mig_7series_0/u_onets_bd_mig_7series_0_0_mig/u_memc_ui_top_axi/mem_intfc0/ddr_phy_top0/u_ddr_mc_phy_wrapper/u_ddr_mc_phy/ddr_phy_4lanes_0.u_ddr_phy_4lanes/ddr_byte_lane_B.ddr_byte_lane_B/ddr_byte_group_io/output_[*].oserdes_dq_.ddr.oserdes_dq_i/RST}]
set_false_path -from [get_pins i_onets_bd_wrapper/onets_bd_i/mig_7series_0/u_onets_bd_mig_7series_0_0_mig/u_memc_ui_top_axi/mem_intfc0/ddr_phy_top0/u_ddr_mc_phy_wrapper/u_ddr_mc_phy/ddr_phy_4lanes_0.u_ddr_phy_4lanes/ddr_byte_lane_C.ddr_byte_lane_C/phaser_out/OCLK] -to [get_pins {i_onets_bd_wrapper/onets_bd_i/mig_7series_0/u_onets_bd_mig_7series_0_0_mig/u_memc_ui_top_axi/mem_intfc0/ddr_phy_top0/u_ddr_mc_phy_wrapper/u_ddr_mc_phy/ddr_phy_4lanes_0.u_ddr_phy_4lanes/ddr_byte_lane_C.ddr_byte_lane_C/ddr_byte_group_io/output_[*].oserdes_dq_.ddr.oserdes_dq_i/RST}]
set_false_path -from [get_pins i_onets_bd_wrapper/onets_bd_i/mig_7series_0/u_onets_bd_mig_7series_0_0_mig/u_memc_ui_top_axi/mem_intfc0/ddr_phy_top0/u_ddr_mc_phy_wrapper/u_ddr_mc_phy/ddr_phy_4lanes_0.u_ddr_phy_4lanes/ddr_byte_lane_D.ddr_byte_lane_D/phaser_out/OCLK] -to [get_pins {i_onets_bd_wrapper/onets_bd_i/mig_7series_0/u_onets_bd_mig_7series_0_0_mig/u_memc_ui_top_axi/mem_intfc0/ddr_phy_top0/u_ddr_mc_phy_wrapper/u_ddr_mc_phy/ddr_phy_4lanes_0.u_ddr_phy_4lanes/ddr_byte_lane_D.ddr_byte_lane_D/ddr_byte_group_io/output_[*].oserdes_dq_.ddr.oserdes_dq_i/RST}]
set_false_path -from [get_pins i_onets_bd_wrapper/onets_bd_i/mig_7series_0/u_onets_bd_mig_7series_0_0_mig/u_memc_ui_top_axi/mem_intfc0/ddr_phy_top0/u_ddr_mc_phy_wrapper/u_ddr_mc_phy/ddr_phy_4lanes_0.u_ddr_phy_4lanes/ddr_byte_lane_A.ddr_byte_lane_A/phaser_out/OCLK] -to [get_pins i_onets_bd_wrapper/onets_bd_i/mig_7series_0/u_onets_bd_mig_7series_0_0_mig/u_memc_ui_top_axi/mem_intfc0/ddr_phy_top0/u_ddr_mc_phy_wrapper/u_ddr_mc_phy/ddr_phy_4lanes_0.u_ddr_phy_4lanes/ddr_byte_lane_A.ddr_byte_lane_A/ddr_byte_group_io/slave_ts.oserdes_slave_ts/RST]
set_false_path -from [get_pins i_onets_bd_wrapper/onets_bd_i/mig_7series_0/u_onets_bd_mig_7series_0_0_mig/u_memc_ui_top_axi/mem_intfc0/ddr_phy_top0/u_ddr_mc_phy_wrapper/u_ddr_mc_phy/ddr_phy_4lanes_0.u_ddr_phy_4lanes/ddr_byte_lane_B.ddr_byte_lane_B/phaser_out/OCLK] -to [get_pins i_onets_bd_wrapper/onets_bd_i/mig_7series_0/u_onets_bd_mig_7series_0_0_mig/u_memc_ui_top_axi/mem_intfc0/ddr_phy_top0/u_ddr_mc_phy_wrapper/u_ddr_mc_phy/ddr_phy_4lanes_0.u_ddr_phy_4lanes/ddr_byte_lane_B.ddr_byte_lane_B/ddr_byte_group_io/slave_ts.oserdes_slave_ts/RST]
set_false_path -from [get_pins i_onets_bd_wrapper/onets_bd_i/mig_7series_0/u_onets_bd_mig_7series_0_0_mig/u_memc_ui_top_axi/mem_intfc0/ddr_phy_top0/u_ddr_mc_phy_wrapper/u_ddr_mc_phy/ddr_phy_4lanes_0.u_ddr_phy_4lanes/ddr_byte_lane_C.ddr_byte_lane_C/phaser_out/OCLK] -to [get_pins i_onets_bd_wrapper/onets_bd_i/mig_7series_0/u_onets_bd_mig_7series_0_0_mig/u_memc_ui_top_axi/mem_intfc0/ddr_phy_top0/u_ddr_mc_phy_wrapper/u_ddr_mc_phy/ddr_phy_4lanes_0.u_ddr_phy_4lanes/ddr_byte_lane_C.ddr_byte_lane_C/ddr_byte_group_io/slave_ts.oserdes_slave_ts/RST]
set_false_path -from [get_pins i_onets_bd_wrapper/onets_bd_i/mig_7series_0/u_onets_bd_mig_7series_0_0_mig/u_memc_ui_top_axi/mem_intfc0/ddr_phy_top0/u_ddr_mc_phy_wrapper/u_ddr_mc_phy/ddr_phy_4lanes_0.u_ddr_phy_4lanes/ddr_byte_lane_D.ddr_byte_lane_D/phaser_out/OCLK] -to [get_pins i_onets_bd_wrapper/onets_bd_i/mig_7series_0/u_onets_bd_mig_7series_0_0_mig/u_memc_ui_top_axi/mem_intfc0/ddr_phy_top0/u_ddr_mc_phy_wrapper/u_ddr_mc_phy/ddr_phy_4lanes_0.u_ddr_phy_4lanes/ddr_byte_lane_D.ddr_byte_lane_D/ddr_byte_group_io/slave_ts.oserdes_slave_ts/RST]
set_false_path -reset_path -from [get_pins {i_onets_bd_wrapper/onets_bd_i/proc_sys_reset_0/U0/PR_OUT_DFF[0].peripheral_reset_reg[0]/C}]
set_false_path -reset_path -from [get_pins {i_onets_bd_wrapper/onets_bd_i/proc_sys_reset_0/U0/ACTIVE_LOW_PR_OUT_DFF[0].peripheral_aresetn_reg[0]/C}]


create_debug_core u_ila_0_0 labtools_ila_v3
set_property ALL_PROBE_SAME_MU true [get_debug_cores u_ila_0_0]
set_property ALL_PROBE_SAME_MU_CNT 1 [get_debug_cores u_ila_0_0]
set_property C_ADV_TRIGGER false [get_debug_cores u_ila_0_0]
set_property C_DATA_DEPTH 1024 [get_debug_cores u_ila_0_0]
set_property C_EN_STRG_QUAL false [get_debug_cores u_ila_0_0]
set_property C_INPUT_PIPE_STAGES 0 [get_debug_cores u_ila_0_0]
set_property C_TRIGIN_EN false [get_debug_cores u_ila_0_0]
set_property C_TRIGOUT_EN false [get_debug_cores u_ila_0_0]
set_property port_width 1 [get_debug_ports u_ila_0_0/clk]
connect_debug_port u_ila_0_0/clk [get_nets [list bd_fclk0_125m]]
set_property port_width 1 [get_debug_ports u_ila_0_0/probe0]
connect_debug_port u_ila_0_0/probe0 [get_nets [list {i_onets_bd_wrapper/onets_bd_i/proc_sys_reset_0/U0/peripheral_aresetn[0]}]]
create_debug_port u_ila_0_0 probe
set_property port_width 1 [get_debug_ports u_ila_0_0/probe1]
connect_debug_port u_ila_0_0/probe1 [get_nets [list i_onets_bd_wrapper/onets_bd_i/ext_rst]]
create_debug_port u_ila_0_0 probe
set_property port_width 1 [get_debug_ports u_ila_0_0/probe2]
connect_debug_port u_ila_0_0/probe2 [get_nets [list i_onets_bd_wrapper/onets_bd_i/mig_7series_0/init_calib_complete]]
create_debug_port u_ila_0_0 probe
set_property port_width 1 [get_debug_ports u_ila_0_0/probe3]
connect_debug_port u_ila_0_0/probe3 [get_nets [list i_onets_bd_wrapper/onets_bd_i/mig_7series_0/mmcm_locked]]
create_debug_port u_ila_0_0 probe
set_property port_width 1 [get_debug_ports u_ila_0_0/probe4]
connect_debug_port u_ila_0_0/probe4 [get_nets [list i_onets_bd_wrapper/onets_bd_i/mig_7series_0/ui_clk_sync_rst]]
set_property C_USER_SCAN_CHAIN 1 [get_debug_cores dbg_hub]
