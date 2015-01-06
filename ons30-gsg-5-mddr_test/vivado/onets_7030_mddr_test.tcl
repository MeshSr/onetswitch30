#
# Vivado (TM) v2013.4 (64-bit)
#

############################################################
### 0. General settings
############################################################
set proj_root "."
set proj_name "onets_7030_mddr_test"
set proj_part "xc7z030sbg485-2"
set proj_bd   "onets_bd"
set proj_top  "onetswitch_top"

set proj_bd_tcl      "$proj_root/$proj_name/bd/$proj_bd.tcl"
set proj_source_dir  "$proj_root/$proj_name/sources"
set proj_constr_dir  "$proj_root/$proj_name/constrs"

set sources_files [list \
 "[file normalize "$proj_source_dir/onetswitch_top.v"]"\
]

set constrs_files [list \
 "[file normalize "$proj_constr_dir/onetswitch_pins.xdc"]"\
 "[file normalize "$proj_constr_dir/onetswitch_top.xdc"]"\
]


### set bd_files [list \
###  "[file normalize "$proj_root/$proj_name.srcs/sources_1/bd/$proj_bd/$proj_bd.bd"]"\
###  "[file normalize "$proj_root/$proj_name.srcs/sources_1/bd/$proj_bd/hdl/${proj_bd}_wrapper.v"]"\
### ]

############################################################
### 1. Project
############################################################
# Create project
create_project $proj_name $proj_root -part $proj_part -force

############################################################
### 2. Generate the user-defined IPs
############################################################

############################################################
### 3. Generate the block design
############################################################
source $proj_bd_tcl
add_files [ make_wrapper -files [get_files $proj_root/$proj_name.srcs/sources_1/bd/$proj_bd/$proj_bd.bd] -top ]

############################################################
### 4. Add the source files
############################################################
# Create 'sources_1' fileset (if not found)
if {[string equal [get_filesets sources_1] ""]} {
  create_fileset -srcset sources_1
}

# Add files to 'sources_1' fileset
import_files -fileset sources_1 $sources_files -flat
### add_files -fileset sources_1 $bd_files

# Set 'sources_1' fileset properties
set obj [get_filesets sources_1]
set_property "top" $proj_top $obj

############################################################
### 5. Add the constraint files
############################################################
# Create 'constrs_1' fileset (if not found)
if {[string equal [get_filesets constrs_1] ""]} {
  create_fileset -constrset constrs_1
}

# Add files to 'constrs_1' fileset
import_files -fileset constrs_1 $constrs_files -flat

############################################################
### 6. Add the simulation files
############################################################
# Create 'sim_1' fileset (if not found)
if {[string equal [get_filesets sim_1] ""]} {
  create_fileset -simset sim_1
}

# Add files to 'sim_1' fileset
set obj [get_filesets sim_1]
# Empty (no sources present)

# Set 'sim_1' fileset properties
set obj [get_filesets sim_1]
set_property "top" $proj_top $obj

############################################################
### 7. Run the design flow
############################################################
# Create 'synth_1' run (if not found)
if {[string equal [get_runs synth_1] ""]} {
  create_run -name synth_1 -part $proj_part -flow {Vivado Synthesis 2013} -strategy "Vivado Synthesis Defaults" -constrset constrs_1
}
set obj [get_runs synth_1]
set_property "part" $proj_part $obj

# Create 'impl_1' run (if not found)
if {[string equal [get_runs impl_1] ""]} {
  create_run -name impl_1 -part $proj_part -flow {Vivado Implementation 2013} -strategy "Vivado Implementation Defaults" -constrset constrs_1 -parent_run synth_1
}
set obj [get_runs impl_1]
set_property "part" $proj_part $obj


puts "INFO: Project created."
