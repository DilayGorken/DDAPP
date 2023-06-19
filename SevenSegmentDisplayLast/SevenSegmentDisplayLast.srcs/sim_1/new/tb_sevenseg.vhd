
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity tb_sevenseg is
end tb_sevenseg;

architecture tb of tb_sevenseg is

component SevenSegmentDisplayDesign is
port ( 
clk  	 : in std_logic;
segment  : out std_logic_vector (6 downto 0); 
anode	 : out std_logic_vector(3 downto 0)
);
end component;

signal clk_tb:  std_logic ;

signal segment_tb: std_logic_vector (6 downto 0);
signal anode_tb: std_logic_vector (3 downto 0);
constant clk_period: time := 10 ns;

begin

    uut: SevenSegmentDisplayDesign port map(
    clk => clk_tb,
    segment => segment_tb,
    anode => anode_tb);
    
    clk_process: process
    begin 
    clk_tb <= '0';
    wait for clk_period/2;
    clk_tb <= '1';
    wait for clk_period/2;
    end process;
    
    main: process
    begin 
    segment_tb <= "1111111";
    anode_tb <= "1111";
    wait for 100ns;
    
    end process;
end tb;
