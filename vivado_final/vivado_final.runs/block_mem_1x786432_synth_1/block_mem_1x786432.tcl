# 
# Synthesis run script generated by Vivado
# 

proc create_report { reportName command } {
  set status "."
  append status $reportName ".fail"
  if { [file exists $status] } {
    eval file delete [glob $status]
  }
  send_msg_id runtcl-4 info "Executing : $command"
  set retval [eval catch { $command } msg]
  if { $retval != 0 } {
    set fp [open $status w]
    close $fp
    send_msg_id runtcl-5 warning "$msg"
  }
}
set_msg_config -id {Common 17-41} -limit 10000000
set_param project.vivado.isBlockSynthRun true
set_msg_config -msgmgr_mode ooc_run
create_project -in_memory -part xc7z020clg400-1

set_param project.singleFileAddWarning.threshold 0
set_param project.compositeFile.enableAutoGeneration 0
set_param synth.vivado.isSynthRun true
set_msg_config -source 4 -id {IP_Flow 19-2162} -severity warning -new_severity info
set_property webtalk.parent_dir /home/cc/eecs151/sp18/class/eecs151-aaq/sp18_team69/vivado_final/vivado_final.cache/wt [current_project]
set_property parent.project_path /home/cc/eecs151/sp18/class/eecs151-aaq/sp18_team69/vivado_final/vivado_final.xpr [current_project]
set_property XPM_LIBRARIES XPM_MEMORY [current_project]
set_property default_lib xil_defaultlib [current_project]
set_property target_language Verilog [current_project]
set_property ip_repo_paths /home/cc/eecs151/sp18/class/eecs151-aaq/sp18_team69/hardware/src/video/rgb2dvi [current_project]
set_property ip_output_repo /home/cc/eecs151/sp18/class/eecs151-aaq/sp18_team69/vivado_final/vivado_final.cache/ip [current_project]
set_property ip_cache_permissions {read write} [current_project]
read_ip -quiet /home/cc/eecs151/sp18/class/eecs151-aaq/sp18_team69/hardware/src/video/framebuffer_ram_1x786432/framebuffer_ram_1x786432/block_mem_1x786432.xci
set_property used_in_implementation false [get_files -all /home/cc/eecs151/sp18/class/eecs151-aaq/sp18_team69/hardware/src/video/framebuffer_ram_1x786432/framebuffer_ram_1x786432/block_mem_1x786432_ooc.xdc]

# Mark all dcp files as not used in implementation to prevent them from being
# stitched into the results of this synthesis run. Any black boxes in the
# design are intentionally left as such for best results. Dcp files will be
# stitched into the design at a later time, either when this synthesis run is
# opened, or when it is stitched into a dependent implementation run.
foreach dcp [get_files -quiet -all -filter file_type=="Design\ Checkpoint"] {
  set_property used_in_implementation false $dcp
}
read_xdc dont_touch.xdc
set_property used_in_implementation false [get_files dont_touch.xdc]

set cached_ip [config_ip_cache -export -no_bom -use_project_ipc -dir /home/cc/eecs151/sp18/class/eecs151-aaq/sp18_team69/vivado_final/vivado_final.runs/block_mem_1x786432_synth_1 -new_name block_mem_1x786432 -ip [get_ips block_mem_1x786432]]

