
The 
[Opsis board by Numato and TimVideos](http://hdmi2usb.tv/opsis).
includes a 
[Microchip USB3340 Enhanced Single Supply Hi-Speed USB ULPI Transceiver](http://www.microchip.com/wwwproducts/Devices.aspx?product=USB3340)

[Datasheet for the USB3340](http://ww1.microchip.com/downloads/en/DeviceDoc/00001678A.pdf)

ULPI stands for "UTMI+ Low Pin Interface" and is a standard for interfacing USB
controllers to USB transceivers. The ULPI IC only does minimal low level
translation between the USB signals and the FPGA, meaning the that the FPGA has
to implement a full USB stack.

The FPGA can acting as any of,
 * A USB Host
 * A USB Device
 * A USB OTG device

FOSS Cores:
 * Daisho - http://goo.gl/eSwTeb
 * joris_vr - http://jorisvr.nl/usb/


USB 2.0 Low-Pin Interface (ULPI) is a low-power/low-pincount version (12 signal
lines) of the UTMI specification released in 2004. ULPI is designed to work as
a pair of wrappers around UTMI, one at the "link" end and the other at the
"PHY" end.

ULPI is primarily aimed at handling the high-speed (480Mbps) analog circuitry
and presenting an ASIC or FPGA with a parallel 8-bit data stream at 60MHz. The
ULPI interface will typically interact with Verilog or VHDL code running on the
ASIC or FPGA.
