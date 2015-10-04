----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date:    17:51:54 10/02/2015 
-- Design Name: 
-- Module Name:    gtpa1_dual_reset_controller - Behavioral 
-- Project Name: 
-- Target Devices: 
-- Tool versions: 
-- Description: 
--
-- Dependencies: 
--
-- Revision: 
-- Revision 0.01 - File Created
-- Additional Comments: 
--
----------------------------------------------------------------------------------
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity gtpa1_dual_reset_controller is
    Port ( -- control signals
           clk             : in  STD_LOGIC;
           powerup_channel : in  STD_LOGIC_VECTOR (1 downto 0);
           pll_used        : in  std_logic_vector(1 downto 0);
           tx_running      : out STD_LOGIC_VECTOR (1 downto 0);
           -- link to GTP signals
           refclk          : in  STD_LOGIC_VECTOR (1 downto 0);
           pllpowerdown    : out STD_LOGIC_VECTOR (1 downto 0);
           plllocken       : out STD_LOGIC_VECTOR (1 downto 0);
           plllock         : in  STD_LOGIC_VECTOR (1 downto 0);
           gtpreset        : out STD_LOGIC_VECTOR (1 downto 0);
           txreset         : out STD_LOGIC_VECTOR (1 downto 0);
           txpowerdown     : out STD_LOGIC_VECTOR (3 downto 0);
           gtpresetdone    : in  STD_LOGIC_VECTOR (1 downto 0));
end gtpa1_dual_reset_controller;

architecture Behavioral of gtpa1_dual_reset_controller is
   signal count : unsigned(9 downto 0) := (8=>'1',7=>'1',6=>'1',others => '0');
   signal state : std_logic_vector(2 downto 0) := (others => '0');
begin   

process(clk) 
   begin
      if rising_edge(clk) then
         ----------------------------------------------------
         -- Turn on the PLLs if either channel needs to be on
         ----------------------------------------------------
         
         if count(count'high) = '0' then
             count <= count + 1;
         end if;
         case state is
            when "000"  =>  -- Disabled
               tx_running   <= "00";
               pllpowerdown <= "11";
               plllocken    <= "00";
               gtpreset     <= "11";
               txreset      <= "11";
               txpowerdown  <= "1111";

               if powerup_channel /= "00" and count(count'high) = '1' then
                  state <= "001";
                  count <= (others => '0');
               end if;

            when "001"  =>  -- Power up PLLs
               tx_running   <= "00";
               pllpowerdown <= not pll_used(1 downto 0);
               plllocken    <= pll_used(1 downto 0);
               gtpreset     <= not powerup_channel;
               txreset      <= "11";
               txpowerdown  <= "1111";

               if plllock /= "00" then
                  state <= "010";
                  count <= (others => '0');
               elsif count(count'high) = '1' then  -- timeout
                  state <= "000";
                  count <= (others => '0');
               end if;

            when "010" => -- Start transceivers 
               tx_running   <= "00";
               pllpowerdown <= not pll_used(1 downto 0);
               plllocken    <= pll_used(1 downto 0);
               gtpreset     <= not powerup_channel;
               txreset      <= not powerup_channel;
               txpowerdown  <= (not powerup_channel(1)) & (not powerup_channel(1)) 
                             & (not powerup_channel(0)) & (not powerup_channel(0));

               if plllock = "00" then
                  state <= "000";
                  count <= (others => '0');
               elsif gtpresetdone = powerup_channel then -- reset done
                  state <= "011";  
                  count <= (others => '0');
               elsif count(count'high) = '1' then  -- timeout
                  state <= "000";
                  count <= (others => '0');
               end if;

            when "011" => -- Running 
               tx_running   <= powerup_channel;
               pllpowerdown <= not pll_used(1 downto 0);
               plllocken    <= pll_used(1 downto 0);
               gtpreset     <= not powerup_channel;
               txreset      <= not powerup_channel;
               txpowerdown  <= (not powerup_channel(1)) & (not powerup_channel(1)) 
                             & (not powerup_channel(0)) & (not powerup_channel(0));
                             
               if plllock = "00" then
                  state <= "000";
                  count <= (others => '0');
               elsif gtpresetdone = powerup_channel then -- reset done
                  state <= "011";  
                  count <= (others => '0');
               elsif count(count'high) = '1' then  -- timeout
                  state <= "000";
                  count <= (others => '0');
               end if;            
            
            when others => --- error state
               state <= "000";
               count <= (others => '0');
         end case;

         if powerup_channel = "00" then 
            state <= "000";
         end if;
        
      end if;
   end process;
end Behavioral;

