set_property PACKAGE_PIN B1 [get_ports {pl_led[0]}]
set_property PACKAGE_PIN C4 [get_ports {pl_led[1]}]
set_property IOSTANDARD LVCMOS15 [get_ports {pl_led[0]}]
set_property IOSTANDARD LVCMOS15 [get_ports {pl_led[1]}]

set_property PACKAGE_PIN R17 [get_ports {pl_pmod[0]}]
set_property PACKAGE_PIN U19 [get_ports {pl_pmod[1]}]
set_property IOSTANDARD LVCMOS25 [get_ports {pl_pmod[0]}]
set_property IOSTANDARD LVCMOS25 [get_ports {pl_pmod[1]}]

set_property PACKAGE_PIN P2 [get_ports pl_btn]
set_property IOSTANDARD LVCMOS15 [get_ports pl_btn]

set_property PACKAGE_PIN Y15 [get_ports sgmii_refclk_n]
set_property IOSTANDARD LVDS_25 [get_ports sgmii_refclk_p]
set_property IOSTANDARD LVDS_25 [get_ports sgmii_refclk_n]

############################################################
## GTX Bank 112
############################################################
### GTX #1
set_property PACKAGE_PIN W4  [get_ports gtx_pcie_txp]
### GTX #3
### set_property PACKAGE_PIN W2  [get_ports gtx_pcie_txp]
set_property PACKAGE_PIN U5  [get_ports gtx_pcie_clk_100m_p]

############################################################
## PCIe misc
############################################################
set_property PACKAGE_PIN M4 [get_ports pcie_wake_b]
set_property PACKAGE_PIN R5 [get_ports pcie_perst_b]
set_property PACKAGE_PIN M3 [get_ports pcie_clkreq_b]
set_property PACKAGE_PIN R4 [get_ports pcie_w_disable_b]
set_property IOSTANDARD LVCMOS15 [get_ports pcie_wake_b]
set_property IOSTANDARD LVCMOS15 [get_ports pcie_perst_b]
set_property IOSTANDARD LVCMOS15 [get_ports pcie_clkreq_b]
set_property IOSTANDARD LVCMOS15 [get_ports pcie_w_disable_b]
