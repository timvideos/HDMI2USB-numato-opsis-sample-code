https://github.com/m-labs/milkymist/tree/master/cores/softusb/rtl
http://opencores.org/project,softusb

SoftUSB is part of the Milkymist System-on-Chip, the most advanced open source SoC for interactive multimedia applications. 

 * Supports full (12Mbps) and low (1.5Mbps) speed operation
 * Two downstream ports with shared bandwidth
 * Integrated PHY
 * Directly interfaces to common USB transceivers such as the MIC2550A
 * Hybrid architecture featuring the Navré AVR compatible processor (8-bit
   RISC) to implement the complex parts of OHCI in C software.
 * Two asynchronous clock domains: system clock and 48MHz USB
 * AVR program and OHCI descriptors and data are stored in shared (system
   addressable) on-chip dual-port RAM.

