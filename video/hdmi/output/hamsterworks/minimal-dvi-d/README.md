
**In Progress**

This is a modified version of
[Hamsterworks' Minimal DVI-D](http://hamsterworks.co.nz/mediawiki/index.php/Spartan_6_1080p)
to run on the 
[Opsis board by Numato and TimVideos](http://hdmi2usb.tv/opsis).

Hamsterworks' Minimal DVI-D
===========================

> In the good old days you could generate video signals for VGA with ease -
> just set up the appropriate video clock, waggle the horizontal and vertical
> signals appropriately, and then send low colour depth VGA using DACs made out
> of a few resistors. It is not so easy now that most monitors and more and
> more FPGA development boards have all digital interfaces, forcing you to
> implement and debug complex high speed physical layers and protocols to bring
> up the simplest of displays.
>
> Well, the good old days are (almost) back!
> 
> By keeping the resolution relatively low, and by using only a carefully
> selecting subset of TMDS symbols to use, the simplest of interfaces (DVI-D)
> can be up and running in a couple of pages of VHDL.
