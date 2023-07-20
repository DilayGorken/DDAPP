
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.all;


entity rgb is
port(
			  CLOCK : in  STD_LOGIC;--50 MHz 
         
			  OE:inout std_logic;--output enable
			  
			  SH_CP:OUT STD_LOGIC;--shift register clock pulse
			  ST_CP:OUT STD_LOGIC;--store register clock pulse
			  
			  reset:OUT STD_LOGIC;--shift register iï¿½in reset

			  
				DS : out  std_logic;--digital signal
			  
           KATOT : inout  STD_LOGIC_VECTOR (7 downto 0));
end rgb;

architecture Behavioral of rgb is


signal mesaj:std_logic_vector(24 downto 1);  --burada alias kullanýmýnýn ilk örneðini görüyoruz 
										     --alias kullanýmý burada bize mesaj içine yerleþtireceðimiz
											 -- renk kodlarýný bölerek ve yerleþtirme adreslerini seçerek
											 --yerleþtirmemize olanak saðlar.
alias kirmizi : Std_Logic_Vector(7 downto 0) is mesaj(24 downto 17) ;
alias yesil : Std_Logic_Vector(7 downto 0) is mesaj(16 downto 9) ;
alias mavi : Std_Logic_Vector(7 downto 0) is mesaj(8 downto 1) ;

signal f:std_logic;
signal e:std_logic;



begin

process(clock)

variable counter: unsigned(7 downto 0);
variable i:integer range 410 downto 1:=1;--data signalin seri olarak iletilmesini kontrol eder.
variable a:integer range 7 downto 0:=0; ---sütun sayýcýsý/tutucusu
variable d:integer range 400 downto 0:=0;


begin


if rising_edge(clock) then--registerlar için clock sinyali clock'u olarak kullanýlýyor.
counter:=counter+1;
end if;


f<=counter(7);
e<=not f;				
if rising_edge(e) then--seri olarak datayý almak için her clock pulse tan sonra i bir arttýrýlýyor.  
					  --i e için clock counter gibi kullanýlýyor (decimal)
i:=i+1;
end if;


if i<4 then----baþlangýçtan 4'e gelene kadar sisteme reset atýlýyor. Bu bir gecikme saðlayýcýsý
reset<='0';
else
reset<='1'; 
end if;


if i>3 and i<28 then--4'le 27 arasýnda data akýþý seri olacak.
DS<=mesaj(i-3);  --ds:digital signal . i integer range 410
else 
DS<='0';
end if;


if i<28 then--i 28'e geldiðinde data akýþý da tamamlanýyor.24 bit data alýnmýþ oluyor. sonrasýnda  yeni data akýþýna kadar clock durduruluyor
SH_CP<=f;        --shift register <= f     e ve f birbirinin tersi!
ST_CP<=e;        --store register <= e
else
SH_CP<='0';
ST_CP<='1';
end if;

if rising_edge(f) then--bir satýr tamamlandýðýnda a bir arttýrýlýyor 2. satýra geçmek için
if (i>28 and i<409) then
oe<='0';
else
oe<='1';
end if;
end if;


if rising_edge(f) then--bir satýr tamamlandýðýnda a bir arttýrýlýyor 2. satýra geçmek için
if i=410 then
a:=a+1;
end if;
end if;

if rising_edge(f) then--satrlar ve sutunlar tamamlandýðýnda yeni giriþ için(ful ekran) d bir arttýrýlýyor
if i=410 then
if a=7 then
d:=d+1;
end if;
end if;
end if;

		
if a=0 then
katot<="10000000";
elsif a=1 then
katot<="01000000";
elsif a=2 then
katot<="00100000";
elsif a=3 then
katot<="00010000";
elsif a=4 then
katot<="00001000";
elsif a=5 then
katot<="00000100";
elsif a=6 then
katot<="00000010";
else
katot<="00000001";
end if;


		if d<100 then

if a = 0 then 
kirmizi<="00000000";
mavi<="00000000";
yesil<="00000000";

elsif a=1 then

kirmizi<="00000000";
mavi<="11100111";
yesil<="11100111";

	

elsif a=2 then
kirmizi<="00000000";
	mavi<="11111111";
	yesil<="11111111";

	

elsif a=3 then

	kirmizi<="00000000";
mavi<="11011011";
yesil<="11011011";

elsif a=4 then

kirmizi<="00000000";
mavi<="11011011";
yesil<="11011011";

elsif a=5 then

    kirmizi<="00000000";
	mavi<="11111111";
	yesil<="11111111";

	
elsif a=6 then

    kirmizi<="00000000";
	mavi<="11111111";
	yesil<="11111111";
	

else

kirmizi<="00000000";
mavi<="00000000";
yesil<="00000000";

end if;

 
		elsif d<200 then

if a=0 then

	kirmizi<="00000000";
mavi<="00000000";
yesil<="00000000";

elsif a=1 then
kirmizi<="11000011";
mavi<="11000011";
yesil<="00000000";
	

elsif a=2 then
kirmizi<="11011011";
mavi<="11011011";
yesil<="00000000";
	

elsif a=3 then
kirmizi<="11011011";
mavi<="11011011";
yesil<="00000000";

	

elsif a=4 then
kirmizi<="11011011";
mavi<="11011011";
yesil<="00000000";
	
elsif a=5 then

kirmizi<="11111111";
mavi<="11111111";
yesil<="00000000";
	

elsif a=6 then
kirmizi<="11111111";
mavi<="11111111";
yesil<="00000000";
	

else

kirmizi<="00000000";
mavi<="00000000";
yesil<="00000000";

end if;

	
		
		elsif d<300 then
		
if a=0 then

	kirmizi<="11000000";
mavi<="00000000";
yesil<="00000000";

elsif a=1 then

		kirmizi<="11000000";
mavi<="00000000";
yesil<="00000000";

elsif a=2 then

		kirmizi<="11000000";
mavi<="00000000";
yesil<="00000000";

elsif a=3 then

	kirmizi<="11111111";
mavi<="00000000";
yesil<="00000000";


elsif a=4 then

	kirmizi<="11111111";
mavi<="00000000";
yesil<="00000000";
elsif a=5 then

		kirmizi<="11000000";
mavi<="00000000";
yesil<="00000000";

elsif a=6 then

		kirmizi<="11000000";
mavi<="00000000";
yesil<="00000000";

else

	kirmizi<="11000000";
mavi<="00000000";
yesil<="00000000";
end if;

		
		
		elsif d<400 then
		
if a=0 then

	kirmizi<="00000000";
mavi<="00000000";
yesil<="00000000";

elsif a=1 then

	kirmizi<="00000000";
mavi<="00000000";
yesil<="00000000";

elsif a=2 then

	kirmizi<="00000000";
mavi<="00000000";
yesil<="00000000";

elsif a=3 then

	kirmizi<="00000000";
mavi<="00000000";
yesil<="11011111";

elsif a=4 then

	kirmizi<="00000000";
mavi<="00000000";
yesil<="11011111";

elsif a=5 then

	kirmizi<="00000000";
mavi<="00000000";
yesil<="00000000";---!

elsif a=6 then

	kirmizi<="00000000";
mavi<="00000000";
yesil<="00000000";---!
else

kirmizi<="00000000";
mavi<="00000000";
yesil<="00000000";

end if;

		
end if;

end process;
end Behavioral;
