open_hw_target

current_hw_device [lindex [get_hw_devices xcvu190_0] 0]
refresh_hw_device -update_hw_probes false [lindex [get_hw_devices xcvu190_0] 0]

set_property PROBES.FILE {} [lindex [get_hw_devices xcvu190_0] 0]
set_property PROGRAM.FILE {/home/aharris/system.bit} [lindex [get_hw_devices xcvu190_0] 0]
program_hw_devices [lindex [get_hw_devices xcvu190_0] 0]
