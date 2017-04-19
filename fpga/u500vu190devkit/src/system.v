// See LICENSE for license details.
`timescale 1ns/1ps
`default_nettype none

module system
(
  input wire         ddr4_sys_clk_1_p,
  input wire         ddr4_sys_clk_1_n,
  //active low reset
  input wire         sys_rst_l,
  // DDR4 Interface
  output wire        m0_ddr4_act_n,
  output wire [16:0] m0_ddr4_adr,
  output wire [1:0]  m0_ddr4_ba,
  output wire [1:0]  m0_ddr4_bg,
  output wire [1:0]  m0_ddr4_cke,
  output wire [1:0]  m0_ddr4_odt,
  output wire [3:0]  m0_ddr4_cs_n,
  output wire [0:0]  m0_ddr4_ck_t,
  output wire [0:0]  m0_ddr4_ck_c,
  output wire        m0_ddr4_reset_n,
  output wire        m0_ddr4_parity,
  inout wire [71:0]  m0_ddr4_dq,
  inout wire [17:0]  m0_ddr4_dqs_t,
  inout wire [17:0]  m0_ddr4_dqs_c,
  // LED
  output wire [3:0]  led,
  //UART
  input wire         uart_tx,
  output wire        uart_rx,
  input wire         uart_rtsn,
  output wire        uart_ctsn,
  //PCIe
  output wire [0:0]  pcie_7x_mgt_rtl_txp,
  output wire [0:0]  pcie_7x_mgt_rtl_txn,
  input wire [0:0]   pcie_7x_mgt_rtl_rxp,
  input wire [0:0]   pcie_7x_mgt_rtl_rxn,
  input wire         pcie_sys_clkp,
  input wire         pcie_sys_clkn,
  input wire         pcie_sys_clk_1_p,
  input wire         pcie_sys_clk_1_n,
  input wire         pcie_sys_reset_l,
 //MISC
  input wire         rd_prsnt_l_1,
  input wire         rd_prsnt_l_2,
  input wire         rd_prsnt_l_3,
  input wire         rd_prsnt_l_4,
  input wire         sep_prsnt_l,
  input wire         pcie_bp_l,
  output wire        fpga_i2c_master_l
);

reg [1:0] uart_rx_sync;
wire [3:0] sd_spi_dq_i;
wire [3:0] sd_spi_dq_o;
wire sd_spi_sck;
wire sd_spi_cs;
wire top_clock,top_reset;

U500VU190DevKitTop top
(
  //UART
  .io_uarts_0_rxd(uart_rx_sync[1]),
  .io_uarts_0_txd(uart_rx),
  //GPIO
  .io_gpio_pins_0_i_ival(1'b0),
  .io_gpio_pins_1_i_ival(1'b0),
  .io_gpio_pins_2_i_ival(1'b0),
  .io_gpio_pins_3_i_ival(1'b0),
  .io_gpio_pins_0_o_oval(led[0]),
  .io_gpio_pins_1_o_oval(led[1]),
  .io_gpio_pins_2_o_oval(led[2]),
  .io_gpio_pins_3_o_oval(led[3]),
  .io_gpio_pins_0_o_oe(),
  .io_gpio_pins_1_o_oe(),
  .io_gpio_pins_2_o_oe(),
  .io_gpio_pins_3_o_oe(),
  .io_gpio_pins_0_o_pue(),
  .io_gpio_pins_1_o_pue(),
  .io_gpio_pins_2_o_pue(),
  .io_gpio_pins_3_o_pue(),
  .io_gpio_pins_0_o_ds(),
  .io_gpio_pins_1_o_ds(),
  .io_gpio_pins_2_o_ds(),
  .io_gpio_pins_3_o_ds(),
  //MIG
  .io_xilinxvu190xdma__inout_c0_ddr4_dq(m0_ddr4_dq),
  .io_xilinxvu190xdma__inout_c0_ddr4_dqs_t(m0_ddr4_dqs_t),
  .io_xilinxvu190xdma__inout_c0_ddr4_dqs_c(m0_ddr4_dqs_c),
  .io_xilinxvu190xdma_c0_ddr4_act_n(m0_ddr4_act_n),
  .io_xilinxvu190xdma_c0_ddr4_adr(m0_ddr4_adr),
  .io_xilinxvu190xdma_c0_ddr4_ba(m0_ddr4_ba),
  .io_xilinxvu190xdma_c0_ddr4_bg(m0_ddr4_bg),
  .io_xilinxvu190xdma_c0_ddr4_cke(m0_ddr4_cke),
  .io_xilinxvu190xdma_c0_ddr4_odt(m0_ddr4_odt),
  .io_xilinxvu190xdma_c0_ddr4_cs_n(m0_ddr4_cs_n),
  .io_xilinxvu190xdma_c0_ddr4_ck_t(m0_ddr4_ck_t),
  .io_xilinxvu190xdma_c0_ddr4_ck_c(m0_ddr4_ck_c),
  .io_xilinxvu190xdma_c0_ddr4_reset_n(m0_ddr4_reset_n),
  .io_xilinxvu190xdma_c0_ddr4_par(m0_ddr4_parity),
  //Clock + Reset
  .io_pcie_refclk_p(pcie_sys_clkp),
  .io_pcie_refclk_n(pcie_sys_clkn),
  .io_pcie_sys_reset_l(pcie_sys_reset_l),
  .io_ddr4_sys_clk_1_p(ddr4_sys_clk_1_p),
  .io_ddr4_sys_clk_1_n(ddr4_sys_clk_1_n),
  .io_sys_reset(~sys_rst_l),
  .clock(top_clock),
  //Misc outputs for system.v
  .io_core_clock(top_clock),
  .io_core_reset(top_reset)
);

  //UART
  assign uart_ctsn =1'b0;  
  always @(posedge top_clock) begin
    if (top_reset) begin
      uart_rx_sync <= 2'b11;
    end else begin
      uart_rx_sync[0] <= uart_tx;
      uart_rx_sync[1] <= uart_rx_sync[0];
    end
  end

  assign  fpga_i2c_master_l = 1'b0;

endmodule

`default_nettype wire
