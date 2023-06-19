library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity keypad_main_tb is
end keypad_main_tb;

architecture Behavioral of keypad_main_tb is

  component keypad_main
    port(
      clock       : in  std_logic;
      RST         : in  std_logic;
      sutun_en    : out std_logic_vector(3 downto 0);
      satir_data  : in  std_logic_vector(3 downto 0);
      anot        : out std_logic_vector(3 downto 0);
      led         : out std_logic_vector(6 downto 0)
    );
  end component;

  signal clock_tb      : std_logic := '0';
  signal RST_tb        : std_logic := '0';
  signal sutun_en_tb   : std_logic_vector(3 downto 0);
  signal satir_data_tb : std_logic_vector(3 downto 0);
  signal anot_tb       : std_logic_vector(3 downto 0);
  signal led_tb        : std_logic_vector(6 downto 0);

begin

  UUT: keypad_main
    port map(
      clock       => clock_tb,
      RST         => RST_tb,
      sutun_en    => sutun_en_tb,
      satir_data  => satir_data_tb,
      anot        => anot_tb,
      led         => led_tb
    );

  process
  begin
    RST_tb <= '1';
    wait for 10 ns;
    RST_tb <= '0';
    wait for 10 ns;

    -- Test for pressing button 1
    satir_data_tb <= "0001";
    wait for 10 ns;
    assert (sutun_en_tb = "0001" and anot_tb = "1110" and led_tb = "0000001")
    report "Test failed for pressing button 1" severity error;
    wait for 10 ns;

    -- Test for pressing button 2
    satir_data_tb <= "0010";
    wait for 10 ns;
    assert (sutun_en_tb = "0010" and anot_tb = "1101" and led_tb = "0000010")
    report "Test failed for pressing button 2" severity error;
    wait for 10 ns;

    -- Test for pressing button 3
    satir_data_tb <= "0100";
    wait for 10 ns;
    assert (sutun_en_tb = "0100" and anot_tb = "1011" and led_tb = "0000011")
    report "Test failed for pressing button 3" severity error;
    wait for 10 ns;

    -- Test for pressing button 4
    satir_data_tb <= "0001";
    wait for 10 ns;
    assert (sutun_en_tb = "0001" and anot_tb = "1110" and led_tb = "0000001")
    report "Test failed for pressing button 4" severity error;
    wait for 10 ns;

    -- Test for pressing button A
    satir_data_tb <= "0001";
    wait for 10 ns;
    satir_data_tb <= "0100";
    wait for 10 ns;
    assert (sutun_en_tb = "1000" and anot_tb = "0111" and led_tb = "0010100")
    report "Test failed for pressing button A" severity error;
    wait for 10 ns;

    report "All tests passed";
    
    end process;
    end behavioral;