if { $cached_ip eq {} } {

synth_design -top block_mem_1x786432 -part xc7z020clg400-1 -mode out_of_context

#---------------------------------------------------------
# Generate Checkpoint/Stub/Simulation Files For IP Cache
#---------------------------------------------------------
# disable binary constraint mode for IPCache checkpoints
set_param constraints.enableBinaryConstraints false

catch {
 write_checkpoint -force -noxdef -rename_prefix block_mem_1x786432_ block_mem_1x786432.dcp

 set ipCachedFiles {}
 write_verilog -force -mode synth_stub -rename_top decalper_eb_ot_sdeen_pot_pi_dehcac_xnilix -prefix decalper_eb_ot_sdeen_pot_pi_dehcac_xnilix_ block_mem_1x786432_stub.v
 lappend ipCachedFiles block_mem_1x786432_stub.v

 write_vhdl -force -mode synth_stub -rename_top decalper_eb_ot_sdeen_pot_pi_dehcac_xnilix -prefix decalper_eb_ot_sdeen_pot_pi_dehcac_xnilix_ block_mem_1x786432_stub.vhdl
 lappend ipCachedFiles block_mem_1x786432_stub.vhdl

 write_verilog -force -mode funcsim -rename_top decalper_eb_ot_sdeen_pot_pi_dehcac_xnilix -prefix decalper_eb_ot_sdeen_pot_pi_dehcac_xnilix_ block_mem_1x786432_sim_netlist.v
 lappend ipCachedFiles block_mem_1x786432_sim_netlist.v

 write_vhdl -force -mode funcsim -rename_top decalper_eb_ot_sdeen_pot_pi_dehcac_xnilix -prefix decalper_eb_ot_sdeen_pot_pi_dehcac_xnilix_ block_mem_1x786432_sim_netlist.vhdl
 lappend ipCachedFiles block_mem_1x786432_sim_netlist.vhdl

 config_ip_cache -add -dcp block_mem_1x786432.dcp -move_files $ipCachedFiles -use_project_ipc -ip [get_ips block_mem_1x786432]
}

rename_ref -prefix_all block_mem_1x786432_

# disable binary constraint mode for synth run checkpoints
set_param constraints.enableBinaryConstraints false
write_checkpoint -force -noxdef block_mem_1x786432.dcp
create_report "block_mem_1x786432_synth_1_synth_report_utilization_0" "report_utilization -file block_mem_1x786432_utilization_synth.rpt -pb block_mem_1x786432_utilization_synth.pb"

if { [catch {
  write_verilog -force -mode synth_stub /home/cc/eecs151/sp18/class/eecs151-aaq/sp18_team69/vivado_final/vivado_final.runs/block_mem_1x786432_synth_1/block_mem_1x786432_stub.v
} _RESULT ] } { 
  puts "CRITICAL WARNING: Unable to successfully create a Verilog synthesis stub for the sub-design. This may lead to errors in top level synthesis of the design. Error reported: $_RESULT"
}

if { [catch {
  write_vhdl -force -mode synth_stub /home/cc/eecs151/sp18/class/eecs151-aaq/sp18_team69/vivado_final/vivado_final.runs/block_mem_1x786432_synth_1/block_mem_1x786432_stub.vhdl
} _RESULT ] } { 
  puts "CRITICAL WARNING: Unable to successfully create a VHDL synthesis stub for the sub-design. This may lead to errors in top level synthesis of the design. Error reported: $_RESULT"
}

if { [catch {
  write_verilog -force -mode funcsim /home/cc/eecs151/sp18/class/eecs151-aaq/sp18_team69/vivado_final/vivado_final.runs/block_mem_1x786432_synth_1/block_mem_1x786432_sim_netlist.v
} _RESULT ] } { 
  puts "CRITICAL WARNING: Unable to successfully create the Verilog functional simulation sub-design file. Post-Synthesis Functional Simulation with this file may not be possible or may give incorrect results. Error reported: $_RESULT"
}

if { [catch {
  write_vhdl -force -mode funcsim /home/cc/eecs151/sp18/class/eecs151-aaq/sp18_team69/vivado_final/vivado_final.runs/block_mem_1x786432_synth_1/block_mem_1x786432_sim_netlist.vhdl
} _RESULT ] } { 
  puts "CRITICAL WARNING: Unable to successfully create the VHDL functional simulation sub-design file. Post-Synthesis Functional Simulation with this file may not be possible or may give incorrect results. Error reported: $_RESULT"
}


} else {


}; # end if cached_ip 

add_files /home/cc/eecs151/sp18/class/eecs151-aaq/sp18_team69/vivado_final/vivado_final.runs/block_mem_1x786432_synth_1/block_mem_1x786432_stub.v -of_objects [get_files /home/cc/eecs151/sp18/class/eecs151-aaq/sp18_team69/hardware/src/video/framebuffer_ram_1x786432/framebuffer_ram_1x786432/block_mem_1x786432.xci]

