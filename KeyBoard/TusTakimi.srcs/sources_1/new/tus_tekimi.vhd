
----------------------------------------------------------------------------------
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.all;



entity keypad_main is
port(
clock:in std_logic;
RST  :in std_logic;

sutun_en	:out std_logic_vector(3 downto 0);

satir_data :in std_logic_vector(3 downto 0);


anot 		:out std_logic_vector(3 downto 0);
led      :out std_logic_vector(6 downto 0)----katotlar


);
end keypad_main;

architecture Behavioral of keypad_main is

signal okunan_karakter : std_logic_vector(3 downto 0);

signal counter:unsigned(26 downto 0);

signal hata : std_logic;

signal satir_data_buf  : std_logic_vector(3 downto 0);
signal satir_data_buf2  : std_logic_vector(3 downto 0);
signal satir_data_buf3  : std_logic_vector(3 downto 0);
signal satir_data_buf4  : std_logic_vector(3 downto 0);
signal satir_data_temiz : std_logic_vector(3 downto 0);
begin




PROCESS(rst,clock)

BEGIN




--anotlarýn taranmasý
if rst='0' then
	counter<=(OTHERS=>'0');
	okunan_karakter     <=(OTHERS=>'0');
	sutun_en			<=(OTHERS=>'0');
	led				    <=(OTHERS=>'0');	
	anot				<=(OTHERS=>'0');	

	satir_data_buf	<=(OTHERS=>'0');
	satir_data_buf2	<=(OTHERS=>'0');
	satir_data_buf3	<=(OTHERS=>'0');
	satir_data_buf4	<=(OTHERS=>'0');	
	satir_data_temiz	<=(OTHERS=>'0');		
elsif rising_edge(clock) then

   counter<=counter+1;
	satir_data_buf	   <= satir_data;
	satir_data_buf2    <=satir_data_buf;	
	satir_data_buf3	   <=satir_data_buf2;	
	satir_data_buf4    <=satir_data_buf3;
	
	
	if (satir_data_buf4 = satir_data_buf3 and satir_data_buf4=satir_data_buf2 and satir_data_buf4=satir_data_buf  and satir_data_buf4=satir_data ) then
		satir_data_temiz<=satir_data_buf4;
	end if;

case (std_logic_vector'(counter(16),counter(15), counter(14))) is
when"000" => 
	sutun_en<="0001";--sutun1
	case(satir_data_temiz) is
	when"0001" => hata<='0'    ;okunan_karakter<="0001";--1
	when"0010" => hata<='0'    ;okunan_karakter<="0100";--4
	when"0100" => hata<='0'    ;okunan_karakter<="0111";--7
	when"1000" => hata<='0'    ;okunan_karakter<="1110";--*
	when others =>hata<='1'    ;
	end case;
when"001" => 	sutun_en<="0000";	

when"010" => 
	sutun_en<="0010";--sutun2
	case(satir_data_temiz) is
	when"0001" => hata<='0'    ;okunan_karakter<="0010";--2
	when"0010" => hata<='0'    ;okunan_karakter<="0101";--5
	when"0100" => hata<='0'    ;okunan_karakter<="1000";--8
	when"1000" => hata<='0'    ;okunan_karakter<="0000";--0
	when others =>hata<='1'    ;
	end case;
when"011" => 	sutun_en<="0000";		
when"100" => 
	sutun_en<="0100";--sutun3
	case(satir_data_temiz) is
	when"0001" => hata<='0'    ;okunan_karakter<="0011";--3
	when"0010" => hata<='0'    ;okunan_karakter<="0110";--6
	when"0100" => hata<='0'    ;okunan_karakter<="1001";--9
	when"1000" => hata<='0'    ;okunan_karakter<="1111";--#
	when others =>hata<='1' ;
	end case;
when"101" => 	sutun_en<="0000";	
when "110" => 
	sutun_en<="1000";--sutun4
	case(satir_data_temiz) is
	when"0001" => hata<='0'    ;okunan_karakter<="1010";--A
	when"0010" => hata<='0'    ;okunan_karakter<="1011";--B
	when"0100" => hata<='0'    ;okunan_karakter<="1100";--C
	when"1000" => hata<='0'    ;okunan_karakter<="1101";--D
	when others =>hata<='1' ;
	end case;
when OTHERS=> 	sutun_en<="0000";		
end case;







anot<="0111" ;--anot0 aktif

if hata='0' then
case (okunan_karakter) is
when"0000"=> led<="1000000";
when"0001"=> led<="1111001";
when"0010"=> led<="0100100";
when"0011"=> led<="0110000";
when"0100"=> led<="0011001";
when"0101"=> led<="0010010";
when"0110"=> led<="0000010";
when"0111"=> led<="1111000";
when"1000"=> led<="0000000";--8
when"1001"=> led<="0010000";--9
when"1010"=> led<="0001000";--a
when"1011"=> led<="0000000";--b
when"1100"=> led<="1000110";--c
when"1101"=> led<="1000000";--d
when"1110"=> led<="0000110";--e
when"1111"=> led<="0001110";--f
when others=> led<="0010000";
end case;
end if;


end if;


END PROCESS;


end Behavioral;
