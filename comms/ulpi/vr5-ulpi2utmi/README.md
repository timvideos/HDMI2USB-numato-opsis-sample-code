
http://vr5.narod.ru/fpga/usb/index.html

# ULPI port

ulpi_port.vhdl module is a bridge between IP modules with UTMI interface and ULPI PHYs.

Notes
 * One of the design goals was to have a module which does not need a CPU for
   configuration.

 * ulpi_port assumes that UTMI module works as USB device and connected PHY is
   Microchip/SMSC USB3300 - after startup ulpi_port initializes PHY's OTG
   control register for working in USB device mode.

 * ulpi_port assumes that PHY goes out of reset at the same time as ulpi_port
   clock starts and that it's enough for PHY to have 32 clock cycles for
   finishing it's internal initialization sequence and to be ready to accept
   commands and data.

