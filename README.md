Sample code for the Numato Opsis Board
======================================

The [Numato](http://numato.com) Opsis board is the first [HDMI2USB](http://hdmi2usb.tv)
production board developed in conjugation with the
[TimVideos.us](http://code.timvideos.us) project. 

It's features include;
 * 2 x HDMI input ports,
 * 2 x HDMI output ports,
 * DisplayPort input and output ports,
 * 128Mbit DDR3-1600 ram,
 * Gigabit Ethernet with MAC address EEPROM,
 * Micro SD card,
 * Cypress FX2 for USB device functionality,
 * ULPI for USB OTG functionality,
 * Quad speed SPI flash.

Repository Structure
====================

 * comms - Sample code around communicating with the board such as USB or
   Ethernet.

 * expansion - Sample code for compatible expansion boards.

 * ram - Sample code for interfacing to the DDR3 ram.

 * soc - Sample code demonstrating a full "System on Chip" examples.

 * storage - Sample code for talking to storage systems like the SPI, EEPROM
   and SD card.

 * video - Sample for for using the HDMI and DisplayPort video input and output
   ports.

