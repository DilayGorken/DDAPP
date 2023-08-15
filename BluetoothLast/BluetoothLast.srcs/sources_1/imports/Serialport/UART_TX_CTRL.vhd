----------------------------------------------------------------------------
--	UART_TX_CTRL.vhd -- UART Data Transfer Component
----------------------------------------------------------------------------
-- Author:  Sam Bobrowicz
--          Copyright 2011 Digilent, Inc.
----------------------------------------------------------------------------
--
----------------------------------------------------------------------------
--	Bu bile�en, bir UART cihaz� �zerinden veri aktarmak i�in kullan�labilir.
-- Bir veri byte'�n� seri hale getirir ve bir TXD hatt� �zerinden iletecektir.
-- Serile�tirilmi� verinin a�a��daki �zelliklere sahip olmas� gerekir:
--         *9600 Baud H�z�
--         *8 veri biti, en d���k bit �nce
--         *1 stop bit
--         *parity yok
--         				
-- Port A��klamalar�:
--
--           SEND - Bir g�nderim i�lemi tetiklemek i�in kullan�l�r. �st katman mant���
--           bu sinyali y�ksek bir saat d�ng�s� boyunca ayarlayarak g�nderimi tetiklemelidir.
--           Bu sinyal y�ksek ayarlanmamal�d�r, e�er READY y�ksek de�ilse.

--           DATA - G�nderilecek paralel veri. SEND y�ksek ayarland���nda saat d�ng�s�nde
--           DATA ge�erli olmal�d�r.

--           CLK  - 100 MHz saat beklenir.

--           READY - Bu sinyal, bir g�nderim i�lemi ba�lad���nda d��er ve
--           i�lem tamamland���nda y�kselir ve bile�en ba�ka bir byte g�ndermeye haz�r hale gelir.

--           UART_TX - Bu sinyal, harici UART cihaz�n�n uygun TX pimine y�nlendirilmelidir.
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

--Mevcut bitin UART TX hatt� �zerinde ne kadar saat d�ng�s� boyunca sabit tutuldu�unun sayac�.
--9600 baud h�z�n� sa�lamak i�in hangi de�ere kadar say�ld��� bu sinyalle belirtilir
signal bitTmr : std_logic_vector(13 downto 0) := (others => '0');

--9600 baud h�z�n� sa�lamak i�in bitTmr'�n do�ru de�ere kadar say�ld���nda y�kselecek mant�ksal sinyal

signal bitDone : std_logic;

--G�nderilecek sonraki bitin txData i�indeki indeksini i�eren sinyal
signal bitIndex : natural;

--UART TX hatt� �zerinde g�nderilen mevcut veriyi i�eren bir kay�t
signal txBit : std_logic := '1';

--Ba�lang�� ve stop bitleri dahil g�nderilecek t�m veri paketini i�eren bir kay�t
signal txData : std_logic_vector(9 downto 0);

signal txState : TX_STATE_TYPE := RDY;

begin

-- durum makinesi (state machine)
next_txState_process : process (CLK)
begin
	if (rising_edge(CLK)) then
		case txState is 
		when RDY =>                                   -- RDY oldu�unda:
			if (SEND = '1') then                      -- Ayn� zamanda SEND 1 ise; 
				txState <= LOAD_BIT;                  -- bitler y�klenmeye ba�lan�r.
			end if;
		when LOAD_BIT =>                              -- LOAD_BIT oldu�unda;
			txState <= SEND_BIT;                      -- Bit g�nderime haz�rlan�l�r

		when SEND_BIT =>                              --SEND_BIT oldu�unda;
			if (bitDone = '1') then                   -- bitDone =1 ise ( 1 bit g�nderimi tamamlanm�� ise)
				if (bitIndex = BIT_INDEX_MAX) then    -- max bit mi g�nderilmi� if blo�u olu�turulur.
				                                      -- B�ylece son iletilen 1 bitin sonuncu olup olmad���n� ��z�mleriz.
					txState <= RDY;                   -- e�er son bit ise durum RDY e ge�er
				else
					txState <= LOAD_BIT;              -- e�er de�il ise; y�kleme devam eder.
				end if;
			end if;
		when others=>                                 --asla ula��lmamas� gerekir (hata durumu olarak da nitelendirilebilir.)
			txState <= RDY;
		end case;
	end if;
