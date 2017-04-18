// See LICENSE for license details.
package sifive.freedom.unleashed.u500vc707devkit

import config._
import coreplex.{WithL1DCacheWays, WithNBigCores, WithoutFPU, WithBootROMFile}
import rocketchip.{BaseConfig,WithRTCPeriod,WithJtagDTM}
import sifive.blocks.devices.uart.{UARTParams,PeripheryUARTKey}
import sifive.blocks.devices.gpio.{GPIOParams,PeripheryGPIOKey}
import sifive.blocks.devices.spi.{SPIParams,PeripherySPIKey}

// Don't use directly. Requires additional bootfile configuration
class DefaultFreedomUConfig extends Config(
  new WithJtagDTM ++
  new WithNBigCores(1) ++
  new BaseConfig
)

class WithU500VC707DevKitPeripheryParams extends Config((site, here, up) => {
  case PeripheryUARTKey => List(UARTParams(address = BigInt(0x54000000L)))
  case PeripheryGPIOKey => GPIOParams(address = BigInt(0x54002000L), width = 4)
  case PeripherySPIKey => List(SPIParams(rAddress = BigInt(0x54001000L)))
})

//----------------------------------------------------------------------------------
// Freedom U500 VC707 Dev Kit

class U500VC707DevKitConfig extends Config(
  new WithBootROMFile("./bootrom/u500vc707devkit.img") ++
  new WithRTCPeriod(62) ++    //Default value of 100 generates 1 Mhz clock @ 100Mhz, then corrected in sbi_entry.c
                              //Value 62 generates ~ 1Mhz clock @ 62.5Mhz
  new WithoutFPU ++
  new WithU500VC707DevKitPeripheryParams ++
  new DefaultFreedomUConfig)
