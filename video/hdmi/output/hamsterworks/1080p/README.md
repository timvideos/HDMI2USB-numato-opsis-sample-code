**In Progress**

Hamsterworks' Spartan 6 1080p Transmitter
=========================================

**This code should not be used in production.** 

This is a modified version of
[Hamsterworks' "Spartan 6 1080p" code](http://hamsterworks.co.nz/mediawiki/index.php/Spartan_6_1080p).

Manual placement of critical components has been done to make the code
compatible with the layout of the 
[Opsis board by Numato and TimVideos](http://hdmi2usb.tv/opsis)

> The serializers on the Spartan 6 LX are rated to 1050Mb/s, In itself this is
> quite impressive, but for most development boards without HDMI transmitters it
> leaves huge hole in the feature set - it is is not fast enough for 1080p (aka
> Full HD, aka 1920x1080@60Hz). A 720p signal uses about 750Mb/s on four
> channels, and 1080p requires four channels of 1,500Mb/s each!
>
> But wouldn't it be nice to generate 1080p? You could then test your decoders
> or image processing on a less expensive board like an Digilent Atlys.
> 
> Well you can - if not for production at least for testing. Due to the
> unavoidable 175 ps jitter in the PLL's outputs the signal is not up to spec.
> However, that doesn't meant that it won't work! Think of this as a stop-gap
> measure you can use while a board with an HDMI encoder chip is being
> engineered.
>
> **Due to the unavoidable 175 ps jitter in the PLL's outputs the signal is not
> up to the HDMI spec.**
