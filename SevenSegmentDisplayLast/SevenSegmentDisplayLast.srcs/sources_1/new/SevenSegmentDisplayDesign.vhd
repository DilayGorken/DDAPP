library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

use IEEE.STD_LOGIC_UNSIGNED.ALL;

entity SevenSegmentDisplayDesign is
port ( 
clk  	 : in std_logic;
segment  : out std_logic_vector (6 downto 0):=(others=>'0'); 
anode	 : out std_logic_vector(3 downto 0)
);
end SevenSegmentDisplayDesign;

architecture Behavioral of SevenSegmentDisplayDesign is
signal counter_1hz	    : std_logic_vector(27 downto 0):= (others=>'0'); -- 1 saniye counter'ı olarak kullanırız. Display üzerindeki sayıların 1 saniyede değişmesini sağlar
signal gosterilceksayi	: std_logic_vector(15 downto 0):= (others=>'0');
signal display_bit	  	: std_logic_vector(3 downto 0); 
signal counter_1mhz	    : std_logic_vector(19 downto 0) := (others=>'0');  
signal anode_secici     : std_logic_vector(1 downto 0):= (others=>'0');    --aktif anotu seçer
 begin
 
 process(clk,display_bit)
begin	
if rising_edge(clk) then
	case display_bit is
		when "0000" => segment <= "0000001"; -- "0"     
		when "0001" => segment <= "1001111"; -- "1" 
		when "0010" => segment <= "0010010"; -- "2" 
		when "0011" => segment <= "0000110"; -- "3" 
		when "0100" => segment <= "1001100"; -- "4" 
		when "0101" => segment <= "0100100"; -- "5" 
		when "0110" => segment <= "0100000"; -- "6" 
		when "0111" => segment <= "0001111"; -- "7" 
		when "1000" => segment <= "0000000"; -- "8"     
		when "1001" => segment <= "0000100"; -- "9" 
		when others => segment <=(others=>'0');
end case;
end if;
end process;

process(clk)
begin
	if rising_edge(clk) then
			if (counter_1mhz="11110100001001000000") then --1_000_000'a kadar sayar bu da 1mhz'ye eşittir
				counter_1mhz <= (others => '0');
			else 
				counter_1mhz <= counter_1mhz+1;
			end if;
	end if;
end process;
---------------anode seçme-------------
anode_secici<= counter_1mhz(19 downto 18); -- anode_secici' de bir gecikme uygulanır
process(anode_secici,gosterilceksayi,display_bit,counter_1mhz,counter_1hz)
begin
case anode_secici is
	when "11" =>anode <= "0111"; 
	display_bit<=gosterilceksayi(15 downto 12);
	 when "10"=>anode <="1011";
	display_bit<= gosterilceksayi(11 downto 8);  
	when "01"=>anode <="1101";
	display_bit<= gosterilceksayi(7 downto 4);   
       when "00" =>anode <="1110";                    
	display_bit<= gosterilceksayi(3 downto 0);   
     when others =>
	 end case;
	 end process;
	 
	 -----1 saniye üretme---------
	 process(clk,counter_1hz)
		begin
		if rising_edge(clk) then
			if (counter_1hz /= "0101111101011110000100000000" )then --counter_1hz eşit değilse 100_000_000'a ++;
			counter_1hz <= counter_1hz+1;
			else
				counter_1hz <= (others => '0');						-- eşitse sıfırlanır
			end if;
			end if;
			end process;
	 
	------------hex to decimal gösterilecek sayı------------
	--> burada yapılan işlem: hex a= dec10 olduğundan her bir a  da bir basamak kaydırma yapılır. 

process(gosterilceksayi,clk,counter_1hz) 
begin

			if rising_edge(clk) then
				if (counter_1hz = "0101111101011110000100000000" )then 
				gosterilceksayi  <= gosterilceksayi+x"0001";
					end if;
				
		
			
			if(gosterilceksayi(3 downto 0) =x"a") then
				gosterilceksayi(7 downto 4) <= gosterilceksayi(7 downto 4) + "0001";
				gosterilceksayi(3 downto 0) <="0000";
				
				end if;
			
			if (gosterilceksayi(7 downto 4) =x"a" and gosterilceksayi(3 downto 0)="0000") then
				gosterilceksayi(11 downto 8) <= gosterilceksayi(11 downto 8) + "0001";
				gosterilceksayi(7 downto 0) <=x"00";
				
				end if;
			
			if (gosterilceksayi(11 downto 8)=x"a" and gosterilceksayi(7 downto 4) =x"0" and gosterilceksayi(3 downto 0)="0000") then
					gosterilceksayi(15 downto 12) <= gosterilceksayi(15 downto 12) + "0001";
					gosterilceksayi(11 downto 0) <= x"000";
					
				end if;
			if (gosterilceksayi(15 downto 12)=x"a" and gosterilceksayi(11 downto 8)=x"0" and gosterilceksayi(7 downto 4) =x"0" and gosterilceksayi(3 downto 0)="0000") then		
					   gosterilceksayi(15 downto 0) <= x"0000";
				
					end if;
					end if;
					
					end process;
					
end Behavioral;

