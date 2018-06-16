# 
# Synthesis run script generated by Vivado
# 

set_param simulator.modelsimInstallPath D:/modeltech_10.4/win64
set_msg_config -id {HDL 9-1061} -limit 100000
set_msg_config -id {HDL 9-1654} -limit 100000
create_project -in_memory -part xc7vx485tffg1157-1

set_param project.compositeFile.enableAutoGeneration 0
set_param synth.vivado.isSynthRun true
set_property webtalk.parent_dir D:/tjj/modulation_first_try/vvd/project_2/project_2.cache/wt [current_project]
set_property parent.project_path D:/tjj/modulation_first_try/vvd/project_2/project_2.xpr [current_project]
set_property default_lib xil_defaultlib [current_project]
set_property target_language Verilog [current_project]
set_property vhdl_version vhdl_2k [current_fileset]
add_files -quiet D:/tjj/modulation_first_try/vvd/project_2/project_2.runs/fifo_generator_0_synth_1/fifo_generator_0.dcp
set_property used_in_implementation false [get_files D:/tjj/modulation_first_try/vvd/project_2/project_2.runs/fifo_generator_0_synth_1/fifo_generator_0.dcp]
read_vhdl -library xil_defaultlib {
  D:/tjj/modulation_first_try/src/posedge_det.vhd
  D:/tjj/modulation_first_try/src/data_cache.vhd
}
synth_design -top data_cache -part xc7vx485tffg1157-1
write_checkpoint -noxdef data_cache.dcp
catch { report_utilization -file data_cache_utilization_synth.rpt -pb data_cache_utilization_synth.pb }