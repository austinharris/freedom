// See LICENSE for license details.
package sifive.freedom.everywhere.e300artydevkit

import config._
import coreplex._
import rocketchip._
import rocket._
import sifive.blocks.devices.mockaon._
import sifive.blocks.devices.pwm._
import sifive.blocks.devices.spi._
import sifive.blocks.devices.gpio._
import sifive.blocks.devices.uart._


class DefaultFreedomEConfig extends Config(
  new WithStatelessBridge        ++
  new WithNBreakpoints(2)        ++
  new WithRV32                   ++
  new DefaultSmallConfig
)

class WithE300ArtyDevKitPeripheryParams extends Config((site, here, up) => {
  case PeripheryMockAONKey => MockAONParams(address = 0x10000000)
  case PeripheryGPIOKey => GPIOParams(address = 0x10012000, width = 32)
  case PeripheryPWMKey => List(
    PWMParams(address = 0x10015000, cmpWidth = 8),
    PWMParams(address = 0x10025000, cmpWidth = 16),
    PWMParams(address = 0x10035000, cmpWidth = 16))
  case PeripherySPIKey => List(
    SPIParams(csWidth = 4, rAddress = 0x10024000, sampleDelay = 3),
    SPIParams(csWidth = 1, rAddress = 0x10034000, sampleDelay = 3))
  case PeripherySPIFlashKey => SPIFlashParams(fAddress = 0x20000000, rAddress = 0x10014000, sampleDelay = 3)
  case PeripheryUARTKey => List(UARTParams(address = 0x10013000), UARTParams(address = 0x1023000))
})

class WithDataScratchpad(n: Int) extends Config((site, here, up) => {
  case RocketTilesKey => up(RocketTilesKey, site) map { r =>
    r.copy(dcache = r.dcache.map(_.copy(nSets = n / site(CacheBlockBytes), scratch = Some(0x80000000L)))) }
})

class E300ArtyDevKitConfig extends Config(
  new WithBootROMFile("./bootrom/e300artydevkit.img") ++
  new WithNExtTopInterrupts(0) ++
  new WithJtagDTM ++
  new WithL1ICacheSets(8192/32) ++ // 8 KiB **per set**
  new WithCacheBlockBytes(32) ++
  new WithL1ICacheWays(2) ++
  new WithDefaultBtb ++
  new WithFastMulDiv ++
  new WithDataScratchpad(16384) ++
  new WithNMemoryChannels(0) ++
  new WithoutFPU ++
  new WithE300ArtyDevKitPeripheryParams ++
  new DefaultFreedomEConfig
)
