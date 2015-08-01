The DisplayPort AUX lines are bidirectional and according to Xilinx compatible
with the LVDS levels. However, on the Spartan-6 and Virtex-6 devices when using
the LVDS standard you aren't able to bidirectional signals. The work around is
to connect a pair of pins together and setting one as a LVDS input and one as a
LVDS output (and using tri-state logic). 

From the 
[LogiCORE IP DisplayPort v3.2 Product Guide](http://www.xilinx.com/support/documentation/ip_documentation/displayport/v3_2/pg064-displayport.pdf)
on page 110;

> The core has been designed as unidirectional LVDS_25, requiring two pin
> pairs. The output AUX signal is 3-state controlled. The board should be
> designed to combine these signals external to the FPGA.

(BTW v3.2 is the last version of this LogiCORE to support Spartan-6 devices.)

The DISPLAY_PORT I/O standard on the Spartan-6 allows you to do the
bidirectional nature only use one set of I/O pins instead of the two sets of
pins needed when using the LVDS standard. 

Again from the 
[LogiCORE IP DisplayPort v3.2 Product Guide](http://www.xilinx.com/support/documentation/ip_documentation/displayport/v3_2/pg064-displayport.pdf)
on page 111;

> Spartan-6 FPGAs offer an I/O standard explicitly for DisplayPort (called
> Display_Port). This is a bidirectional standard. *The user can, but is not
> required to*, combine the unidirectional pins and use this standard.

The other thing that I discovered is that the LVDS_33 "IOSTANDARD" and LVDS_25
"IOSTANDARD" are not real I/O standards but just a way to tell the Spartan-6
fabric to bias the pins to produce electrically identical output. This means
that any signal which is compatible with the LVDS standard (and according to
Xilinx - that is DisplayPort) should be compatible with any pin set to LVDS_25
and LVDS_33.

From [Spartan-6 FPGA SelectIO Resources User Guide](http://www.xilinx.com/support/documentation/user_guides/ug381.pdf)
 (UG381 (v1.6) February 14, 2014) on page 28;
> #### LVDS_33—Low Voltage Differential Signal 
> LVDS_33 is used to drive TIA/EIA644 LVDS levels in a bank powered with 3.3V
> VCCO. Electrically the same as LVDS_25. LVDS inputs require a parallel
> termination resistor, either through the use of a discrete resistor on the
> PCB, or the use of the DIFF_TERM attribute to enable internal termination.
> LVDS inputs can be placed on any I/O bank, while LVDS outputs are only
> available on I/O banks 0 and 2.

And from the 
[Spartan-6 FPGA Data Sheet: DC and Switching Characteristics](http://www.xilinx.com/support/documentation/data_sheets/ds162.pdf)
on page 11, the "Table 10: Differential I/O Standard DC Input and Output
Levels" also seems to indicate this too.

The only thing we need to be careful of, both the RX and TX DisplayPort AUX
channels require a LVDS output and a LVDS input and that LVDS outputs can only
be placed on banks 0 and 2 (LVDS inputs can be placed anywhere).

Do note that the GTP transceiver still needs to be drive by the 2.5V supply and
set to LVDS_25 standard.

-------

Asked to find out more information at http://forums.xilinx.com/t5/Connectivity/Correct-electrical-connection-for-unidirectional-LVDS-signals/m-p/570403#M7709
