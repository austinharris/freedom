// See LICENSE for license details.
package sifive.freedom.unleashed.u500vu190devkit

import Chisel._
import config._
import util._
import junctions._
import diplomacy._
import uncore.tilelink._
import uncore.tilelink2._
import uncore.axi4._
import uncore.devices._
import uncore.util._
import uncore.converters._
import rocket._
import coreplex._
import rocketchip._

import sifive.blocks.devices.xilinxvu190xdma._
import sifive.blocks.devices.gpio._
import sifive.blocks.devices.spi._
import sifive.blocks.devices.uart._
import sifive.blocks.util.ResetCatchAndSync


class U500VU190DevKitSystem(implicit p: Parameters) extends BaseSystem
    with HasPeripheryBootROM
    with HasPeripheryDebug
    with HasPeripheryRTCCounter
    with HasPeripheryUART
    with HasPeripheryGPIO
    with HasPeripheryXilinxVU190XDMA
    with HasRocketPlexMaster {
  override lazy val module = new U500VU190DevKitSystemModule(this)
}

class U500VU190DevKitSystemModule[+L <: U500VU190DevKitSystem](_outer: L) extends BaseSystemModule(_outer)
    with HasPeripheryBootROMModuleImp
    with HasPeripheryDebugModuleImp
    with HasPeripheryRTCCounterModuleImp
    with HasPeripheryUARTModuleImp
    with HasPeripheryGPIOModuleImp
    with HasPeripheryXilinxVU190XDMAModuleImp
    with HasRocketPlexMasterModuleImp

class U500VU190DevKitIO(implicit p: Parameters) extends Bundle {
  val uarts = Vec(p(PeripheryUARTKey).size, new UARTPortIO)
  val gpio = HeterogeneousBag(p(PeripheryGPIOKey).map(new GPIOPortIO(_)))
  val xilinxvu190xdma = new XilinxVU190XDMAPads
  //Clocks
  val ddr4_sys_clk_1_n = Bool(INPUT)
  val ddr4_sys_clk_1_p = Bool(INPUT)
  val pcie_refclk_p = Bool(INPUT)
  val pcie_refclk_n = Bool(INPUT)
  //Reset
  val sys_reset = Bool(INPUT)
  val pcie_sys_reset_l = Bool(INPUT)
  //Misc outputs used in system.v
  val core_reset = Bool(OUTPUT)
  val core_clock = Clock(OUTPUT)
}

class U500VU190DevKitTop(implicit val p: Parameters) extends Module {

  // ------------------------------------------------------------
  // Instantiate U500 VU190 Dev Kit system (sys)
  // ------------------------------------------------------------
  val sys = Module(LazyModule(new U500VU190DevKitSystem).module)
  val io = new U500VU190DevKitIO

  // ------------------------------------------------------------
  // Clock and Reset
  // ------------------------------------------------------------
  val init_calib_complete = Wire(Bool())
  val do_reset            = Wire(Bool())
  val top_clock           = Wire(Clock())
  val top_reset           = Wire(Bool())
  val host_done           = Wire(Bool())
  val host_done_reg       = Reg(Bool())
  val user_lnk_up         = Wire(Bool())

  when(!init_calib_complete) {
    host_done_reg := Bool(false)
  }
  .elsewhen(host_done) {
    host_done_reg := !host_done_reg
  }

  do_reset             := !host_done_reg || !init_calib_complete// || !user_lnk_up

  top_clock := sys.xilinxvu190xdma.div_clk
  host_done := sys.xilinxvu190xdma.host_done

  sys.clock := top_clock
  sys.reset := top_reset

  top_reset := do_reset


  // ------------------------------------------------------------
  // UART
  // ------------------------------------------------------------
  io.uarts <> sys.uarts

  // ------------------------------------------------------------
  // GPIO
  // ------------------------------------------------------------
  io.gpio <> sys.gpio

  // ------------------------------------------------------------
  // DMA
  // ------------------------------------------------------------
  sys.xilinxvu190xdma.sys_reset               := io.sys_reset
  sys.xilinxvu190xdma.pcie_sys_reset_l        := io.pcie_sys_reset_l
  sys.xilinxvu190xdma.c0_sys_clk_p            := io.ddr4_sys_clk_1_p
  sys.xilinxvu190xdma.c0_sys_clk_n            := io.ddr4_sys_clk_1_n
  sys.xilinxvu190xdma.pcie_sys_clk_clk_n := io.pcie_refclk_n
  sys.xilinxvu190xdma.pcie_sys_clk_clk_p := io.pcie_refclk_p
  init_calib_complete := sys.xilinxvu190xdma.c0_init_calib_complete
  user_lnk_up := sys.xilinxvu190xdma.user_lnk_up

  io.xilinxvu190xdma <> sys.xilinxvu190xdma

  // Debug
  // ------------------------------------------------------------
  // Tie off
  sys.debug.clockeddmi.get.dmiReset := true.B


  // ------------------------------------------------------------
  // Misc outputs used in system.v
  // ------------------------------------------------------------
  io.core_clock := top_clock
  io.core_reset := top_reset
}
