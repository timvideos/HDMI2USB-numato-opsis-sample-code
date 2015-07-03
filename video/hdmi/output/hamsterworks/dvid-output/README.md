
**In Progress**

This is a modified version of
[Hamsterworks' Minimal HDMI](http://hamsterworks.co.nz/mediawiki/index.php/Minimal_HDMI)
to run on the 
[Opsis board by Numato and TimVideos](http://hdmi2usb.tv/opsis).

Hamsterworks' DVID Output
===========================

> To make the most of the Scarab miniSpartan6+ I've slightly reworked my DVI-D
> output design, making it a bit more self contained. The component now
> encapsulates all the clocking, and provides a nice clean interface:
>
```vhdl
---------------------------------------------------
-- Convert the VGA signals to the DVI-D/TMDS output 
---------------------------------------------------
Inst_dvid_out: dvid_out PORT MAP(
      -- Clocking
      clk_pixel  => pixel_clock,
      -- VGA signals
      red_p      => red_p,
      green_p    => green_p,
      blue_p     => blue_p,
      blank      => blank,
      hsync      => hsync,
      vsync      => vsync,
      -- TMDS outputs
      tmds_out_p => hdmi_out_p,
      tmds_out_n => hdmi_out_n
   );
```

> Due to the PLL frequency limits of the Spartan 6, changes need to be made to
> the PLL settings to select two pixel clock ranges, 25Mhz to 50MHz or 40MHz to
> 100MHz. See dvid_out_clocking.vhd for details.