end process;
--

bit_timing_process : process (CLK)
begin
	if (rising_edge(CLK)) then
		if (txState = RDY) then                   -- txState= RDY ise;
			bitTmr <= (others => '0');            -- bitTmr adl� saya�, t�m bit g�nderme s�recinin ba��nda s�f�rlan�r.
			                                      -- Bu, yeni bir veri g�nderimi ba�lad���nda s�renin s�f�rlanmas�n� sa�lar.
		
		else                                      -- else durumu: veri g�nderimi deavm ediyor
			if (bitDone = '1') then               
				bitTmr <= (others => '0');        
			else
				bitTmr <= bitTmr + 1;
			end if;
		end if;
	end if;
end process;
---------------------------------------------------------------------------------------------------------------

-- Bu ifade, her bitin g�nderilme s�resini izlemek ve bit tamamland���nda bitDone sinyalini y�ksek yapmak i�in kullan�l�r.
-- bitDone sinyali, her bit g�nderimi tamamland���nda belirli bir s�re boyunca y�ksek sinyal �retir ve bu, bit g�nderiminin do�ru bir �ekilde yap�ld���n� g�sterir.

bitDone <= '1' when (bitTmr = BIT_TMR_MAX) else   -- BIT_TMR_MAX: Bu, bir bitin tam olarak g�nderilmesi i�in ge�mesi 
				'0';                              -- gereken saat d�ng�s� say�s�n� temsil eder. 9600 baud h�z�nda
				                                  -- her bir bit i�in ge�mesi gereken saat d�ng�s� say�s� belirlenir.


---------------------------------------------------------------------------------------------------------------

--Bu i�lem blo�u, hangi bitin g�nderilmekte oldu�unu ve hangi bitin s�radaki oldu�unu izlemekten sorumludur.

bit_counting_process : process (CLK)
begin

	if (rising_edge(CLK)) then
		if (txState = RDY) then
			bitIndex <= 0;
		elsif (txState = LOAD_BIT) then
			bitIndex <= bitIndex + 1;        --bit index'i artt�rarak i�lem s�ras�n�n takibi sa�lanmaktad�r.
		end if;
	end if;
end process;
--------------------------------------------------------------------------------------------------------------

--Bu i�lem blo�u, g�nderilecek verinin d�zenini olu�turur ve txData adl� sinyale y�kler. 

tx_data_latch_process : process (CLK)
begin
	if (rising_edge(CLK)) then
		if (SEND = '1') then
			txData <= '1' & DATA & '0';      -- txData ba�lang�� ve biti� bitleriyle beraber DATA'y� tutar
		end if;
	end if;
end process;


--------------------------------------------------------------------------------------------------------------

--Bu i�lem blo�u, seri veriyi fiziksel olarak g�ndermeye y�nelik mant��� uygular.

tx_bit_process : process (CLK)
begin
	if (rising_edge(CLK)) then
		if (txState = RDY) then
			txBit <= '1';                    -- herhangi bir g�nderim olmad���nda iletim hatt�n� y�ksek seviyeye ��kar�r.
		elsif (txState = LOAD_BIT) then
			txBit <= txData(bitIndex);       --LOAD_BIT geldi�inde txBit'e bitIndex indexini tutarak txData y�klenir.
			--
		end if;
	end if;
end process;

UART_TX <= txBit;                           -- son olarak signal'ler ile yapt���m�z i�lemleri ��k��a at�yoruz.
READY <= '1' when (txState = RDY) else
			'0';

end Behavioral;

