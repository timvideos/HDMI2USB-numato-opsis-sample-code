
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


USB 2.0 Low-Pin Interface (ULPI) is a low-power/low-pincount version (12 signal
lines) of the UTMI specification released in 2004. ULPI is designed to work as
a pair of wrappers around UTMI, one at the "link" end and the other at the
"PHY" end.

ULPI is primarily aimed at handling the high-speed (480Mbps) analog circuitry
and presenting an ASIC or FPGA with a parallel 8-bit data stream at 60MHz. The
ULPI interface will typically interact with Verilog or VHDL code running on the
ASIC or FPGA.

## FOSS Cores

FOSS Cores:
 * Daisho - http://goo.gl/eSwTeb
 * joris_vr - http://jorisvr.nl/usb/

## Commercial Cores

* [USB 2.0 Device Core with Hardware based enumeration RAM Interface](http://www.slscorp.com/ip-cores/communication/usb-20-device/usb20hr.html)
* [USB2.0 High-Speed Device Interface for Altera SOPC Builder](http://www.vreelin.com/altera/usbusermanual_altera.pdf) from Vreelin Engineering
* [USB2 High-Speed Device Interface for Xilinx EDK](http://www.vreelin.com/usbusermanual-xilinxpdf.pdf) from Vreelin Engineering
* [USB 2.0 Device Only IP Core](http://www.hitechglobal.com/IPCores/usbdevice.htm) - interfaces with Wishbone
* [USB2.0 On-The-Go Controller Core from CAST/Actel](http://www.actel.com/ipdocs/cast_usbhs-otg-sd-ac_DS.pdf)
* [USB Hi-Speed On-The-Go Controller for Multiple Peripheral Devices Core](http://www.cast-inc.com/ip-cores/interfaces/usbhs-otg-mpd/index.html) from CAST, Inc.

