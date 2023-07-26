-----------------------------------------
-- tx.vhd - Transmit data to an ESP8266
--
-- Author: Mike Field <hamster@snap.net.nz>
--
-- Designed for 9600 baud and 100MHz clock
--
------------------------------------------------
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity tx is
    Port ( clk         : in  STD_LOGIC;                     --100mhz
           data        : in  STD_LOGIC_VECTOR (7 downto 0); -- iletilecek veri
           data_enable : in  STD_LOGIC;                     -- veri iletimi aktivasyonunu kontrol eder
           busy        : out STD_LOGIC;                     --me�gul ��k���n� sa�lar
           tx_out      : out STD_LOGIC);                    -- UART aray�z� �zerinden seri olarak g�nderilecek veriyi temsil eder.
end tx;

architecture Behavioral of tx is
    signal baud_count       : unsigned(13 downto 0) := (others => '0'); -- veri iletimi i�in baud h�z� aral���n� belirtir.
    constant baud_count_max : unsigned(13 downto 0) := to_unsigned(100000000/115200, 14); -- burada belirlenen de�er 100mhz frekans ile 
                                                                                          -- 115.200 h�z aras�ndaki ili�kiyi belirtir
  
    signal busy_sr          : std_logic_vector(9 downto 0) := (others => '0');            --g�nderme i�leminin tamamland���n� belirten 1 bitlik bir kayd�rma kaydedicidir.      

    signal sending          : std_logic_vector(9 downto 0) := (others => '0');--veri g�nderme s�recinde g�nderilen karakterleri tutar 
begin                                                                         --g�nderilen karakterleri d�ng�sel olarak doldurarak UART format�nda haz�rlar.
    busy <= busy_sr(0) or data_enable; 
    
clk_proc: process(clk)
    begin   
        if rising_edge(clk) then
            if baud_count = 0 then                                 
                baud_count <= baud_count_max;                      --
                tx_out     <= sending(0);                           -- tx_out a sending in lsb biti atan�r.
                sending    <= '1' & sending(sending'high downto 1);--sending i�in bir d�ng�sel kayd�rma yap�l�r
                                                                   --msb biti al�n�r, di�er bitler 1 sa�a kayar 
                                                                   --lsb bitine 1 ekler. Veri g�nderimi haz�rlan�r.
                busy_sr    <= '0' & busy_sr(busy_sr'high downto 1);--d�ng�sel kayd�r�l�r. lsb biti 0 yap�l�r
            else
                baud_count  <= baud_count - 1;                      --baud_count max de�erinden 1 azalarak �al���r.
                                                                    -- max de�erinden 0 a ula�ana kadar ileti�imin 
                                                                    -- sa�lanmas�n� sa�lar.
            end if;

            if busy_sr(0) = '0' and data_enable = '1' then          --data_enable=1 ise; g�nderim talebi var.
                                                                    -- ancak yeni veri g�nderimin olabilmesi i�in
                                                                    --bir �nceki g�nderimin tammalanm�� olmas� gerekir.
                                                                    --busy_sr(0)=0 bunu kan�tlar.
                                                                    
                                                                    
                baud_count <= baud_count_max;                       --belirtilen �artlar sa�land���nda baud aral��� 
                                                                    --max de�erine ayarlanarak yeni zaman dilimi ba�lat�l�r.
                                                                    
                                                                    
                sending    <= "1" & data & "0";                     --start(1)-stop(0) bitleri ile birlikte data sending'e y�klenir.
                busy_sr    <= (others =>'1');                       -- yeni veri ak��� ba�lad� busy_sr t�m bitleri 1.
            end if;
            
        end if;
    end process;

end Behavioral;