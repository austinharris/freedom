
################################################################
# This is a generated script based on design: vu190_xdma
#
# Though there are limitations about the generated script,
# the main purpose of this utility is to make learning
# IP Integrator Tcl commands easier.
################################################################

namespace eval _tcl {
proc get_script_folder {} {
   set script_path [file normalize [info script]]
   set script_folder [file dirname $script_path]
   return $script_folder
}
}
variable script_folder
set script_folder [_tcl::get_script_folder]

################################################################
# Check if script is running in correct Vivado version.
################################################################
set scripts_vivado_version 2017.1
set current_vivado_version [version -short]

if { [string first $scripts_vivado_version $current_vivado_version] == -1 } {
   puts ""
   catch {common::send_msg_id "BD_TCL-109" "ERROR" "This script was generated using Vivado <$scripts_vivado_version> and is being run in <$current_vivado_version> of Vivado. Please run the script in Vivado <$scripts_vivado_version> then open the design in Vivado <$current_vivado_version>. Upgrade the design by running \"Tools => Report => Report IP Status...\", then run write_bd_tcl to create an updated script."}

   return 1
}

################################################################
# START
################################################################

# To test this script, run the following commands from Vivado Tcl console:
# source vu190_xdma_script.tcl

# If there is no project opened, this script will create a
# project, but make sure you do not have an existing project
# <./myproj/project_1.xpr> in the current working folder.

set list_projs [get_projects -quiet]
if { $list_projs eq "" } {
   create_project project_1 myproj -part xcvu190-flgb2104-2-e
}


# CHANGE DESIGN NAME HERE
set design_name vu190_xdma_bd

# If you do not already have an existing IP Integrator design open,
# you can create a design using the following command:
#    create_bd_design $design_name

# Creating design if needed
set errMsg ""
set nRet 0

set cur_design [current_bd_design -quiet]
set list_cells [get_bd_cells -quiet]

if { ${design_name} eq "" } {
   # USE CASES:
   #    1) Design_name not set

   set errMsg "Please set the variable <design_name> to a non-empty value."
   set nRet 1

} elseif { ${cur_design} ne "" && ${list_cells} eq "" } {
   # USE CASES:
   #    2): Current design opened AND is empty AND names same.
   #    3): Current design opened AND is empty AND names diff; design_name NOT in project.
   #    4): Current design opened AND is empty AND names diff; design_name exists in project.

   if { $cur_design ne $design_name } {
      common::send_msg_id "BD_TCL-001" "INFO" "Changing value of <design_name> from <$design_name> to <$cur_design> since current design is empty."
      set design_name [get_property NAME $cur_design]
   }
   common::send_msg_id "BD_TCL-002" "INFO" "Constructing design in IPI design <$cur_design>..."

} elseif { ${cur_design} ne "" && $list_cells ne "" && $cur_design eq $design_name } {
   # USE CASES:
   #    5) Current design opened AND has components AND same names.

   set errMsg "Design <$design_name> already exists in your project, please set the variable <design_name> to another value."
   set nRet 1
} elseif { [get_files -quiet ${design_name}.bd] ne "" } {
   # USE CASES: 
   #    6) Current opened design, has components, but diff names, design_name exists in project.
   #    7) No opened design, design_name exists in project.

   set errMsg "Design <$design_name> already exists in your project, please set the variable <design_name> to another value."
   set nRet 2

} else {
   # USE CASES:
   #    8) No opened design, design_name not in project.
   #    9) Current opened design, has components, but diff names, design_name not in project.

   common::send_msg_id "BD_TCL-003" "INFO" "Currently there is no design <$design_name> in project, so creating one..."

   create_bd_design $design_name

   common::send_msg_id "BD_TCL-004" "INFO" "Making design <$design_name> as current_bd_design."
   current_bd_design $design_name

}

common::send_msg_id "BD_TCL-005" "INFO" "Currently the variable <design_name> is equal to \"$design_name\"."

