-- Nexys4 DDR kart�nda UART'in �al��t���n� g�steren donan�m testi.
-- 9600 bps h�z�nda al�nan her karakteri geri yans�t.
-- Warren Toomey, 2015

library ieee;
use ieee.std_logic_1164.all;

entity serialport is
    port (CLK:        in std_logic;
          BT_UART_RXD:   in std_logic;
          BT_UART_TXD:   out std_logic;          
          UART_RXD:   in std_logic;
          UART_TXD:   out std_logic;
          LED:        out std_logic; 
          SSEG_CA:    out std_logic_vector(6 downto 0);
          SSEG_AN:    out std_logic_vector(3 downto 0)
      );
end entity;

architecture behaviour of serialport is
    -- UART bile�eni 9600 bps seri portunu sim�le eder
    -- ve bir al�m (RX) ve g�nderim (TX) bile�eni bulunur
     component UART_RX_CTRL
        port (UART_RX:    in  STD_LOGIC;
              CLK:        in  STD_LOGIC;
              DATA:       out STD_LOGIC_VECTOR (7 downto 0);
              READ_DATA:  out STD_LOGIC;
              RESET_READ: in  STD_LOGIC
        );
        end component;

     component UART_TX_CTRL is
        port (SEND:    in   STD_LOGIC;
              DATA:    in   STD_LOGIC_VECTOR (7 downto 0);
              CLK:     in   STD_LOGIC;
              READY:   out  STD_LOGIC;
              UART_TX: out  STD_LOGIC);
    end component;
        
   
    -- UART'dan al�nan ve g�nderilen veriyi tutacak sinyaller
    signal uart_data_in: std_logic_vector(7 downto 0);
    signal uart_data_out: std_logic_vector(7 downto 0);

    signal uart_data_in_bt: std_logic_vector(7 downto 0);
    signal uart_data_out_bt: std_logic_vector(7 downto 0);
    signal led_lighting:std_logic_vector(7 downto 0):="00000000";
    
    -- UART al�m sinyalleri: veri kullan�labilir durumda,
    -- ve verinin al�nd���n� UART'a bildiren sinyal
    signal data_available: std_logic;
    signal reset_read: std_logic := '0';
    signal data_available_bt: std_logic;
    signal reset_read_bt: std_logic := '0';

    -- UART g�nderim sinyalleri: bile�en veri g�ndermeye haz�r durumda,
    -- ve veriyi �imdi g�ndermesini s�yleyen sinyal
    signal tx_is_ready: std_logic;
    signal send_data: std_logic := '0';
    signal tx_is_ready_bt: std_logic;
    signal send_data_bt: std_logic := '0';
    
    -- Veri al�nd���nda SEND_STATE de�i�keni kullan�l�r
    -- BT al�m durumu i�in
    type SEND_STATE_TYPE is (READY, SENT_BT,WAITING);
    signal SEND_STATE : SEND_STATE_TYPE := READY;
    
    -- Veri al�nd���nda TAKE_STATE de�i�keni kullan�l�r
    -- BT g�nderim durumu i�in
    type TAKE_STATE_TYPE is (READY, TAKE_BT,WAITING);
    signal TAKE_STATE : TAKE_STATE_TYPE := READY;

begin
    -- UART al�m bile�eni uygulamas�
    inst_UART_RX_CTRL: UART_RX_CTRL
        port map(
          UART_RX => UART_RXD,
          CLK => CLK,
          DATA => uart_data_in,
          READ_DATA => data_available,
          RESET_READ => reset_read
        );
        
    -- BT i�in UART al�m bile�eni uygulamas�
    inst_UART_RX_CTRL_BT: UART_RX_CTRL
        port map(
          UART_RX => BT_UART_RXD,
          CLK => CLK,
          DATA => uart_data_in_bt,
          READ_DATA => data_available_bt,
          RESET_READ => reset_read_bt
        );
        
    -- UART g�nderim bile�eni uygulamas�
    inst_UART_TX_CTRL: UART_TX_CTRL
        port map(
          SEND => send_data,
          CLK => CLK,
          DATA => uart_data_out,
	      READY => tx_is_ready,
          UART_TX => UART_TXD
        );

    -- BT i�in UART g�nderim bile�eni uygulamas�
    inst_UART_TX_CTRL_BT: UART_TX_CTRL
        port map(
          SEND => send_data_bt,
          CLK => CLK,
          DATA => uart_data_out_bt,
        READY => tx_is_ready_bt,
          UART_TX => BT_UART_TXD
        );

uart_receive: process(CLK, SEND_STATE, data_available)
    begin
	if (rising_edge(CLK)) then
            case SEND_STATE is
                when READY =>
		    -- Verinin gelmesini bekliyoruz.
		    -- Veri kullan�labilir ve verici haz�r durumdaysa
                    if (data_available = '1' and tx_is_ready_bt = '1') then
		  	-- Al�nan veriyi vericiye kopyala
			-- ve veriyi iletimi ba�lat
			uart_data_out_bt <= uart_data_in;
			send_data_bt <= '1';
		
                        SEND_STATE <= SENT_BT;
                    end if;
                
                when SENT_BT =>
		    -- Bir sonraki saat d�ng�s�nde, UART al�c�s�na verinin al�nd���n� bildir
		    -- ve veri iletimini ba�latma i�lemini s�f�rla
                    reset_read <= '1';
                    send_data_bt <= '0';
                    SEND_STATE <= WAITING;
                
                when WAITING =>
		    -- Al�c�n�n veriyi ald���n� bildirdikten sonra, kulland���m�z sinyali d���r.
		    -- �imdi tekrar ALINDI durumunday�z ve al�c�n�n gelecek karakteri almas�n� bekliyoruz.
                    if (data_available = '0') then
                        reset_read <= '0';
                        SEND_STATE <= READY;
                    end if;
            end case;
	end if;
	led_lighting<=uart_data_in_bt;
                    if(led_lighting=x"31") then
                            LED<='1';
                            end if;
                    if(led_lighting=x"30") then
                         LED<='0';
                            end if;

    end process;
    
uart_transmit: process(CLK, TAKE_STATE, data_available_bt)
        begin
        if (rising_edge(CLK)) then
                case TAKE_STATE is
                    when READY =>
                -- Verinin gelmesini bekliyoruz.
                        if (data_available_bt = '1' and tx_is_ready = '1') then
                  -- Al�nan veriyi vericiye kopyala
                            uart_data_out <= uart_data_in_bt;
                
                            send_data <= '1';
                            TAKE_STATE <= TAKE_BT;
                        end if;
                    
                    when TAKE_BT =>
                -- Bir sonraki saat d�ng�s�nde, UART al�c�s�na verinin al�nd���n� bildir
                        reset_read_bt <= '1';
                        send_data <= '0';
                        TAKE_STATE <= WAITING;
                    
                    when WAITING =>
		    -- Al�c�n�n veriyi ald���n� bildirdikten sonra, kulland���m�z sinyali d���r.
		    -- �imdi tekrar ALINDI durumunday�z ve al�c�n�n gelecek karakteri almas�n� bekliyoruz.
                        if (data_available_bt = '0') then
                            reset_read_bt <= '0';
                            TAKE_STATE <= READY;
                        end if;
                end case;
        end if;
        end process;
end architecture;
