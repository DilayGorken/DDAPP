----------------------------------------------------------------------------
-- UART_RX_CTRL.vhd -- Simple UART RX controller
-- Written by Hamster
-- Modified by Warren Toomey
--
-- Bu bileþen, bir UART cihazý üzerinden veri aktarmak için kullanýlabilir.
-- Bir byte seri veri alacak ve bunu 8-bit bir veri yolu üzerinden iletecektir.
-- Serileþtirilmiþ verinin aþaðýdaki özelliklere sahip olmasý gerekir:
--   *9600 Baud Hýzý
--   *8 veri biti, en düþük bit önce
--   *1 stop bit
--   *parity yok
--                                      
-- Port Açýklamalarý:
--    UART_RX - Bu, UART'dan seri sinyal hattýdýr.
--        CLK - 100 MHz saat beklenir.
--       DATA - Okunacak paralel veri.
--  READ_DATA - Verinin okunmaya hazýr olduðunu belirten sinyal bayraðý.
-- RESET_READ - Veri okundu, bu da READ_DATA'yý kapatýr.
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
     constant BAUD : integer := 9600;       -- Seri iletiþim bit hýzý
    
     -- Bir saat çevrim sayacý. Gelen seri sinyali örneklemeyi,
     -- seri bit süresinin 1.5 katý kadar gerçekleþtiriyoruz.
     -- Bu sayede baþlangýç bitini atlayýp ilk veri bitinin ortasýna geçiyoruz.
     -- Sonrasýnda, diðer veri bitlerinin ortasýndan örneklemek için tam bit sürelerini atlýyoruz.
    
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
    
     -- Seri giriþten gelen bitler burada birikir
    signal byte: std_logic_vector(7 downto 0) := (others => '0');
     
begin
    rx_state_process : process (CLK)
    begin
        if (rising_edge(CLK)) then
            
           -- Veri okundu, bu yüzden yeni veri geldiðini belirten bayraðý düþür
            if (RESET_READ = '1') then
                READ_DATA <= '0';
            end if;
            
	    -- Seri hattý birkaç kez örneklemleyerek sekiz veri bitini ve stop bitini buluyoruz
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
                    -- Geçerli bir stop biti gördüðümüzde veriyi gönder
                    if UART_RX = '1' then 
                        DATA <= byte;
                        READ_DATA <= '1';
                    end if;
                when others =>
                    null;
            end case;
            
            -- SStop bitine ulaþýldýðýnda sayacý sýfýrla
            if count = stop_bit then
                count <= 0;
            elsif count = 0 then
                if UART_RX = '0' then -- Baþlangýç biti görüldü, saymayý baþlat
                    count <= count + 1;   
                end if;
            else
                count <= count + 1;   
            end if;
            
            
            
            
        end if;
    end process;
end behavioral;
