set ip_proj_root [pwd]
set ip_proj_name "ref_openflow_core"
set ip_proj_part "xc7z030sbg485-2"


create_project $ip_proj_name $ip_proj_root -part $ip_proj_part -force

 import_ip $ip_proj_root/src/ip/pkt_fifo/pkt_fifo.xci
 import_ip $ip_proj_root/src/ip/txfifo_512x72_to_36/txfifo_512x72_to_36.xci
 import_ip $ip_proj_root/src/ip/rxlengthfifo_128x13/rxlengthfifo_128x13.xci
 import_ip $ip_proj_root/src/ip/rxfifo_2kx36_to_72/rxfifo_2kx36_to_72.xci
 import_ip $ip_proj_root/src/ip/reg_access_fifo/reg_access_fifo.xci
 import_ip $ip_proj_root/src/ip/pkt_len_fifo_12x32/pkt_len_fifo_12x32.xci
 import_files $ip_proj_root/src/udp/onet_defines.v
 import_files $ip_proj_root/src/udp/generic_sw_regs.v
 import_files $ip_proj_root/src/udp/generic_hw_regs.v
 import_files $ip_proj_root/src/udp/generic_cntr_regs.v
 import_files $ip_proj_root/src/core/small_fifo.v
 import_files $ip_proj_root/src/udp/unencoded_cam_lut_sm.v
 import_files $ip_proj_root/src/udp/tcam_parallel_matcher.v
 import_files $ip_proj_root/src/udp/rate_limiter_regs.v
 import_files $ip_proj_root/src/udp/generic_regs.v
 import_files $ip_proj_root/src/udp/fallthrough_small_fifo_v2.v
 import_files $ip_proj_root/src/udp/wildcard_match.v
 import_files $ip_proj_root/src/udp/rate_limiter.v
 import_files $ip_proj_root/src/udp/queue_splitter.v
 import_files $ip_proj_root/src/udp/queue_aggr.v
 import_files $ip_proj_root/src/udp/opl_processor.v
 import_files $ip_proj_root/src/udp/in_arb_regs.v
 import_files $ip_proj_root/src/udp/header_parser.v
 import_files $ip_proj_root/src/core/pulse_synchronizer.v
 import_files $ip_proj_root/src/udp/vlan_remover.v
 import_files $ip_proj_root/src/udp/vlan_adder.v
 import_files $ip_proj_root/src/udp/udp_reg_master.v
 import_files $ip_proj_root/src/udp/output_queues.v
 import_files $ip_proj_root/src/udp/output_port_lookup.v
 import_files $ip_proj_root/src/udp/meter_lite.v
 import_files $ip_proj_root/src/udp/input_arbiter.v
 import_files $ip_proj_root/src/core/tx_queue.v
 import_files $ip_proj_root/src/core/rx_queue.v
 import_files $ip_proj_root/src/core/eth_queue_regs.v
 import_files $ip_proj_root/src/udp/user_data_path.v
 import_files $ip_proj_root/src/core/unused_reg.v
 import_files $ip_proj_root/src/core/udp_reg_path_decode.v
 import_files $ip_proj_root/src/core/reg_grp.v
 import_files $ip_proj_root/src/core/eth_queue.v
 import_files $ip_proj_root/src/core/axi_to_reg_bus.v
 import_files $ip_proj_root/src/core/onet_core_logic.v
 import_files $ip_proj_root/src/core/axis_control_if.v
 import_files $ip_proj_root/src/core/packet_pipeline.v

# Set 'sources_1' fileset file properties for local files
set file "udp/onet_defines.v"
set file_obj [get_files -of_objects sources_1 [list "*$file"]]
set_property "is_global_include" "1" $file_obj

ipx::package_project -root_dir $ip_proj_root
set_property library {user} [ipx::current_core]
ipx::create_xgui_files [ipx::current_core]
ipx::save_core [ipx::current_core]
set_property ip_repo_paths  $ip_proj_root [current_fileset]
update_ip_catalog

set_property vendor {meshsr} [ipx::current_core]
set_property name $ip_proj_name [ipx::current_core]
set_property display_name {ref_switch_core} [ipx::current_core]
set_property description {ref_switch_core} [ipx::current_core]

