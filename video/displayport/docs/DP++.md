

8.1 Dongle or cable adaptor detect discovery mechanism

The PTN3381B supports the source-side dongle detect discovery mechanism described
in VESA DisplayPort Interoperability Guideline Version 1.1.

When a source-side cable adaptor is plugged into a multi-mode source device that
supports multiple standards such as DisplayPort, DVI and HDMI, a discovery mechanism
is needed for the multi-mode source to configure itself for outputting DisplayPort, DVI or
HDMI compliant signals through the dongle or cable adaptor. The discovery mechanism
ensures that a multi-mode source device only sends either DVI or HDMI signals when a
valid DVI or HDMI cable adaptor is present.

The VESA Interoperability Guideline recommends that a multi-mode source to power up
with both DDC and AUX CH disabled. After initialization, the source device can use a
variety of mechanisms to decide whether a dongle or cable adaptor is present by
detecting pin 13 on the DisplayPort connector. Depending on the voltage level detected at
pin 13, the source configures itself either:

 * as a DVI or HDMI source (see below paragraph for detection between DVI and
HDMI), and enables DDC, while keeping AUX CH disabled, or
 * as a DisplayPort source and enables AUX CH, while keeping DDC disabled.

The monitoring of the voltage level on pin 13 by a multi-mode source device is optional. A
multi-mode source may also e.g. attempt an AUX CH read transaction and, if the
transaction fails, a DDC transaction to discover the presence/absence of a cable adaptor.
Furthermore, a source that supports both DVI and HDMI can discover whether a DVI or
HDMI dongle or cable adaptor is present by using a variety of discovery procedures. One
possible method is to check the voltage level of pin 14 of the DisplayPort connector.
Pin 14 also carries CEC signal used for HDMI. Please note that other HDMI devices on
the CEC line may be momentarily pulling down pin 14 as a part of CEC protocol.
The VESA Interoperability Guideline recommends that a multi-mode source should
distinguish a source-side HDMI cable adaptor from a DVI cable adaptor by checking the
DDC buffer ID as described in Section 7.6 “I
2C-bus based HDMI dongle detection”. While
it is optional for a multi-mode source to use the I2C-bus based HDMI dongle detection
mechanism, it is mandatory for HDMI dongle or cable adaptor to respond to the I2C-bus
read command described in Section 7.7. The PTN3381B provides an integrated I2C-bus
slave ROM to support this mandatory HDMI dongle detect mechanism for HDMI dongles.
For a DisplayPort-to-HDMI source-side dongle or cable adaptor, DDET must be tied HIGH
to enable the I2C-based HDMI dongle detection response function of PTN3381B. For a
DisplayPort-to-DVI sink-side dongle or cable adaptor, DDET must be tied LOW to disable
the function.




5.4.4 Distinction of a Sink-side HDMI Cable Adaptor 

A Dual-mode Sink Device must distinguish a Sink-side HDMI cable adaptor from a
DVI cable adaptor by checking the voltage level of Pin 14. It should be noted
that Pin 14 may be momentarily pulled low by another HDMI Device.