if { $nRet != 0 } {
   catch {common::send_msg_id "BD_TCL-114" "ERROR" $errMsg}
   return $nRet
}

##################################################################
# DESIGN PROCs
##################################################################



# Procedure to create entire design; Provide argument to make
# procedure reusable. If parentCell is "", will use root.
proc create_root_design { parentCell } {

  variable script_folder

  if { $parentCell eq "" } {
     set parentCell [get_bd_cells /]
  }

  # Get object for parentCell
  set parentObj [get_bd_cells $parentCell]
  if { $parentObj == "" } {
     catch {common::send_msg_id "BD_TCL-100" "ERROR" "Unable to find parent cell <$parentCell>!"}
     return
  }

  # Make sure parentObj is hier blk
  set parentType [get_property TYPE $parentObj]
  if { $parentType ne "hier" } {
     catch {common::send_msg_id "BD_TCL-101" "ERROR" "Parent <$parentObj> has TYPE = <$parentType>. Expected to be <hier>."}
     return
  }

  # Save current instance; Restore later
  set oldCurInst [current_bd_instance .]

  # Set parent object as current
  current_bd_instance $parentObj


  # Create interface ports
  set c0_ddr4 [ create_bd_intf_port -mode Master -vlnv xilinx.com:interface:ddr4_rtl:1.0 c0_ddr4 ]
  set c0_ddr4_s_axi [ create_bd_intf_port -mode Slave -vlnv xilinx.com:interface:aximm_rtl:1.0 c0_ddr4_s_axi ]
  set_property -dict [ list \
CONFIG.ADDR_WIDTH {35} \
CONFIG.ARUSER_WIDTH {0} \
CONFIG.AWUSER_WIDTH {0} \
CONFIG.BUSER_WIDTH {0} \
CONFIG.DATA_WIDTH {256} \
CONFIG.FREQ_HZ {100000000} \
CONFIG.HAS_BRESP {1} \
CONFIG.HAS_BURST {1} \
CONFIG.HAS_CACHE {1} \
CONFIG.HAS_LOCK {1} \
CONFIG.HAS_PROT {1} \
CONFIG.HAS_QOS {1} \
CONFIG.HAS_REGION {0} \
CONFIG.HAS_RRESP {1} \
CONFIG.HAS_WSTRB {1} \
CONFIG.ID_WIDTH {4} \
CONFIG.MAX_BURST_LENGTH {256} \
CONFIG.NUM_READ_OUTSTANDING {2} \
CONFIG.NUM_READ_THREADS {1} \
CONFIG.NUM_WRITE_OUTSTANDING {2} \
CONFIG.NUM_WRITE_THREADS {1} \
CONFIG.PROTOCOL {AXI4} \
CONFIG.READ_WRITE_MODE {READ_WRITE} \
CONFIG.RUSER_BITS_PER_BYTE {0} \
CONFIG.RUSER_WIDTH {0} \
CONFIG.SUPPORTS_NARROW_BURST {1} \
CONFIG.WUSER_BITS_PER_BYTE {0} \
CONFIG.WUSER_WIDTH {0} \
 ] $c0_ddr4_s_axi
  set c0_ddr4_s_axi_ctrl [ create_bd_intf_port -mode Slave -vlnv xilinx.com:interface:aximm_rtl:1.0 c0_ddr4_s_axi_ctrl ]
  set_property -dict [ list \
CONFIG.ADDR_WIDTH {32} \
CONFIG.ARUSER_WIDTH {0} \
CONFIG.AWUSER_WIDTH {0} \
CONFIG.BUSER_WIDTH {0} \
CONFIG.DATA_WIDTH {32} \
CONFIG.HAS_BRESP {1} \
CONFIG.HAS_BURST {0} \
CONFIG.HAS_CACHE {0} \
CONFIG.HAS_LOCK {0} \
CONFIG.HAS_PROT {0} \
CONFIG.HAS_QOS {0} \
CONFIG.HAS_REGION {0} \
CONFIG.HAS_RRESP {1} \
CONFIG.HAS_WSTRB {0} \
CONFIG.ID_WIDTH {0} \
CONFIG.MAX_BURST_LENGTH {1} \
CONFIG.NUM_READ_OUTSTANDING {1} \
CONFIG.NUM_READ_THREADS {1} \
CONFIG.NUM_WRITE_OUTSTANDING {1} \
CONFIG.NUM_WRITE_THREADS {1} \
CONFIG.PROTOCOL {AXI4LITE} \
CONFIG.READ_WRITE_MODE {READ_WRITE} \
CONFIG.RUSER_BITS_PER_BYTE {0} \
CONFIG.RUSER_WIDTH {0} \
CONFIG.SUPPORTS_NARROW_BURST {0} \
CONFIG.WUSER_BITS_PER_BYTE {0} \
CONFIG.WUSER_WIDTH {0} \
 ] $c0_ddr4_s_axi_ctrl
  set c0_sys [ create_bd_intf_port -mode Slave -vlnv xilinx.com:interface:diff_clock_rtl:1.0 c0_sys ]
  set_property -dict [ list \
CONFIG.FREQ_HZ {100000000} \
 ] $c0_sys
  set pcie_7x_mgt_rtl [ create_bd_intf_port -mode Master -vlnv xilinx.com:interface:pcie_7x_mgt_rtl:1.0 pcie_7x_mgt_rtl ]

  # Create ports
  set c0_ddr4_ui_clk [ create_bd_port -dir O -type clk c0_ddr4_ui_clk ]
  set_property -dict [ list \
CONFIG.ASSOCIATED_BUSIF {c0_ddr4_s_axi_ctrl} \
 ] $c0_ddr4_ui_clk
  set c0_init_calib_complete [ create_bd_port -dir O c0_init_calib_complete ]
  set core_clk [ create_bd_port -dir I -type clk core_clk ]
  set_property -dict [ list \
CONFIG.FREQ_HZ {100000000} \
 ] $core_clk
  set host_done [ create_bd_port -dir O -from 0 -to 0 host_done ]
  set pcie_refclk [ create_bd_port -dir I -type clk pcie_refclk ]
  set_property -dict [ list \
CONFIG.CLK_DOMAIN {vu190_xdma_util_ds_buf_0_IBUF_DS_ODIV2} \
 ] $pcie_refclk
  set pcie_sys_clk_gt [ create_bd_port -dir I -type clk pcie_sys_clk_gt ]
  set_property -dict [ list \
CONFIG.CLK_DOMAIN {vu190_xdma_util_ds_buf_0_IBUF_OUT} \
 ] $pcie_sys_clk_gt
  set pcie_sys_reset_l [ create_bd_port -dir I -type rst pcie_sys_reset_l ]
  set_property -dict [ list \
CONFIG.POLARITY {ACTIVE_LOW} \
 ] $pcie_sys_reset_l
  set s01_aclk [ create_bd_port -dir O -type clk s01_aclk ]
  set_property -dict [ list \
CONFIG.ASSOCIATED_BUSIF {} \
 ] $s01_aclk
  set s01_aresetn [ create_bd_port -dir O s01_aresetn ]
  set sys_reset [ create_bd_port -dir I -type rst sys_reset ]
  set_property -dict [ list \
CONFIG.POLARITY {ACTIVE_HIGH} \
 ] $sys_reset

  # Create instance: axi_bram_ctrl_1, and set properties
  set axi_bram_ctrl_1 [ create_bd_cell -type ip -vlnv xilinx.com:ip:axi_bram_ctrl:4.0 axi_bram_ctrl_1 ]
  set_property -dict [ list \
CONFIG.DATA_WIDTH {256} \
CONFIG.ECC_TYPE {0} \
CONFIG.SINGLE_PORT_BRAM {1} \
 ] $axi_bram_ctrl_1

  # Create instance: axi_mem_intercon, and set properties
  set axi_mem_intercon [ create_bd_cell -type ip -vlnv xilinx.com:ip:axi_interconnect:2.1 axi_mem_intercon ]
  set_property -dict [ list \
CONFIG.NUM_MI {2} \
CONFIG.NUM_SI {2} \
CONFIG.S00_HAS_DATA_FIFO {2} \
CONFIG.S01_HAS_DATA_FIFO {2} \
CONFIG.STRATEGY {2} \
 ] $axi_mem_intercon

  # Create instance: ddr4_0, and set properties

  set parts_file [file join [pwd]/script/MTA36ASF4G72PZ-2G1.csv]
  set ddr4_0 [ create_bd_cell -type ip -vlnv xilinx.com:ip:ddr4:2.2 ddr4_0 ]
  set_property -dict [ list \
CONFIG.C0.CKE_WIDTH {2} \
CONFIG.C0.CS_WIDTH {2} \
CONFIG.C0.DDR4_AxiAddressWidth {35} \
CONFIG.C0.DDR4_AxiDataWidth {256} \
CONFIG.C0.DDR4_CasLatency {11} \
CONFIG.C0.DDR4_CasWriteLatency {11} \
CONFIG.C0.DDR4_CustomParts $parts_file \
CONFIG.C0.DDR4_DataMask {NONE} \
CONFIG.C0.DDR4_DataWidth {72} \
CONFIG.C0.DDR4_InputClockPeriod {10000} \
CONFIG.C0.DDR4_MemoryPart {MTA36ASF4G72PZ-2G3} \
CONFIG.C0.DDR4_MemoryType {RDIMMs} \
CONFIG.C0.DDR4_Slot {Single} \
CONFIG.C0.DDR4_TimePeriod {1250} \
CONFIG.C0.DDR4_isCustom {true} \
CONFIG.C0.ODT_WIDTH {2} \
 ] $ddr4_0

  # Create instance: proc_sys_reset_0, and set properties
  set proc_sys_reset_0 [ create_bd_cell -type ip -vlnv xilinx.com:ip:proc_sys_reset:5.0 proc_sys_reset_0 ]

  # Create instance: proc_sys_reset_1, and set properties
  set proc_sys_reset_1 [ create_bd_cell -type ip -vlnv xilinx.com:ip:proc_sys_reset:5.0 proc_sys_reset_1 ]

  # Create instance: util_vector_logic_0, and set properties
  set util_vector_logic_0 [ create_bd_cell -type ip -vlnv xilinx.com:ip:util_vector_logic:2.0 util_vector_logic_0 ]
  set_property -dict [ list \
CONFIG.C_SIZE {1} \
 ] $util_vector_logic_0

  # Create instance: xdma_0, and set properties
  set xdma_0 [ create_bd_cell -type ip -vlnv xilinx.com:ip:xdma:3.1 xdma_0 ]
  set_property -dict [ list \
CONFIG.INS_LOSS_NYQ {5} \
CONFIG.axi_data_width {256_bit} \
CONFIG.axisten_freq {125} \
CONFIG.cfg_mgmt_if {true} \
CONFIG.coreclk_freq {250} \
CONFIG.dedicate_perst {true} \
CONFIG.en_gt_selection {true} \
CONFIG.ins_loss_profile {Chip-to-Chip} \
CONFIG.mode_selection {Advanced} \
CONFIG.pcie_blk_locn {X0Y2} \
CONFIG.pf0_base_class_menu {Memory_controller} \
CONFIG.pf0_class_code {FFFF00} \
CONFIG.pf0_class_code_base {FF} \
CONFIG.pf0_class_code_interface {00} \
CONFIG.pf0_class_code_sub {FF} \
CONFIG.pf0_device_id {0054} \
CONFIG.pf0_sub_class_interface_menu {Other_memory_controller} \
CONFIG.pf0_subsystem_id {0054} \
CONFIG.pf0_subsystem_vendor_id {12BA} \
CONFIG.pl_link_cap_max_link_speed {5.0_GT/s} \
CONFIG.pl_link_cap_max_link_width {X8} \
CONFIG.plltype {CPLL} \
CONFIG.select_quad {GTH_Quad_225} \
CONFIG.vendor_id {12BA} \
CONFIG.xdma_axi_intf_mm {AXI_Memory_Mapped} \
CONFIG.xdma_rnum_chnl {2} \
CONFIG.xdma_wnum_chnl {2} \
 ] $xdma_0

  # Create interface connections
  connect_bd_intf_net -intf_net C0_DDR4_S_AXI_CTRL_1 [get_bd_intf_ports c0_ddr4_s_axi_ctrl] [get_bd_intf_pins ddr4_0/C0_DDR4_S_AXI_CTRL]
  connect_bd_intf_net -intf_net S01_AXI_1 [get_bd_intf_ports c0_ddr4_s_axi] [get_bd_intf_pins axi_mem_intercon/S01_AXI]
  connect_bd_intf_net -intf_net axi_mem_intercon_M00_AXI [get_bd_intf_pins axi_bram_ctrl_1/S_AXI] [get_bd_intf_pins axi_mem_intercon/M00_AXI]
  connect_bd_intf_net -intf_net axi_mem_intercon_M01_AXI [get_bd_intf_pins axi_mem_intercon/M01_AXI] [get_bd_intf_pins ddr4_0/C0_DDR4_S_AXI]
  connect_bd_intf_net -intf_net ddr4_0_C0_DDR4 [get_bd_intf_ports c0_ddr4] [get_bd_intf_pins ddr4_0/C0_DDR4]
connect_bd_intf_net -intf_net diff_clock_rtl_0_1 [get_bd_intf_ports c0_sys] [get_bd_intf_pins ddr4_0/C0_SYS_CLK]
  connect_bd_intf_net -intf_net xdma_0_M_AXI [get_bd_intf_pins axi_mem_intercon/S00_AXI] [get_bd_intf_pins xdma_0/M_AXI]
  connect_bd_intf_net -intf_net xdma_0_pcie_mgt [get_bd_intf_ports pcie_7x_mgt_rtl] [get_bd_intf_pins xdma_0/pcie_mgt]

  # Create port connections
  connect_bd_net -net S00_ACLK_1 [get_bd_ports s01_aclk] [get_bd_pins axi_mem_intercon/ACLK] [get_bd_pins axi_mem_intercon/S00_ACLK] [get_bd_pins xdma_0/axi_aclk]
  connect_bd_net -net axi_bram_ctrl_1_s_axi_arready [get_bd_pins axi_bram_ctrl_1/s_axi_arready] [get_bd_pins axi_mem_intercon/M00_AXI_arready] [get_bd_pins util_vector_logic_0/Op1]
  connect_bd_net -net axi_mem_intercon_M00_AXI_arvalid [get_bd_pins axi_bram_ctrl_1/s_axi_arvalid] [get_bd_pins axi_mem_intercon/M00_AXI_arvalid] [get_bd_pins util_vector_logic_0/Op2]
  connect_bd_net -net ddr4_0_c0_ddr4_ui_clk [get_bd_ports c0_ddr4_ui_clk] [get_bd_pins axi_mem_intercon/M01_ACLK] [get_bd_pins ddr4_0/c0_ddr4_ui_clk] [get_bd_pins proc_sys_reset_0/slowest_sync_clk]
  connect_bd_net -net ddr4_0_c0_ddr4_ui_clk_sync_rst [get_bd_pins ddr4_0/c0_ddr4_ui_clk_sync_rst] [get_bd_pins proc_sys_reset_0/ext_reset_in] [get_bd_pins proc_sys_reset_1/ext_reset_in]
  connect_bd_net -net ddr4_0_c0_init_calib_complete [get_bd_ports c0_init_calib_complete] [get_bd_pins ddr4_0/c0_init_calib_complete]
  connect_bd_net -net core_clk_1 [get_bd_ports core_clk] [get_bd_pins axi_bram_ctrl_1/s_axi_aclk] [get_bd_pins axi_mem_intercon/M00_ACLK] [get_bd_pins axi_mem_intercon/S01_ACLK] [get_bd_pins proc_sys_reset_1/slowest_sync_clk]
  connect_bd_net -net proc_sys_reset_0_peripheral_aresetn [get_bd_pins axi_mem_intercon/M01_ARESETN] [get_bd_pins ddr4_0/c0_ddr4_aresetn] [get_bd_pins proc_sys_reset_0/peripheral_aresetn]
  connect_bd_net -net proc_sys_reset_1_peripheral_aresetn [get_bd_pins axi_bram_ctrl_1/s_axi_aresetn] [get_bd_pins axi_mem_intercon/M00_ARESETN] [get_bd_pins axi_mem_intercon/S01_ARESETN] [get_bd_pins proc_sys_reset_1/peripheral_aresetn]
  connect_bd_net -net reset_rtl_0_1 [get_bd_ports sys_reset] [get_bd_pins ddr4_0/sys_rst]
  connect_bd_net -net reset_rtl_1 [get_bd_ports pcie_sys_reset_l] [get_bd_pins xdma_0/sys_rst_n]
  connect_bd_net -net sys_clk_1 [get_bd_ports pcie_refclk] [get_bd_pins xdma_0/sys_clk]
  connect_bd_net -net sys_clk_gt_1 [get_bd_ports pcie_sys_clk_gt] [get_bd_pins xdma_0/sys_clk_gt]
  connect_bd_net -net util_vector_logic_0_Res [get_bd_ports host_done] [get_bd_pins util_vector_logic_0/Res]
  connect_bd_net -net xdma_0_axi_aresetn [get_bd_ports s01_aresetn] [get_bd_pins axi_mem_intercon/ARESETN] [get_bd_pins axi_mem_intercon/S00_ARESETN] [get_bd_pins xdma_0/axi_aresetn]

  # Create address segments
  create_bd_addr_seg -range 0x00002000 -offset 0x000800000000 [get_bd_addr_spaces xdma_0/M_AXI] [get_bd_addr_segs axi_bram_ctrl_1/S_AXI/Mem0] SEG_axi_bram_ctrl_1_Mem0
  create_bd_addr_seg -range 0x000800000000 -offset 0x00000000 [get_bd_addr_spaces xdma_0/M_AXI] [get_bd_addr_segs ddr4_0/C0_DDR4_MEMORY_MAP/C0_DDR4_ADDRESS_BLOCK] SEG_ddr4_0_C0_DDR4_ADDRESS_BLOCK
  create_bd_addr_seg -range 0x000800000000 -offset 0x00000000 [get_bd_addr_spaces c0_ddr4_s_axi] [get_bd_addr_segs ddr4_0/C0_DDR4_MEMORY_MAP/C0_DDR4_ADDRESS_BLOCK] SEG_ddr4_0_C0_DDR4_ADDRESS_BLOCK
  create_bd_addr_seg -range 0x00100000 -offset 0x80000000 [get_bd_addr_spaces c0_ddr4_s_axi_ctrl] [get_bd_addr_segs ddr4_0/C0_DDR4_MEMORY_MAP_CTRL/C0_REG] SEG_ddr4_0_C0_REG


  # Restore current instance
  current_bd_instance $oldCurInst

  save_bd_design
}
# End of create_root_design()


##################################################################
# MAIN FLOW
##################################################################

create_root_design ""


