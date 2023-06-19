
# Clock signal
set_property PACKAGE_PIN W5 [get_ports clock]							
	set_property IOSTANDARD LVCMOS33 [get_ports clock]
	create_clock -add -name sys_clk_pin -period 10.00 -waveform {0 5} [get_ports clock]
	
#sw15
set_property PACKAGE_PIN R2 [get_ports RST]					
        set_property IOSTANDARD LVCMOS33 [get_ports RST]	

#Sch name = JB1
set_property PACKAGE_PIN A14 [get_ports {sutun_en[0]}]					
	set_property IOSTANDARD LVCMOS33 [get_ports {sutun_en[0]}]
#Sch name = JB2
set_property PACKAGE_PIN A16 [get_ports {sutun_en[1]}]					
	set_property IOSTANDARD LVCMOS33 [get_ports {sutun_en[1]}]
#Sch name = JB3
set_property PACKAGE_PIN B15 [get_ports {sutun_en[2]}]					
	set_property IOSTANDARD LVCMOS33 [get_ports {sutun_en[2]}]
#Sch name = JB4
set_property PACKAGE_PIN B16 [get_ports {sutun_en[3]}]					
	set_property IOSTANDARD LVCMOS33 [get_ports {sutun_en[3]}]


#Sch name = JB7
set_property PACKAGE_PIN A15 [get_ports {satir_data[0]}]					
	set_property IOSTANDARD LVCMOS33 [get_ports {satir_data[0]}]
	set_property PULLDOWN true [get_ports {satir_data[0]}]
#Sch name = JB8
set_property PACKAGE_PIN A17 [get_ports {satir_data[1]}]					
	set_property IOSTANDARD LVCMOS33 [get_ports {satir_data[1]}]
	set_property PULLDOWN true [get_ports {satir_data[1]}]
#Sch name = JB9
set_property PACKAGE_PIN C15 [get_ports {satir_data[2]}]					
	set_property IOSTANDARD LVCMOS33 [get_ports {satir_data[2]}]
	set_property PULLDOWN true [get_ports {satir_data[2]}]
#Sch name = JB10 
set_property PACKAGE_PIN C16 [get_ports {satir_data[3]}]					
	set_property IOSTANDARD LVCMOS33 [get_ports {satir_data[3]}]
	set_property PULLDOWN true [get_ports {satir_data[3]}]


	
#7 segment display
set_property PACKAGE_PIN W7 [get_ports {led[0]}]					
	set_property IOSTANDARD LVCMOS33 [get_ports {led[0]}]
set_property PACKAGE_PIN W6 [get_ports {led[1]}]					
	set_property IOSTANDARD LVCMOS33 [get_ports {led[1]}]
set_property PACKAGE_PIN U8 [get_ports {led[2]}]					
	set_property IOSTANDARD LVCMOS33 [get_ports {led[2]}]
set_property PACKAGE_PIN V8 [get_ports {led[3]}]					
	set_property IOSTANDARD LVCMOS33 [get_ports {led[3]}]
set_property PACKAGE_PIN U5 [get_ports {led[4]}]					
	set_property IOSTANDARD LVCMOS33 [get_ports {led[4]}]
set_property PACKAGE_PIN V5 [get_ports {led[5]}]					
	set_property IOSTANDARD LVCMOS33 [get_ports {led[5]}]
set_property PACKAGE_PIN U7 [get_ports {led[6]}]					
	set_property IOSTANDARD LVCMOS33 [get_ports {led[6]}]

#set_property PACKAGE_PIN V7 [get_ports dp]							
#	set_property IOSTANDARD LVCMOS33 [get_ports dp]

set_property PACKAGE_PIN U2 [get_ports {anot[0]}]					
	set_property IOSTANDARD LVCMOS33 [get_ports {anot[0]}]
set_property PACKAGE_PIN U4 [get_ports {anot[1]}]					
	set_property IOSTANDARD LVCMOS33 [get_ports {anot[1]}]
set_property PACKAGE_PIN V4 [get_ports {anot[2]}]					
	set_property IOSTANDARD LVCMOS33 [get_ports {anot[2]}]
set_property PACKAGE_PIN W4 [get_ports {anot[3]}]					
	set_property IOSTANDARD LVCMOS33 [get_ports {anot[3]}]



