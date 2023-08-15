----------------------------------------------------------------------------
--	UART_TX_CTRL.vhd -- UART Data Transfer Component
----------------------------------------------------------------------------
-- Author:  Sam Bobrowicz
--          Copyright 2011 Digilent, Inc.
----------------------------------------------------------------------------
--
----------------------------------------------------------------------------
--	Bu bileþen, bir UART cihazý üzerinden veri aktarmak için kullanýlabilir.
-- Bir veri byte'ýný seri hale getirir ve bir TXD hattý üzerinden iletecektir.
-- Serileþtirilmiþ verinin aþaðýdaki özelliklere sahip olmasý gerekir:
--         *9600 Baud Hýzý
--         *8 veri biti, en düþük bit önce
--         *1 stop bit
--         *parity yok
--         				
-- Port Açýklamalarý:
--
--           SEND - Bir gönderim iþlemi tetiklemek için kullanýlýr. Üst katman mantýðý
--           bu sinyali yüksek bir saat döngüsü boyunca ayarlayarak gönderimi tetiklemelidir.
--           Bu sinyal yüksek ayarlanmamalýdýr, eðer READY yüksek deðilse.

--           DATA - Gönderilecek paralel veri. SEND yüksek ayarlandýðýnda saat döngüsünde
--           DATA geçerli olmalýdýr.

--           CLK  - 100 MHz saat beklenir.

--           READY - Bu sinyal, bir gönderim iþlemi baþladýðýnda düþer ve
--           iþlem tamamlandýðýnda yükselir ve bileþen baþka bir byte göndermeye hazýr hale gelir.

--           UART_TX - Bu sinyal, harici UART cihazýnýn uygun TX pimine yönlendirilmelidir.
----------------------------------------------------------------------------
--
----------------------------------------------------------------------------
-- Revision History:
--  08/08/2011(SamB): Created using Xilinx Tools 13.2
----------------------------------------------------------------------------
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.std_logic_unsigned.all;

entity UART_TX_CTRL is
    Port ( SEND : in  STD_LOGIC;
           DATA : in  STD_LOGIC_VECTOR (7 downto 0);
           CLK : in  STD_LOGIC;
           READY : out  STD_LOGIC;
           UART_TX : out  STD_LOGIC);
end UART_TX_CTRL;

architecture Behavioral of UART_TX_CTRL is

type TX_STATE_TYPE is (RDY, LOAD_BIT, SEND_BIT);

constant BIT_TMR_MAX : std_logic_vector(13 downto 0) := "10100010110000"; --10416 = (round(100MHz / 9600)) - 1
constant BIT_INDEX_MAX : natural := 10;

--Mevcut bitin UART TX hattý üzerinde ne kadar saat döngüsü boyunca sabit tutulduðunun sayacý.
--9600 baud hýzýný saðlamak için hangi deðere kadar sayýldýðý bu sinyalle belirtilir
signal bitTmr : std_logic_vector(13 downto 0) := (others => '0');

--9600 baud hýzýný saðlamak için bitTmr'ýn doðru deðere kadar sayýldýðýnda yükselecek mantýksal sinyal

signal bitDone : std_logic;

--Gönderilecek sonraki bitin txData içindeki indeksini içeren sinyal
signal bitIndex : natural;

--UART TX hattý üzerinde gönderilen mevcut veriyi içeren bir kayýt
signal txBit : std_logic := '1';

--Baþlangýç ve stop bitleri dahil gönderilecek tüm veri paketini içeren bir kayýt
signal txData : std_logic_vector(9 downto 0);

signal txState : TX_STATE_TYPE := RDY;

begin

