
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