ipx::add_bus_interface {s_axis_rxd_aclk} [ipx::current_core]
set_property abstraction_type_vlnv {xilinx.com:signal:clock_rtl:1.0} [ipx::get_bus_interface s_axis_rxd_aclk [ipx::current_core]]
set_property bus_type_vlnv {xilinx.com:signal:clock:1.0} [ipx::get_bus_interface s_axis_rxd_aclk [ipx::current_core]]
set_property display_name {s_axis_rxd_aclk} [ipx::get_bus_interface s_axis_rxd_aclk [ipx::current_core]]
ipx::add_port_map {CLK} [ipx::get_bus_interface s_axis_rxd_aclk [ipx::current_core]]
set_property physical_name {s_axis_rxd_aclk} [ipx::get_port_map CLK [ipx::get_bus_interface s_axis_rxd_aclk [ipx::current_core]]]
ipx::add_bus_parameter {ASSOCIATED_BUSIF} [ipx::get_bus_interface s_axis_rxd_aclk [ipx::current_core]]
set_property value {s_axis_rxd_0:s_axis_rxd_1:s_axis_rxd_2:s_axis_rxd_3:s_axis_rxs_0:s_axis_rxs_1:s_axis_rxs_2:s_axis_rxs_3} [ipx::get_bus_parameter ASSOCIATED_BUSIF [ipx::get_bus_interface s_axis_rxd_aclk [ipx::current_core]]]
ipx::add_bus_parameter {ASSOCIATED_RESET} [ipx::get_bus_interface s_axis_rxd_aclk [ipx::current_core]]
set_property value {s_axis_rxd_aresetn} [ipx::get_bus_parameter ASSOCIATED_RESET [ipx::get_bus_interface s_axis_rxd_aclk [ipx::current_core]]]

ipx::add_bus_interface {s_axis_txd_aclk} [ipx::current_core]
set_property abstraction_type_vlnv {xilinx.com:signal:clock_rtl:1.0} [ipx::get_bus_interface s_axis_txd_aclk [ipx::current_core]]
set_property bus_type_vlnv {xilinx.com:signal:clock:1.0} [ipx::get_bus_interface s_axis_txd_aclk [ipx::current_core]]
set_property display_name {s_axis_txd_aclk} [ipx::get_bus_interface s_axis_txd_aclk [ipx::current_core]]
ipx::add_port_map {CLK} [ipx::get_bus_interface s_axis_txd_aclk [ipx::current_core]]
set_property physical_name {s_axis_txd_aclk} [ipx::get_port_map CLK [ipx::get_bus_interface s_axis_txd_aclk [ipx::current_core]]]
ipx::add_bus_parameter {ASSOCIATED_BUSIF} [ipx::get_bus_interface s_axis_txd_aclk [ipx::current_core]]
set_property value {m_axis_txc_0:m_axis_txc_1:m_axis_txc_2:m_axis_txc_3:m_axis_txd_0:m_axis_txd_1:m_axis_txd_2:m_axis_txd_3} [ipx::get_bus_parameter ASSOCIATED_BUSIF [ipx::get_bus_interface s_axis_txd_aclk [ipx::current_core]]]
ipx::add_bus_parameter {ASSOCIATED_RESET} [ipx::get_bus_interface s_axis_txd_aclk [ipx::current_core]]
set_property value {s_axis_txd_aresetn} [ipx::get_bus_parameter ASSOCIATED_RESET [ipx::get_bus_interface s_axis_txd_aclk [ipx::current_core]]]

