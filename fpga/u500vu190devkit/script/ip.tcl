source [file join $scriptdir vu190_xdma_bd.tcl]
ipx::package_project -root_dir $ipdir -vendor user.org -library user -taxonomy /UserIP -module vu190_xdma_bd -import_files
set_property core_revision 2 [ipx::find_open_core user.org:user:vu190_xdma_bd:1.0]
ipx::create_xgui_files [ipx::find_open_core user.org:user:vu190_xdma_bd:1.0]
ipx::update_checksums [ipx::find_open_core user.org:user:vu190_xdma_bd:1.0]
ipx::save_core [ipx::find_open_core user.org:user:vu190_xdma_bd:1.0]
update_ip_catalog -rebuild
create_ip -vendor user.org -name vu190_xdma_bd -library user -version 1.0 -module_name vu190_xdma
set bd_file [file join $commondir/.srcs/sources_1/ip/vu190_xdma/vu190_xdma.xci]
generate_target all [get_files $bd_file]

#MIG
# create_ip -vendor xilinx.com -library ip -name ddr4 -version 2.1 -module_name vu190mig -dir $ipdir -force
# set ddrfile [file join [pwd] $scriptdir {MTA36ASF4G72PZ-2G1.csv}]
# set_property -dict [ list \
#                          CONFIG.ADDN_UI_CLKOUT1_FREQ_HZ {None} \
#                          CONFIG.C0.CKE_WIDTH {2} \
#                          CONFIG.C0.CS_WIDTH {2} \
#                          CONFIG.C0.DDR4_AxiAddressWidth {35} \
#                          CONFIG.C0.DDR4_AxiDataWidth {64} \
#                          CONFIG.C0.DDR4_CLKOUT0_DIVIDE {7} \
#                          CONFIG.C0.DDR4_CasLatency {11} \
#                          CONFIG.C0.DDR4_CasWriteLatency {11} \
#                          CONFIG.C0.DDR4_DataMask {NONE} \
#                          CONFIG.C0.DDR4_DataWidth {72} \
#                          CONFIG.C0.DDR4_Ecc {true} \
#                          CONFIG.C0.DDR4_InputClockPeriod {10000} \
#                          CONFIG.C0.DDR4_MemoryPart {MTA36ASF4G72PZ-2G3} \
#                          CONFIG.C0.DDR4_MemoryType {RDIMMs} \
#                          CONFIG.C0.DDR4_Slot {Single} \
#                          CONFIG.C0.DDR4_TimePeriod {1250} \
#                          CONFIG.C0.DDR4_isCustom {true} \
#                          CONFIG.C0.ODT_WIDTH {2} \
#                         ] [get_ips vu190mig]
# #set migprj [file join [pwd] $scriptdir {mig.prj}] 
# #set_property CONFIG.XML_INPUT_FILE $migprj [get_ips vu190mig]

# puts "SCRIPTDIR $scriptdir"

# # #DMA
# create_ip -vendor xilinx.com -library ip -version 3.0 -name xdma -module_name vu190_xdma_x1 -dir $ipdir -force
# set_property -dict [ list \
#                          CONFIG.INS_LOSS_NYQ {5} \
#                          CONFIG.axi_data_width {64_bit} \
#                          CONFIG.axisten_freq {62.5} \
#                          CONFIG.cfg_mgmt_if {true} \
#                          CONFIG.coreclk_freq {250} \
#                          CONFIG.dedicate_perst {true} \
#                          CONFIG.en_gt_selection {true} \
#                          CONFIG.ins_loss_profile {Chip-to-Chip} \
#                          CONFIG.mode_selection {Advanced} \
#                          CONFIG.pcie_blk_locn {X0Y2} \
#                          CONFIG.pf0_base_class_menu {Memory_controller} \
#                          CONFIG.pf0_class_code {FFFF00} \
#                          CONFIG.pf0_class_code_base {FF} \
#                          CONFIG.pf0_class_code_interface {00} \
#                          CONFIG.pf0_class_code_sub {FF} \
#                          CONFIG.pf0_device_id {0054} \
#                          CONFIG.pf0_sub_class_interface_menu {Other_memory_controller} \
#                          CONFIG.pf0_subsystem_id {0054} \
#                          CONFIG.pf0_subsystem_vendor_id {12BA} \
#                          CONFIG.pl_link_cap_max_link_speed {2.5_GT/s} \
#                          CONFIG.pl_link_cap_max_link_width {X1} \
#                          CONFIG.plltype {CPLL} \
#                          CONFIG.select_quad {GTH_Quad_225} \
#                          CONFIG.vendor_id {12BA} \
#                          CONFIG.xdma_axi_intf_mm {AXI_Memory_Mapped} \
#                          CONFIG.xdma_rnum_chnl {2} \
#                          CONFIG.xdma_wnum_chnl {2} \
#                         ] [get_ips vu190_xdma_x1]

