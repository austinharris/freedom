// See LICENSE for license details.

package sifive.freedom.unleashed

import Chisel._
import chisel3.experimental.{withClockAndReset}

import boom.system.{BoomSubsystem, BoomSubsystemModule}

import freechips.rocketchip.config._
import freechips.rocketchip.subsystem._
import freechips.rocketchip.devices.debug._
import freechips.rocketchip.diplomacy._
import freechips.rocketchip.interrupts._
import freechips.rocketchip.tilelink._
import freechips.rocketchip.devices.tilelink._
import freechips.rocketchip.system._
import freechips.rocketchip.util.{ElaborationArtefacts,ResetCatchAndSync}

import sifive.blocks.devices.msi._
import sifive.blocks.devices.chiplink._
import sifive.blocks.devices.spi._
import sifive.blocks.devices.uart._
import sifive.blocks.devices.gpio._
import sifive.blocks.devices.pinctrl.{BasePin}

import sifive.fpgashells.shell._
import sifive.fpgashells.clocks._

class DevKitBoomWrapper()(implicit p: Parameters) extends LazyModule
{
  val sysClock  = p(ClockInputOverlayKey).head(ClockInputOverlayParams())
  val corePLL   = p(PLLFactoryKey)()
  val coreGroup = ClockGroup()
  val wrangler  = LazyModule(new ResetWrangler)
  val coreClock = ClockSinkNode(freqMHz = p(DevKitFPGAFrequencyKey))
  coreClock := wrangler.node := coreGroup := corePLL := sysClock

  // removing the debug trait is invasive, so we hook it up externally for now
  val jt = p(JTAGDebugOverlayKey).headOption.map(_(JTAGDebugOverlayParams())).get

  val topMod = LazyModule(new DevKitBoomFPGADesign(wrangler.node)(p))

  override lazy val module = new LazyRawModuleImp(this) {
    val (core, _) = coreClock.in(0)
    childClock := core.clock

    val djtag = topMod.module.debug.systemjtag.get
    djtag.jtag.TCK := jt.jtag_TCK
    djtag.jtag.TMS := jt.jtag_TMS
    djtag.jtag.TDI := jt.jtag_TDI
    jt.jtag_TDO    := djtag.jtag.TDO.data

    djtag.mfr_id := p(JtagDTMKey).idcodeManufId.U(11.W)
    djtag.reset  := core.reset

    childReset := core.reset | topMod.module.debug.ndreset
  }
}

class DevKitBoomFPGADesign(wranglerNode: ClockAdapterNode)(implicit p: Parameters) extends BoomSubsystem
  with HasPeripheryMaskROMSlave
  with HasPeripheryDebug
{
  val tlclock = new FixedClockResource("tlclk", p(DevKitFPGAFrequencyKey))

  // hook up UARTs, based on configuration and available overlays
  val divinit = (p(PeripheryBusKey).frequency / 115200).toInt
  val uartParams = p(PeripheryUARTKey)
  val uartOverlays = p(UARTOverlayKey)
  val uartParamsWithOverlays = uartParams zip uartOverlays
  uartParamsWithOverlays.foreach { case (uparam, uoverlay) => {
    val u = uoverlay(UARTOverlayParams(uparam, divinit, pbus, ibus.fromAsync))
    tlclock.bind(u.device)
  } }

  (p(PeripherySPIKey) zip p(SDIOOverlayKey)).foreach { case (sparam, soverlay) => {
    val s = soverlay(SDIOOverlayParams(sparam, pbus, ibus.fromAsync))
    tlclock.bind(s.device)

    // Assuming MMC slot attached to SPIs. See TODO above.
    val mmc = new MMCDevice(s.device)
    ResourceBinding {
      Resource(mmc, "reg").bind(ResourceAddress(0))
    }
  } }


  // TODO: currently, only hook up one memory channel
  val ddr = p(DDROverlayKey).headOption.map(_(DDROverlayParams(p(ExtMem).get.master.base, wranglerNode)))
  ddr.get := mbus.toDRAMController(Some("xilinxvc707mig"))()

  // Work-around for a kernel bug (command-line ignored if /chosen missing)
  val chosen = new DeviceSnippet {
    def describe() = Description("chosen", Map())
  }

  // hook the first PCIe the board has
  val pcies = p(PCIeOverlayKey).headOption.map(_(PCIeOverlayParams(wranglerNode)))
  pcies.zipWithIndex.map { case((pcieNode, pcieInt), i) =>
    val pciename = Some(s"pcie_$i")
    sbus.fromMaster(pciename) { pcieNode }
    sbus.toFixedWidthSlave(pciename) { pcieNode }
    ibus.fromSync := pcieInt
  }

  // LEDs / GPIOs
  val gpioParams = p(PeripheryGPIOKey)
  val gpios = gpioParams.map { case(params) =>
    val g = GPIO.attach(GPIOAttachParams(gpio = params, pbus, ibus.fromAsync))
    g.ioNode.makeSink
  }

  val leds = p(LEDOverlayKey).headOption.map(_(LEDOverlayParams()))

  override lazy val module = new U500VC707BoomDevKitSystemModule(this)
}


class U500VC707BoomDevKitSystemModule[+L <: DevKitBoomFPGADesign](_outer: L)
  extends BoomSubsystemModule(_outer)
    with HasRTCModuleImp
    with HasPeripheryDebugModuleImp
{
  // Reset vector is set to the location of the mask rom
  val maskROMParams = p(PeripheryMaskROMKey)
  global_reset_vector := maskROMParams(0).address.U

  // hook up GPIOs to LEDs
  val gpioParams = _outer.gpioParams
  val gpio_pins = Wire(new GPIOPins(() => PinGen(), gpioParams(0)))

  GPIOPinsFromPort(gpio_pins, _outer.gpios(0).bundle)

  gpio_pins.pins.foreach { _.i.ival := Bool(false) }
  val gpio_cat = Cat(Seq.tabulate(gpio_pins.pins.length) { i => gpio_pins.pins(i).o.oval })
  _outer.leds.get := gpio_cat
}

class DevKitBoomU500FPGADesign extends Config(
  new BoomU500DevKitConfig().alter((site, here, up) => {
    case DesignKey => { (p:Parameters) => new DevKitBoomWrapper()(p) }
  }))
