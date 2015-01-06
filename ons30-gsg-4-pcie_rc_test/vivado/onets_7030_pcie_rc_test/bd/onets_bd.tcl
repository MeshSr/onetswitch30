
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
  set pcie_7x_mgt [ create_bd_intf_port -mode Master -vlnv xilinx.com:interface:pcie_7x_mgt_rtl:1.0 pcie_7x_mgt ]

  # Create ports
  set bd_aresetn [ create_bd_port -dir O -from 0 -to 0 -type rst bd_aresetn ]
  set bd_fclk0_125m [ create_bd_port -dir O -type clk bd_fclk0_125m ]
  set bd_fclk1_75m [ create_bd_port -dir O -type clk bd_fclk1_75m ]
  set bd_fclk2_200m [ create_bd_port -dir O -type clk bd_fclk2_200m ]
  set ext_rst [ create_bd_port -dir I -type rst ext_rst ]
  set pcie_dbg_clk [ create_bd_port -dir O -type clk pcie_dbg_clk ]
  set pcie_dbg_mmcm_lock [ create_bd_port -dir O pcie_dbg_mmcm_lock ]
  set pcie_msi_en [ create_bd_port -dir O pcie_msi_en ]
  set pcie_msi_gnt [ create_bd_port -dir O pcie_msi_gnt ]
  set pcie_msi_req [ create_bd_port -dir I pcie_msi_req ]
  set pcie_msi_vec_num [ create_bd_port -dir I -from 4 -to 0 pcie_msi_vec_num ]
  set pcie_msi_vec_width [ create_bd_port -dir O -from 2 -to 0 pcie_msi_vec_width ]
  set pcie_refclk [ create_bd_port -dir I -type clk pcie_refclk ]

  # Create instance: axi_ic_gp_m, and set properties
  set axi_ic_gp_m [ create_bd_cell -type ip -vlnv xilinx.com:ip:axi_interconnect:2.1 axi_ic_gp_m ]

  # Create instance: axi_ic_hp_s, and set properties
  set axi_ic_hp_s [ create_bd_cell -type ip -vlnv xilinx.com:ip:axi_interconnect:2.1 axi_ic_hp_s ]
  set_property -dict [ list CONFIG.NUM_MI {1}  ] $axi_ic_hp_s

  # Create instance: axi_pcie_0, and set properties
  set axi_pcie_0 [ create_bd_cell -type ip -vlnv xilinx.com:ip:axi_pcie:2.3 axi_pcie_0 ]
  set_property -dict [ list CONFIG.BAR0_SCALE {Gigabytes} CONFIG.CLASS_CODE {0x060400} CONFIG.COMP_TIMEOUT {50ms} CONFIG.INCLUDE_RC {Root_Port_of_PCI_Express_Root_Complex} CONFIG.PCIE_CAP_SLOT_IMPLEMENTED {true} CONFIG.SUB_CLASS_INTERFACE_MENU {PCI_to_PCI_bridge} CONFIG.S_AXI_SUPPORTS_NARROW_BURST {true}  ] $axi_pcie_0

  # Create instance: proc_sys_reset_0, and set properties
  set proc_sys_reset_0 [ create_bd_cell -type ip -vlnv xilinx.com:ip:proc_sys_reset:5.0 proc_sys_reset_0 ]

  # Create instance: processing_system7_0, and set properties
  set processing_system7_0 [ create_bd_cell -type ip -vlnv xilinx.com:ip:processing_system7:5.3 processing_system7_0 ]
  set_property -dict [ list CONFIG.PCW_ENET0_ENET0_IO {MIO 16 .. 27} CONFIG.PCW_ENET0_GRP_MDIO_ENABLE {1} CONFIG.PCW_ENET0_PERIPHERAL_ENABLE {1} CONFIG.PCW_ENET0_PERIPHERAL_FREQMHZ {1000 Mbps} CONFIG.PCW_ENET0_RESET_ENABLE {1} CONFIG.PCW_ENET0_RESET_IO {MIO 10} CONFIG.PCW_EN_CLK1_PORT {1} CONFIG.PCW_EN_CLK2_PORT {1} CONFIG.PCW_FPGA0_PERIPHERAL_FREQMHZ {125} CONFIG.PCW_FPGA1_PERIPHERAL_FREQMHZ {75} CONFIG.PCW_FPGA2_PERIPHERAL_FREQMHZ {200} CONFIG.PCW_GPIO_MIO_GPIO_ENABLE {1} CONFIG.PCW_IRQ_F2P_INTR {1} CONFIG.PCW_MIO_0_PULLUP {disabled} CONFIG.PCW_MIO_10_PULLUP {disabled} CONFIG.PCW_MIO_11_PULLUP {disabled} CONFIG.PCW_MIO_12_PULLUP {disabled} CONFIG.PCW_MIO_13_PULLUP {disabled} CONFIG.PCW_MIO_14_PULLUP {disabled} CONFIG.PCW_MIO_15_PULLUP {disabled} CONFIG.PCW_MIO_16_PULLUP {disabled} CONFIG.PCW_MIO_17_PULLUP {disabled} CONFIG.PCW_MIO_18_PULLUP {disabled} CONFIG.PCW_MIO_19_PULLUP {disabled} CONFIG.PCW_MIO_1_PULLUP {disabled} CONFIG.PCW_MIO_20_PULLUP {disabled} CONFIG.PCW_MIO_21_PULLUP {disabled} CONFIG.PCW_MIO_22_PULLUP {disabled} CONFIG.PCW_MIO_23_PULLUP {disabled} CONFIG.PCW_MIO_24_PULLUP {disabled} CONFIG.PCW_MIO_25_PULLUP {disabled} CONFIG.PCW_MIO_26_PULLUP {disabled} CONFIG.PCW_MIO_27_PULLUP {disabled} CONFIG.PCW_MIO_28_PULLUP {disabled} CONFIG.PCW_MIO_29_PULLUP {disabled} CONFIG.PCW_MIO_30_PULLUP {disabled} CONFIG.PCW_MIO_31_PULLUP {disabled} CONFIG.PCW_MIO_32_PULLUP {disabled} CONFIG.PCW_MIO_33_PULLUP {disabled} CONFIG.PCW_MIO_34_PULLUP {disabled} CONFIG.PCW_MIO_35_PULLUP {disabled} CONFIG.PCW_MIO_36_PULLUP {disabled} CONFIG.PCW_MIO_37_PULLUP {disabled} CONFIG.PCW_MIO_38_PULLUP {disabled} CONFIG.PCW_MIO_39_PULLUP {disabled} CONFIG.PCW_MIO_40_PULLUP {disabled} CONFIG.PCW_MIO_41_PULLUP {disabled} CONFIG.PCW_MIO_42_PULLUP {disabled} CONFIG.PCW_MIO_43_PULLUP {disabled} CONFIG.PCW_MIO_44_PULLUP {disabled} CONFIG.PCW_MIO_45_PULLUP {disabled} CONFIG.PCW_MIO_46_PULLUP {disabled} CONFIG.PCW_MIO_47_PULLUP {disabled} CONFIG.PCW_MIO_48_PULLUP {disabled} CONFIG.PCW_MIO_49_PULLUP {disabled} CONFIG.PCW_MIO_50_PULLUP {disabled} CONFIG.PCW_MIO_51_PULLUP {disabled} CONFIG.PCW_MIO_52_PULLUP {disabled} CONFIG.PCW_MIO_53_PULLUP {disabled} CONFIG.PCW_MIO_9_PULLUP {disabled} CONFIG.PCW_PRESET_BANK1_VOLTAGE {LVCMOS 2.5V} CONFIG.PCW_QSPI_GRP_FBCLK_ENABLE {1} CONFIG.PCW_QSPI_PERIPHERAL_ENABLE {1} CONFIG.PCW_SD0_GRP_CD_ENABLE {1} CONFIG.PCW_SD0_GRP_CD_IO {MIO 14} CONFIG.PCW_SD0_PERIPHERAL_ENABLE {1} CONFIG.PCW_SDIO_PERIPHERAL_FREQMHZ {50} CONFIG.PCW_TTC0_PERIPHERAL_ENABLE {1} CONFIG.PCW_TTC1_PERIPHERAL_ENABLE {0} CONFIG.PCW_UART0_PERIPHERAL_ENABLE {1} CONFIG.PCW_UART0_UART0_IO {MIO 50 .. 51} CONFIG.PCW_UIPARAM_DDR_PARTNO {MT41J256M16 RE-125} CONFIG.PCW_UIPARAM_DDR_USE_INTERNAL_VREF {1} CONFIG.PCW_USB0_PERIPHERAL_ENABLE {1} CONFIG.PCW_USB0_RESET_ENABLE {1} CONFIG.PCW_USB0_RESET_IO {MIO 9} CONFIG.PCW_USE_FABRIC_INTERRUPT {1} CONFIG.PCW_USE_M_AXI_GP0 {1} CONFIG.PCW_USE_S_AXI_HP0 {1} CONFIG.PCW_WDT_PERIPHERAL_ENABLE {0}  ] $processing_system7_0

  # Create interface connections
  connect_bd_intf_net -intf_net axi_ic_gp_m_M00_AXI [get_bd_intf_pins axi_ic_gp_m/M00_AXI] [get_bd_intf_pins axi_pcie_0/S_AXI_CTL]
  connect_bd_intf_net -intf_net axi_ic_gp_m_M01_AXI [get_bd_intf_pins axi_ic_gp_m/M01_AXI] [get_bd_intf_pins axi_pcie_0/S_AXI]
  connect_bd_intf_net -intf_net axi_ic_hp_s_M00_AXI [get_bd_intf_pins axi_ic_hp_s/M00_AXI] [get_bd_intf_pins processing_system7_0/S_AXI_HP0]
  connect_bd_intf_net -intf_net axi_pcie_0_M_AXI [get_bd_intf_pins axi_ic_hp_s/S00_AXI] [get_bd_intf_pins axi_pcie_0/M_AXI]
  connect_bd_intf_net -intf_net axi_pcie_0_pcie_7x_mgt [get_bd_intf_ports pcie_7x_mgt] [get_bd_intf_pins axi_pcie_0/pcie_7x_mgt]
  connect_bd_intf_net -intf_net processing_system7_0_DDR [get_bd_intf_ports DDR] [get_bd_intf_pins processing_system7_0/DDR]
  connect_bd_intf_net -intf_net processing_system7_0_FIXED_IO [get_bd_intf_ports FIXED_IO] [get_bd_intf_pins processing_system7_0/FIXED_IO]
  connect_bd_intf_net -intf_net processing_system7_0_M_AXI_GP0 [get_bd_intf_pins axi_ic_gp_m/S00_AXI] [get_bd_intf_pins processing_system7_0/M_AXI_GP0]

  # Create port connections
  connect_bd_net -net INTX_MSI_Request_1 [get_bd_ports pcie_msi_req] [get_bd_pins axi_pcie_0/INTX_MSI_Request]
  connect_bd_net -net MSI_Vector_Num_1 [get_bd_ports pcie_msi_vec_num] [get_bd_pins axi_pcie_0/MSI_Vector_Num]
  connect_bd_net -net REFCLK_1 [get_bd_ports pcie_refclk] [get_bd_pins axi_pcie_0/REFCLK]
  connect_bd_net -net axi_pcie_0_INTX_MSI_Grant [get_bd_ports pcie_msi_gnt] [get_bd_pins axi_pcie_0/INTX_MSI_Grant]
  connect_bd_net -net axi_pcie_0_MSI_Vector_Width [get_bd_ports pcie_msi_vec_width] [get_bd_pins axi_pcie_0/MSI_Vector_Width]
  connect_bd_net -net axi_pcie_0_MSI_enable [get_bd_ports pcie_msi_en] [get_bd_pins axi_pcie_0/MSI_enable]
  connect_bd_net -net axi_pcie_0_axi_aclk_out [get_bd_ports pcie_dbg_clk] [get_bd_pins axi_ic_gp_m/M01_ACLK] [get_bd_pins axi_ic_hp_s/S00_ACLK] [get_bd_pins axi_pcie_0/axi_aclk] [get_bd_pins axi_pcie_0/axi_aclk_out]
  connect_bd_net -net axi_pcie_0_axi_ctl_aclk_out [get_bd_pins axi_ic_gp_m/M00_ACLK] [get_bd_pins axi_pcie_0/axi_ctl_aclk] [get_bd_pins axi_pcie_0/axi_ctl_aclk_out]
  connect_bd_net -net axi_pcie_0_interrupt_out [get_bd_pins axi_pcie_0/interrupt_out] [get_bd_pins processing_system7_0/IRQ_F2P]
  connect_bd_net -net axi_pcie_0_mmcm_lock [get_bd_ports pcie_dbg_mmcm_lock] [get_bd_pins axi_pcie_0/mmcm_lock] [get_bd_pins proc_sys_reset_0/dcm_locked]
  connect_bd_net -net ext_reset_in_1 [get_bd_ports ext_rst] [get_bd_pins proc_sys_reset_0/ext_reset_in]
  connect_bd_net -net proc_sys_reset_0_peripheral_aresetn [get_bd_ports bd_aresetn] [get_bd_pins axi_ic_gp_m/ARESETN] [get_bd_pins axi_ic_gp_m/M00_ARESETN] [get_bd_pins axi_ic_gp_m/M01_ARESETN] [get_bd_pins axi_ic_gp_m/S00_ARESETN] [get_bd_pins axi_ic_hp_s/ARESETN] [get_bd_pins axi_ic_hp_s/M00_ARESETN] [get_bd_pins axi_ic_hp_s/S00_ARESETN] [get_bd_pins axi_pcie_0/axi_aresetn] [get_bd_pins proc_sys_reset_0/peripheral_aresetn]
  connect_bd_net -net processing_system7_0_FCLK_CLK0 [get_bd_ports bd_fclk0_125m] [get_bd_pins axi_ic_gp_m/ACLK] [get_bd_pins axi_ic_gp_m/S00_ACLK] [get_bd_pins axi_ic_hp_s/ACLK] [get_bd_pins axi_ic_hp_s/M00_ACLK] [get_bd_pins proc_sys_reset_0/slowest_sync_clk] [get_bd_pins processing_system7_0/FCLK_CLK0] [get_bd_pins processing_system7_0/M_AXI_GP0_ACLK] [get_bd_pins processing_system7_0/S_AXI_HP0_ACLK]
  connect_bd_net -net processing_system7_0_FCLK_CLK1 [get_bd_ports bd_fclk1_75m] [get_bd_pins processing_system7_0/FCLK_CLK1]
  connect_bd_net -net processing_system7_0_FCLK_CLK2 [get_bd_ports bd_fclk2_200m] [get_bd_pins processing_system7_0/FCLK_CLK2]
  connect_bd_net -net processing_system7_0_FCLK_RESET0_N [get_bd_pins proc_sys_reset_0/aux_reset_in] [get_bd_pins processing_system7_0/FCLK_RESET0_N]

  # Create address segments
  create_bd_addr_seg -range 0x40000000 -offset 0x0 [get_bd_addr_spaces axi_pcie_0/M_AXI] [get_bd_addr_segs processing_system7_0/S_AXI_HP0/HP0_DDR_LOWOCM] SEG_processing_system7_0_HP0_DDR_LOWOCM
  create_bd_addr_seg -range 0x1000000 -offset 0x40000000 [get_bd_addr_spaces processing_system7_0/Data] [get_bd_addr_segs axi_pcie_0/S_AXI/BAR0] SEG_axi_pcie_0_BAR0
  create_bd_addr_seg -range 0x1000000 -offset 0x60000000 [get_bd_addr_spaces processing_system7_0/Data] [get_bd_addr_segs axi_pcie_0/S_AXI_CTL/CTL0] SEG_axi_pcie_0_CTL0
  

  # Restore current instance
  current_bd_instance $oldCurInst

  save_bd_design
}
# End of create_root_design()


##################################################################
# MAIN FLOW
##################################################################

create_root_design ""


