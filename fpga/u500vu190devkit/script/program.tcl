open_hw
connect_hw_server -url localhost:3121
current_hw_target [get_hw_targets */xilinx_tcf/Digilent/210308A1D511]
set_property PARAM.FREQUENCY 15000000 [get_hw_targets */xilinx_tcf/Digilent/210308A1D511]

open_hw_target

current_hw_device [lindex [get_hw_devices xcvu190_0] 0]
refresh_hw_device -update_hw_probes false [lindex [get_hw_devices xcvu190_0] 0]

set_property PROBES.FILE {} [lindex [get_hw_devices xcvu190_0] 0]
set_property PROGRAM.FILE {/home/aharris/sifive.freedom.unleashed.u500vu190devkit.U500VU190DevKitConfig.bit} [lindex [get_hw_devices xcvu190_0] 0]
program_hw_devices [lindex [get_hw_devices xcvu190_0] 0]