ipx::add_bus_interface {s_axis_mm2s_aclk} [ipx::current_core]
set_property abstraction_type_vlnv {xilinx.com:signal:clock_rtl:1.0} [ipx::get_bus_interface s_axis_mm2s_aclk [ipx::current_core]]
set_property bus_type_vlnv {xilinx.com:signal:clock:1.0} [ipx::get_bus_interface s_axis_mm2s_aclk [ipx::current_core]]
set_property display_name {s_axis_mm2s_aclk} [ipx::get_bus_interface s_axis_mm2s_aclk [ipx::current_core]]
ipx::add_port_map {CLK} [ipx::get_bus_interface s_axis_mm2s_aclk [ipx::current_core]]
set_property physical_name {s_axis_mm2s_aclk} [ipx::get_port_map CLK [ipx::get_bus_interface s_axis_mm2s_aclk [ipx::current_core]]]
ipx::add_bus_parameter {ASSOCIATED_BUSIF} [ipx::get_bus_interface s_axis_mm2s_aclk [ipx::current_core]]
set_property value {s_axis_mm2s_0:s_axis_mm2s_1:s_axis_mm2s_2:s_axis_mm2s_3:s_axis_mm2s_ctrl_0:s_axis_mm2s_ctrl_1:s_axis_mm2s_ctrl_2:s_axis_mm2s_ctrl_3} [ipx::get_bus_parameter ASSOCIATED_BUSIF [ipx::get_bus_interface s_axis_mm2s_aclk [ipx::current_core]]]
ipx::add_bus_parameter {ASSOCIATED_RESET} [ipx::get_bus_interface s_axis_mm2s_aclk [ipx::current_core]]
set_property value {s_axis_mm2s_aresetn} [ipx::get_bus_parameter ASSOCIATED_RESET [ipx::get_bus_interface s_axis_mm2s_aclk [ipx::current_core]]]

ipx::add_bus_interface {s_axis_s2mm_aclk} [ipx::current_core]
set_property abstraction_type_vlnv {xilinx.com:signal:clock_rtl:1.0} [ipx::get_bus_interface s_axis_s2mm_aclk [ipx::current_core]]
set_property bus_type_vlnv {xilinx.com:signal:clock:1.0} [ipx::get_bus_interface s_axis_s2mm_aclk [ipx::current_core]]
set_property display_name {s_axis_s2mm_aclk} [ipx::get_bus_interface s_axis_s2mm_aclk [ipx::current_core]]
ipx::add_port_map {CLK} [ipx::get_bus_interface s_axis_s2mm_aclk [ipx::current_core]]
set_property physical_name {s_axis_s2mm_aclk} [ipx::get_port_map CLK [ipx::get_bus_interface s_axis_s2mm_aclk [ipx::current_core]]]
ipx::add_bus_parameter {ASSOCIATED_BUSIF} [ipx::get_bus_interface s_axis_s2mm_aclk [ipx::current_core]]
set_property value {m_axis_s2mm_0:m_axis_s2mm_1:m_axis_s2mm_2:m_axis_s2mm_3:m_axis_s2mm_sts_0:m_axis_s2mm_sts_1:m_axis_s2mm_sts_2:m_axis_s2mm_sts_3} [ipx::get_bus_parameter ASSOCIATED_BUSIF [ipx::get_bus_interface s_axis_s2mm_aclk [ipx::current_core]]]
ipx::add_bus_parameter {ASSOCIATED_RESET} [ipx::get_bus_interface s_axis_s2mm_aclk [ipx::current_core]]
set_property value {s_axis_s2mm_aresetn} [ipx::get_bus_parameter ASSOCIATED_RESET [ipx::get_bus_interface s_axis_s2mm_aclk [ipx::current_core]]]

ipx::add_bus_interface {s_axis_rxd_aresetn} [ipx::current_core]
set_property abstraction_type_vlnv {xilinx.com:signal:reset_rtl:1.0} [ipx::get_bus_interface s_axis_rxd_aresetn [ipx::current_core]]
set_property bus_type_vlnv {xilinx.com:signal:reset:1.0} [ipx::get_bus_interface s_axis_rxd_aresetn [ipx::current_core]]
set_property display_name {s_axis_rxd_aresetn} [ipx::get_bus_interface s_axis_rxd_aresetn [ipx::current_core]]
ipx::add_port_map {RST} [ipx::get_bus_interface s_axis_rxd_aresetn [ipx::current_core]]
set_property physical_name {s_axis_rxd_aresetn} [ipx::get_port_map RST [ipx::get_bus_interface s_axis_rxd_aresetn [ipx::current_core]]]
ipx::add_bus_parameter {POLARITY} [ipx::get_bus_interface s_axis_rxd_aresetn [ipx::current_core]]
set_property value {ACTIVE_LOW} [ipx::get_bus_parameter POLARITY [ipx::get_bus_interface s_axis_rxd_aresetn [ipx::current_core]]]

