----------------------------------------------------------------------------------
-- Module Name: transceiver_gtp_dual - Behavioral
--
-- Description: A wrapper around the Xilinx Spartan 6 GTP Dual transceiver
-- 
----------------------------------------------------------------------------------
----------------------------------------------------------------------------------
-- FPGA_DisplayPort from https://github.com/hamsternz/FPGA_DisplayPort
------------------------------------------------------------------------------------
-- The MIT License (MIT)
-- 
-- Copyright (c) 2015 Michael Alan Field <hamster@snap.net.nz>
-- 
-- Permission is hereby granted, free of charge, to any person obtaining a copy
-- of this software and associated documentation files (the "Software"), to deal
-- in the Software without restriction, including without limitation the rights
-- to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
-- copies of the Software, and to permit persons to whom the Software is
-- furnished to do so, subject to the following conditions:
-- 
-- The above copyright notice and this permission notice shall be included in
-- all copies or substantial portions of the Software.
-- 
-- THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
-- IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
-- FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
-- AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
-- LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
-- OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
-- THE SOFTWARE.
------------------------------------------------------------------------------------
----- Want to say thanks? ----------------------------------------------------------
------------------------------------------------------------------------------------
--
-- This design has taken many hours - 3 months of work. I'm more than happy
-- to share it if you can make use of it. It is released under the MIT license,
-- so you are not under any onus to say thanks, but....
-- 
-- If you what to say thanks for this design either drop me an email, or how about 
-- trying PayPal to my email (hamster@snap.net.nz)?
--
--  Educational use - Enough for a beer
--  Hobbyist use    - Enough for a pizza
--  Research use    - Enough to take the family out to dinner
--  Commercial use  - A weeks pay for an engineer (I wish!)
--------------------------------------------------------------------------------------
--  Ver | Date       | Change
--------+------------+---------------------------------------------------------------
--  0.1 | 2015-09-17 | Initial Version
--  0.2 | 2015-09-18 | Move bit reordering here from the 8b/10b encoder
--  0.3 | 2015-09-30 | Created version for Spartan 6
------------------------------------------------------------------------------------


library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

library UNISIM;
use UNISIM.VComponents.all;

entity Transceiver is
    Port ( mgmt_clk        : in  STD_LOGIC;
           powerup_channel : in  STD_LOGIC_VECTOR;

           preemp_0p0      : in  STD_LOGIC;
           preemp_3p5      : in  STD_LOGIC;
           preemp_6p0      : in  STD_LOGIC;
           
           swing_0p4       : in  STD_LOGIC;
           swing_0p6       : in  STD_LOGIC;
           swing_0p8       : in  STD_LOGIC;

           tx_running      : out STD_LOGIC_VECTOR := (others => '0');

           refclk0_p       : in  STD_LOGIC;
           refclk0_n       : in  STD_LOGIC;

           refclk1_p       : in  STD_LOGIC;
           refclk1_n       : in  STD_LOGIC;

           symbolclk       : out STD_LOGIC;
           in_symbols      : in  std_logic_vector(79 downto 0);
           
           gtptxp         : out std_logic_vector;
           gtptxn         : out std_logic_vector);
end transceiver;

