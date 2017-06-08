// See LICENSE for license details.
package sifive.freedom.unleashed.u500vu190devkit

import config._
import coreplex.{WithL1ICacheWays,WithL1DCacheWays,WithL1DCacheSets,WithL1ICacheSets,WithoutFPU,WithBootROMFile,WithNBigCores,WithoutMulDiv,RocketTilesKey}
import rocketchip.{BaseConfig,WithRTCPeriod,WithJtagDTM,ExtMem,MasterConfig,WithEdgeDataBits,WithoutTLMonitors}
import rocket.{PAddrBits,MulDivParams}
import sifive.blocks.devices.uart.{UARTParams,PeripheryUARTKey}
import sifive.blocks.devices.gpio.{GPIOParams,PeripheryGPIOKey}
import uncore.devices.{DMKey}

// Don't use directly. Requires additional bootfile configuration
class DefaultFreedomUConfig extends Config(
  new WithNBigCores(2) ++
  new WithJtagDTM ++
  new BaseConfig
)

class WithU500VU190DevKitPeripheryParams extends Config((site, here, up) => {
  case PeripheryUARTKey => List(UARTParams(address = BigInt(0x54000000L)))
  case PeripheryGPIOKey => GPIOParams(address = BigInt(0x54002000L), width = 4)
})

class WithBigExtMem extends Config((site, here, up) => {
  case PAddrBits => 35
  case ExtMem => MasterConfig(base=0x80000000L, size=0x780000000L, beatBytes=8, idBits=4)
})

class WithSlowMulDiv extends Config((site, here, up) => {
  case RocketTilesKey => up(RocketTilesKey, site) map { r =>
    r.copy(core = r.core.copy(mulDiv = Some(
      MulDivParams(mulUnroll = 1, mulEarlyOut = false, divEarlyOut = false)
  )))}
})


//----------------------------------------------------------------------------------
// Freedom U500 VU190 Dev Kit

class U500VU190DevKitConfig extends Config(
  new WithBootROMFile("./bootrom/u500vu190devkit.img") ++
  new WithRTCPeriod(61) ++    //Default value of 100 generates 1 Mhz clock @ 100Mhz, then corrected in sbi_entry.c
                              //Value 62 generates ~ 1Mhz clock @ 62.5Mhz
  new WithSlowMulDiv ++
  new WithoutTLMonitors ++
  new WithEdgeDataBits(256) ++
  new WithoutFPU ++
  new WithU500VU190DevKitPeripheryParams ++
  new WithL1DCacheWays(8) ++
  new WithL1ICacheWays(8) ++
  new DefaultFreedomUConfig)
