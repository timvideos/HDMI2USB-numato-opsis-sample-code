There are multiple tools for doing JTAG programming using the FX2.

https://fpga4u.epfl.ch/wiki/FX2 and it'll appears as an Altera USB Blaster.
Which in turn may allow you to use tools you'd normally use with the Altera
USB-Blaster, including available Linux tools such as UrJTAG.

FPGALink 

## JTAG

JTAG is connected to IO Port E of the FX2.
Unlike all the other IO ports, the Port E is **not** bit addressable.

 * Bit0 - TDO    (Output)  - JTAG bit data from FX2 into FPGA
 * Bit1 - PROG_B (Input)   - PROGRAM_B_2 is the main chip reset pin. It should be pulled up, and to reset pulled low.

Active-Low asynchronous reset to configuration logic. This pin has a
default weak pull-up resistor.

 * Bit2 - TDI    (Input)   - JTAG bit data from FPGA into FX2
 * Bit3 - TMS    (Output)  - JTAG bit state from FX2 into FPGA
 * Bit4 - TCK    (Output)  - JTAG bit clock from FX2 into FPGA
 * Bit5 - LED    (Output)  - User indicator LED
 * Bit6 - INIT_B (Input)   - Held Low to delay configuration, afterwards CRC Error

When Low, this pin indicates that the configuration memory is being
cleared. When held Low, the start of configuration is delayed. During
configuration, a Low on this output indicates that a configuration data
error has occurred. Can be used after configuration (optional) to indicate
POST_CRC status.

 * Bit7 - DONE   (Input)   - Asserts high when the FPGA is configured

DONE is a bidirectional signal with an optional internal pull-up resistor.
As an output, this pin indicates completion of the configuration process.
As an input, a Low level on DONE can be configured to delay the startup
sequence