ipx::add_bus_interface {s_axis_txd_aresetn} [ipx::current_core]
set_property abstraction_type_vlnv {xilinx.com:signal:reset_rtl:1.0} [ipx::get_bus_interface s_axis_txd_aresetn [ipx::current_core]]
set_property bus_type_vlnv {xilinx.com:signal:reset:1.0} [ipx::get_bus_interface s_axis_txd_aresetn [ipx::current_core]]
set_property display_name {s_axis_txd_aresetn} [ipx::get_bus_interface s_axis_txd_aresetn [ipx::current_core]]
ipx::add_port_map {RST} [ipx::get_bus_interface s_axis_txd_aresetn [ipx::current_core]]
set_property physical_name {s_axis_txd_aresetn} [ipx::get_port_map RST [ipx::get_bus_interface s_axis_txd_aresetn [ipx::current_core]]]
ipx::add_bus_parameter {POLARITY} [ipx::get_bus_interface s_axis_txd_aresetn [ipx::current_core]]
set_property value {ACTIVE_LOW} [ipx::get_bus_parameter POLARITY [ipx::get_bus_interface s_axis_txd_aresetn [ipx::current_core]]]

ipx::add_bus_interface {s_axis_mm2s_aresetn} [ipx::current_core]
set_property abstraction_type_vlnv {xilinx.com:signal:reset_rtl:1.0} [ipx::get_bus_interface s_axis_mm2s_aresetn [ipx::current_core]]
set_property bus_type_vlnv {xilinx.com:signal:reset:1.0} [ipx::get_bus_interface s_axis_mm2s_aresetn [ipx::current_core]]
set_property display_name {s_axis_mm2s_aresetn} [ipx::get_bus_interface s_axis_mm2s_aresetn [ipx::current_core]]
ipx::add_port_map {RST} [ipx::get_bus_interface s_axis_mm2s_aresetn [ipx::current_core]]
set_property physical_name {s_axis_mm2s_aresetn} [ipx::get_port_map RST [ipx::get_bus_interface s_axis_mm2s_aresetn [ipx::current_core]]]
ipx::add_bus_parameter {POLARITY} [ipx::get_bus_interface s_axis_mm2s_aresetn [ipx::current_core]]
set_property value {ACTIVE_LOW} [ipx::get_bus_parameter POLARITY [ipx::get_bus_interface s_axis_mm2s_aresetn [ipx::current_core]]]

ipx::add_bus_interface {s_axis_s2mm_aresetn} [ipx::current_core]
set_property abstraction_type_vlnv {xilinx.com:signal:reset_rtl:1.0} [ipx::get_bus_interface s_axis_s2mm_aresetn [ipx::current_core]]
set_property bus_type_vlnv {xilinx.com:signal:reset:1.0} [ipx::get_bus_interface s_axis_s2mm_aresetn [ipx::current_core]]
set_property display_name {s_axis_s2mm_aresetn} [ipx::get_bus_interface s_axis_s2mm_aresetn [ipx::current_core]]
ipx::add_port_map {RST} [ipx::get_bus_interface s_axis_s2mm_aresetn [ipx::current_core]]
set_property physical_name {s_axis_s2mm_aresetn} [ipx::get_port_map RST [ipx::get_bus_interface s_axis_s2mm_aresetn [ipx::current_core]]]
ipx::add_bus_parameter {POLARITY} [ipx::get_bus_interface s_axis_s2mm_aresetn [ipx::current_core]]
set_property value {ACTIVE_LOW} [ipx::get_bus_parameter POLARITY [ipx::get_bus_interface s_axis_s2mm_aresetn [ipx::current_core]]]


set_property vendor {meshsr} [ipx::current_core]
set_property name $ip_proj_name [ipx::current_core]
set_property display_name $ip_proj_name [ipx::current_core]
set_property description $ip_proj_name [ipx::current_core]

ipx::check_integrity -quiet [ipx::current_core]
ipx::archive_core $ip_proj_root/$ip_proj_name.zip [ipx::current_core]

close_project

file delete -force $ip_proj_root/$ip_proj_name.data $ip_proj_root/$ip_proj_name.srcs $ip_proj_root/xgui $ip_proj_root/component.xml $ip_proj_root/$ip_proj_name.xpr 
 
