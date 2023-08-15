---------------------------------------------------------------------
-- Bu bileþen, Nexys4 DDR geliþtirme kartýndaki yedi segment LED'lerine
-- sekiz onaltýlýk rakamý görüntülemek için kullanýlýr. Giriþler, 100MHz CLK,
-- 32 bit veri deðeri ve sekiz haneli LED'leri etkinleþtiren 8 bitlik maskeyi içerir.
--
-- CLK, SSEG_CA ve SSEG_EN sinyallerini kartýnýzdaki uygun I/O pinlerine baðlamanýz gerekir.
-- 
-- (c) 2015 Warren Toomey, GPL3 lisansý
---------------------------------------------------------------------
library ieee;
use ieee.std_logic_1164.all;

entity hex_7seg is
    port (CLK:          in std_logic;
	      DATA:         in std_logic_vector(31 downto 0);
          DIGIT_ENABLE: in std_logic_vector(3 downto 0);
          SSEG_CA:      out std_logic_vector(6 downto 0);
          SSEG_AN:      out std_logic_vector(3 downto 0)
    );
end entity;

architecture behaviour of hex_7seg is
    -- Yedi segment LED hanelerinde görüntülenecek 4 bitlik bir deðer
    signal hex_value: std_logic_vector(3 downto 0);

    --Belirli bir anodu seçmek için 4 bitlik bir maske
    signal chosen_anode: std_logic_vector(3 downto 0) := "1110";

    -- Yedi segment LED anotlarýný sarmak için bir saat ve bir sayaç
    signal sseg_clk: std_logic := '0';
    signal sseg_counter: integer := 0;

begin
    -- Yavaþ çalýþan bir saate ihtiyacýmýz var, bu nedenle yavaþ bir saat oluþturan bir iþlem var
    sseg_clock_process: process(CLK)
        begin
            if (rising_edge(CLK)) then
                if (sseg_counter = 0) then
                    sseg_counter <= 10000; -- 1 sn süre bekler
                    -- Sayaç sýfýrlandýðýnda sseg_clk'yi tersine çevir
                    sseg_clk <= not(sseg_clk);
                else
                    sseg_counter <= sseg_counter - 1; --sayaç devamlý azaltýlýr.
                end if;
            end if;
        end process;

    -- Adres ve veri otobüs deðerlerini 7-seg LED'lerinde görüntülemek için kod

    with hex_value select
	SSEG_CA <= "1000000" when "0000",	-- 0
                   "1111001" when "0001",	-- 1
                   "0100100" when "0010",	-- 2
                   "0110000" when "0011",	-- 3
                   "0011001" when "0100",	-- 4
                   "0010010" when "0101",	-- 5
                   "0000010" when "0110",	-- 6
                   "1111000" when "0111",	-- 7
                   "0000000" when "1000",	-- 8
                   "0010000" when "1001",	-- 9
                   "0001000" when "1010",	-- A
                   "0000011" when "1011",	-- B
                   "1000110" when "1100",	-- C
                   "0100001" when "1101",	-- D
                   "0000110" when "1110",	-- E
                   "0001110" when "1111",	-- F
                   "1111111" when others;

    -- Kullanýcý seçimine baðlý olarak anotlarý etkinleþtirme/devre dýþý býrakma
    SSEG_AN <= chosen_anode or not(DIGIT_ENABLE);
    
    
    ------------------------------------------------------------------------------------------------------
    -- Veriyi hex_value hatlarýna çoklayarak her bir anotu sürme


-- Bu süreç, yedi segment LED göstergelerini sarmak için kullanýlýr. 
-- Her bir anot döngüsü boyunca, belirli bir anotun etkinleþtirilmesi
-- gereken yedi segment LED'lere hangi verinin atanacaðýný belirler.


    seven_segment_process: process(sseg_clk)
        begin
            if (rising_edge(sseg_clk)) then
		case chosen_anode is 
		    when "1110" =>
		    	chosen_anode <= "1101";
		    	hex_value <= DATA(7 downto 4);
		    when "1101" =>
		    	chosen_anode <= "1011";
		    	hex_value <= DATA(11 downto 8);
		    when "1011" =>
		    	chosen_anode <= "0111";
		    	hex_value <= DATA(15 downto 12);
		    when "0111" =>
		    	chosen_anode <= "1110";
		    	hex_value <= DATA(19 downto 16);
		    
		    when others =>
		    	chosen_anode <= "1111";
		    	hex_value <= "0000";
            	end case;
            	
            	-- her bir döngüde farklý bir onaltýlýk hane görüntülenir.
            end if;
        end process;
end architecture;
