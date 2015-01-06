set ip_proj_root [pwd]
set ip_proj_name "ref_switch_core"
set ip_proj_part "xc7z030sbg485-2"


create_project $ip_proj_name $ip_proj_root -part $ip_proj_part -force

import_files $ip_proj_root/src/ip/rxfifo_2kx36_to_72.ngc
import_files $ip_proj_root/src/ip/txfifo_512x72_to_36.ngc
import_files $ip_proj_root/src/ip/cam_16x48.ngc
import_files $ip_proj_root/src/ip/pkt_len_fifo_12x32.ngc
import_files $ip_proj_root/src/ip/rxlengthfifo_128x13.ngc
import_files $ip_proj_root/src/ip/reg_access_fifo.ngc
import_files $ip_proj_root/src/core/rx_queue.v
import_files $ip_proj_root/src/udp/onet_defines.v
import_files $ip_proj_root/src/udp/in_arb_regs.v
import_files $ip_proj_root/src/udp/user_data_path.v
import_files $ip_proj_root/src/core/tx_queue.v
import_files $ip_proj_root/src/ip/pkt_len_fifo_12x32.v
import_files $ip_proj_root/src/udp/ethernet_parser_32bit.v
import_files $ip_proj_root/src/core/axi_to_reg_bus.v
import_files $ip_proj_root/src/ip/txfifo_512x72_to_36.v
import_files $ip_proj_root/src/ip/rxlengthfifo_128x13.v
import_files $ip_proj_root/src/core/reg_grp.v
import_files $ip_proj_root/src/udp/output_port_lookup.v
import_files $ip_proj_root/src/core/onet_core_logic.v
import_files $ip_proj_root/src/core/unused_reg.v
import_files $ip_proj_root/src/udp/ethernet_parser.v
import_files $ip_proj_root/src/udp/input_arbiter.v
import_files $ip_proj_root/src/core/eth_queue.v
import_files $ip_proj_root/src/core/axis_control_if.v
import_files $ip_proj_root/src/core/pulse_synchronizer.v
import_files $ip_proj_root/src/udp/udp_reg_master.v
import_files $ip_proj_root/src/udp/mac_cam_lut.v
import_files $ip_proj_root/src/udp/output_queues.v
import_files $ip_proj_root/src/ip/rxfifo_2kx36_to_72.v
import_files $ip_proj_root/src/core/udp_reg_path_decode.v
import_files $ip_proj_root/src/core/small_fifo.v
import_files $ip_proj_root/src/udp/op_lut_regs.v
import_files $ip_proj_root/src/core/eth_queue_regs.v
import_files $ip_proj_root/src/ip/reg_access_fifo.v
import_files $ip_proj_root/src/udp/ethernet_parser_64bit.v
import_files $ip_proj_root/src/udp/cam_16x48.v
import_files $ip_proj_root/src/core/pipeline_switch.v

update_compile_order -fileset sources_1
update_compile_order -fileset sim_1

set file "udp/onet_defines.v"
set file_obj [get_files -of_objects sources_1 [list "*$file"]]
set_property "is_global_include" "1" $file_obj
#set_property "is_global_include" "1" $global_files

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

ipx::check_integrity -quiet [ipx::current_core]
ipx::archive_core $ip_proj_root/$ip_proj_name.zip [ipx::current_core]

close_project

file delete -force $ip_proj_root/$ip_proj_name.data $ip_proj_root/$ip_proj_name.srcs $ip_proj_root/xgui $ip_proj_root/component.xml $ip_proj_root/$ip_proj_name.xpr 
 