architecture Behavioral of transceiver is
    constant duals_required : integer := (gtptxp'high+1)/2;

    signal txchardispmode :   std_logic_vector( 4*gtptxp'length-1  downto 0)  := (others => '0');
    signal txchardispval  :   std_logic_vector( 4*gtptxp'length-1 downto 0)  := (others => '0');
    signal txdata_for_tx  :   std_logic_vector( 32*gtptxp'length-1 downto 0) := (others => '0');
    
    component gtpa1_dual_reset_controller is
    port (  clk             : in  std_logic;
            powerup_channel : in  std_logic_vector(1 downto 0);
            pll_used        : in  std_logic_vector(1 downto 0);
            tx_running      : out std_logic_vector(1 downto 0);
            ------------------------------
            -- Signals to/from transceiver
            ------------------------------
            refclk          : in  std_logic_vector(1 downto 0);
            pllpowerdown    : out std_logic_vector(1 downto 0);
            plllock         : in  std_logic_vector(1 downto 0);
            gtpreset        : out std_logic_vector(1 downto 0);
            txreset         : out std_logic_vector(1 downto 0);
            txpowerdown     : out std_logic_vector(3 downto 0);
            gtpresetdone    : in  std_logic_vector(1 downto 0));
    end component;

    signal powerdown_channel : STD_LOGIC_VECTOR(powerup_channel'high downto 0);

    signal refclk        : std_logic_vector(duals_required*2-1 downto 0);
    
    --signal ref_clk_fabric : std_logic_vector(gtptxp'high downto 0); -- need to connect;
    
    -- Reset controller connections
    ------------------------------
--    signal pllreset      : std_logic_vector(duals_required*2-1 downto 0);

    signal pllpowerdown  : std_logic_vector(duals_required*2-1 downto 0);
    signal plllock       : std_logic_vector(duals_required*2-1 downto 0);
    signal gtpreset      : std_logic_vector(duals_required*2-1 downto 0);
    signal txpowerdown   : std_logic_vector(duals_required*4-1 downto 0);
    signal txreset       : std_logic_vector(duals_required*2-1 downto 0);
    signal txresetdone   : std_logic_vector(duals_required*2-1 downto 0);
    signal gtpresetdone  : std_logic_vector(duals_required*2-1 downto 0);
    signal pll_in_use    : std_logic_vector(duals_required*2-1 downto 0);
    
    signal gtpclkout     : std_logic_vector(duals_required*4-1 downto 0);

    signal preemp_level   : std_logic_vector(2 downto 0); 
    signal swing_level    : std_logic_vector(3 downto 0); 

    constant PLL0_FBDIV_IN      :   integer := 4;
    constant PLL1_FBDIV_IN      :   integer := 1;
    constant PLL0_FBDIV_45_IN   :   integer := 5;
    constant PLL1_FBDIV_45_IN   :   integer := 4;
    constant PLL0_REFCLK_DIV_IN :   integer := 1;
    constant PLL1_REFCLK_DIV_IN :   integer := 1;
                   
--    signal txusrclk          : STD_LOGIC_vector(gtptxp'length-1 downto 0);
--    signal txusrclk2         : STD_LOGIC_vector(gtptxp'length-1 downto 0);
    signal txoutclk          : STD_LOGIC_vector(gtptxp'length-1 downto 0);

    signal txusrclk_u         : STD_LOGIC;
    signal txusrclk_buffered  : STD_LOGIC;
    signal txusrclk2_u        : STD_LOGIC;
    signal txusrclk2_buffered : STD_LOGIC;

    signal gtpclkout_buffered : STD_LOGIC;
    signal gtpclkout_divided  : STD_LOGIC;
--  signal txoutclk_buffered  : STD_LOGIC;
    signal dcm_reset_sr       : STD_LOGIC_vector(3 downto 0);
begin
    pll_in_use <= (0=>'1', others => '1');
    
    powerdown_channel <= not powerup_channel;
   
    symbolclk    <= txusrclk2_buffered;
    
    preemp_level <= "110" when preemp_6p0 = '1' else   -- +6.0 db from table 3-30 in UG476
                    "100" when preemp_3p5 = '1' else   -- +3.5 db
                    "000";                             -- +0.0 db

    swing_level  <= "0110" when swing_0p8 = '1' else     -- 0.762 V (should be 0.8)
                    "0100" when swing_0p6 = '1' else     -- 0.578 V (should be 0.6)
                    "0010";                              -- 0.393 V (should be 0.4)

i_bufg_txusrclk: BUFG PORT MAP (
        i => txusrclk_u,
        o => txusrclk_buffered
    );

i_bufg_txusrclk2: BUFG PORT MAP (
        i => txusrclk2_u,
        o => txusrclk2_buffered
    );

i_bufg_io2: BUFIO2 GENERIC MAP (
         DIVIDE => 1         
    ) PORT MAP (
        i => gtpclkout(0),
        ioclk => open,
        divclk => gtpclkout_buffered,
        serdesstrobe => open
    );
    
process(mgmt_clk, plllock(0))
   -- The DCM reset must be asserted for at least 3 cycles after
   -- the GTP PLL gets lock
   begin
      if plllock(0) = '0' then
         dcm_reset_sr <= (others => '1');
      elsif rising_edge(mgmt_clk) then
         dcm_reset_sr <= '0' & dcm_reset_sr(dcm_reset_sr'high downto 1);
      end if;
   end process;

DCM_SP_inst : DCM_SP
   generic map (
      CLKDV_DIVIDE => 2.0,                   -- CLKDV divide value
                                             -- (1.5,2,2.5,3,3.5,4,4.5,5,5.5,6,6.5,7,7.5,8,9,10,11,12,13,14,15,16).
      CLKFX_DIVIDE => 4,
      CLKFX_MULTIPLY => 2, 
      CLKIN_DIVIDE_BY_2 => FALSE,
      CLKIN_PERIOD => 3.7,
      CLKOUT_PHASE_SHIFT => "NONE",          -- Output phase shift (NONE, FIXED, VARIABLE)
      CLK_FEEDBACK => "1X",                  -- Feedback source (NONE, 1X, 2X)
      DESKEW_ADJUST => "SYSTEM_SYNCHRONOUS", -- SYSTEM_SYNCHRNOUS or SOURCE_SYNCHRONOUS
      DFS_FREQUENCY_MODE => "LOW",           -- Unsupported - Do not change value
      DLL_FREQUENCY_MODE => "LOW",           -- Unsupported - Do not change value
      DSS_MODE => "NONE",                    -- Unsupported - Do not change value
      DUTY_CYCLE_CORRECTION => TRUE,         -- Unsupported - Do not change value
      FACTORY_JF => X"c080",                 -- Unsupported - Do not change value
      PHASE_SHIFT => 0,                      -- Amount of fixed phase shift (-255 to 255)
      STARTUP_WAIT => FALSE                  -- Delay config DONE until DCM_SP LOCKED (TRUE/FALSE)
   )
   port map (
      CLK0     => txusrclk_u,
      CLK180   => open,
      CLK270   => open,
      CLK2X    => open, 
      CLK2X180 => open,
      CLK90    => open,   
      CLKDV    => txusrclk2_u,
      CLKFX    => open,
      CLKFX180 => open,
      LOCKED   => open,
      PSDONE   => open,
      STATUS   => open,
      CLKFB    => txusrclk_u,
      CLKIN    => gtpclkout_buffered, 
      DSSEN    => '0',
      PSCLK    => '0',
      PSEN     => '0',
      PSINCDEC => '0',
      RST      => dcm_reset_sr(0) 
   );
    

    -------------  GT txdata_i Assignments for 20 bit datapath  -------  
  

I_IBUFDS_0 : IBUFDS
    port map
    (
        O               => 	refclk(0),
        I               => 	refclk0_p,
        IB              => 	refclk0_n
    );

I_IBUFDS_1 : IBUFDS
    port map
    (
        O               => 	refclk(1),
        I               => 	refclk1_p,
        IB              => 	refclk1_n
    );

g_tx: for i in 0 to duals_required-1 generate -- gtptxp'high generate

Inst_gtpa1_dual_reset_controller: gtpa1_dual_reset_controller PORT MAP(
		clk             => mgmt_clk,
		powerup_channel => powerup_channel(i*2+1 downto i*2),
      pll_used        => pll_in_use(i*2+1 downto i*2),
		tx_running      => tx_running(i*2+1 downto i*2),
		refclk          => refclk(i*2+1 downto i*2),
		pllpowerdown    => pllpowerdown(i*2+1 downto i*2),
		plllock         => plllock(i*2+1 downto i*2),
		gtpreset        => gtpreset(i*2+1 downto i*2),
		txreset         => txreset(i*2+1 downto i*2),
		txpowerdown     => txpowerdown(i*4+3 downto i*4),
		gtpresetdone    => gtpresetdone(i*2+1 downto i*2)
	);

   
    -- First channel
    txdata_for_tx(64*i+ 0) <= in_symbols( 0+40*i);
    txdata_for_tx(64*i+ 1) <= in_symbols( 1+40*i);
    txdata_for_tx(64*i+ 2) <= in_symbols( 2+40*i);
    txdata_for_tx(64*i+ 3) <= in_symbols( 3+40*i);
    txdata_for_tx(64*i+ 4) <= in_symbols( 4+40*i);
    txdata_for_tx(64*i+ 5) <= in_symbols( 5+40*i);
    txdata_for_tx(64*i+ 6) <= in_symbols( 6+40*i);
    txdata_for_tx(64*i+ 7) <= in_symbols( 7+40*i);
    txchardispval (8*i+ 0) <= in_symbols( 8+40*i);
    txchardispmode(8*i+ 0) <= in_symbols( 9+40*i);

    txdata_for_tx(64*i+ 8) <= in_symbols(10+40*i);
    txdata_for_tx(64*i+ 9) <= in_symbols(11+40*i);
    txdata_for_tx(64*i+10) <= in_symbols(12+40*i);
    txdata_for_tx(64*i+11) <= in_symbols(13+40*i);
    txdata_for_tx(64*i+12) <= in_symbols(14+40*i);
    txdata_for_tx(64*i+13) <= in_symbols(15+40*i);
    txdata_for_tx(64*i+14) <= in_symbols(16+40*i);
    txdata_for_tx(64*i+15) <= in_symbols(17+40*i);
    txchardispval (8*i+1)  <= in_symbols(18+40*i);
    txchardispmode(8*i+1)  <= in_symbols(19+40*i);
    
    -- Second channel
    txdata_for_tx(64*i+32) <= in_symbols(20+40*i);
    txdata_for_tx(64*i+33) <= in_symbols(21+40*i);
    txdata_for_tx(64*i+34) <= in_symbols(22+40*i);
    txdata_for_tx(64*i+35) <= in_symbols(23+40*i);
    txdata_for_tx(64*i+36) <= in_symbols(24+40*i);
    txdata_for_tx(64*i+37) <= in_symbols(25+40*i);
    txdata_for_tx(64*i+38) <= in_symbols(26+40*i);
    txdata_for_tx(64*i+39) <= in_symbols(27+40*i);
    txchardispval (8*i+ 4) <= in_symbols(28+40*i);
    txchardispmode(8*i+ 4) <= in_symbols(29+40*i);

    txdata_for_tx(64*i+40) <= in_symbols(30+40*i);
    txdata_for_tx(64*i+41) <= in_symbols(31+40*i);
    txdata_for_tx(64*i+42) <= in_symbols(32+40*i);
    txdata_for_tx(64*i+43) <= in_symbols(33+40*i);
    txdata_for_tx(64*i+44) <= in_symbols(34+40*i);
    txdata_for_tx(64*i+45) <= in_symbols(35+40*i);
    txdata_for_tx(64*i+46) <= in_symbols(36+40*i);
    txdata_for_tx(64*i+47) <= in_symbols(37+40*i);
    txchardispval (8*i+5)  <= in_symbols(38+40*i);
    txchardispmode(8*i+5)  <= in_symbols(39+40*i);

    ----------------------------- GTPA1_DUAL Instance  --------------------------   

gtpa1_dual_i:GTPA1_DUAL
    generic map
    (

        --_______________________ Simulation-Only Attributes ___________________

        SIM_RECEIVER_DETECT_PASS    =>      (TRUE),
        SIM_TX_ELEC_IDLE_LEVEL      =>      ("Z"),
        SIM_VERSION                 =>      ("2.0"),
 
        SIM_REFCLK0_SOURCE          =>      ("100"),
        SIM_REFCLK1_SOURCE          =>      ("100"),
 
        SIM_GTPRESET_SPEEDUP        =>      (1),
        CLK25_DIVIDER_0             =>      (5),
        CLK25_DIVIDER_1             =>      (5),
        PLL_DIVSEL_FB_0             =>      (2), 
        PLL_DIVSEL_FB_1             =>      (2),  
        PLL_DIVSEL_REF_0            =>      (1), 
        PLL_DIVSEL_REF_1            =>      (1),
        CLK_OUT_GTP_SEL_0           =>      ("TXOUTCLK0"),
        CLK_OUT_GTP_SEL_1           =>      ("TXOUTCLK1"),
 
        

       --PLL Attributes
        CLKINDC_B_0                             =>     (TRUE),
        CLKRCV_TRST_0                           =>     (TRUE),
        OOB_CLK_DIVIDER_0                       =>     (4),
        PLL_COM_CFG_0                           =>     (x"21680a"),
        PLL_CP_CFG_0                            =>     (x"00"),
        PLL_RXDIVSEL_OUT_0                      =>     (1),
        PLL_SATA_0                              =>     (FALSE),
        PLL_SOURCE_0                            =>     ("PLL0"),  -- Source from PLL 0
        PLL_TXDIVSEL_OUT_0                      =>     (1),
        PLLLKDET_CFG_0                          =>     ("111"),

       --
        CLKINDC_B_1                             =>     (TRUE),
        CLKRCV_TRST_1                           =>     (TRUE),
        OOB_CLK_DIVIDER_1                       =>     (4),
        PLL_COM_CFG_1                           =>     (x"21680a"),
        PLL_CP_CFG_1                            =>     (x"00"),
        PLL_RXDIVSEL_OUT_1                      =>     (1),
        PLL_SATA_1                              =>     (FALSE),
        PLL_SOURCE_1                            =>     ("PLL0"),  -- Source from PLL 0
        PLL_TXDIVSEL_OUT_1                      =>     (1),
        PLLLKDET_CFG_1                          =>     ("111"),
        PMA_COM_CFG_EAST                        =>     (x"000008000"),
        PMA_COM_CFG_WEST                        =>     (x"00000a000"),
        TST_ATTR_0                              =>     (x"00000000"),
        TST_ATTR_1                              =>     (x"00000000"),

       --TX Interface Attributes
        TX_TDCC_CFG_0                           =>     ("11"),
        TX_TDCC_CFG_1                           =>     ("11"),

       --TX Buffer and Phase Alignment Attributes
        PMA_TX_CFG_0                            =>     (x"00082"),
        TX_BUFFER_USE_0                         =>     (TRUE),
        TX_XCLK_SEL_0                           =>     ("TXOUT"),
        TXRX_INVERT_0                           =>     ("111"),
        PMA_TX_CFG_1                            =>     (x"00082"),
        TX_BUFFER_USE_1                         =>     (TRUE),
        TX_XCLK_SEL_1                           =>     ("TXOUT"),
        TXRX_INVERT_1                           =>     ("111"),

       --TX Driver and OOB signalling Attributes
        CM_TRIM_0                               =>     ("00"),
        TX_IDLE_DELAY_0                         =>     ("011"),
        CM_TRIM_1                               =>     ("00"),
        TX_IDLE_DELAY_1                         =>     ("011"),

       --TX PIPE/SATA Attributes
        COM_BURST_VAL_0                         =>     ("1111"),
        COM_BURST_VAL_1                         =>     ("1111"),

       --RX Driver,OOB signalling,Coupling and Eq,CDR Attributes
        AC_CAP_DIS_0                            =>     (TRUE),
        OOBDETECT_THRESHOLD_0                   =>     ("110"),
        PMA_CDR_SCAN_0                          =>     (x"6404040"),
        PMA_RX_CFG_0                            =>     (x"05ce089"),
        PMA_RXSYNC_CFG_0                        =>     (x"00"),
        RCV_TERM_GND_0                          =>     (FALSE),
        RCV_TERM_VTTRX_0                        =>     (TRUE),
        RXEQ_CFG_0                              =>     ("01111011"),
        TERMINATION_CTRL_0                      =>     ("10100"),
        TERMINATION_OVRD_0                      =>     (FALSE),
        TX_DETECT_RX_CFG_0                      =>     (x"1832"),
        AC_CAP_DIS_1                            =>     (TRUE),
        OOBDETECT_THRESHOLD_1                   =>     ("110"),
        PMA_CDR_SCAN_1                          =>     (x"6404040"),
        PMA_RX_CFG_1                            =>     (x"05ce089"),
        PMA_RXSYNC_CFG_1                        =>     (x"00"),
        RCV_TERM_GND_1                          =>     (FALSE),
        RCV_TERM_VTTRX_1                        =>     (TRUE),
        RXEQ_CFG_1                              =>     ("01111011"),
        TERMINATION_CTRL_1                      =>     ("10100"),
        TERMINATION_OVRD_1                      =>     (FALSE),
        TX_DETECT_RX_CFG_1                      =>     (x"1832"),

       --PRBS Detection Attributes
        RXPRBSERR_LOOPBACK_0                    =>     ('0'),
        RXPRBSERR_LOOPBACK_1                    =>     ('0'),

       --Comma Detection and Alignment Attributes
        ALIGN_COMMA_WORD_0                      =>     (1),
        COMMA_10B_ENABLE_0                      =>     ("1111111111"),
        DEC_MCOMMA_DETECT_0                     =>     (TRUE),
        DEC_PCOMMA_DETECT_0                     =>     (TRUE),
        DEC_VALID_COMMA_ONLY_0                  =>     (TRUE),
        MCOMMA_10B_VALUE_0                      =>     ("1010000011"),
        MCOMMA_DETECT_0                         =>     (TRUE),
        PCOMMA_10B_VALUE_0                      =>     ("0101111100"),
        PCOMMA_DETECT_0                         =>     (TRUE),
        RX_SLIDE_MODE_0                         =>     ("PCS"),
        ALIGN_COMMA_WORD_1                      =>     (1),
        COMMA_10B_ENABLE_1                      =>     ("1111111111"),
        DEC_MCOMMA_DETECT_1                     =>     (TRUE),
        DEC_PCOMMA_DETECT_1                     =>     (TRUE),
        DEC_VALID_COMMA_ONLY_1                  =>     (TRUE),
        MCOMMA_10B_VALUE_1                      =>     ("1010000011"),
        MCOMMA_DETECT_1                         =>     (TRUE),
        PCOMMA_10B_VALUE_1                      =>     ("0101111100"),
        PCOMMA_DETECT_1                         =>     (TRUE),
        RX_SLIDE_MODE_1                         =>     ("PCS"),

       --RX Loss-of-sync State Machine Attributes
        RX_LOS_INVALID_INCR_0                   =>     (8),
        RX_LOS_THRESHOLD_0                      =>     (128),
        RX_LOSS_OF_SYNC_FSM_0                   =>     (TRUE),
        RX_LOS_INVALID_INCR_1                   =>     (8),
        RX_LOS_THRESHOLD_1                      =>     (128),
        RX_LOSS_OF_SYNC_FSM_1                   =>     (TRUE),

       --RX Elastic Buffer and Phase alignment Attributes
        RX_BUFFER_USE_0                         =>     (TRUE),
        RX_EN_IDLE_RESET_BUF_0                  =>     (TRUE),
        RX_IDLE_HI_CNT_0                        =>     ("1000"),
        RX_IDLE_LO_CNT_0                        =>     ("0000"),
        RX_XCLK_SEL_0                           =>     ("RXREC"),
        RX_BUFFER_USE_1                         =>     (TRUE),
        RX_EN_IDLE_RESET_BUF_1                  =>     (TRUE),
        RX_IDLE_HI_CNT_1                        =>     ("1000"),
        RX_IDLE_LO_CNT_1                        =>     ("0000"),
        RX_XCLK_SEL_1                           =>     ("RXREC"),

       --Clock Correction Attributes
        CLK_COR_ADJ_LEN_0                       =>     (1),
        CLK_COR_DET_LEN_0                       =>     (1),
        CLK_COR_INSERT_IDLE_FLAG_0              =>     (FALSE),
        CLK_COR_KEEP_IDLE_0                     =>     (FALSE),
        CLK_COR_MAX_LAT_0                       =>     (18),
        CLK_COR_MIN_LAT_0                       =>     (16),
        CLK_COR_PRECEDENCE_0                    =>     (TRUE),
        CLK_COR_REPEAT_WAIT_0                   =>     (5),
        CLK_COR_SEQ_1_1_0                       =>     ("0100000000"),
        CLK_COR_SEQ_1_2_0                       =>     ("0100000000"),
        CLK_COR_SEQ_1_3_0                       =>     ("0100000000"),
        CLK_COR_SEQ_1_4_0                       =>     ("0100000000"),
        CLK_COR_SEQ_1_ENABLE_0                  =>     ("0000"),
        CLK_COR_SEQ_2_1_0                       =>     ("0100000000"),
        CLK_COR_SEQ_2_2_0                       =>     ("0100000000"),
        CLK_COR_SEQ_2_3_0                       =>     ("0100000000"),
        CLK_COR_SEQ_2_4_0                       =>     ("0100000000"),
        CLK_COR_SEQ_2_ENABLE_0                  =>     ("0000"),
        CLK_COR_SEQ_2_USE_0                     =>     (FALSE),
        CLK_CORRECT_USE_0                       =>     (FALSE),
        RX_DECODE_SEQ_MATCH_0                   =>     (TRUE),
        CLK_COR_ADJ_LEN_1                       =>     (1),
        CLK_COR_DET_LEN_1                       =>     (1),
        CLK_COR_INSERT_IDLE_FLAG_1              =>     (FALSE),
        CLK_COR_KEEP_IDLE_1                     =>     (FALSE),
        CLK_COR_MAX_LAT_1                       =>     (18),
        CLK_COR_MIN_LAT_1                       =>     (16),
        CLK_COR_PRECEDENCE_1                    =>     (TRUE),
        CLK_COR_REPEAT_WAIT_1                   =>     (5),
        CLK_COR_SEQ_1_1_1                       =>     ("0100000000"),
        CLK_COR_SEQ_1_2_1                       =>     ("0100000000"),
        CLK_COR_SEQ_1_3_1                       =>     ("0100000000"),
        CLK_COR_SEQ_1_4_1                       =>     ("0100000000"),
        CLK_COR_SEQ_1_ENABLE_1                  =>     ("0000"),
        CLK_COR_SEQ_2_1_1                       =>     ("0100000000"),
        CLK_COR_SEQ_2_2_1                       =>     ("0100000000"),
        CLK_COR_SEQ_2_3_1                       =>     ("0100000000"),
        CLK_COR_SEQ_2_4_1                       =>     ("0100000000"),
        CLK_COR_SEQ_2_ENABLE_1                  =>     ("0000"),
        CLK_COR_SEQ_2_USE_1                     =>     (FALSE),
        CLK_CORRECT_USE_1                       =>     (FALSE),
        RX_DECODE_SEQ_MATCH_1                   =>     (TRUE),

       --Channel Bonding Attributes
        CHAN_BOND_1_MAX_SKEW_0                  =>     (1),
        CHAN_BOND_2_MAX_SKEW_0                  =>     (1),
        CHAN_BOND_KEEP_ALIGN_0                  =>     (FALSE),
        CHAN_BOND_SEQ_1_1_0                     =>     ("0110111100"),
        CHAN_BOND_SEQ_1_2_0                     =>     ("0011001011"),
        CHAN_BOND_SEQ_1_3_0                     =>     ("0110111100"),
        CHAN_BOND_SEQ_1_4_0                     =>     ("0011001011"),
        CHAN_BOND_SEQ_1_ENABLE_0                =>     ("0000"),
        CHAN_BOND_SEQ_2_1_0                     =>     ("0000000000"),
        CHAN_BOND_SEQ_2_2_0                     =>     ("0000000000"),
        CHAN_BOND_SEQ_2_3_0                     =>     ("0000000000"),
        CHAN_BOND_SEQ_2_4_0                     =>     ("0000000000"),
        CHAN_BOND_SEQ_2_ENABLE_0                =>     ("0000"),
        CHAN_BOND_SEQ_2_USE_0                   =>     (FALSE),
        CHAN_BOND_SEQ_LEN_0                     =>     (1),
        RX_EN_MODE_RESET_BUF_0                  =>     (FALSE),
        CHAN_BOND_1_MAX_SKEW_1                  =>     (1),
        CHAN_BOND_2_MAX_SKEW_1                  =>     (1),
        CHAN_BOND_KEEP_ALIGN_1                  =>     (FALSE),
        CHAN_BOND_SEQ_1_1_1                     =>     ("0110111100"),
        CHAN_BOND_SEQ_1_2_1                     =>     ("0011001011"),
        CHAN_BOND_SEQ_1_3_1                     =>     ("0110111100"),
        CHAN_BOND_SEQ_1_4_1                     =>     ("0011001011"),
        CHAN_BOND_SEQ_1_ENABLE_1                =>     ("0000"),
        CHAN_BOND_SEQ_2_1_1                     =>     ("0000000000"),
        CHAN_BOND_SEQ_2_2_1                     =>     ("0000000000"),
        CHAN_BOND_SEQ_2_3_1                     =>     ("0000000000"),
        CHAN_BOND_SEQ_2_4_1                     =>     ("0000000000"),
        CHAN_BOND_SEQ_2_ENABLE_1                =>     ("0000"),
        CHAN_BOND_SEQ_2_USE_1                   =>     (FALSE),
        CHAN_BOND_SEQ_LEN_1                     =>     (1),
        RX_EN_MODE_RESET_BUF_1                  =>     (FALSE),

       --RX PCI Express Attributes
        CB2_INH_CC_PERIOD_0                     =>     (8),
        CDR_PH_ADJ_TIME_0                       =>     ("01010"),
        PCI_EXPRESS_MODE_0                      =>     (FALSE),
        RX_EN_IDLE_HOLD_CDR_0                   =>     (FALSE),
        RX_EN_IDLE_RESET_FR_0                   =>     (TRUE),
        RX_EN_IDLE_RESET_PH_0                   =>     (TRUE),
        RX_STATUS_FMT_0                         =>     ("PCIE"),
        TRANS_TIME_FROM_P2_0                    =>     (x"03c"),
        TRANS_TIME_NON_P2_0                     =>     (x"19"),
        TRANS_TIME_TO_P2_0                      =>     (x"064"),
        CB2_INH_CC_PERIOD_1                     =>     (8),
        CDR_PH_ADJ_TIME_1                       =>     ("01010"),
        PCI_EXPRESS_MODE_1                      =>     (FALSE),
        RX_EN_IDLE_HOLD_CDR_1                   =>     (FALSE),
        RX_EN_IDLE_RESET_FR_1                   =>     (TRUE),
        RX_EN_IDLE_RESET_PH_1                   =>     (TRUE),
        RX_STATUS_FMT_1                         =>     ("PCIE"),
        TRANS_TIME_FROM_P2_1                    =>     (x"03c"),
        TRANS_TIME_NON_P2_1                     =>     (x"19"),
        TRANS_TIME_TO_P2_1                      =>     (x"064"),

       --RX SATA Attributes
        SATA_BURST_VAL_0                        =>     ("100"),
        SATA_IDLE_VAL_0                         =>     ("100"),
        SATA_MAX_BURST_0                        =>     (10),
        SATA_MAX_INIT_0                         =>     (29),
        SATA_MAX_WAKE_0                         =>     (10),
        SATA_MIN_BURST_0                        =>     (5),
        SATA_MIN_INIT_0                         =>     (16),
        SATA_MIN_WAKE_0                         =>     (5),
        SATA_BURST_VAL_1                        =>     ("100"),
        SATA_IDLE_VAL_1                         =>     ("100"),
        SATA_MAX_BURST_1                        =>     (10),
        SATA_MAX_INIT_1                         =>     (29),
        SATA_MAX_WAKE_1                         =>     (10),
        SATA_MIN_BURST_1                        =>     (5),
        SATA_MIN_INIT_1                         =>     (16),
        SATA_MIN_WAKE_1                         =>     (5)


    ) 
    port map 
    (
        ------------------------ Loopback and Powerdown Ports ----------------------
        LOOPBACK0                       =>      (others => '0'),
        LOOPBACK1                       =>      (others => '0'),
        RXPOWERDOWN0                    =>      "11",
        RXPOWERDOWN1                    =>      "11",
        TXPOWERDOWN0                    =>      txpowerdown(i*2+1 downto i*2+0),
        TXPOWERDOWN1                    =>      txpowerdown(i*2+3 downto i*2+2),
        --------------------------------- PLL Ports --------------------------------
        CLK00                           =>      refclk(0),
        CLK01                           =>      refclk(0),
        CLK10                           =>      refclk(1),
        CLK11                           =>      refclk(1),
        CLKINEAST0                      =>      '0',
        CLKINEAST1                      =>      '0',
        CLKINWEST0                      =>      '0',
        CLKINWEST1                      =>      '0',
        GCLK00                          =>      '0',
        GCLK01                          =>      '0',
        GCLK10                          =>      '0',
        GCLK11                          =>      '0',
        GTPRESET0                       =>      gtpreset(i*2+0),
        GTPRESET1                       =>      gtpreset(i*2+1),
        GTPTEST0                        =>      "00010000",
        GTPTEST1                        =>      "00010000",
        INTDATAWIDTH0                   =>      '1',
        INTDATAWIDTH1                   =>      '1',
        PLLCLK00                        =>      '0',
        PLLCLK01                        =>      '0',
        PLLCLK10                        =>      '0',
        PLLCLK11                        =>      '0',
        PLLLKDET0                       =>      plllock(i*2+0),
        PLLLKDET1                       =>      plllock(i*2+1),
        PLLLKDETEN0                     =>      '1',
        PLLLKDETEN1                     =>      '1',
        PLLPOWERDOWN0                   =>      pllpowerdown(i*2+0),
        PLLPOWERDOWN1                   =>      pllpowerdown(i*2+1),
        REFCLKOUT0                      =>      open,
        REFCLKOUT1                      =>      open,
        REFCLKPLL0                      =>      open,
        REFCLKPLL1                      =>      open,
        REFCLKPWRDNB0                   =>      '0',  -- Not used - should power down
        REFCLKPWRDNB1                   =>      '0',  -- Used- must be powered up
        REFSELDYPLL0                    =>      "100", -- CLK10
        REFSELDYPLL1                    =>      "100", -- CLK11
        RESETDONE0                      =>      gtpresetdone(0),
        RESETDONE1                      =>      gtpresetdone(1),
        TSTCLK0                         =>      '0',
        TSTCLK1                         =>      '0',
        TSTIN0                          =>      (others => '0'),
        TSTIN1                          =>      (others => '0'),
        TSTOUT0                         =>      open,
        TSTOUT1                         =>      open,
        ----------------------- Receive Ports - 8b10b Decoder ----------------------
        RXCHARISCOMMA0                  =>      open,
        RXCHARISCOMMA1                  =>      open,
        RXCHARISK0                      =>      open,
        RXCHARISK1                      =>      open,
        RXDEC8B10BUSE0                  =>      '1',
        RXDEC8B10BUSE1                  =>      '1',
        RXDISPERR0                      =>      open,
        RXDISPERR1                      =>      open,
        RXNOTINTABLE0                   =>      open,
        RXNOTINTABLE1                   =>      open,
        RXRUNDISP0                      =>      open,
        RXRUNDISP1                      =>      open,
        USRCODEERR0                     =>      '0',
        USRCODEERR1                     =>      '0',
        ---------------------- Receive Ports - Channel Bonding ---------------------
        RXCHANBONDSEQ0                  =>      open,
        RXCHANBONDSEQ1                  =>      open,
        RXCHANISALIGNED0                =>      open,
        RXCHANISALIGNED1                =>      open,
        RXCHANREALIGN0                  =>      open,
        RXCHANREALIGN1                  =>      open,
        RXCHBONDI                       =>      (others => '0'),
        RXCHBONDMASTER0                 =>      '0',
        RXCHBONDMASTER1                 =>      '0',
        RXCHBONDO                       =>      open,
        RXCHBONDSLAVE0                  =>      '0',
        RXCHBONDSLAVE1                  =>      '0',
        RXENCHANSYNC0                   =>      '0',
        RXENCHANSYNC1                   =>      '0',
        ---------------------- Receive Ports - Clock Correction --------------------
        RXCLKCORCNT0                    =>      open,
        RXCLKCORCNT1                    =>      open,
        --------------- Receive Ports - Comma Detection and Alignment --------------
        RXBYTEISALIGNED0                =>      open,
        RXBYTEISALIGNED1                =>      open,
        RXBYTEREALIGN0                  =>      open,
        RXBYTEREALIGN1                  =>      open,
        RXCOMMADET0                     =>      open,
        RXCOMMADET1                     =>      open,
        RXCOMMADETUSE0                  =>      '1',
        RXCOMMADETUSE1                  =>      '1',
        RXENMCOMMAALIGN0                =>      '0',
        RXENMCOMMAALIGN1                =>      '0',
        RXENPCOMMAALIGN0                =>      '0',
        RXENPCOMMAALIGN1                =>      '0',
        RXSLIDE0                        =>      '0',
        RXSLIDE1                        =>      '0',
        ----------------------- Receive Ports - PRBS Detection ---------------------
        PRBSCNTRESET0                   =>      '1',
        PRBSCNTRESET1                   =>      '1',
        RXENPRBSTST0                    =>      "000",
        RXENPRBSTST1                    =>      "000",
        RXPRBSERR0                      =>      open,
        RXPRBSERR1                      =>      open,
        ------------------- Receive Ports - RX Data Path interface -----------------
        RXDATA0                         =>      open,
        RXDATA1                         =>      open,
        RXDATAWIDTH0                    =>      "01",
        RXDATAWIDTH1                    =>      "01",
        RXRECCLK0                       =>      open,
        RXRECCLK1                       =>      open,
        RXRESET0                        =>      '1',
        RXRESET1                        =>      '1',
        RXUSRCLK0                       =>      '0',
        RXUSRCLK1                       =>      '0',
        RXUSRCLK20                      =>      '0',
        RXUSRCLK21                      =>      '0',
        ------- Receive Ports - RX Driver,OOB signalling,Coupling and Eq.,CDR ------
        GATERXELECIDLE0                 =>      '0',
        GATERXELECIDLE1                 =>      '0',
        IGNORESIGDET0                   =>      '1',
        IGNORESIGDET1                   =>      '1',
        RCALINEAST                      =>      (others =>'0'),
        RCALINWEST                      =>      (others =>'0'),
        RCALOUTEAST                     =>      open,
        RCALOUTWEST                     =>      open,
        RXCDRRESET0                     =>      '0',
        RXCDRRESET1                     =>      '0',
        RXELECIDLE0                     =>      open,
        RXELECIDLE1                     =>      open,
        RXEQMIX0                        =>      "11",
        RXEQMIX1                        =>      "11",
        RXN0                            =>      '0',
        RXN1                            =>      '0',
        RXP0                            =>      '1',
        RXP1                            =>      '1',
        ----------- Receive Ports - RX Elastic Buffer and Phase Alignment ----------
        RXBUFRESET0                     =>      '1',
        RXBUFRESET1                     =>      '1',
        RXBUFSTATUS0                    =>      open,
        RXBUFSTATUS1                    =>      open,
        RXENPMAPHASEALIGN0              =>      '0',
        RXENPMAPHASEALIGN1              =>      '0',
        RXPMASETPHASE0                  =>      '0',
        RXPMASETPHASE1                  =>      '0',
        RXSTATUS0                       =>      open,
        RXSTATUS1                       =>      open,
        --------------- Receive Ports - RX Loss-of-sync State Machine --------------
        RXLOSSOFSYNC0                   =>      open,
        RXLOSSOFSYNC1                   =>      open,
        -------------- Receive Ports - RX Pipe Control for PCI Express -------------
        PHYSTATUS0                      =>      open,
        PHYSTATUS1                      =>      open,
        RXVALID0                        =>      open,
        RXVALID1                        =>      open,
        -------------------- Receive Ports - RX Polarity Control -------------------
        RXPOLARITY0                     =>      '0',
        RXPOLARITY1                     =>      '0',
        ------------- Shared Ports - Dynamic Reconfiguration Port (DRP) ------------
        DADDR                           =>      (others=>'0'),
        DCLK                            =>      '0',
        DEN                             =>      '0',
        DI                              =>      (others => '0'),
        DRDY                            =>      open,
        DRPDO                           =>      open,
        DWE                             =>      '0',
        ---------------------------- TX/RX Datapath Ports --------------------------
        GTPCLKFBEAST                    =>      open,
        GTPCLKFBSEL0EAST                =>      "10",
        GTPCLKFBSEL0WEST                =>      "00",
        GTPCLKFBSEL1EAST                =>      "11",
        GTPCLKFBSEL1WEST                =>      "01",
        GTPCLKFBWEST                    =>      open,
        GTPCLKOUT0                      =>      gtpclkout(1 downto 0),
        GTPCLKOUT1                      =>      gtpclkout(3 downto 2),
        ------------------- Transmit Ports - 8b10b Encoder Control -----------------
        TXBYPASS8B10B0                  =>      "0000",
        TXBYPASS8B10B1                  =>      "0000",
        TXCHARDISPMODE0                 =>      TXCHARDISPMODE(3 downto 0),
        TXCHARDISPMODE1                 =>      TXCHARDISPMODE(7 downto 4),
        TXCHARDISPVAL0                  =>      TXCHARDISPVAL(3 downto 0),
        TXCHARDISPVAL1                  =>      TXCHARDISPVAL(7 downto 4),
        TXCHARISK0                      =>      "0000",
        TXCHARISK1                      =>      "0000",
        TXENC8B10BUSE0                  =>      '0',
        TXENC8B10BUSE1                  =>      '0',
        TXKERR0                         =>      open,
        TXKERR1                         =>      open,
        TXRUNDISP0                      =>      open,
        TXRUNDISP1                      =>      open,
        --------------- Transmit Ports - TX Buffer and Phase Alignment -------------
        TXBUFSTATUS0                    =>      open,
        TXBUFSTATUS1                    =>      open,
        TXENPMAPHASEALIGN0              =>      '0',
        TXENPMAPHASEALIGN1              =>      '0',
        TXPMASETPHASE0                  =>      '0',
        TXPMASETPHASE1                  =>      '0',
        ------------------ Transmit Ports - TX Data Path interface -----------------
        TXDATA0                         =>      txdata_for_tx(31 downto 0),
        TXDATA1                         =>      txdata_for_tx(63 downto 32),
        TXDATAWIDTH0                    =>      "01",
        TXDATAWIDTH1                    =>      "01",
        TXOUTCLK0                       =>      txoutclk(0),
        TXOUTCLK1                       =>      txoutclk(1),
        TXRESET0                        =>      txreset(0),
        TXRESET1                        =>      txreset(1),
        TXUSRCLK0                       =>      txusrclk_buffered,
        TXUSRCLK1                       =>      txusrclk_buffered,
        TXUSRCLK20                      =>      txusrclk2_buffered,
        TXUSRCLK21                      =>      txusrclk2_buffered,
        --------------- Transmit Ports - TX Driver and OOB signalling --------------
        TXBUFDIFFCTRL0                  =>      "101",
        TXBUFDIFFCTRL1                  =>      "101",
        TXDIFFCTRL0                     =>      swing_level,
        TXDIFFCTRL1                     =>      swing_level,
        TXINHIBIT0                      =>      '0',
        TXINHIBIT1                      =>      '0',
        TXP0                            =>      gtptxp(0),
        TXN0                            =>      gtptxn(0),
        TXP1                            =>      gtptxp(1),
        TXN1                            =>      gtptxn(1),
        TXPREEMPHASIS0                  =>      preemp_level,
        TXPREEMPHASIS1                  =>      preemp_level,
        --------------------- Transmit Ports - TX PRBS Generator -------------------
        TXENPRBSTST0                    =>      "000",
        TXENPRBSTST1                    =>      "000",
        TXPRBSFORCEERR0                 =>      '0',
        TXPRBSFORCEERR1                 =>      '0',
        -------------------- Transmit Ports - TX Polarity Control ------------------
        TXPOLARITY0                     =>      '0',
        TXPOLARITY1                     =>      '0',
        ----------------- Transmit Ports - TX Ports for PCI Express ----------------
        TXDETECTRX0                     =>      '0',
        TXDETECTRX1                     =>      '0',
        TXELECIDLE0                     =>      '0',
        TXELECIDLE1                     =>      '0',
        TXPDOWNASYNCH0                  =>      '0',
        TXPDOWNASYNCH1                  =>      '0',
        --------------------- Transmit Ports - TX Ports for SATA -------------------
        TXCOMSTART0                     =>      '0',
        TXCOMSTART1                     =>      '0',
        TXCOMTYPE0                      =>      '0',
        TXCOMTYPE1                      =>      '0'
    );
    end generate;
end Behavioral;
