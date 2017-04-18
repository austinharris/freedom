// See LICENSE for license details.
package sifive.freedom.unleashed.u500vc707devkit

import Chisel._
import config._
import util._
import junctions._
import diplomacy._
import uncore.tilelink._
import uncore.devices._
import uncore.util._
import uncore.converters._
import rocket._
import coreplex._
import rocketchip._
import jtag._

import sifive.blocks.devices.xilinxvc707mig._
import sifive.blocks.devices.xilinxvc707pciex1._
import sifive.blocks.devices.gpio._
import sifive.blocks.devices.spi._
import sifive.blocks.devices.uart._
import sifive.blocks.util.ResetCatchAndSync

trait PeripheryDebugTRSTnBundle extends PeripheryDebugBundle {
  override val jtag = (p(IncludeJtagDTM)).option(new JTAGIO(hasTRSTn = true).flip)
}

class U500VC707DevKitSystem(implicit p: Parameters) extends BaseTop
    with PeripheryBootROM
    with PeripheryDebug
    with PeripheryCounter
    with HasPeripheryUART
    with HasPeripherySPI
    with HasPeripheryGPIO
    with HasPeripheryXilinxVC707MIG
    with HasPeripheryXilinxVC707PCIeX1
    with HardwiredResetVector
    with RocketPlexMaster {
  override lazy val module = new U500VC707DevKitSystemModule(this, () => new U500VC707DevKitSystemBundle(this))
}

class U500VC707DevKitSystemBundle[+L <: U500VC707DevKitSystem](_outer: L) extends BaseTopBundle(_outer)
    with PeripheryBootROMBundle
    with PeripheryDebugTRSTnBundle
    with PeripheryCounterBundle
    with HasPeripheryUARTBundle
    with HasPeripherySPIBundle
    with HasPeripheryGPIOBundle
    with HasPeripheryXilinxVC707MIGBundle
    with HasPeripheryXilinxVC707PCIeX1Bundle
    with HardwiredResetVectorBundle
    with RocketPlexMasterBundle

class U500VC707DevKitSystemModule[+L <: U500VC707DevKitSystem, +B <: U500VC707DevKitSystemBundle[L]](_outer: L, _io: () => B) extends BaseTopModule(_outer, _io)
    with PeripheryBootROMModule
    with PeripheryDebugModule
    with PeripheryCounterModule
    with HasPeripheryUARTModule
    with HasPeripherySPIModule
    with HasPeripheryGPIOModule
    with HasPeripheryXilinxVC707MIGModule
    with HasPeripheryXilinxVC707PCIeX1Module
    with HardwiredResetVectorModule
    with RocketPlexMasterModule

/////

class ResetDone extends Module {
  //unused - in future io.resetdone can set rocketchip STOP_COND/PRINTF_COND
  val io = new Bundle{
    val reset = Bool(INPUT)
    val resetdone = Bool(OUTPUT)
  }
  val resetdonereg = Reg(init = Bool(false))
  val resetff = Reg(init = Bool(false))
  resetff := io.reset;
  resetdonereg := Mux( ((!io.reset)&&resetff), UInt("b1"), resetdonereg)
  io.resetdone := resetdonereg
}

/////

class U500VC707DevKitIO(implicit val p: Parameters) extends Bundle {
  val uarts = Vec(p(PeripheryUARTKey).size, new UARTPortIO)
  val gpio = new GPIOPortIO(p(PeripheryGPIOKey))
  val spis = HeterogeneousBag(p(PeripherySPIKey).map(new SPIPortIO(_)))
  val debug = (!p(IncludeJtagDTM)).option(Flipped(new DMIIO()(p)))
  val jtag = p(IncludeJtagDTM).option(Flipped(new JTAGIO(hasTRSTn=true)))
  //MIG
  val xilinxvc707mig = new XilinxVC707MIGPads
  //PCIe
  val xilinxvc707pcie = new XilinxVC707PCIeX1Pads
  //Clocks
  val sys_clk_n = Bool(INPUT)
  val sys_clk_p = Bool(INPUT)
  val pcie_refclk_p = Bool(INPUT)
  val pcie_refclk_n = Bool(INPUT)
  //Reset
  val sys_reset = Bool(INPUT)
  //Misc outputs used in system.v
  val core_reset = Bool(OUTPUT)
  val core_clock = Clock(OUTPUT)
}

/////

class U500VC707DevKitTop(implicit val p: Parameters) extends Module {

  // ------------------------------------------------------------
  // Instantiate U500 VC707 Dev Kit system (sys)
  // ------------------------------------------------------------
  val sys = Module(LazyModule(new U500VC707DevKitSystem).module)
  val io = new U500VC707DevKitIO

