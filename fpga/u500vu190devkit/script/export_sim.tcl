set_property target_simulator VCS [current_project]

set simlibdir [file join [pwd] {.cache/compile_simlib}]
set vcsdir [file join $::env(VCS_HOME) /bin]
compile_simlib -language all -dir $simlibdir -simulator vcs_mx -simulator_exec_path $::env(VCS_HOME)/bin -library all -family  all

set_param {messaging.defaultLimit} 1000000

generate_target all [get_ips vu190_xdma]

export_simulation -lib_map_path $simlibdir -directory [pwd] -simulator vcs -force
