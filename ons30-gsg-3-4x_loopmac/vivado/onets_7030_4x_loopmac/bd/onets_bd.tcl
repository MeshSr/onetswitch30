
################################################################
# This is a generated script based on design: onets_bd
#
# Though there are limitations about the generated script,
# the main purpose of this utility is to make learning
# IP Integrator Tcl commands easier.
################################################################

################################################################
# Check if script is running in correct Vivado version.
################################################################
set scripts_vivado_version 2013.4
set current_vivado_version [version -short]

if { [string first $scripts_vivado_version $current_vivado_version] == -1 } {
   puts ""
   puts "ERROR: This script was generated using Vivado <$scripts_vivado_version> and is being run in <$current_vivado_version> of Vivado. Please run the script in Vivado <$scripts_vivado_version> then open the design in Vivado <$current_vivado_version>. Upgrade the design by running \"Tools => Report => Report IP Status...\", then run write_bd_tcl to create an updated script."

   return 1
}

################################################################
# START
################################################################

# To test this script, run the following commands from Vivado Tcl console:
# source onets_bd_script.tcl

# If you do not already have a project created,
# you can create a project using the following command:
#    create_project project_1 myproj -part xc7z030sbg485-2


# CHANGE DESIGN NAME HERE
set design_name onets_bd

# If you do not already have an existing IP Integrator design open,
# you can create a design using the following command:
#    create_bd_design $design_name

# CHECKING IF PROJECT EXISTS
if { [get_projects -quiet] eq "" } {
   puts "ERROR: Please open or create a project!"
   return 1
}


# Creating design if needed
set errMsg ""
set nRet 0

set cur_design [current_bd_design -quiet]
if { ${design_name} ne "" && ${cur_design} eq ${design_name} } {
   # Checks if design is empty or not
   set list_cells [get_bd_cells -quiet]

   if { $list_cells ne "" } {
      set errMsg "ERROR: Design <$design_name> already exists in your project, please set the variable <design_name> to another value."
      set nRet 1
   } else {
      puts "INFO: Constructing design in IPI design <$design_name>..."
   }
} else {

   if { [get_files -quiet ${design_name}.bd] eq "" } {
      puts "INFO: Currently there is no design <$design_name> in project, so creating one..."

      create_bd_design $design_name

      puts "INFO: Making design <$design_name> as current_bd_design."
      current_bd_design $design_name

   } else {
      set errMsg "ERROR: Design <$design_name> already exists in your project, please set the variable <design_name> to another value."
      set nRet 3
   }

}

puts "INFO: Currently the variable <design_name> is equal to \"$design_name\"."

if { $nRet != 0 } {
   puts $errMsg
   return $nRet
}

##################################################################
# DESIGN PROCs
##################################################################



