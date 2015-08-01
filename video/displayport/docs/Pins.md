
#-----------------------------------------

# DISPLAY_PORT - connector J9 - Direction RX
NET "lnk_j9_lane_p[0]"     LOC =     "D7"       |IOSTANDARD =         LVDS_25;     # (/DisplayPort/DPRX_LANEP0)
NET "lnk_j9_lane_n[0]"     LOC =     "C7"       |IOSTANDARD =         LVDS_25;     # (/DisplayPort/DPRX_LANEN0)
NET "lnk_j9_lane_p[1]"     LOC =     "D9"       |IOSTANDARD =         LVDS_25;     # (/DisplayPort/DPRX_LANEP1)
NET "lnk_j9_lane_n[1]"     LOC =     "C9"       |IOSTANDARD =         LVDS_25;     # (/DisplayPort/DPRX_LANEN1)
NET "lnk_j9_lane_p[2]"     LOC =    "D13"       |IOSTANDARD =         LVDS_25;     # (/DisplayPort/DPRX_LANEP2)
NET "lnk_j9_lane_n[2]"     LOC =    "C13"       |IOSTANDARD =         LVDS_25;     # (/DisplayPort/DPRX_LANEN2)
NET "lnk_j9_lane_p[3]"     LOC =    "D15"       |IOSTANDARD =         LVDS_25;     # (/DisplayPort/DPRX_LANEP3)
NET "lnk_j9_lane_n[3]"     LOC =    "C15"       |IOSTANDARD =         LVDS_25;     # (/DisplayPort/DPRX_LANEN3)
# \/ Weakly pulled (1M) to GND via R45
NET "dp_j9_config1"        LOC =    "AA8"       |IOSTANDARD =        LVCMOS33;     # (/DisplayPort/DPRXCONFIG1)
# \/ Weakly pulled (5M) to GND via R46
NET "dp_j9_config2"        LOC =    "AB8"       |IOSTANDARD =        LVCMOS33;     # (/DisplayPort/DPRXCONFIG2)
# \/ Weakly pulled (100k) to GND via R47
NET "hpd_j9"               LOC =    "W11"       |IOSTANDARD =        LVCMOS33;     # (/FPGA_Bank_1_2/DPRXHPD)

NET "aux_j9_XXX_channel_p" LOC =    "T10"       |IOSTANDARD =         LVDS_33;     # (/DisplayPort/DPRXAUXCH_P)
NET "aux_j9_XXX_channel_n" LOC =    "T11"       |IOSTANDARD =         LVDS_33;     # (/DisplayPort/DPRXAUXCH_N)

NET "aux_j9_XXX_channel_p" LOC =    "R11"       |IOSTANDARD =         LVDS_33;     # (/DisplayPort/DPRXAUXCH_P)
NET "aux_j9_XXX_channel_n" LOC =    "U10"       |IOSTANDARD =         LVDS_33;     # (/DisplayPort/DPRXAUXCH_N)

#-----------------------------------------

# DISPLAY_PORT - connector J8 - Direction TX
NET "lnk_j8_lane_p[0]"     LOC =     "B6"       |IOSTANDARD =         LVDS_25;     # (/DisplayPort/DPTX_LANEP0)
NET "lnk_j8_lane_n[0]"     LOC =     "A6"       |IOSTANDARD =         LVDS_25;     # (/DisplayPort/DPTX_LANEN0)
NET "lnk_j8_lane_p[1]"     LOC =     "B8"       |IOSTANDARD =         LVDS_25;     # (/DisplayPort/DPTX_LANEP1)
NET "lnk_j8_lane_n[1]"     LOC =     "A8"       |IOSTANDARD =         LVDS_25;     # (/DisplayPort/DPTX_LANEN1)
NET "lnk_j8_lane_p[2]"     LOC =    "B14"       |IOSTANDARD =         LVDS_25;     # (/DisplayPort/DPTX_LANEP2)
NET "lnk_j8_lane_n[2]"     LOC =    "A14"       |IOSTANDARD =         LVDS_25;     # (/DisplayPort/DPTX_LANEN2)
NET "lnk_j8_lane_p[3]"     LOC =    "B16"       |IOSTANDARD =         LVDS_25;     # (/DisplayPort/DPTX_LANEP3)
NET "lnk_j8_lane_n[3]"     LOC =    "A16"       |IOSTANDARD =         LVDS_25;     # (/DisplayPort/DPTX_LANEN3)

# \/ Weakly pulled (1M) to GND via R42
NET "dp_j8_config1"        LOC =    "V20"       |IOSTANDARD =        LVCMOS33;     # (/DisplayPort/DPTXCONFIG1)
# \/ Weakly pulled (5M) to GND via R43
NET "dp_j8_config2"        LOC =   "AB19"       |IOSTANDARD =        LVCMOS33;     # (/DisplayPort/DPTXCONFIG2)
# \/ Weakly pulled (100k) to GND via R44
NET "hpd_j8"               LOC =    "V11"       |IOSTANDARD =        LVCMOS33;     # (/FPGA_Bank_1_2/DPTXHPD)

NET "aux_j8_XXX_channel_p" LOC =    "U16"       |IOSTANDARD =         LVDS_33;     # (/DisplayPort/DPTXAUXCH_P)
NET "aux_j8_XXX_channel_n" LOC =    "U15"       |IOSTANDARD =         LVDS_33;     # (/DisplayPort/DPTXAUXCH_N)

NET "aux_j8_XXX_channel_p" LOC =    "T15"       |IOSTANDARD =         LVDS_33;     # (/DisplayPort/DPTXAUXCH_P)
NET "aux_j8_XXX_channel_n" LOC =    "V15"       |IOSTANDARD =         LVDS_33;     # (/DisplayPort/DPTXAUXCH_N)

#-----------------------------------------
