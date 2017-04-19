`timescale 1ps / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 03/06/2017 10:34:11 AM
// Design Name: 
// Module Name: tb
// Project Name: 
// Target Devices: 
// Tool Versions: 
// Description: 
// 
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////

module tb(

    );

   reg sys_rst;
   reg pcie_sys_clk;
   reg ddr_sys_clk;
   wire pcie_sys_clk_p;
   wire pcie_sys_clk_n;
   wire ddr4_sys_clk_p;
   wire ddr4_sys_clk_n;

   wire  uart_tx;
   wire  uart_rx;
   wire  uart_ctsn;
   wire  uart_rtsn;

   //assign uart_tx = uart_rx;
   assign uart_rtsn = 1'b0;
   initial begin
      pcie_sys_clk = 1'b0;
      forever #(5000) pcie_sys_clk=~pcie_sys_clk;
   end
   initial begin
      ddr_sys_clk = 1'b0;
      forever #(5000) ddr_sys_clk = ~ddr_sys_clk;
   end
     //------------------------------------------------------------------------------//
   // Generate system-level reset
   //------------------------------------------------------------------------------//
   initial begin
     $display("[%t] : System Reset Is Asserted...", $realtime);
     sys_rst = 1'b1;
     repeat (100) begin 
        @(posedge pcie_sys_clk_p);
     end
     sys_rst = 1'b0;
     repeat (500) begin 
        @(posedge pcie_sys_clk_p);
     end
     $display("[%t] : System Reset Is De-asserted...", $realtime);
     sys_rst = 1'b1;
   end

   initial begin
    force system_i.top.host_done = 1'b1;
    //force system_i.uart_ctsn = 1'b0;
   end

   always @(posedge pcie_sys_clk_p) begin
    if (system_i.top.host_done_reg == 1'b1 && sys_rst == 1'b1 && system_i.top.init_calib_complete == 1'b1)
       release system_i.top.host_done;
   end

   assign pcie_sys_clk_p = pcie_sys_clk;
   assign pcie_sys_clk_n = ~pcie_sys_clk;
   assign ddr4_sys_clk_p = ddr_sys_clk;
   assign ddr4_sys_clk_n = ~ddr_sys_clk;


   system system_i(
                   .sys_rst_l(sys_rst),
                   .uart_tx(uart_tx),
                   .uart_rx(uart_rx),
                   .uart_rtsn(uart_rtsn),
                   .uart_ctsn(uart_ctsn),
                   .pcie_sys_reset_l(sys_rst),
                   .pcie_sys_clkp(pcie_sys_clk_p),
                   .pcie_sys_clkn(pcie_sys_clk_n),
                   .ddr4_sys_clk_1_p(ddr4_sys_clk_p),
                   .ddr4_sys_clk_1_n(ddr4_sys_clk_n)
                   );

   initial begin
    $fsdbDumpfile("tb");
    $fsdbDumpvars;
   end
endmodule
