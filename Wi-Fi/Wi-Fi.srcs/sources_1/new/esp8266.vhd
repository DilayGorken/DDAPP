---------------------------------------------------------
-- WifiTopLevel.vhd 
--
-- Top level for the ESP8266 demo project
--
-- Author: Mike Field <hamster@snap.net.nz>
-----------------------------------------------------------

library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity WifiTopLevel is
    Port ( clk100        : in  STD_LOGIC;                     -- 100MHz saat girişi
           led           : out STD_LOGIC_VECTOR(15 downto 0) := (others => '0'); -- 16-bit LED çıkışı
           sw            : in  STD_LOGIC_VECTOR( 0 downto 0) := (others => '0'); -- 1-bit anahtarlama girişi
           wifi_enable   : out STD_LOGIC;                    -- WiFi modülünün etkinleştirme sinyali
           wifi_rx       : in  STD_LOGIC;                     -- WiFi modülünden seri veri alımı
           wifi_tx       : out STD_LOGIC);                   -- WiFi modülüne seri veri gönderimi
end WifiTopLevel;

architecture Behavioral of WifiTopLevel is

    component esp8266_driver is
    Port ( clk100           : in  STD_LOGIC;                     -- 100MHz saat girişi
           powerdown        : in  STD_LOGIC;                     -- Güç kapama sinyali (0 ile modülü uyutma, 1 ile çalıştırma)
           status_active    : out STD_LOGIC;                    -- Modülün etkinleştirilip etkinleştirilmediğini gösteren LED
           status_wifi_up   : out STD_LOGIC;                    -- WiFi bağlantısının olup olmadığını gösteren LED
           status_connected : out STD_LOGIC;                    -- ESP8266'nın bir ağa bağlanıp bağlanmadığını gösteren LED
           status_sending   : out STD_LOGIC;                    -- Veri gönderim durumunu gösteren LED
           status_error     : out STD_LOGIC;                    -- Hata durumunu gösteren LED
           status_led_1     : out STD_LOGIC;                    -- Kullanıcı tanımlı LED 1
           status_led_2     : out STD_LOGIC;                    -- Kullanıcı tanımlı LED 2
           status_led_3     : out STD_LOGIC;                    -- Kullanıcı tanımlı LED 3
           status_led_4     : out STD_LOGIC;                    -- Kullanıcı tanımlı LED 4
           payload0         : in  std_logic_vector(7 downto 0) := x"00";  -- Gönderilecek 1. karakter
           payload1         : in  std_logic_vector(7 downto 0) := x"00";  -- Gönderilecek 2. karakter
           payload2         : in  std_logic_vector(7 downto 0) := x"00";  -- Gönderilecek 3. karakter
           payload3         : in  std_logic_vector(7 downto 0) := x"00";  -- Gönderilecek 4. karakter
           wifi_enable      : out STD_LOGIC;                    -- WiFi modülünün etkinleştirme sinyali
           wifi_rx          : in  STD_LOGIC;                     -- WiFi modülünden seri veri alımı
           wifi_tx          : out STD_LOGIC);                   -- WiFi modülüne seri veri gönderimi
    end component;

    signal char0 : std_logic_vector(7 downto 0) := x"00";  -- Gönderilecek 1. karakter için geçici değişken
    signal char1 : std_logic_vector(7 downto 0) := x"00";  -- Gönderilecek 2. karakter için geçici değişken
    signal char2 : std_logic_vector(7 downto 0) := x"00";  -- Gönderilecek 3. karakter için geçici değişken
    signal char3 : std_logic_vector(7 downto 0) := x"00";  -- Gönderilecek 4. karakter için geçici değişken

begin

    i_esp8226: esp8266_driver Port map (
           clk100           => clk100,
           powerdown        => sw(0),
           status_active    => led(0),
           status_wifi_up   => led(1),
           status_connected => led(2),
           status_sending   => led(3),
           status_error     => led(4),
           status_led_1     => led(15),
           status_led_2     => led(14),
           status_led_3     => led(13),
           status_led_4     => led(12),
           payload0         => x"41", -- ASCII A karakterini gönder
           payload1         => x"42", -- ASCII B karakterini gönder
           payload2         => x"43", -- ASCII C karakterini gönder
           payload3         => x"44", -- ASCII D karakterini gönder
           wifi_enable      => wifi_enable,
           wifi_rx          => wifi_rx,
           wifi_tx          => wifi_tx);

end Behavioral;