  // ------------------------------------------------------------
  // Clock and Reset
  // ------------------------------------------------------------
  val mig_mmcm_locked     = Wire(Bool())
  val mig_sys_reset       = Wire(Bool())
  val init_calib_complete = Wire(Bool())
  val mmcm_lock_pcie      = Wire(Bool())
  val do_reset            = Wire(Bool())
  val mig_clock           = Wire(Clock())
  val mig_resetn          = Wire(Bool())
  val top_resetn          = Wire(Bool())
  val pcie_dat_reset      = Wire(Bool())
  val pcie_dat_resetn     = Wire(Bool())
  val pcie_cfg_reset      = Wire(Bool())
  val pcie_cfg_resetn     = Wire(Bool())
  val pcie_dat_clock      = Wire(Clock())
  val pcie_cfg_clock      = Wire(Clock())
  val top_clock           = Wire(Clock())
  val top_reset           = Wire(Bool())
  val mig_reset           = Wire(Bool())

  do_reset             := !mig_mmcm_locked || !mmcm_lock_pcie || mig_sys_reset
  mig_resetn           := !mig_reset
  top_resetn           := !top_reset
  pcie_dat_resetn      := !pcie_dat_reset
  pcie_cfg_resetn      := !pcie_cfg_reset
  // For now, run the CPU synchronous to the PCIe data bus
  top_clock            := pcie_dat_clock
  val safe_reset = Module(new vc707reset)
  safe_reset.io.areset := do_reset
  safe_reset.io.clock1 := mig_clock
  mig_reset            := safe_reset.io.reset1
  safe_reset.io.clock2 := pcie_dat_clock
  pcie_dat_reset       := safe_reset.io.reset2
  safe_reset.io.clock3 := pcie_cfg_clock
  pcie_cfg_reset       := safe_reset.io.reset3
  safe_reset.io.clock4 := top_clock
  top_reset            := safe_reset.io.reset4

  sys.clock := top_clock
  sys.reset := top_reset

  // ------------------------------------------------------------
  // UART
  // ------------------------------------------------------------
  io.uarts <> sys.io.uarts

  // ------------------------------------------------------------
  // SPI
  // ------------------------------------------------------------
  io.spis <> sys.io.spis

  // ------------------------------------------------------------
  // GPIO
  // ------------------------------------------------------------
  io.gpio <> sys.io.gpio

  // ------------------------------------------------------------
  // MIG
  // ------------------------------------------------------------
  sys.io.xilinxvc707mig.sys_clk_p := io.sys_clk_p
  sys.io.xilinxvc707mig.sys_clk_n := io.sys_clk_n
  mig_clock                              := sys.io.xilinxvc707mig.ui_clk
  mig_sys_reset                          := sys.io.xilinxvc707mig.ui_clk_sync_rst
  mig_mmcm_locked                        := sys.io.xilinxvc707mig.mmcm_locked
  sys.io.xilinxvc707mig.aresetn   := mig_resetn
  init_calib_complete                    := sys.io.xilinxvc707mig.init_calib_complete
  sys.io.xilinxvc707mig.sys_rst   := io.sys_reset
  //the below bundle assignment is dangerous and relies on matching signal names
  //  io.xilinxvc707 is of type XilinxVC707MIGPads
  //  sys.io.xilinxvc707mig is of type XilinxVC707MIGIO
  io.xilinxvc707mig <> sys.io.xilinxvc707mig

  // ------------------------------------------------------------
  // PCIe
  // ------------------------------------------------------------
  sys.io.xilinxvc707pcie.axi_aresetn      := pcie_dat_resetn
  pcie_dat_clock                                 := sys.io.xilinxvc707pcie.axi_aclk_out
  pcie_cfg_clock                                 := sys.io.xilinxvc707pcie.axi_ctl_aclk_out
  mmcm_lock_pcie                                 := sys.io.xilinxvc707pcie.mmcm_lock
  sys.io.xilinxvc707pcie.axi_ctl_aresetn := pcie_dat_resetn
  sys.io.xilinxvc707pcie.REFCLK_rxp      := io.pcie_refclk_p
  sys.io.xilinxvc707pcie.REFCLK_rxn      := io.pcie_refclk_n
  //another dangerous bundle assignment which relies on matching signal names
  //  io.xilinxvc707pcie is of type XilinxVC707PCIeX1Pads
  //  sys.io.xilinxvc707pcie is of type XilinxVC707PCIeX1IO
  io.xilinxvc707pcie <> sys.io.xilinxvc707pcie

  // ------------------------------------------------------------
  // Debug
  // ------------------------------------------------------------
  if (p(IncludeJtagDTM)) {
    sys.io.jtag.get <> io.jtag.get
    //Override TRST to reset this logic IFF the core is in reset.
    // This will require 3 ticks of TCK before the debug logic
    // comes out of reset, but JTAG needs 5 ticks anyway.
    // This means that the "real" TRST is never actually used.
    sys.io.jtag.get.TRSTn.get := ResetCatchAndSync(sys.io.jtag.get.TCK, top_reset)
  }else{
    // SimDTM; only for simulation use
    sys.io.debug.get := io.debug.get
    // test_mode_clk shouldn't be used for simulation
    //sys.io.test_mode_clk := Bool(false).asClock
  }

  // ------------------------------------------------------------
  // Misc outputs used in system.v
  // ------------------------------------------------------------
  io.core_clock := top_clock
  io.core_reset := top_reset

}