# create_ip -vendor xilinx.com -library ip -version 2.1 -name axi_crossbar -module_name vu190_axi_crossbar -dir $ipdir -force
# set_property -dict [ list \
#                          CONFIG.NUM_SI {2} \
#                          CONFIG.NUM_MI {5} \
#                          CONFIG.ID_WIDTH {4} \
#                          CONFIG.DATA_WIDTH {64} \
#                         ] [get_ips vu190_axi_crossbar]

# create_ip -vendor xilinx.com -library ip -version 2.1 -name axi_clock_converter -module_name vu190_axi_clock_converter -dir $ipdir -force
# set_property -dict [ list \
#                          CONFIG.ID_WIDTH {4} \
#                          CONFIG.DATA_WIDTH {64} \
#                         ] [get_ips vu190_axi_crossbar]


# #AXI_PCIE
# create_ip -vendor xilinx.com -library ip -version 3.0 -name axi_pcie3 -module_name vu190axi_to_pcie_x1 -dir $ipdir -force
# set_property -dict [ list \
# CONFIG.axi_aclk_loopback {true} \
# CONFIG.axi_data_width {128_bit} \
# CONFIG.axibar2pciebar_0 {0x0000000000000000} \
# CONFIG.axibar_0 {0x0000000060000000} \
# CONFIG.axibar_highaddr_0 {0x000000007fffffff} \
# CONFIG.axisten_freq {125} \
# CONFIG.comp_timeout {50ms} \
# CONFIG.coreclk_freq {250} \
# CONFIG.dedicate_perst {true} \
# CONFIG.en_axi_slave_if {true} \
# CONFIG.en_axi_master_if {true} \
# CONFIG.en_ext_ch_gt_drp {false} \
# CONFIG.en_gt_selection {true} \
# CONFIG.en_pcie_drp {false} \
# CONFIG.mode_selection {Advanced} \
# CONFIG.pcie_blk_locn {X0Y2} \
# CONFIG.pciebar2axibar_0 {0x43c00000} \
# CONFIG.pf0_class_code {FFFF00} \
# CONFIG.pf0_class_code_base {FF} \
# CONFIG.pf0_class_code_sub {FF} \
# CONFIG.pf0_device_id {0054} \
# CONFIG.pf0_link_status_slot_clock_config {true} \
# CONFIG.pf0_msi_enabled {true} \
# CONFIG.pf0_subsystem_id {0054} \
# CONFIG.pf0_subsystem_vendor_id {12BA} \
# CONFIG.pl_link_cap_max_link_speed {2.5_GT/s} \
# CONFIG.pl_link_cap_max_link_width {X8} \
# CONFIG.plltype {CPLL} \
# CONFIG.select_quad {GTH_Quad_225} \
# CONFIG.vendor_id {12BA} \
# ] [get_ips vu190axi_to_pcie_x1]
# # set_property -dict [list \
# # CONFIG.AXIBAR2PCIEBAR_0             {0x60000000} \
# # CONFIG.AXIBAR2PCIEBAR_1             {0x00000000} \
# # CONFIG.AXIBAR2PCIEBAR_2             {0x00000000} \
# # CONFIG.AXIBAR2PCIEBAR_3             {0x00000000} \
# # CONFIG.AXIBAR2PCIEBAR_4             {0x00000000} \
# # CONFIG.AXIBAR2PCIEBAR_5             {0x00000000} \
# # CONFIG.AXIBAR_0                     {0x60000000} \
# # CONFIG.AXIBAR_1                     {0xFFFFFFFF} \
# # CONFIG.AXIBAR_2                     {0xFFFFFFFF} \
# # CONFIG.AXIBAR_3                     {0xFFFFFFFF} \
# # CONFIG.AXIBAR_4                     {0xFFFFFFFF} \
# # CONFIG.AXIBAR_5                     {0xFFFFFFFF} \
# # CONFIG.AXIBAR_AS_0                  {true} \
# # CONFIG.AXIBAR_AS_1                  {false} \
# # CONFIG.AXIBAR_AS_2                  {false} \
# # CONFIG.AXIBAR_AS_3                  {false} \
# # CONFIG.AXIBAR_AS_4                  {false} \
# # CONFIG.AXIBAR_AS_5                  {false} \
# # CONFIG.AXIBAR_HIGHADDR_0            {0x7FFFFFFF} \
# # CONFIG.AXIBAR_HIGHADDR_1            {0x00000000} \
# # CONFIG.AXIBAR_HIGHADDR_2            {0x00000000} \
# # CONFIG.AXIBAR_HIGHADDR_3            {0x00000000} \
# # CONFIG.AXIBAR_HIGHADDR_4            {0x00000000} \
# # CONFIG.AXIBAR_HIGHADDR_5            {0x00000000} \
# # CONFIG.AXIBAR_NUM                   {1} \
# # CONFIG.BAR0_ENABLED                 {true} \
# # CONFIG.BAR0_SCALE                   {Gigabytes} \
# # CONFIG.BAR0_SIZE                    {4} \
# # CONFIG.BAR0_TYPE                    {Memory} \
# # CONFIG.BAR1_ENABLED                 {false} \
# # CONFIG.BAR1_SCALE                   {N/A} \
# # CONFIG.BAR1_SIZE                    {8} \
# # CONFIG.BAR1_TYPE                    {N/A} \
# # CONFIG.BAR2_ENABLED                 {false} \
# # CONFIG.BAR2_SCALE                   {N/A} \
# # CONFIG.BAR2_SIZE                    {8} \
# # CONFIG.BAR2_TYPE                    {N/A} \
# # CONFIG.BAR_64BIT                    {true} \
# # CONFIG.BASEADDR                     {0x50000000} \
# # CONFIG.BASE_CLASS_MENU              {Bridge_device} \
# # CONFIG.CLASS_CODE                   {0x060400} \
# # CONFIG.COMP_TIMEOUT                 {50us} \
# # CONFIG.Component_Name               {design_1_axi_pcie_1_0} \
# # CONFIG.DEVICE_ID                    {0x7111} \
# # CONFIG.ENABLE_CLASS_CODE            {true} \
# # CONFIG.HIGHADDR                     {0x53FFFFFF} \
# # CONFIG.INCLUDE_BAROFFSET_REG        {true} \
# # CONFIG.INCLUDE_RC                   {Root_Port_of_PCI_Express_Root_Complex} \
# # CONFIG.INTERRUPT_PIN                {false} \
# # CONFIG.MAX_LINK_SPEED               {2.5_GT/s} \
# # CONFIG.MSI_DECODE_ENABLED           {true} \
# # CONFIG.M_AXI_ADDR_WIDTH             {32} \
# # CONFIG.M_AXI_DATA_WIDTH             {64} \
# # CONFIG.NO_OF_LANES                  {X1} \
# # CONFIG.NUM_MSI_REQ                  {0} \
# # CONFIG.PCIEBAR2AXIBAR_0_SEC         {1} \
# # CONFIG.PCIEBAR2AXIBAR_0             {0x00000000} \
# # CONFIG.PCIEBAR2AXIBAR_1             {0xFFFFFFFF} \
# # CONFIG.PCIEBAR2AXIBAR_1_SEC         {1} \
# # CONFIG.PCIEBAR2AXIBAR_2             {0xFFFFFFFF} \
# # CONFIG.PCIEBAR2AXIBAR_2_SEC         {1} \
# # CONFIG.PCIE_BLK_LOCN                {X1Y1} \
# # CONFIG.PCIE_USE_MODE                {GES_and_Production} \
# # CONFIG.REF_CLK_FREQ                 {100_MHz} \
# # CONFIG.REV_ID                       {0x00} \
# # CONFIG.SLOT_CLOCK_CONFIG            {true} \
# # CONFIG.SUBSYSTEM_ID                 {0x0007} \
# # CONFIG.SUBSYSTEM_VENDOR_ID          {0x10EE} \
# # CONFIG.SUB_CLASS_INTERFACE_MENU     {Host_bridge} \
# # CONFIG.S_AXI_ADDR_WIDTH             {32} \
# # CONFIG.S_AXI_DATA_WIDTH             {64} \
# # CONFIG.S_AXI_ID_WIDTH               {4} \
# # CONFIG.S_AXI_SUPPORTS_NARROW_BURST  {false} \
# # CONFIG.VENDOR_ID                    {0x10EE} \
# # CONFIG.XLNX_REF_BOARD               {None} \
# # CONFIG.axi_aclk_loopback            {false} \
# # CONFIG.en_ext_ch_gt_drp             {false} \
# # CONFIG.en_ext_clk                   {false} \
# # CONFIG.en_ext_gt_common             {false} \
# # CONFIG.en_ext_pipe_interface        {false} \
# # CONFIG.en_transceiver_status_ports  {false} \
# # CONFIG.no_slv_err                   {false} \
# # CONFIG.rp_bar_hide                  {true} \
# # CONFIG.shared_logic_in_core         {false} ] [get_ips vu190axi_to_pcie_x1]

