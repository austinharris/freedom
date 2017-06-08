set_param {messaging.defaultLimit} 1000000

synth_ip [get_ips vu190_xdma]

synth_design -top $top -flatten_hierarchy rebuilt
write_checkpoint -force [file join $wrkdir post_synth]

opt_design
write_checkpoint -force [file join $wrkdir post_opt]

place_design
write_checkpoint -force [file join $wrkdir post_place]

phys_opt_design
power_opt_design
route_design
write_checkpoint -force [file join $wrkdir post_route]

write_bitstream -force [file join $wrkdir "${top}.bit"]
write_sdf -force [file join $wrkdir "${top}.sdf"]
write_verilog -mode timesim -force [file join ${wrkdir} "${top}.v"]
write_debug_probes -force [file join $wrkdir "${top}.ltx"]

set rptdir [file join $wrkdir report]
file mkdir $rptdir
set rptutil [file join $rptdir utilization.txt]
report_datasheet -file [file join $rptdir datasheet.txt]
report_utilization -hierarchical -file $rptutil
report_clock_utilization -file $rptutil -append
report_ram_utilization -file $rptutil -append -detail
report_timing_summary -file [file join $rptdir timing.txt] -max_paths 10
report_high_fanout_nets -file [file join $rptdir fanout.txt] -timing -load_types -max_nets 25
report_drc -file [file join $rptdir drc.txt]
report_io -file [file join $rptdir io.txt]
report_clocks -file [file join $rptdir clocks.txt]
