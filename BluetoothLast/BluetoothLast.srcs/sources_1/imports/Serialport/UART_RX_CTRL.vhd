----------------------------------------------------------------------------
-- UART_RX_CTRL.vhd -- Simple UART RX controller
-- Written by Hamster
-- Modified by Warren Toomey
--
-- Bu bile�en, bir UART cihaz� �zerinden veri aktarmak i�in kullan�labilir.
-- Bir byte seri veri alacak ve bunu 8-bit bir veri yolu �zerinden iletecektir.
-- Serile�tirilmi� verinin a�a��daki �zelliklere sahip olmas� gerekir:
--   *9600 Baud H�z�
--   *8 veri biti, en d���k bit �nce
--   *1 stop bit
--   *parity yok
--                                      
-- Port A��klamalar�:
--    UART_RX - Bu, UART'dan seri sinyal hatt�d�r.
--        CLK - 100 MHz saat beklenir.
--       DATA - Okunacak paralel veri.
--  READ_DATA - Verinin okunmaya haz�r oldu�unu belirten sinyal bayra��.
-- RESET_READ - Veri okundu, bu da READ_DATA'y� kapat�r.
----------------------------------------------------------------------------

library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;
entity UART_RX_CTRL is
    port ( UART_RX: in   STD_LOGIC;
        CLK:        in   STD_LOGIC;
        DATA:       out  STD_LOGIC_VECTOR (7 downto 0);
        READ_DATA:  out  STD_LOGIC := '0';
        RESET_READ: in   STD_LOGIC
    );
end UART_RX_CTRL;

architecture behavioral of UART_RX_CTRL is
    
     constant FREQ : integer := 100_000_000;  -- 100MHz Basys3 CLK
     constant BAUD : integer := 9600;       -- Seri ileti�im bit h�z�
    
     -- Bir saat �evrim sayac�. Gelen seri sinyali �rneklemeyi,
     -- seri bit s�resinin 1.5 kat� kadar ger�ekle�tiriyoruz.
     -- Bu sayede ba�lang�� bitini atlay�p ilk veri bitinin ortas�na ge�iyoruz.
     -- Sonras�nda, di�er veri bitlerinin ortas�ndan �rneklemek i�in tam bit s�relerini atl�yoruz.
    
    signal   count   : integer := 0;
    constant sample_0: integer := 3 * FREQ/(BAUD*2)-1;   -- 15.624
    constant sample_1: integer := 5 * FREQ/(BAUD*2)-1;   -- 26.041
    constant sample_2: integer := 7 * FREQ/(BAUD*2)-1;
    constant sample_3: integer := 9 * FREQ/(BAUD*2)-1;
    constant sample_4: integer := 11 * FREQ/(BAUD*2)-1;
    constant sample_5: integer := 13 * FREQ/(BAUD*2)-1;
    constant sample_6: integer := 15 * FREQ/(BAUD*2)-1;
    constant sample_7: integer := 17 * FREQ/(BAUD*2)-1;
    constant stop_bit: integer := 19 * FREQ/(BAUD*2)-1;
    
     -- Seri giri�ten gelen bitler burada birikir
    signal byte: std_logic_vector(7 downto 0) := (others => '0');
     
begin
    rx_state_process : process (CLK)
    begin
        if (rising_edge(CLK)) then
            
           -- Veri okundu, bu y�zden yeni veri geldi�ini belirten bayra�� d���r
            if (RESET_READ = '1') then
                READ_DATA <= '0';
            end if;
            
	    -- Seri hatt� birka� kez �rneklemleyerek sekiz veri bitini ve stop bitini buluyoruz
            case count is 
                when sample_0 => byte <= UART_RX & byte(7 downto 1);
                when sample_1 => byte <= UART_RX & byte(7 downto 1);
                when sample_2 => byte <= UART_RX & byte(7 downto 1);
                when sample_3 => byte <= UART_RX & byte(7 downto 1);
                when sample_4 => byte <= UART_RX & byte(7 downto 1);
                when sample_5 => byte <= UART_RX & byte(7 downto 1);
                when sample_6 => byte <= UART_RX & byte(7 downto 1);
                when sample_7 => byte <= UART_RX & byte(7 downto 1);
                when stop_bit =>  
                    -- Ge�erli bir stop biti g�rd���m�zde veriyi g�nder
                    if UART_RX = '1' then 
                        DATA <= byte;
                        READ_DATA <= '1';
                    end if;
                when others =>
                    null;
            end case;
            
            -- SStop bitine ula��ld���nda sayac� s�f�rla
            if count = stop_bit then
                count <= 0;
            elsif count = 0 then
                if UART_RX = '0' then -- Ba�lang�� biti g�r�ld�, saymay� ba�lat
                    count <= count + 1;   
                end if;
            else
                count <= count + 1;   
            end if;
            
            
            
            
        end if;
    end process;
end behavioral;
