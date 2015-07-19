library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity opsis is
  Port ( switch : in  STD_LOGIC;
         LED0 : out  STD_LOGIC;
			LED1 : out  STD_LOGIC;
			LED2 : out  STD_LOGIC;
			LED3 : out  STD_LOGIC
			);
end opsis;

architecture Behavioral of opsis is
begin
  LED0 <= switch;
  LED1 <= switch;
  LED2 <= switch;
  LED3 <= switch;
end Behavioral;
