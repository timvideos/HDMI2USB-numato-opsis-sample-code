
The 
[Opsis board by Numato and TimVideos](http://hdmi2usb.tv/opsis).
includes a 
[Cypress EZ-USB FX2LP](http://www.cypress.com/?id=193).


Cypress’s EZ-USB® FX2LP™ (CY7C68013A/14/15/16A) is a low power, highly
integrated USB 2.0 microcontroller. FX2LP has a fully configurable General
Programmable Interface (GPIF™) and master/slave endpoint FIFO (8-bit or 16-bit
data bus), which provides an easy and glueless connection to popular interfaces
such as ATA, UTOPIA, EPP, PCMCIA, DSP, and most processors.

The FX2 can be used in the following ways;

 * Fully open source firmware for USB JTAG programmer and USB-UART

 * Fully programmable with open source toolchains.

 * High speed data transfer reaching real world transfer rates of
   30Megabytes/second - 40Megabytes/second.

 * Emulation support for wide range of USB devices.

The CY7C68013A_100AC is connected to the FPGA in the following way;

 * Port E is connected to the JTAG programming interface of the FPGA.
   * PE0 - TDO
   * PE1 - PROG_B
   * PE2 - TDI
   * PE3 - TMS
   * PE4 - TCK
   * PE5 - Indicator LED
   * PE6 - INIT_B
   * PE7 - DONE

   * This means [FPGALink](https://github.com/makestuff/libfpgalink) can be
     used to program the FPGA using NeroJTAG protocol.

 * Two hardware UARTs
   * Port 0
     * RX - Cypress (Pin 41) -> FPGA (Pin P18 / IO_L71N_1)      -- Incorrectly labeled CY_RXD1
     * TX - FPGA (Pin T17 / IO_L72N_1) -> Cypress (Pin 40)      -- Incorrectly labeled CY_TXD1
   * Port 1
     * RX - Cypress (Pin 43) -> FPGA (Pin P17 / IO_L71P_1)      -- Incorrectly labeled CY_RXD0
     * TX - FPGA (Pin R17 / IO_L72P_1) -> Cypress (Pin 42)      -- Incorrectly labeled CY_TXD0


 * Port A, Port B, Port C, Port D and RDY+CTL all connected to the FPGA
   allowing either GPIF Master or Slave FIFO mode operation.

   * Full 16 bit external data interface connected for usage in GPIF Master or
     Slave FIFO mode.

   * Almost full GPIF (general programmable interface) connected,
     * 8 bit GPIF address out signals
     * 6 ready in signals
     * 6 control out signals

 * I2C interface connected to both;
   * Small EEPROM for storing VID+PID
   * FPGA to allow full 16k ROM to be stored in FPGA's SPI flash

 * Additional Timer 0 and INT5# connectivity.

 * Reset controllable via FPGA with fail safe pull up.


Libraries for working with the Cypress FX2

 * ezusb_io - Easy FPGA interface

 * fx2lib - Library for programming the FX2 with sdcc

 * uart - FX2 FPGA firmware which appears as USB UART to computer

 * jtag - NeroJTAG compatible firmware from FPGALink


More links

 * http://www.linux-usb.org/ezusb/
 * https://github.com/hansiglaser/ezusb-firmware
 * http://allmybrain.com/tag/fx2/
 * http://www.triplespark.net/elec/periph/USB-FX2/
 * https://fpga4u.epfl.ch/wiki/FX2
 * http://ixo-jtag.sourceforge.net/
