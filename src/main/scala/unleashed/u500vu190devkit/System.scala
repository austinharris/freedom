// See LICENSE for license details.
package sifive.freedom.unleashed.u500vu190devkit

import Chisel._

import freechips.rocketchip.config._
import freechips.rocketchip.coreplex._
import freechips.rocketchip.devices.debug._
import freechips.rocketchip.devices.tilelink._
import freechips.rocketchip.diplomacy._
import freechips.rocketchip.system._

import sifive.blocks.devices.gpio._
import sifive.blocks.devices.spi._
import sifive.blocks.devices.uart._

import sifive.fpgashells.devices.xilinx.xilinxvu190xdma._

//-------------------------------------------------------------------------
// U500VU190DevKitSystem
//-------------------------------------------------------------------------

class U500VU190DevKitSystem(implicit p: Parameters) extends RocketCoreplex
    with HasPeripheryMaskROMSlave
    with HasPeripheryDebug
    with HasSystemErrorSlave
    with HasPeripheryUART
    with HasMemoryXilinxVU190XDMA {
  override lazy val module = new U500VU190DevKitSystemModule(this)
}

class U500VU190DevKitSystemModule[+L <: U500VU190DevKitSystem](_outer: L)
  extends RocketCoreplexModule(_outer)
    with HasRTCModuleImp
    with HasPeripheryDebugModuleImp
    with HasPeripheryUARTModuleImp
    with HasMemoryXilinxVU190XDMAModuleImp {
  // Reset vector is set to the location of the mask rom
  val maskROMParams = p(PeripheryMaskROMKey)
  global_reset_vector := maskROMParams(0).address.U
}
