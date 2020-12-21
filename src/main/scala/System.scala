// See LICENSE for license details.
package sifive.freedom.e300artydevkit

import Chisel._

import freechips.rocketchip.config._
import freechips.rocketchip.subsystem._
import freechips.rocketchip.devices.debug._
import freechips.rocketchip.devices.tilelink._
import freechips.rocketchip.diplomacy._
import freechips.rocketchip.system._

import sifive.blocks.devices.mockaon._
import sifive.blocks.devices.gpio._
import sifive.blocks.devices.pwm._
import sifive.blocks.devices.spi._
import sifive.blocks.devices.uart._
import sifive.blocks.devices.i2c._

//-------------------------------------------------------------------------
// E300ArtyDevKitSystem
//-------------------------------------------------------------------------

class E300ArtyDevKitSystem(implicit p: Parameters) extends RocketSubsystem
    with HasPeripheryDebug
    with HasPeripheryMockAON
    with HasPeripheryUART
    with HasPeripherySPIFlash
    with HasPeripherySPI
    with HasPeripheryGPIO
    with HasPeripheryPWM
    with HasPeripheryI2C {

  val maskROMConfigs = p(MaskROMLocated(location))
  val maskRoms = maskROMConfigs.map { MaskROM.attach(_, this, CBUS) }

  val boot = if (maskRoms.isEmpty) {
    None
  } else {
    val boot = BundleBridgeSource(() => UInt(32.W))
    tileResetVectorNexusNode := boot
    Some(boot)
  }

  override lazy val module = new E300ArtyDevKitSystemModule(this)
}

class E300ArtyDevKitSystemModule[+L <: E300ArtyDevKitSystem](_outer: L)
  extends RocketSubsystemModuleImp(_outer)
    with HasPeripheryDebugModuleImp
    with HasPeripheryUARTModuleImp
    with HasPeripherySPIModuleImp
    with HasPeripheryGPIOModuleImp
    with HasPeripherySPIFlashModuleImp
    with HasPeripheryMockAONModuleImp
    with HasPeripheryPWMModuleImp
    with HasPeripheryI2CModuleImp {
  outer.boot.foreach { _.bundle := outer.maskROMConfigs.head.address.U }
}