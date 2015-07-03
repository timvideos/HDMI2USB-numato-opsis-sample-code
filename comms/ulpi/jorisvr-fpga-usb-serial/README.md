
http://jorisvr.nl/usb/

# USB data transfer in VHDL

**usb_serial** is a synthesizable VHDL core, implementing data transfer over
USB. Combined with an external transceiver chip, this core acts as a USB device
that transfers a byte stream in both directions over the bus.

The core is intended for FPGA projects where a simple (RS232-like) interface to
a PC is needed. Higher data rates are possible with USB than with standard
RS232, especially when high-speed USB 2.0 mode is used.

Note: An external USB 2.0 transceiver chip is required between the core and the
actual USB lines. This transceiver must be compatible with the UTMI standard.


## Features

 * Very **simple** application interface that passes one byte at a time.
   Complications involving the USB protocol (packets, endpoints, descriptors)
   are handled within the core. This is in fact the whole point of this
   package.

 * UTMI-compatible transceiver interface.

 * Supports USB 2.0 in full-speed (12 Mbit/s) and high-speed (480 Mbit/s) modes.

 * No special driver is needed on the computer.

 * The core is compatible with the Communication Device Class (CDC-ACM) and
   works with generic CDC-ACM drivers provided by Linux, Mac OS X and Windows.
    * _Note: On Windows, a custom INF file is needed._
    * _Note: Custom drivers are needed for optimal performance in high-speed mode._

 * Tested on a Xilinx Spartan-3 FPGA.

 * Works out-of-the-box on a Trenz TE0146 micromodule.

 * The latest version (2011-10-04) adds support for strings describing
   manufacturer, product, and serial number in the USB device descriptor.

## License

This package is free software; you can redistribute it and/or modify it under
the terms of the GNU General Public License as published by the Free Software
Foundation; either version 2 of the License, or (at your option) any later
version.

