

library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity LED_SWITCH is
 Port ( led : out std_logic;
 switch: in std_logic );
end LED_SWITCH;
architecture Behavioral of LED_SWITCH is
begin
led <= switch;
end Behavioral;









