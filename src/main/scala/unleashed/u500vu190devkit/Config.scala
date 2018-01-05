// See LICENSE for license details.
package sifive.freedom.unleashed.u500vu190devkit

import freechips.rocketchip.config._
import freechips.rocketchip.coreplex._
import freechips.rocketchip.devices.debug._
import freechips.rocketchip.devices.tilelink._
import freechips.rocketchip.diplomacy._
import freechips.rocketchip.system._
import freechips.rocketchip.tile._

import sifive.blocks.devices.gpio._
import sifive.blocks.devices.spi._
import sifive.blocks.devices.uart._

import sifive.fpgashells.devices.xilinx.xilinxvu190xdma.{MemoryXilinxDDRKey,XilinxVU190XDMAParams}

// Default FreedomUVU190Config
class FreedomUVU190Config extends Config(
  new WithNMemoryChannels(1) ++
  new WithNBigCores(2)       ++
  new BaseConfig
)

// Freedom U500 VU190 Dev Kit Peripherals
class U500VU190DevKitPeripherals extends Config((site, here, up) => {
  case PeripheryUARTKey => List(
    UARTParams(address = BigInt(0x54000000L)))
  case PeripheryMaskROMKey => List(
    MaskROMParams(address = 0x10000, name = "BootROM"))
})

// Freedom U500 VU190 Dev Kit
class U500VU190DevKitConfig extends Config(
  new WithEdgeDataBits(256) ++
  new WithL1DCacheWays(8) ++
  new WithL1ICacheWays(8) ++
  // new WithNPerfCounters(29) ++
  new WithNExtTopInterrupts(0)   ++
  new U500VU190DevKitPeripherals ++
  new FreedomUVU190Config().alter((site,here,up) => {
    case ErrorParams => ErrorParams(Seq(AddressSet(0x3000, 0xfff)), 4096, 4096)
    case PeripheryBusKey => up(PeripheryBusKey, site).copy(frequency = 100000000)
    case MemoryXilinxDDRKey => XilinxVU190XDMAParams(address = Seq(AddressSet(0x80000000L, 0x80000000L-1)))
    case DTSTimebase => BigInt(1000000)
    case ExtMem => up(ExtMem).copy(size = 0x80000000L)
  })
)
