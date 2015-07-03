
**In Progress**

This is a modified version of
[SD card testing](http://hamsterworks.co.nz/mediawiki/index.php/SD_card_testing)
to run on the 
[Opsis board by Numato and TimVideos](http://hdmi2usb.tv/opsis).

Hamsterworks' SD Card Testing
===========================

> This follows the flow chart in http://www.chlazza.net/sdcardinfo.html to
> initialize both SD and SDHC cards - however it is missing a lot of the
> error/compatibility detection tests.
>
> Once initialsied, it issues a multi-block read command and processes the
> first data block. It does not however cancel the read, so additional blocks
> will be transferred if CS is asserted. This might be a useful way to provide
> a data stream to a future project...

