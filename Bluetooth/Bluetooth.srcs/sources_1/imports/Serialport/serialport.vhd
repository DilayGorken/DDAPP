-- Hardware testbed to show that the UART works on the Nexys4 DDR board.
-- For each character received at 9600bps, echo it back.
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
    -- The UART component simulates a 9600 bps serial port
    -- and there is a receive (RX) and transmit (TX) component
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

    
    -- Signals to hold the data in from and out to the UART
    signal uart_data_in: std_logic_vector(7 downto 0);
    signal uart_data_out: std_logic_vector(7 downto 0);

    signal uart_data_in_bt: std_logic_vector(7 downto 0);
    signal uart_data_out_bt: std_logic_vector(7 downto 0);
    signal led_lighting:std_logic_vector(7 downto 0):="00000000";
    -- UART receive signals: data is available, and
    -- a line to tell the UART that we have absorbed the data
    signal data_available: std_logic;
    signal reset_read: std_logic := '0';
    signal data_available_bt: std_logic;
    signal reset_read_bt: std_logic := '0';

    -- UART transmit signals: the component is ready to send
    -- a character, and a line to tell it to send the data now
    signal tx_is_ready: std_logic;
    signal send_data: std_logic := '0';
    signal tx_is_ready_bt: std_logic;
    signal send_data_bt: std_logic := '0';
    -- Once the READ_DATA line goes high, we strobe the send_data
    -- line and move to the SENT state. Then we move into the
    -- WAITING state until READ_DATA drops, and we return to READY.

--    type SEND_STATE_TYPE is (READY, SENT_BT, WAIT_BT, TAKE, SENT_PMOD, WAITING);
    type SEND_STATE_TYPE is (READY, SENT_BT,WAITING);
    signal SEND_STATE : SEND_STATE_TYPE := READY;
    
    type TAKE_STATE_TYPE is (READY, TAKE_BT,WAITING);
    signal TAKE_STATE : TAKE_STATE_TYPE := READY;

    -- Diagnostic: store the last four characters here
    signal last_four_chars: std_logic_vector(31 downto 0) := (others => '0');
    
begin
    -- Instantiation of the UART receive component
    inst_UART_RX_CTRL: UART_RX_CTRL
        port map(
          UART_RX => UART_RXD,
          CLK => CLK,
          DATA => uart_data_in,
          READ_DATA => data_available,
          RESET_READ => reset_read
        );
        
    -- Instantiation of the UART receive component for BT
    inst_UART_RX_CTRL_BT: UART_RX_CTRL
        port map(
          UART_RX => BT_UART_RXD,
          CLK => CLK,
          DATA => uart_data_in_bt,
          READ_DATA => data_available_bt,
          RESET_READ => reset_read_bt
        );
        
        
    -- Instantiation of the UART transmit component
    inst_UART_TX_CTRL: UART_TX_CTRL
        port map(
          SEND => send_data,
          CLK => CLK,
          DATA => uart_data_out,
	      READY => tx_is_ready,
          UART_TX => UART_TXD
        );

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
		    -- We are waiting for data to arrive.
		    -- If data is available and the transmitter is ready
                    if (data_available = '1' and tx_is_ready_bt = '1') then
		  	-- Copy the data read in to the transmitter
			-- and initiate the transmiss
			uart_data_out_bt <= uart_data_in;
			send_data_bt <= '1';
		
                        SEND_STATE <= SENT_BT;
                    end if;
                
                when SENT_BT =>
		    -- On the next clock cycle, tell the UART receiver
		    -- that we read the data, and reset the transmit initiation
                    reset_read <= '1';
                    send_data_bt <= '0';
                    SEND_STATE <= WAITING;
                
                when WAITING =>
		    -- Once the receiver knows that we have absorbed the
		    -- data, lower the line that we used to tell it so.
		    -- We are now back in the READY state, waiting for the
		    -- next character to arrive on the receiver.
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
                -- We are waiting for data to arrive.
                -- If data is available and the transmitter is ready
                        if (data_available_bt = '1' and tx_is_ready = '1') then
                  -- Copy the data read in to the transmitter
                -- and initiate the transmission
                uart_data_out <= uart_data_in_bt;
                
                            send_data <= '1';
                            TAKE_STATE <= TAKE_BT;
                        end if;
                    
                    when TAKE_BT =>
                -- On the next clock cycle, tell the UART receiver
                -- that we read the data, and reset the transmit initiation
                        reset_read_bt <= '1';
                        send_data <= '0';
                        TAKE_STATE <= WAITING;
                    
                    when WAITING =>
                -- Once the receiver knows that we have absorbed the
                -- data, lower the line that we used to tell it so.
                -- We are now back in the READY state, waiting for the
                -- next character to arrive on the receiver.
                        if (data_available_bt = '0') then
                            reset_read_bt <= '0';
                            TAKE_STATE <= READY;
                        end if;
                end case;
        end if;
        end process;
        


        	

         
--    uart_receive: process(CLK, SEND_STATE, data_available)
--    begin
--	if (rising_edge(CLK)) then
--            case SEND_STATE is
--                when READY =>
--		    -- We are waiting for data to arrive.
--		    -- If data is available and the transmitter is ready
--                    if (data_available = '1' and tx_is_ready_bt = '1') then
--                    -- Copy the data read in to the transmitter
--                    -- and initiate the transmission
--                    uart_data_out_bt <= uart_data_in;
			
--                        send_data_bt <= '1';
--                        SEND_STATE <= SENT_BT;
--                    end if;
                
--                when SENT_BT =>
--		    -- On the next clock cycle, tell the UART receiver
--		    -- that we read the data, and reset the transmit initiation
--                    reset_read <= '1';
--                    send_data_bt <= '0';
--                    SEND_STATE <= WAIT_BT;
--                when WAIT_BT =>
--                    if (data_available = '0' and data_available_bt = '0' ) then
--                        reset_read <= '0';
--                        reset_read_bt <= '0';
--                        SEND_STATE <= TAKE;
--                    end if;
--                when TAKE =>
--                    if (data_available_bt = '1' and tx_is_ready = '1') then
--                        uart_data_out <= uart_data_in_bt;
--                        send_data <= '1';
--                        SEND_STATE <= SENT_PMOD;
--                    end if;
--                when SENT_PMOD =>
--                    reset_read_bt <= '1';
--                    send_data <= '0';
--                    SEND_STATE <= WAITING;
                
--                when WAITING =>
--		    -- Once the receiver knows that we have absorbed the
--		    -- data, lower the line that we used to tell it so.
--		    -- We are now back in the READY state, waiting for the
--		    -- next character to arrive on the receiver.
--                    if (data_available = '0' and data_available_bt = '0' ) then
--                        reset_read <= '0';
--                        reset_read_bt <= '0';
--                        SEND_STATE <= READY;
--                    end if;
--            end case;
--	end if;
--    end process;
    
end architecture;