add_files /home/cc/eecs151/sp18/class/eecs151-aaq/sp18_team69/vivado_final/vivado_final.runs/block_mem_1x786432_synth_1/block_mem_1x786432_stub.vhdl -of_objects [get_files /home/cc/eecs151/sp18/class/eecs151-aaq/sp18_team69/hardware/src/video/framebuffer_ram_1x786432/framebuffer_ram_1x786432/block_mem_1x786432.xci]

add_files /home/cc/eecs151/sp18/class/eecs151-aaq/sp18_team69/vivado_final/vivado_final.runs/block_mem_1x786432_synth_1/block_mem_1x786432_sim_netlist.v -of_objects [get_files /home/cc/eecs151/sp18/class/eecs151-aaq/sp18_team69/hardware/src/video/framebuffer_ram_1x786432/framebuffer_ram_1x786432/block_mem_1x786432.xci]

add_files /home/cc/eecs151/sp18/class/eecs151-aaq/sp18_team69/vivado_final/vivado_final.runs/block_mem_1x786432_synth_1/block_mem_1x786432_sim_netlist.vhdl -of_objects [get_files /home/cc/eecs151/sp18/class/eecs151-aaq/sp18_team69/hardware/src/video/framebuffer_ram_1x786432/framebuffer_ram_1x786432/block_mem_1x786432.xci]

add_files /home/cc/eecs151/sp18/class/eecs151-aaq/sp18_team69/vivado_final/vivado_final.runs/block_mem_1x786432_synth_1/block_mem_1x786432.dcp -of_objects [get_files /home/cc/eecs151/sp18/class/eecs151-aaq/sp18_team69/hardware/src/video/framebuffer_ram_1x786432/framebuffer_ram_1x786432/block_mem_1x786432.xci]

if {[file isdir /home/cc/eecs151/sp18/class/eecs151-aaq/sp18_team69/vivado_final/vivado_final.ip_user_files/ip/block_mem_1x786432]} {
  catch { 
    file copy -force /home/cc/eecs151/sp18/class/eecs151-aaq/sp18_team69/vivado_final/vivado_final.runs/block_mem_1x786432_synth_1/block_mem_1x786432_sim_netlist.v /home/cc/eecs151/sp18/class/eecs151-aaq/sp18_team69/vivado_final/vivado_final.ip_user_files/ip/block_mem_1x786432
  }
}

if {[file isdir /home/cc/eecs151/sp18/class/eecs151-aaq/sp18_team69/vivado_final/vivado_final.ip_user_files/ip/block_mem_1x786432]} {
  catch { 
    file copy -force /home/cc/eecs151/sp18/class/eecs151-aaq/sp18_team69/vivado_final/vivado_final.runs/block_mem_1x786432_synth_1/block_mem_1x786432_sim_netlist.vhdl /home/cc/eecs151/sp18/class/eecs151-aaq/sp18_team69/vivado_final/vivado_final.ip_user_files/ip/block_mem_1x786432
  }
}

if {[file isdir /home/cc/eecs151/sp18/class/eecs151-aaq/sp18_team69/vivado_final/vivado_final.ip_user_files/ip/block_mem_1x786432]} {
  catch { 
    file copy -force /home/cc/eecs151/sp18/class/eecs151-aaq/sp18_team69/vivado_final/vivado_final.runs/block_mem_1x786432_synth_1/block_mem_1x786432_stub.v /home/cc/eecs151/sp18/class/eecs151-aaq/sp18_team69/vivado_final/vivado_final.ip_user_files/ip/block_mem_1x786432
  }
}

if {[file isdir /home/cc/eecs151/sp18/class/eecs151-aaq/sp18_team69/vivado_final/vivado_final.ip_user_files/ip/block_mem_1x786432]} {
  catch { 
    file copy -force /home/cc/eecs151/sp18/class/eecs151-aaq/sp18_team69/vivado_final/vivado_final.runs/block_mem_1x786432_synth_1/block_mem_1x786432_stub.vhdl /home/cc/eecs151/sp18/class/eecs151-aaq/sp18_team69/vivado_final/vivado_final.ip_user_files/ip/block_mem_1x786432
  }
}
