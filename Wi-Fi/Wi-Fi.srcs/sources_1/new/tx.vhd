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
           busy        : out STD_LOGIC;                     --meþgul çýkýþýný saðlar
           tx_out      : out STD_LOGIC);                    -- UART arayüzü üzerinden seri olarak gönderilecek veriyi temsil eder.
end tx;

architecture Behavioral of tx is
    signal baud_count       : unsigned(13 downto 0) := (others => '0'); -- veri iletimi için baud hýzý aralýðýný belirtir.
    constant baud_count_max : unsigned(13 downto 0) := to_unsigned(100000000/115200, 14); -- burada belirlenen deðer 100mhz frekans ile 
                                                                                          -- 115.200 hýz arasýndaki iliþkiyi belirtir
  
    signal busy_sr          : std_logic_vector(9 downto 0) := (others => '0');            --gönderme iþleminin tamamlandýðýný belirten 1 bitlik bir kaydýrma kaydedicidir.      

    signal sending          : std_logic_vector(9 downto 0) := (others => '0');--veri gönderme sürecinde gönderilen karakterleri tutar 
begin                                                                         --gönderilen karakterleri döngüsel olarak doldurarak UART formatýnda hazýrlar.
    busy <= busy_sr(0) or data_enable; 
    
clk_proc: process(clk)
    begin   
        if rising_edge(clk) then
            if baud_count = 0 then                                 
                baud_count <= baud_count_max;                      --
                tx_out     <= sending(0);                           -- tx_out a sending in lsb biti atanýr.
                sending    <= '1' & sending(sending'high downto 1);--sending için bir döngüsel kaydýrma yapýlýr
                                                                   --msb biti alýnýr, diðer bitler 1 saða kayar 
                                                                   --lsb bitine 1 ekler. Veri gönderimi hazýrlanýr.
                busy_sr    <= '0' & busy_sr(busy_sr'high downto 1);--döngüsel kaydýrýlýr. lsb biti 0 yapýlýr
            else
                baud_count  <= baud_count - 1;                      --baud_count max deðerinden 1 azalarak çalýþýr.
                                                                    -- max deðerinden 0 a ulaþana kadar iletiþimin 
                                                                    -- saðlanmasýný saðlar.
            end if;

            if busy_sr(0) = '0' and data_enable = '1' then          --data_enable=1 ise; gönderim talebi var.
                                                                    -- ancak yeni veri gönderimin olabilmesi için
                                                                    --bir önceki gönderimin tammalanmýþ olmasý gerekir.
                                                                    --busy_sr(0)=0 bunu kanýtlar.
                                                                    
                                                                    
                baud_count <= baud_count_max;                       --belirtilen þartlar saðlandýðýnda baud aralýðý 
                                                                    --max deðerine ayarlanarak yeni zaman dilimi baþlatýlýr.
                                                                    
                                                                    
                sending    <= "1" & data & "0";                     --start(1)-stop(0) bitleri ile birlikte data sending'e yüklenir.
                busy_sr    <= (others =>'1');                       -- yeni veri akýþý baþladý busy_sr tüm bitleri 1.
            end if;
            
        end if;
    end process;

end Behavioral;