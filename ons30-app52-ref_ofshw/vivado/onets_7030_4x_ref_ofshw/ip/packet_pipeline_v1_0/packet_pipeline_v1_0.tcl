set ip_proj_root [pwd]
set ip_proj_name "packet_pipeline_v1_0"
set ip_proj_part "xc7z030sbg485-2"


create_project $ip_proj_name $ip_proj_root -part $ip_proj_part -force

import_ip $ip_proj_root/src/ip/lut_action_bram/lut_action_bram.xci
import_ip $ip_proj_root/src/ip/qos_fifo_bram/qos_fifo_bram.xci
import_ip $ip_proj_root/src/ip/reg_access_fifo/reg_access_fifo.xci
import_ip $ip_proj_root/src/ip/rxfifo_2kx36_to_72/rxfifo_2kx36_to_72.xci
import_ip $ip_proj_root/src/ip/rxlengthfifo_128x13/rxlengthfifo_128x13.xci
import_ip $ip_proj_root/src/ip/txfifo_512x72_to_36/txfifo_512x72_to_36.xci
import_files $ip_proj_root/src/include/ONETS30.v
import_files $ip_proj_root/src/include/onet_defines.v
import_files $ip_proj_root/src/include/define_reg_addr.v
import_files $ip_proj_root/src/core/axi_to_reg_bus.v
import_files $ip_proj_root/src/core/axis_control_if.v
import_files $ip_proj_root/src/core/eth_queue.v
import_files $ip_proj_root/src/core/onet_core_logic.v
import_files $ip_proj_root/src/core/packet_pipeline.v
import_files $ip_proj_root/src/core/pulse_synchronizer.v
import_files $ip_proj_root/src/core/rx_queue.v
import_files $ip_proj_root/src/core/small_fifo.v
import_files $ip_proj_root/src/core/tx_queue.v
import_files $ip_proj_root/src/user_data_path/configuration.v
import_files $ip_proj_root/src/user_data_path/action_processor.v
import_files $ip_proj_root/src/user_data_path/data_fifo.v
import_files $ip_proj_root/src/user_data_path/dma_queue.v
import_files $ip_proj_root/src/user_data_path/dma_tx_queue.v
import_files $ip_proj_root/src/user_data_path/eth_dma_aggr.v
import_files $ip_proj_root/src/user_data_path/fallthrough_small_fifo_v2.v
import_files $ip_proj_root/src/user_data_path/header_parser.v
import_files $ip_proj_root/src/user_data_path/input_arbiter.v
import_files $ip_proj_root/src/user_data_path/meter_lite.v
import_files $ip_proj_root/src/user_data_path/output_port_lookup.v
import_files $ip_proj_root/src/user_data_path/output_port_lookup_reg_master.v
import_files $ip_proj_root/src/user_data_path/output_queue_reg_master.v
import_files $ip_proj_root/src/user_data_path/output_queues.v
import_files $ip_proj_root/src/user_data_path/qos_wrr.v
import_files $ip_proj_root/src/user_data_path/queue_aggr.v
import_files $ip_proj_root/src/user_data_path/queue_splitter.v
import_files $ip_proj_root/src/user_data_path/rate_limiter.v
import_files $ip_proj_root/src/user_data_path/rate_limiter_regs.v
import_files $ip_proj_root/src/user_data_path/udp_reg_master.v
import_files $ip_proj_root/src/user_data_path/user_data_path.v
import_files $ip_proj_root/src/user_data_path/vlan_adder.v
import_files $ip_proj_root/src/user_data_path/vlan_remover.v
import_files $ip_proj_root/src/user_data_path/wildcard_counter.v
import_files $ip_proj_root/src/user_data_path/wildcard_lut_action.v
import_files $ip_proj_root/src/user_data_path/wildcard_match.v
import_files $ip_proj_root/src/user_data_path/wildcard_processor.v
import_files $ip_proj_root/src/user_data_path/wildcard_tcam.v




set file1 "include/ONETS30.v"
set file2 "include/onet_defines.v"
set file3 "include/define_reg_addr.v"

set file_obj1 [get_files -of_objects sources_1 [list "*$file1"]]
set file_obj2 [get_files -of_objects sources_1 [list "*$file2"]]
set file_obj3 [get_files -of_objects sources_1 [list "*$file3"]]

set_property "is_global_include" "1" $file_obj1
set_property "is_global_include" "1" $file_obj2
set_property "is_global_include" "1" $file_obj3


update_compile_order -fileset sources_1
update_compile_order -fileset sim_1


ipx::package_project -root_dir $ip_proj_root
set_property library {user} [ipx::current_core]

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
ipx::create_xgui_files [ipx::current_core]
ipx::save_core [ipx::current_core]
set_property ip_repo_paths  $ip_proj_root [current_fileset]
update_ip_catalog

set_property vendor {meshsr} [ipx::current_core]
set_property name $ip_proj_name [ipx::current_core]
set_property display_name {packet_pipeline_v1_0} [ipx::current_core]
set_property description {packet_pipeline_v1_0} [ipx::current_core]

ipx::check_integrity -quiet [ipx::current_core]
ipx::archive_core $ip_proj_root/$ip_proj_name.zip [ipx::current_core]

close_project

file delete -force $ip_proj_root/$ip_proj_name.data $ip_proj_root/$ip_proj_name.srcs $ip_proj_root/xgui $ip_proj_root/component.xml $ip_proj_root/$ip_proj_name.xpr 
 