-- durum makinesi (state machine)
next_txState_process : process (CLK)
begin
	if (rising_edge(CLK)) then
		case txState is 
		when RDY =>                                   -- RDY olduðunda:
			if (SEND = '1') then                      -- Ayný zamanda SEND 1 ise; 
				txState <= LOAD_BIT;                  -- bitler yüklenmeye baþlanýr.
			end if;
		when LOAD_BIT =>                              -- LOAD_BIT olduðunda;
			txState <= SEND_BIT;                      -- Bit gönderime hazýrlanýlýr

		when SEND_BIT =>                              --SEND_BIT olduðunda;
			if (bitDone = '1') then                   -- bitDone =1 ise ( 1 bit gönderimi tamamlanmýþ ise)
				if (bitIndex = BIT_INDEX_MAX) then    -- max bit mi gönderilmiþ if bloðu oluþturulur.
				                                      -- Böylece son iletilen 1 bitin sonuncu olup olmadýðýný çözümleriz.
					txState <= RDY;                   -- eðer son bit ise durum RDY e geçer
				else
					txState <= LOAD_BIT;              -- eðer deðil ise; yükleme devam eder.
				end if;
			end if;
		when others=>                                 --asla ulaþýlmamasý gerekir (hata durumu olarak da nitelendirilebilir.)
			txState <= RDY;
		end case;
	end if;
end process;
--

bit_timing_process : process (CLK)
begin
	if (rising_edge(CLK)) then
		if (txState = RDY) then                   -- txState= RDY ise;
			bitTmr <= (others => '0');            -- bitTmr adlý sayaç, tüm bit gönderme sürecinin baþýnda sýfýrlanýr.
			                                      -- Bu, yeni bir veri gönderimi baþladýðýnda sürenin sýfýrlanmasýný saðlar.
		
		else                                      -- else durumu: veri gönderimi deavm ediyor
			if (bitDone = '1') then               
				bitTmr <= (others => '0');        
			else
				bitTmr <= bitTmr + 1;
			end if;
		end if;
	end if;
end process;
---------------------------------------------------------------------------------------------------------------

-- Bu ifade, her bitin gönderilme süresini izlemek ve bit tamamlandýðýnda bitDone sinyalini yüksek yapmak için kullanýlýr.
-- bitDone sinyali, her bit gönderimi tamamlandýðýnda belirli bir süre boyunca yüksek sinyal üretir ve bu, bit gönderiminin doðru bir þekilde yapýldýðýný gösterir.

bitDone <= '1' when (bitTmr = BIT_TMR_MAX) else   -- BIT_TMR_MAX: Bu, bir bitin tam olarak gönderilmesi için geçmesi 
				'0';                              -- gereken saat döngüsü sayýsýný temsil eder. 9600 baud hýzýnda
				                                  -- her bir bit için geçmesi gereken saat döngüsü sayýsý belirlenir.


---------------------------------------------------------------------------------------------------------------

--Bu iþlem bloðu, hangi bitin gönderilmekte olduðunu ve hangi bitin sýradaki olduðunu izlemekten sorumludur.

bit_counting_process : process (CLK)
begin

	if (rising_edge(CLK)) then
		if (txState = RDY) then
			bitIndex <= 0;
		elsif (txState = LOAD_BIT) then
			bitIndex <= bitIndex + 1;        --bit index'i arttýrarak iþlem sýrasýnýn takibi saðlanmaktadýr.
		end if;
	end if;
end process;
--------------------------------------------------------------------------------------------------------------

--Bu iþlem bloðu, gönderilecek verinin düzenini oluþturur ve txData adlý sinyale yükler. 

tx_data_latch_process : process (CLK)
begin
	if (rising_edge(CLK)) then
		if (SEND = '1') then
			txData <= '1' & DATA & '0';      -- txData baþlangýç ve bitiþ bitleriyle beraber DATA'yý tutar
		end if;
	end if;
end process;


--------------------------------------------------------------------------------------------------------------

--Bu iþlem bloðu, seri veriyi fiziksel olarak göndermeye yönelik mantýðý uygular.

tx_bit_process : process (CLK)
begin
	if (rising_edge(CLK)) then
		if (txState = RDY) then
			txBit <= '1';                    -- herhangi bir gönderim olmadýðýnda iletim hattýný yüksek seviyeye çýkarýr.
		elsif (txState = LOAD_BIT) then
			txBit <= txData(bitIndex);       --LOAD_BIT geldiðinde txBit'e bitIndex indexini tutarak txData yüklenir.
			--
		end if;
	end if;
end process;

UART_TX <= txBit;                           -- son olarak signal'ler ile yaptýðýmýz iþlemleri çýkýþa atýyoruz.
READY <= '1' when (txState = RDY) else
			'0';

end Behavioral;