# Procedure to create entire design; Provide argument to make
# procedure reusable. If parentCell is "", will use root.
proc create_root_design { parentCell } {

  if { $parentCell eq "" } {
     set parentCell [get_bd_cells /]
  }

  # Get object for parentCell
  set parentObj [get_bd_cells $parentCell]
  if { $parentObj == "" } {
     puts "ERROR: Unable to find parent cell <$parentCell>!"
     return
  }

  # Make sure parentObj is hier blk
  set parentType [get_property TYPE $parentObj]
  if { $parentType ne "hier" } {
     puts "ERROR: Parent <$parentObj> has TYPE = <$parentType>. Expected to be <hier>."
     return
  }

  # Save current instance; Restore later
  set oldCurInst [current_bd_instance .]

  # Set parent object as current
  current_bd_instance $parentObj


  # Create interface ports
  set DDR [ create_bd_intf_port -mode Master -vlnv xilinx.com:interface:ddrx_rtl:1.0 DDR ]
  set FIXED_IO [ create_bd_intf_port -mode Master -vlnv xilinx.com:display_processing_system7:fixedio_rtl:1.0 FIXED_IO ]
  set mdio [ create_bd_intf_port -mode Master -vlnv xilinx.com:interface:mdio_io:1.0 mdio ]
  set sgmii_0 [ create_bd_intf_port -mode Master -vlnv xilinx.com:interface:sgmii_rtl:1.0 sgmii_0 ]
  set sgmii_1 [ create_bd_intf_port -mode Master -vlnv xilinx.com:interface:sgmii_rtl:1.0 sgmii_1 ]
  set sgmii_2 [ create_bd_intf_port -mode Master -vlnv xilinx.com:interface:sgmii_rtl:1.0 sgmii_2 ]
  set sgmii_3 [ create_bd_intf_port -mode Master -vlnv xilinx.com:interface:sgmii_rtl:1.0 sgmii_3 ]

  # Create ports
  set bd_aresetn [ create_bd_port -dir O -from 0 -to 0 -type rst bd_aresetn ]
  set bd_fclk0_125m [ create_bd_port -dir O -type clk bd_fclk0_125m ]
  set bd_fclk1_75m [ create_bd_port -dir O -type clk bd_fclk1_75m ]
  set bd_fclk2_200m [ create_bd_port -dir O -type clk bd_fclk2_200m ]
  set ext_rst [ create_bd_port -dir I -type rst ext_rst ]
  set ref_clk_125_n [ create_bd_port -dir I -type clk ref_clk_125_n ]
  set_property -dict [ list CONFIG.FREQ_HZ {125000000} CONFIG.PHASE {0}  ] $ref_clk_125_n
  set ref_clk_125_p [ create_bd_port -dir I -type clk ref_clk_125_p ]

  # Create instance: axi_ethernet_0, and set properties
  set axi_ethernet_0 [ create_bd_cell -type ip -vlnv xilinx.com:ip:axi_ethernet:6.0 axi_ethernet_0 ]
  set_property -dict [ list CONFIG.ENABLE_LVDS {true} CONFIG.PHYADDR {5} CONFIG.PHY_TYPE {SGMII} CONFIG.Statistics_Counters {true} CONFIG.Statistics_Reset {false} CONFIG.Statistics_Width {32bit}  ] $axi_ethernet_0

  # Create instance: axi_ethernet_1, and set properties
  set axi_ethernet_1 [ create_bd_cell -type ip -vlnv xilinx.com:ip:axi_ethernet:6.0 axi_ethernet_1 ]
  set_property -dict [ list CONFIG.ENABLE_LVDS {true} CONFIG.PHYADDR {5} CONFIG.PHY_TYPE {SGMII} CONFIG.Statistics_Counters {true} CONFIG.Statistics_Reset {false} CONFIG.Statistics_Width {32bit} CONFIG.SupportLevel {0}  ] $axi_ethernet_1

  # Create instance: axi_ethernet_2, and set properties
  set axi_ethernet_2 [ create_bd_cell -type ip -vlnv xilinx.com:ip:axi_ethernet:6.0 axi_ethernet_2 ]
  set_property -dict [ list CONFIG.ENABLE_LVDS {true} CONFIG.PHYADDR {5} CONFIG.PHY_TYPE {SGMII} CONFIG.Statistics_Counters {true} CONFIG.Statistics_Reset {false} CONFIG.Statistics_Width {32bit} CONFIG.SupportLevel {0}  ] $axi_ethernet_2

  # Create instance: axi_ethernet_3, and set properties
  set axi_ethernet_3 [ create_bd_cell -type ip -vlnv xilinx.com:ip:axi_ethernet:6.0 axi_ethernet_3 ]
  set_property -dict [ list CONFIG.ENABLE_LVDS {true} CONFIG.PHYADDR {5} CONFIG.PHY_TYPE {SGMII} CONFIG.Statistics_Counters {true} CONFIG.Statistics_Reset {false} CONFIG.Statistics_Width {32bit} CONFIG.SupportLevel {0}  ] $axi_ethernet_3

  # Create instance: axi_interconnect_0, and set properties
  set axi_interconnect_0 [ create_bd_cell -type ip -vlnv xilinx.com:ip:axi_interconnect:2.1 axi_interconnect_0 ]
  set_property -dict [ list CONFIG.NUM_MI {4}  ] $axi_interconnect_0

  # Create instance: const_vcc, and set properties
  set const_vcc [ create_bd_cell -type ip -vlnv xilinx.com:ip:xlconstant:1.0 const_vcc ]

  # Create instance: proc_sys_reset_0, and set properties
  set proc_sys_reset_0 [ create_bd_cell -type ip -vlnv xilinx.com:ip:proc_sys_reset:5.0 proc_sys_reset_0 ]

  # Create instance: processing_system7_0, and set properties
  set processing_system7_0 [ create_bd_cell -type ip -vlnv xilinx.com:ip:processing_system7:5.3 processing_system7_0 ]
  set_property -dict [ list CONFIG.PCW_ENET0_ENET0_IO {MIO 16 .. 27} CONFIG.PCW_ENET0_GRP_MDIO_ENABLE {1} CONFIG.PCW_ENET0_PERIPHERAL_ENABLE {1} CONFIG.PCW_ENET0_PERIPHERAL_FREQMHZ {1000 Mbps} CONFIG.PCW_ENET0_RESET_ENABLE {1} CONFIG.PCW_ENET0_RESET_IO {MIO 10} CONFIG.PCW_EN_CLK1_PORT {1} CONFIG.PCW_EN_CLK2_PORT {1} CONFIG.PCW_FPGA0_PERIPHERAL_FREQMHZ {125} CONFIG.PCW_FPGA1_PERIPHERAL_FREQMHZ {75} CONFIG.PCW_FPGA2_PERIPHERAL_FREQMHZ {200} CONFIG.PCW_GPIO_MIO_GPIO_ENABLE {1} CONFIG.PCW_IRQ_F2P_INTR {1} CONFIG.PCW_MIO_0_PULLUP {disabled} CONFIG.PCW_MIO_10_PULLUP {disabled} CONFIG.PCW_MIO_11_PULLUP {disabled} CONFIG.PCW_MIO_12_PULLUP {disabled} CONFIG.PCW_MIO_13_PULLUP {disabled} CONFIG.PCW_MIO_14_PULLUP {disabled} CONFIG.PCW_MIO_15_PULLUP {disabled} CONFIG.PCW_MIO_16_PULLUP {disabled} CONFIG.PCW_MIO_17_PULLUP {disabled} CONFIG.PCW_MIO_18_PULLUP {disabled} CONFIG.PCW_MIO_19_PULLUP {disabled} CONFIG.PCW_MIO_1_PULLUP {disabled} CONFIG.PCW_MIO_20_PULLUP {disabled} CONFIG.PCW_MIO_21_PULLUP {disabled} CONFIG.PCW_MIO_22_PULLUP {disabled} CONFIG.PCW_MIO_23_PULLUP {disabled} CONFIG.PCW_MIO_24_PULLUP {disabled} CONFIG.PCW_MIO_25_PULLUP {disabled} CONFIG.PCW_MIO_26_PULLUP {disabled} CONFIG.PCW_MIO_27_PULLUP {disabled} CONFIG.PCW_MIO_28_PULLUP {disabled} CONFIG.PCW_MIO_29_PULLUP {disabled} CONFIG.PCW_MIO_30_PULLUP {disabled} CONFIG.PCW_MIO_31_PULLUP {disabled} CONFIG.PCW_MIO_32_PULLUP {disabled} CONFIG.PCW_MIO_33_PULLUP {disabled} CONFIG.PCW_MIO_34_PULLUP {disabled} CONFIG.PCW_MIO_35_PULLUP {disabled} CONFIG.PCW_MIO_36_PULLUP {disabled} CONFIG.PCW_MIO_37_PULLUP {disabled} CONFIG.PCW_MIO_38_PULLUP {disabled} CONFIG.PCW_MIO_39_PULLUP {disabled} CONFIG.PCW_MIO_40_PULLUP {disabled} CONFIG.PCW_MIO_41_PULLUP {disabled} CONFIG.PCW_MIO_42_PULLUP {disabled} CONFIG.PCW_MIO_43_PULLUP {disabled} CONFIG.PCW_MIO_44_PULLUP {disabled} CONFIG.PCW_MIO_45_PULLUP {disabled} CONFIG.PCW_MIO_46_PULLUP {disabled} CONFIG.PCW_MIO_47_PULLUP {disabled} CONFIG.PCW_MIO_48_PULLUP {disabled} CONFIG.PCW_MIO_49_PULLUP {disabled} CONFIG.PCW_MIO_50_PULLUP {disabled} CONFIG.PCW_MIO_51_PULLUP {disabled} CONFIG.PCW_MIO_52_PULLUP {disabled} CONFIG.PCW_MIO_53_PULLUP {disabled} CONFIG.PCW_MIO_9_PULLUP {disabled} CONFIG.PCW_PRESET_BANK1_VOLTAGE {LVCMOS 2.5V} CONFIG.PCW_QSPI_GRP_FBCLK_ENABLE {1} CONFIG.PCW_QSPI_PERIPHERAL_ENABLE {1} CONFIG.PCW_SD0_GRP_CD_ENABLE {1} CONFIG.PCW_SD0_GRP_CD_IO {MIO 14} CONFIG.PCW_SD0_PERIPHERAL_ENABLE {1} CONFIG.PCW_SDIO_PERIPHERAL_FREQMHZ {50} CONFIG.PCW_TTC0_PERIPHERAL_ENABLE {1} CONFIG.PCW_TTC1_PERIPHERAL_ENABLE {0} CONFIG.PCW_UART0_PERIPHERAL_ENABLE {1} CONFIG.PCW_UART0_UART0_IO {MIO 50 .. 51} CONFIG.PCW_UIPARAM_DDR_PARTNO {MT41J256M16 RE-125} CONFIG.PCW_UIPARAM_DDR_USE_INTERNAL_VREF {1} CONFIG.PCW_USB0_PERIPHERAL_ENABLE {1} CONFIG.PCW_USB0_RESET_ENABLE {1} CONFIG.PCW_USB0_RESET_IO {MIO 9} CONFIG.PCW_USE_FABRIC_INTERRUPT {1} CONFIG.PCW_USE_M_AXI_GP0 {1} CONFIG.PCW_WDT_PERIPHERAL_ENABLE {0}  ] $processing_system7_0

  # Create instance: xlconcat_0, and set properties
  set xlconcat_0 [ create_bd_cell -type ip -vlnv xilinx.com:ip:xlconcat:1.0 xlconcat_0 ]
  set_property -dict [ list CONFIG.NUM_PORTS {4}  ] $xlconcat_0

  # Create interface connections
  connect_bd_intf_net -intf_net S00_AXI_1 [get_bd_intf_pins axi_interconnect_0/S00_AXI] [get_bd_intf_pins processing_system7_0/M_AXI_GP0]
  connect_bd_intf_net -intf_net axi_ethernet_0_m_axis_rxd [get_bd_intf_pins axi_ethernet_0/m_axis_rxd] [get_bd_intf_pins axi_ethernet_1/s_axis_txd]
  connect_bd_intf_net -intf_net axi_ethernet_0_m_axis_rxs [get_bd_intf_pins axi_ethernet_0/m_axis_rxs] [get_bd_intf_pins axi_ethernet_1/s_axis_txc]
  connect_bd_intf_net -intf_net axi_ethernet_0_mdio [get_bd_intf_ports mdio] [get_bd_intf_pins axi_ethernet_0/mdio]
  connect_bd_intf_net -intf_net axi_ethernet_0_sgmii [get_bd_intf_ports sgmii_0] [get_bd_intf_pins axi_ethernet_0/sgmii]
  connect_bd_intf_net -intf_net axi_ethernet_1_m_axis_rxd [get_bd_intf_pins axi_ethernet_0/s_axis_txd] [get_bd_intf_pins axi_ethernet_1/m_axis_rxd]
  connect_bd_intf_net -intf_net axi_ethernet_1_sgmii [get_bd_intf_ports sgmii_1] [get_bd_intf_pins axi_ethernet_1/sgmii]
  connect_bd_intf_net -intf_net axi_ethernet_2_m_axis_rxd [get_bd_intf_pins axi_ethernet_2/m_axis_rxd] [get_bd_intf_pins axi_ethernet_3/s_axis_txd]
  connect_bd_intf_net -intf_net axi_ethernet_2_m_axis_rxs [get_bd_intf_pins axi_ethernet_2/m_axis_rxs] [get_bd_intf_pins axi_ethernet_3/s_axis_txc]
  connect_bd_intf_net -intf_net axi_ethernet_2_sgmii [get_bd_intf_ports sgmii_2] [get_bd_intf_pins axi_ethernet_2/sgmii]
  connect_bd_intf_net -intf_net axi_ethernet_3_m_axis_rxd [get_bd_intf_pins axi_ethernet_2/s_axis_txd] [get_bd_intf_pins axi_ethernet_3/m_axis_rxd]
  connect_bd_intf_net -intf_net axi_ethernet_3_sgmii [get_bd_intf_ports sgmii_3] [get_bd_intf_pins axi_ethernet_3/sgmii]
  connect_bd_intf_net -intf_net axi_interconnect_0_M00_AXI [get_bd_intf_pins axi_ethernet_0/s_axi] [get_bd_intf_pins axi_interconnect_0/M00_AXI]
  connect_bd_intf_net -intf_net axi_interconnect_0_M01_AXI [get_bd_intf_pins axi_ethernet_1/s_axi] [get_bd_intf_pins axi_interconnect_0/M01_AXI]
  connect_bd_intf_net -intf_net axi_interconnect_0_M02_AXI [get_bd_intf_pins axi_ethernet_2/s_axi] [get_bd_intf_pins axi_interconnect_0/M02_AXI]
  connect_bd_intf_net -intf_net axi_interconnect_0_M03_AXI [get_bd_intf_pins axi_ethernet_3/s_axi] [get_bd_intf_pins axi_interconnect_0/M03_AXI]
  connect_bd_intf_net -intf_net processing_system7_0_DDR [get_bd_intf_ports DDR] [get_bd_intf_pins processing_system7_0/DDR]
  connect_bd_intf_net -intf_net processing_system7_0_FIXED_IO [get_bd_intf_ports FIXED_IO] [get_bd_intf_pins processing_system7_0/FIXED_IO]
  connect_bd_intf_net -intf_net s_axis_txc_1 [get_bd_intf_pins axi_ethernet_2/s_axis_txc] [get_bd_intf_pins axi_ethernet_3/m_axis_rxs]
  connect_bd_intf_net -intf_net s_axis_txc_2 [get_bd_intf_pins axi_ethernet_0/s_axis_txc] [get_bd_intf_pins axi_ethernet_1/m_axis_rxs]

  # Create port connections
  connect_bd_net -net axi_ethernet_0_clk104_out [get_bd_pins axi_ethernet_0/clk104_out] [get_bd_pins axi_ethernet_1/clk104] [get_bd_pins axi_ethernet_2/clk104] [get_bd_pins axi_ethernet_3/clk104]
  connect_bd_net -net axi_ethernet_0_clk125_out [get_bd_pins axi_ethernet_0/clk125_out] [get_bd_pins axi_ethernet_1/clk125m] [get_bd_pins axi_ethernet_2/clk125m] [get_bd_pins axi_ethernet_3/clk125m]
  connect_bd_net -net axi_ethernet_0_clk208_out [get_bd_pins axi_ethernet_0/clk208_out] [get_bd_pins axi_ethernet_1/clk208] [get_bd_pins axi_ethernet_2/clk208] [get_bd_pins axi_ethernet_3/clk208]
  connect_bd_net -net axi_ethernet_0_clk625_out [get_bd_pins axi_ethernet_0/clk625_out] [get_bd_pins axi_ethernet_1/clk625] [get_bd_pins axi_ethernet_2/clk625] [get_bd_pins axi_ethernet_3/clk625]
  connect_bd_net -net axi_ethernet_0_interrupt [get_bd_pins axi_ethernet_0/interrupt] [get_bd_pins xlconcat_0/In0]
  connect_bd_net -net axi_ethernet_0_mmcm_locked_out [get_bd_pins axi_ethernet_0/mmcm_locked_out] [get_bd_pins axi_ethernet_1/mmcm_locked] [get_bd_pins axi_ethernet_2/mmcm_locked] [get_bd_pins axi_ethernet_3/mmcm_locked]
  connect_bd_net -net axi_ethernet_1_interrupt [get_bd_pins axi_ethernet_1/interrupt] [get_bd_pins xlconcat_0/In1]
  connect_bd_net -net axi_ethernet_2_interrupt [get_bd_pins axi_ethernet_2/interrupt] [get_bd_pins xlconcat_0/In2]
  connect_bd_net -net axi_ethernet_3_interrupt [get_bd_pins axi_ethernet_3/interrupt] [get_bd_pins xlconcat_0/In3]
  connect_bd_net -net const_vcc_const [get_bd_pins axi_ethernet_0/signal_detect] [get_bd_pins axi_ethernet_1/signal_detect] [get_bd_pins axi_ethernet_2/signal_detect] [get_bd_pins axi_ethernet_3/signal_detect] [get_bd_pins const_vcc/const] [get_bd_pins proc_sys_reset_0/dcm_locked] 
  connect_bd_net -net ext_reset_in_1 [get_bd_ports ext_rst] [get_bd_pins proc_sys_reset_0/ext_reset_in]
  connect_bd_net -net proc_sys_reset_0_peripheral_aresetn [get_bd_ports bd_aresetn] [get_bd_pins axi_ethernet_0/axi_rxd_arstn] [get_bd_pins axi_ethernet_0/axi_rxs_arstn] [get_bd_pins axi_ethernet_0/axi_txc_arstn] [get_bd_pins axi_ethernet_0/axi_txd_arstn] [get_bd_pins axi_ethernet_0/s_axi_lite_resetn] [get_bd_pins axi_ethernet_1/axi_rxd_arstn] [get_bd_pins axi_ethernet_1/axi_rxs_arstn] [get_bd_pins axi_ethernet_1/axi_txc_arstn] [get_bd_pins axi_ethernet_1/axi_txd_arstn] [get_bd_pins axi_ethernet_1/s_axi_lite_resetn] [get_bd_pins axi_ethernet_2/axi_rxd_arstn] [get_bd_pins axi_ethernet_2/axi_rxs_arstn] [get_bd_pins axi_ethernet_2/axi_txc_arstn] [get_bd_pins axi_ethernet_2/axi_txd_arstn] [get_bd_pins axi_ethernet_2/s_axi_lite_resetn] [get_bd_pins axi_ethernet_3/axi_rxd_arstn] [get_bd_pins axi_ethernet_3/axi_rxs_arstn] [get_bd_pins axi_ethernet_3/axi_txc_arstn] [get_bd_pins axi_ethernet_3/axi_txd_arstn] [get_bd_pins axi_ethernet_3/s_axi_lite_resetn] [get_bd_pins axi_interconnect_0/ARESETN] [get_bd_pins axi_interconnect_0/M00_ARESETN] [get_bd_pins axi_interconnect_0/M01_ARESETN] [get_bd_pins axi_interconnect_0/M02_ARESETN] [get_bd_pins axi_interconnect_0/M03_ARESETN] [get_bd_pins axi_interconnect_0/S00_ARESETN] [get_bd_pins proc_sys_reset_0/peripheral_aresetn]
  connect_bd_net -net processing_system7_0_FCLK_CLK0 [get_bd_ports bd_fclk0_125m] [get_bd_pins axi_ethernet_0/axis_clk] [get_bd_pins axi_ethernet_0/s_axi_lite_clk] [get_bd_pins axi_ethernet_1/axis_clk] [get_bd_pins axi_ethernet_1/s_axi_lite_clk] [get_bd_pins axi_ethernet_2/axis_clk] [get_bd_pins axi_ethernet_2/s_axi_lite_clk] [get_bd_pins axi_ethernet_3/axis_clk] [get_bd_pins axi_ethernet_3/s_axi_lite_clk] [get_bd_pins axi_interconnect_0/ACLK] [get_bd_pins axi_interconnect_0/M00_ACLK] [get_bd_pins axi_interconnect_0/M01_ACLK] [get_bd_pins axi_interconnect_0/M02_ACLK] [get_bd_pins axi_interconnect_0/M03_ACLK] [get_bd_pins axi_interconnect_0/S00_ACLK] [get_bd_pins proc_sys_reset_0/slowest_sync_clk] [get_bd_pins processing_system7_0/FCLK_CLK0] [get_bd_pins processing_system7_0/M_AXI_GP0_ACLK]
  connect_bd_net -net processing_system7_0_FCLK_CLK1 [get_bd_ports bd_fclk1_75m] [get_bd_pins processing_system7_0/FCLK_CLK1]
  connect_bd_net -net processing_system7_0_FCLK_CLK2 [get_bd_ports bd_fclk2_200m] [get_bd_pins processing_system7_0/FCLK_CLK2]
  connect_bd_net -net processing_system7_0_FCLK_RESET0_N [get_bd_pins proc_sys_reset_0/aux_reset_in] [get_bd_pins processing_system7_0/FCLK_RESET0_N]
  connect_bd_net -net ref_clk_125_n_1 [get_bd_ports ref_clk_125_n] [get_bd_pins axi_ethernet_0/ref_clk_125_n]
  connect_bd_net -net ref_clk_125_p_1 [get_bd_ports ref_clk_125_p] [get_bd_pins axi_ethernet_0/ref_clk_125_p]
  connect_bd_net -net rst_125_1 [get_bd_pins axi_ethernet_0/rst_125_out] [get_bd_pins axi_ethernet_1/rst_125] [get_bd_pins axi_ethernet_2/rst_125] [get_bd_pins axi_ethernet_3/rst_125]
  connect_bd_net -net xlconcat_0_dout [get_bd_pins processing_system7_0/IRQ_F2P] [get_bd_pins xlconcat_0/dout]

  # Create address segments
  create_bd_addr_seg -range 0x1000 -offset 0x0 [get_bd_addr_spaces axi_ethernet_0/eth_buf/S_AXI_2TEMAC] [get_bd_addr_segs axi_ethernet_0/eth_mac/s_axi/Reg] SEG_eth_mac_Reg
  create_bd_addr_seg -range 0x1000 -offset 0x0 [get_bd_addr_spaces axi_ethernet_1/eth_buf/S_AXI_2TEMAC] [get_bd_addr_segs axi_ethernet_1/eth_mac/s_axi/Reg] SEG_eth_mac_Reg
  create_bd_addr_seg -range 0x1000 -offset 0x0 [get_bd_addr_spaces axi_ethernet_2/eth_buf/S_AXI_2TEMAC] [get_bd_addr_segs axi_ethernet_2/eth_mac/s_axi/Reg] SEG_eth_mac_Reg
  create_bd_addr_seg -range 0x1000 -offset 0x0 [get_bd_addr_spaces axi_ethernet_3/eth_buf/S_AXI_2TEMAC] [get_bd_addr_segs axi_ethernet_3/eth_mac/s_axi/Reg] SEG_eth_mac_Reg
  create_bd_addr_seg -range 0x40000 -offset 0x43C00000 [get_bd_addr_spaces processing_system7_0/Data] [get_bd_addr_segs axi_ethernet_0/eth_buf/S_AXI/REG] SEG_eth_buf_REG
  create_bd_addr_seg -range 0x40000 -offset 0x43C40000 [get_bd_addr_spaces processing_system7_0/Data] [get_bd_addr_segs axi_ethernet_1/eth_buf/S_AXI/REG] SEG_eth_buf_REG2
  create_bd_addr_seg -range 0x40000 -offset 0x43C80000 [get_bd_addr_spaces processing_system7_0/Data] [get_bd_addr_segs axi_ethernet_2/eth_buf/S_AXI/REG] SEG_eth_buf_REG4
  create_bd_addr_seg -range 0x40000 -offset 0x43CC0000 [get_bd_addr_spaces processing_system7_0/Data] [get_bd_addr_segs axi_ethernet_3/eth_buf/S_AXI/REG] SEG_eth_buf_REG6
  

  # Restore current instance
  current_bd_instance $oldCurInst

  save_bd_design
}
# End of create_root_design()


##################################################################
# MAIN FLOW
##################################################################

create_root_design ""


