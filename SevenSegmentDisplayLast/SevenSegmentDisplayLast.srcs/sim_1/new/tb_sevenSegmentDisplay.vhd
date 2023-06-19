library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity SevenSegmentDisplayDesign_tb is
end SevenSegmentDisplayDesign_tb;

architecture Behavioral of SevenSegmentDisplayDesign_tb is
    -- Component Declaration for Unit Under Test (UUT)
    component SevenSegmentDisplayDesign
    Port (clock_100mhz:in std_logic ;
        reset:in std_logic;
       an: out std_logic_vector(3 downto 0 );
       seg: out std_logic_vector (6 downto 0));
    end component;

    -- Inputs
    signal clock_100mhz : std_logic := '0';
    signal reset : std_logic := '0';

    -- Outputs
    signal an : std_logic_vector(3 downto 0);
    signal seg : std_logic_vector (6 downto 0);

begin
    -- Instantiate the Unit Under Test (UUT)
    uut: SevenSegmentDisplayDesign port map (
        clock_100mhz => clock_100mhz,
        reset => reset,
        an => an,
        seg => seg
    );

    -- Clock process definitions
    clock_100mhz_process :process
     constant clock_period : time := 10ns;
    begin
    
        while now < 1000 ns loop
            clock_100mhz <= '0';
            wait for clock_period / 2;
            clock_100mhz <= '1';
            wait for clock_period / 2;
        end loop;
        wait;
    end process;

    -- Reset process definition
    reset_process : process
    begin
        reset <= '1';
        wait for 10 ns;
        reset <= '0';
        wait for 100 ns;
        reset <= '1';
        wait;
    end process;

end Behavioral;