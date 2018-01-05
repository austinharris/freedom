// See LICENSE for license details.
package sifive.freedom.unleashed.u500vu190devkit

import Chisel._
import chisel3.experimental.{withClockAndReset}

import freechips.rocketchip.config._
import freechips.rocketchip.diplomacy._

import sifive.blocks.devices.gpio._
import sifive.blocks.devices.pinctrl.{BasePin}

import sifive.fpgashells.shell.xilinx.vu190shell._
import sifive.fpgashells.ip.xilinx.{IOBUF}

//-------------------------------------------------------------------------
// PinGen
//-------------------------------------------------------------------------

object PinGen {
  def apply(): BasePin = {
    new BasePin()
  }
}

//-------------------------------------------------------------------------
// U500VU190DevKitFPGAChip
//-------------------------------------------------------------------------

class U500VU190DevKitFPGAChip(implicit override val p: Parameters)
    extends VU190Shell
    with HasDDR4XDMA {

  dut_clock := clk_100_mhz
  withClockAndReset(dut_clock, dut_reset) {
    val dut = Module(LazyModule(new U500VU190DevKitSystem).module)
    connectUART(dut)
    connectXDMA(dut)
    connectDebug(dut)
  }

}
