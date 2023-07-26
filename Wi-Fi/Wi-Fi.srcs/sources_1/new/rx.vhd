-- rx.vhd - ESP8266'dan seri veri almak için kullanılan UART veri alma bileşeni
--
-- 9600 baud hızı ve 100MHz saat frekansı için tasarlanmıştır
--

library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity rx is
    Port ( clk         : in STD_LOGIC;                            -- Saat girişi
           rx_in       : in STD_LOGIC;                            -- RX veri girişi
           data        : out STD_LOGIC_VECTOR (7 downto 0);      -- Alınan veriyi belirtir
           data_enable : out STD_LOGIC);                          -- Veri hazır olduğunda kontrol sinyali
end rx;

architecture Behavioral of rx is
    signal baud_count           : unsigned(13 downto 0) := (others => '0');  -- Baud sayacı
    constant baud_count_max     : unsigned(13 downto 0) := to_unsigned(100000000/115200, 14); -- Baud genişliği tanımlaması 
    signal busy                  : std_logic := '0';  -- Veri alımının devam edip etmediğini gösteren sinyal
    signal receiving             : std_logic_vector(7 downto 0) := (others => '0');  -- Alınan veriyi tutan değişken
    signal rx_in_last            : std_logic := '1';  -- RX sinyalinin önceki durumunu tutar
    signal rx_in_synced          : std_logic := '1';  -- Senkronizasyon sağlandı
    signal rx_in_almost_synced   : std_logic := '1';  -- Neredeyse senkronize edildi

    signal bit_count             : unsigned(3 downto 0) := (others => '0');  -- Alınan bitleri sayan sayaç
begin

    process(clk)
    begin
        if rising_edge(clk) then
            data_enable <= '0';  -- Veri çıkışı için kontrol sinyalini sıfırla, sadece veri alındığında aktif hale gelecek
            
            if busy = '1' then
                if baud_count = 0 then
                    if bit_count = 9 then
                        -- Tüm bitleri aldık
                        busy        <= '0';  -- Veri alımını durdur, veri alındı ve hazır
                        data        <= receiving(7 downto 0);  -- Alınan veriyi dışarı ver
                        data_enable <= '1';  -- Veri hazır olduğunu belirt, dışarı veri çıkabilir
                    end if;
                    
                    -- Bu biti al
                    receiving   <= rx_in_synced & receiving(7 downto 1);  -- Alınan biti veri değişkenine ekleyerek kaydır
                    bit_count   <= bit_count + 1;  -- Bit sayacını arttır, bir sonraki biti almak için
                    baud_count  <= baud_count_max;  -- Baud sayacını sıfırla, bir sonraki bitin başlamasını sağla
                else
                    baud_count <= baud_count - 1;  -- Baud sayacını azalt, veri biti boyunca saymayı sürdür
                end if; 
            else
                -- Bu başlangıç bitinin düşen kenarı mı?
                if rx_in_last = '1' and rx_in_synced = '0' then
                    -- Tam ortada örnekleme yapmak için yarı sayıda yükle
                    baud_count <= '0' & baud_count_max(13 downto 1);  -- Baud sayacını yarıya ayarla, verinin tam ortasında örnekleme yapar
                    bit_count  <= (others => '0');  -- Bit sayacını sıfırla, yeni veri alımı için hazırlık yap
                    busy       <= '1';  -- Veri alımını başlat, veri alınmaya başladı
                end if;   
            end if;

            rx_in_last         <= rx_in_synced;  -- RX sinyalinin önceki durumunu güncelle, bir sonraki çıkış için sakla
            -- RX sinyalini senkronize et
            rx_in_synced        <= rx_in_almost_synced;  -- RX sinyalini daha önceki durumla güncelle
            rx_in_almost_synced <= rx_in;  -- RX sinyalini daha önceki durumla güncelle
        end if;
    end process;
end Behavioral;
