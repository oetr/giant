# !!! Constraint files are application specific !!!
# !!!          This is a template only          !!!

# on-board signals

# CLK 
create_clock -name clk_in -period 38.462 [get_ports clk_in]
set_property PACKAGE_PIN V13 [get_ports clk_in]
set_property IOSTANDARD LVCMOS33 [get_ports clk_in]

# IFCLK 
create_clock -name ifclk_in -period 10 [get_ports ifclk_in]
set_property PACKAGE_PIN W11 [get_ports ifclk_in]
set_property IOSTANDARD LVCMOS33 [get_ports ifclk_in]


set_property PACKAGE_PIN P22 [get_ports {DQ[0]}]  		;# DQ0
set_property IOSTANDARD LVCMOS33 [get_ports {DQ[0]}]

set_property PACKAGE_PIN R22 [get_ports {DQ[1]}]  		;# DQ1
set_property IOSTANDARD LVCMOS33 [get_ports {DQ[1]}]

set_property PACKAGE_PIN P21 [get_ports {DQ[2]}]  		;# DQ2
set_property IOSTANDARD LVCMOS33 [get_ports {DQ[2]}]

set_property PACKAGE_PIN R21 [get_ports {DQ[3]}]  		;# DQ3
set_property IOSTANDARD LVCMOS33 [get_ports {DQ[3]}]

set_property PACKAGE_PIN T21 [get_ports {DQ[4]}]  		;# DQ4
set_property IOSTANDARD LVCMOS33 [get_ports {DQ[4]}]

set_property PACKAGE_PIN U21 [get_ports {DQ[5]}]  		;# DQ5
set_property IOSTANDARD LVCMOS33 [get_ports {DQ[5]}]

set_property PACKAGE_PIN P19 [get_ports {DQ[6]}]  		;# DQ6
set_property IOSTANDARD LVCMOS33 [get_ports {DQ[6]}]

set_property PACKAGE_PIN R19 [get_ports {DQ[7]}]  		;# DQ7
set_property IOSTANDARD LVCMOS33 [get_ports {DQ[7]}]

set_property PACKAGE_PIN T20 [get_ports {DQ[8]}]  		;# DQ8
set_property IOSTANDARD LVCMOS33 [get_ports {DQ[8]}]

set_property PACKAGE_PIN W21 [get_ports {DQ[9]}]  		;# DQ9
set_property IOSTANDARD LVCMOS33 [get_ports {DQ[9]}]

set_property PACKAGE_PIN W22 [get_ports {DQ[10]}]  		;# DQ10
set_property IOSTANDARD LVCMOS33 [get_ports {DQ[10]}]

set_property PACKAGE_PIN AA20 [get_ports {DQ[11]}]  		;# DQ11
set_property IOSTANDARD LVCMOS33 [get_ports {DQ[11]}]

set_property PACKAGE_PIN AA21 [get_ports {DQ[12]}]  		;# DQ12
set_property IOSTANDARD LVCMOS33 [get_ports {DQ[12]}]

set_property PACKAGE_PIN Y22 [get_ports {DQ[13]}]  		;# DQ13
set_property IOSTANDARD LVCMOS33 [get_ports {DQ[13]}]

set_property PACKAGE_PIN AB21 [get_ports {DQ[14]}]  		;# DQ14
set_property IOSTANDARD LVCMOS33 [get_ports {DQ[14]}]

set_property PACKAGE_PIN AB22 [get_ports {DQ[15]}]  		;# DQ15
set_property IOSTANDARD LVCMOS33 [get_ports {DQ[15]}]


set_property PACKAGE_PIN AA19 [get_ports {GPIO38}]  		;# GPIO38/RDWR_B
set_property IOSTANDARD LVCMOS33 [get_ports {GPIO38}]

set_property PACKAGE_PIN V17 [get_ports {GPIO39}]  		;# GPIO39/CSI_B
set_property IOSTANDARD LVCMOS33 [get_ports {GPIO39}]


set_property PACKAGE_PIN AB20 [get_ports {GPIO46}]  		;# GPIO46/UART_RTS
set_property IOSTANDARD LVCMOS33 [get_ports {GPIO46}]

set_property PACKAGE_PIN AB18 [get_ports {GPIO47}]  		;# GPIO47/UART_CTS
set_property IOSTANDARD LVCMOS33 [get_ports {GPIO47}]

set_property PACKAGE_PIN AB17 [get_ports {GPIO48}]  		;# GPIO48/UART_TX
set_property IOSTANDARD LVCMOS33 [get_ports {GPIO48}]

set_property PACKAGE_PIN AA18 [get_ports {GPIO49}]  		;# GPIO49/UART_RX
set_property IOSTANDARD LVCMOS33 [get_ports {GPIO49}]


set_property PACKAGE_PIN W10 [get_ports {CTL0}]  		;# CTL0/SLCS#/GPIO17
set_property IOSTANDARD LVCMOS33 [get_ports {CTL0}]

set_property PACKAGE_PIN Y12 [get_ports {CTL1}]  		;# CTL1/SLWR#/GPIO18
set_property IOSTANDARD LVCMOS33 [get_ports {CTL1}]

set_property PACKAGE_PIN AA13 [get_ports {CTL2}]  		;# CTL2/SLOE#/GPIO19
set_property IOSTANDARD LVCMOS33 [get_ports {CTL2}]

set_property PACKAGE_PIN AB12 [get_ports {CTL3}]  		;# CTL3/SLRD#/GPIO20
set_property IOSTANDARD LVCMOS33 [get_ports {CTL3}]

set_property PACKAGE_PIN AB11 [get_ports {CTL4}]  		;# CTL4/FLAGA/GPIO21
set_property IOSTANDARD LVCMOS33 [get_ports {CTL4}]

set_property PACKAGE_PIN AB13 [get_ports {CTL5}]  		;# CTL5/FLAGB/GPIO22
set_property IOSTANDARD LVCMOS33 [get_ports {CTL5}]

set_property PACKAGE_PIN AA14 [get_ports {CTL6}]  		;# CTL6/GPIO23
set_property IOSTANDARD LVCMOS33 [get_ports {CTL6}]

set_property PACKAGE_PIN AA10 [get_ports {CTL7}]  		;# CTL7/PKTEND#/GPIO24
set_property IOSTANDARD LVCMOS33 [get_ports {CTL7}]

set_property PACKAGE_PIN AB16 [get_ports {CTL8}]  		;# CTL8/GPIO25
set_property IOSTANDARD LVCMOS33 [get_ports {CTL8}]

set_property PACKAGE_PIN AB15 [get_ports {CTL9}]  		;# CTL9/GPIO26
set_property IOSTANDARD LVCMOS33 [get_ports {CTL9}]

set_property PACKAGE_PIN AA16 [get_ports {CTL11}]  		;# CTL11/A1/GPIO28
set_property IOSTANDARD LVCMOS33 [get_ports {CTL11}]

set_property PACKAGE_PIN AA15 [get_ports {CTL12}]  		;# CTL12/A0/GPIO29
set_property IOSTANDARD LVCMOS33 [get_ports {CTL12}]

set_property PACKAGE_PIN AA11 [get_ports {CTL15}]  		;# INT#/CTL15
set_property IOSTANDARD LVCMOS33 [get_ports {CTL15}]


set_property PACKAGE_PIN AB10 [get_ports {SCL}]  		;# SCL
set_property IOSTANDARD LVCMOS33 [get_ports {SCL}]

set_property PACKAGE_PIN AA9 [get_ports {SDA}]  		;# SDA
set_property IOSTANDARD LVCMOS33 [get_ports {SDA}]


set_property PACKAGE_PIN Y17 [get_ports {SPI_CLK}]  		;# FPGA_CLK
set_property IOSTANDARD LVCMOS33 [get_ports {SPI_CLK}]

set_property PACKAGE_PIN Y16 [get_ports {SPI_CS_N}]  		;# FPGA_CS#
set_property IOSTANDARD LVCMOS33 [get_ports {SPI_CS_N}]

set_property PACKAGE_PIN Y14 [get_ports {SPI_MISO}]  		;# FPGA_MISO
set_property IOSTANDARD LVCMOS33 [get_ports {SPI_MISO}]

set_property PACKAGE_PIN W15 [get_ports {SPI_MOSI}]  		;# FPGA_MOSI
set_property IOSTANDARD LVCMOS33 [get_ports {SPI_MOSI}]


set_property PACKAGE_PIN V10 [get_ports {LED1_red}]  		;# LED1:red
set_property IOSTANDARD LVCMOS33 [get_ports {LED1_red}]


# external I/O

set_property PACKAGE_PIN M17 [get_ports {IO_A[0]}]		;# A3 / M17~IO_25_15
set_property IOSTANDARD LVCMOS33 [get_ports {IO_A[0]}]

set_property PACKAGE_PIN N18 [get_ports {IO_A[1]}]		;# A4 / N18~IO_L17P_T2_A26_15
set_property IOSTANDARD LVCMOS33 [get_ports {IO_A[1]}]

set_property PACKAGE_PIN N19 [get_ports {IO_A[2]}]		;# A5 / N19~IO_L17N_T2_A25_15
set_property IOSTANDARD LVCMOS33 [get_ports {IO_A[2]}]

set_property PACKAGE_PIN N22 [get_ports {IO_A[3]}]		;# A6 / N22~IO_L15P_T2_DQS_15
set_property IOSTANDARD LVCMOS33 [get_ports {IO_A[3]}]

set_property PACKAGE_PIN M22 [get_ports {IO_A[4]}]		;# A7 / M22~IO_L15N_T2_DQS_ADV_B_15
set_property IOSTANDARD LVCMOS33 [get_ports {IO_A[4]}]

set_property PACKAGE_PIN L14 [get_ports {IO_A[5]}]		;# A8 / L14~IO_L22P_T3_A17_15
set_property IOSTANDARD LVCMOS33 [get_ports {IO_A[5]}]

set_property PACKAGE_PIN L15 [get_ports {IO_A[6]}]		;# A9 / L15~IO_L22N_T3_A16_15
set_property IOSTANDARD LVCMOS33 [get_ports {IO_A[6]}]

set_property PACKAGE_PIN M18 [get_ports {IO_A[7]}]		;# A10 / M18~IO_L16P_T2_A28_15
set_property IOSTANDARD LVCMOS33 [get_ports {IO_A[7]}]

set_property PACKAGE_PIN L18 [get_ports {IO_A[8]}]		;# A11 / L18~IO_L16N_T2_A27_15
set_property IOSTANDARD LVCMOS33 [get_ports {IO_A[8]}]

set_property PACKAGE_PIN M21 [get_ports {IO_A[9]}]		;# A12 / M21~IO_L10P_T1_AD11P_15
set_property IOSTANDARD LVCMOS33 [get_ports {IO_A[9]}]

set_property PACKAGE_PIN L21 [get_ports {IO_A[10]}]		;# A13 / L21~IO_L10N_T1_AD11N_15
set_property IOSTANDARD LVCMOS33 [get_ports {IO_A[10]}]

set_property PACKAGE_PIN J16 [get_ports {IO_A[11]}]		;# A14 / J16~IO_0_15
set_property IOSTANDARD LVCMOS33 [get_ports {IO_A[11]}]

set_property PACKAGE_PIN J17 [get_ports {IO_A[12]}]		;# A18 / J17~IO_L21N_T3_DQS_A18_15
set_property IOSTANDARD LVCMOS33 [get_ports {IO_A[12]}]

set_property PACKAGE_PIN K19 [get_ports {IO_A[13]}]		;# A19 / K19~IO_L13N_T2_MRCC_15
set_property IOSTANDARD LVCMOS33 [get_ports {IO_A[13]}]

set_property PACKAGE_PIN K22 [get_ports {IO_A[14]}]		;# A20 / K22~IO_L9N_T1_DQS_AD3N_15
set_property IOSTANDARD LVCMOS33 [get_ports {IO_A[14]}]

set_property PACKAGE_PIN H14 [get_ports {IO_A[15]}]		;# A21 / H14~IO_L3N_T0_DQS_AD1N_15
set_property IOSTANDARD LVCMOS33 [get_ports {IO_A[15]}]

set_property PACKAGE_PIN H19 [get_ports {IO_A[16]}]		;# A22 / H19~IO_L12N_T1_MRCC_15
set_property IOSTANDARD LVCMOS33 [get_ports {IO_A[16]}]

set_property PACKAGE_PIN H15 [get_ports {IO_A[17]}]		;# A23 / H15~IO_L5N_T0_AD9N_15
set_property IOSTANDARD LVCMOS33 [get_ports {IO_A[17]}]

set_property PACKAGE_PIN H18 [get_ports {IO_A[18]}]		;# A24 / H18~IO_L6N_T0_VREF_15
set_property IOSTANDARD LVCMOS33 [get_ports {IO_A[18]}]

set_property PACKAGE_PIN J21 [get_ports {IO_A[19]}]		;# A25 / J21~IO_L11N_T1_SRCC_15
set_property IOSTANDARD LVCMOS33 [get_ports {IO_A[19]}]

set_property PACKAGE_PIN H22 [get_ports {IO_A[20]}]		;# A26 / H22~IO_L7N_T1_AD2N_15
set_property IOSTANDARD LVCMOS33 [get_ports {IO_A[20]}]

set_property PACKAGE_PIN G13 [get_ports {IO_A[21]}]		;# A27 / G13~IO_L1N_T0_AD0N_15
set_property IOSTANDARD LVCMOS33 [get_ports {IO_A[21]}]

set_property PACKAGE_PIN G16 [get_ports {IO_A[22]}]		;# A28 / G16~IO_L2N_T0_AD8N_15
set_property IOSTANDARD LVCMOS33 [get_ports {IO_A[22]}]

set_property PACKAGE_PIN G18 [get_ports {IO_A[23]}]		;# A29 / G18~IO_L4N_T0_15
set_property IOSTANDARD LVCMOS33 [get_ports {IO_A[23]}]

set_property PACKAGE_PIN G20 [get_ports {IO_A[24]}]		;# A30 / G20~IO_L8N_T1_AD10N_15
set_property IOSTANDARD LVCMOS33 [get_ports {IO_A[24]}]


set_property PACKAGE_PIN M15 [get_ports {IO_B[0]}]		;# B3 / M15~IO_L24P_T3_RS1_15
set_property IOSTANDARD LVCMOS33 [get_ports {IO_B[0]}]

set_property PACKAGE_PIN M16 [get_ports {IO_B[1]}]		;# B4 / M16~IO_L24N_T3_RS0_15
set_property IOSTANDARD LVCMOS33 [get_ports {IO_B[1]}]

set_property PACKAGE_PIN N20 [get_ports {IO_B[2]}]		;# B5 / N20~IO_L18P_T2_A24_15
set_property IOSTANDARD LVCMOS33 [get_ports {IO_B[2]}]

set_property PACKAGE_PIN M20 [get_ports {IO_B[3]}]		;# B6 / M20~IO_L18N_T2_A23_15
set_property IOSTANDARD LVCMOS33 [get_ports {IO_B[3]}]

set_property PACKAGE_PIN M13 [get_ports {IO_B[4]}]		;# B7 / M13~IO_L20P_T3_A20_15
set_property IOSTANDARD LVCMOS33 [get_ports {IO_B[4]}]

set_property PACKAGE_PIN L13 [get_ports {IO_B[5]}]		;# B8 / L13~IO_L20N_T3_A19_15
set_property IOSTANDARD LVCMOS33 [get_ports {IO_B[5]}]

set_property PACKAGE_PIN L16 [get_ports {IO_B[6]}]		;# B9 / L16~IO_L23P_T3_FOE_B_15
set_property IOSTANDARD LVCMOS33 [get_ports {IO_B[6]}]

set_property PACKAGE_PIN K16 [get_ports {IO_B[7]}]		;# B10 / K16~IO_L23N_T3_FWE_B_15
set_property IOSTANDARD LVCMOS33 [get_ports {IO_B[7]}]

set_property PACKAGE_PIN L19 [get_ports {IO_B[8]}]		;# B11 / L19~IO_L14P_T2_SRCC_15
set_property IOSTANDARD LVCMOS33 [get_ports {IO_B[8]}]

set_property PACKAGE_PIN L20 [get_ports {IO_B[9]}]		;# B12 / L20~IO_L14N_T2_SRCC_15
set_property IOSTANDARD LVCMOS33 [get_ports {IO_B[9]}]

set_property PACKAGE_PIN K13 [get_ports {IO_B[10]}]		;# B13 / K13~IO_L19P_T3_A22_15
set_property IOSTANDARD LVCMOS33 [get_ports {IO_B[10]}]

set_property PACKAGE_PIN K14 [get_ports {IO_B[11]}]		;# B14 / K14~IO_L19N_T3_A21_VREF_15
set_property IOSTANDARD LVCMOS33 [get_ports {IO_B[11]}]

set_property PACKAGE_PIN K17 [get_ports {IO_B[12]}]		;# B18 / K17~IO_L21P_T3_DQS_15
set_property IOSTANDARD LVCMOS33 [get_ports {IO_B[12]}]

set_property PACKAGE_PIN K18 [get_ports {IO_B[13]}]		;# B19 / K18~IO_L13P_T2_MRCC_15
set_property IOSTANDARD LVCMOS33 [get_ports {IO_B[13]}]

set_property PACKAGE_PIN K21 [get_ports {IO_B[14]}]		;# B20 / K21~IO_L9P_T1_DQS_AD3P_15
set_property IOSTANDARD LVCMOS33 [get_ports {IO_B[14]}]

set_property PACKAGE_PIN J14 [get_ports {IO_B[15]}]		;# B21 / J14~IO_L3P_T0_DQS_AD1P_15
set_property IOSTANDARD LVCMOS33 [get_ports {IO_B[15]}]

set_property PACKAGE_PIN J19 [get_ports {IO_B[16]}]		;# B22 / J19~IO_L12P_T1_MRCC_15
set_property IOSTANDARD LVCMOS33 [get_ports {IO_B[16]}]

set_property PACKAGE_PIN J15 [get_ports {IO_B[17]}]		;# B23 / J15~IO_L5P_T0_AD9P_15
set_property IOSTANDARD LVCMOS33 [get_ports {IO_B[17]}]

set_property PACKAGE_PIN H17 [get_ports {IO_B[18]}]		;# B24 / H17~IO_L6P_T0_15
set_property IOSTANDARD LVCMOS33 [get_ports {IO_B[18]}]

set_property PACKAGE_PIN J20 [get_ports {IO_B[19]}]		;# B25 / J20~IO_L11P_T1_SRCC_15
set_property IOSTANDARD LVCMOS33 [get_ports {IO_B[19]}]

set_property PACKAGE_PIN J22 [get_ports {IO_B[20]}]		;# B26 / J22~IO_L7P_T1_AD2P_15
set_property IOSTANDARD LVCMOS33 [get_ports {IO_B[20]}]

set_property PACKAGE_PIN H13 [get_ports {IO_B[21]}]		;# B27 / H13~IO_L1P_T0_AD0P_15
set_property IOSTANDARD LVCMOS33 [get_ports {IO_B[21]}]

set_property PACKAGE_PIN G15 [get_ports {IO_B[22]}]		;# B28 / G15~IO_L2P_T0_AD8P_15
set_property IOSTANDARD LVCMOS33 [get_ports {IO_B[22]}]

set_property PACKAGE_PIN G17 [get_ports {IO_B[23]}]		;# B29 / G17~IO_L4P_T0_15
set_property IOSTANDARD LVCMOS33 [get_ports {IO_B[23]}]

set_property PACKAGE_PIN H20 [get_ports {IO_B[24]}]		;# B30 / H20~IO_L8P_T1_AD10P_15
set_property IOSTANDARD LVCMOS33 [get_ports {IO_B[24]}]


set_property PACKAGE_PIN AB3 [get_ports {IO_C[0]}]		;# C3 / AB3~IO_L8P_T1_34
set_property IOSTANDARD LVCMOS33 [get_ports {IO_C[0]}]

set_property PACKAGE_PIN W7 [get_ports {IO_C[1]}]		;# C4 / W7~IO_L19N_T3_VREF_34
set_property IOSTANDARD LVCMOS33 [get_ports {IO_C[1]}]

set_property PACKAGE_PIN AA3 [get_ports {IO_C[2]}]		;# C5 / AA3~IO_L9N_T1_DQS_34
set_property IOSTANDARD LVCMOS33 [get_ports {IO_C[2]}]

set_property PACKAGE_PIN Y3 [get_ports {IO_C[3]}]		;# C6 / Y3~IO_L9P_T1_DQS_34
set_property IOSTANDARD LVCMOS33 [get_ports {IO_C[3]}]

set_property PACKAGE_PIN Y2 [get_ports {IO_C[4]}]		;# C7 / Y2~IO_L4N_T0_34
set_property IOSTANDARD LVCMOS33 [get_ports {IO_C[4]}]

set_property PACKAGE_PIN W2 [get_ports {IO_C[5]}]		;# C8 / W2~IO_L4P_T0_34
set_property IOSTANDARD LVCMOS33 [get_ports {IO_C[5]}]

set_property PACKAGE_PIN U3 [get_ports {IO_C[6]}]		;# C9 / U3~IO_L6P_T0_34
set_property IOSTANDARD LVCMOS33 [get_ports {IO_C[6]}]

set_property PACKAGE_PIN V3 [get_ports {IO_C[7]}]		;# C10 / V3~IO_L6N_T0_VREF_34
set_property IOSTANDARD LVCMOS33 [get_ports {IO_C[7]}]

set_property PACKAGE_PIN R2 [get_ports {IO_C[8]}]		;# C11 / R2~IO_L3N_T0_DQS_34
set_property IOSTANDARD LVCMOS33 [get_ports {IO_C[8]}]

set_property PACKAGE_PIN R3 [get_ports {IO_C[9]}]		;# C12 / R3~IO_L3P_T0_DQS_34
set_property IOSTANDARD LVCMOS33 [get_ports {IO_C[9]}]

set_property PACKAGE_PIN P2 [get_ports {IO_C[10]}]		;# C13 / P2~IO_L22P_T3_35
set_property IOSTANDARD LVCMOS33 [get_ports {IO_C[10]}]

set_property PACKAGE_PIN N2 [get_ports {IO_C[11]}]		;# C14 / N2~IO_L22N_T3_35
set_property IOSTANDARD LVCMOS33 [get_ports {IO_C[11]}]

set_property PACKAGE_PIN L3 [get_ports {IO_C[12]}]		;# C15 / L3~IO_L14P_T2_SRCC_35
set_property IOSTANDARD LVCMOS33 [get_ports {IO_C[12]}]

set_property PACKAGE_PIN M1 [get_ports {IO_C[13]}]		;# C19 / M1~IO_L15P_T2_DQS_35
set_property IOSTANDARD LVCMOS33 [get_ports {IO_C[13]}]

set_property PACKAGE_PIN L1 [get_ports {IO_C[14]}]		;# C20 / L1~IO_L15N_T2_DQS_35
set_property IOSTANDARD LVCMOS33 [get_ports {IO_C[14]}]

set_property PACKAGE_PIN K2 [get_ports {IO_C[15]}]		;# C21 / K2~IO_L9P_T1_DQS_AD7P_35
set_property IOSTANDARD LVCMOS33 [get_ports {IO_C[15]}]

set_property PACKAGE_PIN J2 [get_ports {IO_C[16]}]		;# C22 / J2~IO_L9N_T1_DQS_AD7N_35
set_property IOSTANDARD LVCMOS33 [get_ports {IO_C[16]}]

set_property PACKAGE_PIN H3 [get_ports {IO_C[17]}]		;# C23 / H3~IO_L11P_T1_SRCC_35
set_property IOSTANDARD LVCMOS33 [get_ports {IO_C[17]}]

set_property PACKAGE_PIN G3 [get_ports {IO_C[18]}]		;# C24 / G3~IO_L11N_T1_SRCC_35
set_property IOSTANDARD LVCMOS33 [get_ports {IO_C[18]}]

set_property PACKAGE_PIN F3 [get_ports {IO_C[19]}]		;# C25 / F3~IO_L6P_T0_35
set_property IOSTANDARD LVCMOS33 [get_ports {IO_C[19]}]

set_property PACKAGE_PIN E3 [get_ports {IO_C[20]}]		;# C26 / E3~IO_L6N_T0_VREF_35
set_property IOSTANDARD LVCMOS33 [get_ports {IO_C[20]}]

set_property PACKAGE_PIN E2 [get_ports {IO_C[21]}]		;# C27 / E2~IO_L4P_T0_35
set_property IOSTANDARD LVCMOS33 [get_ports {IO_C[21]}]

set_property PACKAGE_PIN D2 [get_ports {IO_C[22]}]		;# C28 / D2~IO_L4N_T0_35
set_property IOSTANDARD LVCMOS33 [get_ports {IO_C[22]}]

set_property PACKAGE_PIN C2 [get_ports {IO_C[23]}]		;# C29 / C2~IO_L2P_T0_AD12P_35
set_property IOSTANDARD LVCMOS33 [get_ports {IO_C[23]}]

set_property PACKAGE_PIN B2 [get_ports {IO_C[24]}]		;# C30 / B2~IO_L2N_T0_AD12N_35
set_property IOSTANDARD LVCMOS33 [get_ports {IO_C[24]}]


set_property PACKAGE_PIN AB2 [get_ports {IO_D[0]}]		;# D3 / AB2~IO_L8N_T1_34
set_property IOSTANDARD LVCMOS33 [get_ports {IO_D[0]}]

set_property PACKAGE_PIN AB1 [get_ports {IO_D[1]}]		;# D4 / AB1~IO_L7N_T1_34
set_property IOSTANDARD LVCMOS33 [get_ports {IO_D[1]}]

set_property PACKAGE_PIN AA1 [get_ports {IO_D[2]}]		;# D5 / AA1~IO_L7P_T1_34
set_property IOSTANDARD LVCMOS33 [get_ports {IO_D[2]}]

set_property PACKAGE_PIN Y1 [get_ports {IO_D[3]}]		;# D6 / Y1~IO_L5N_T0_34
set_property IOSTANDARD LVCMOS33 [get_ports {IO_D[3]}]

set_property PACKAGE_PIN W1 [get_ports {IO_D[4]}]		;# D7 / W1~IO_L5P_T0_34
set_property IOSTANDARD LVCMOS33 [get_ports {IO_D[4]}]

set_property PACKAGE_PIN V4 [get_ports {IO_D[5]}]		;# D8 / V4~IO_L12P_T1_MRCC_34
set_property IOSTANDARD LVCMOS33 [get_ports {IO_D[5]}]

set_property PACKAGE_PIN W4 [get_ports {IO_D[6]}]		;# D9 / W4~IO_L12N_T1_MRCC_34
set_property IOSTANDARD LVCMOS33 [get_ports {IO_D[6]}]

set_property PACKAGE_PIN U1 [get_ports {IO_D[7]}]		;# D10 / U1~IO_L1N_T0_34
set_property IOSTANDARD LVCMOS33 [get_ports {IO_D[7]}]

set_property PACKAGE_PIN T1 [get_ports {IO_D[8]}]		;# D11 / T1~IO_L1P_T0_34
set_property IOSTANDARD LVCMOS33 [get_ports {IO_D[8]}]

set_property PACKAGE_PIN R1 [get_ports {IO_D[9]}]		;# D12 / R1~IO_L20P_T3_35
set_property IOSTANDARD LVCMOS33 [get_ports {IO_D[9]}]

set_property PACKAGE_PIN P1 [get_ports {IO_D[10]}]		;# D13 / P1~IO_L20N_T3_35
set_property IOSTANDARD LVCMOS33 [get_ports {IO_D[10]}]

set_property PACKAGE_PIN N3 [get_ports {IO_D[11]}]		;# D14 / N3~IO_L19N_T3_VREF_35
set_property IOSTANDARD LVCMOS33 [get_ports {IO_D[11]}]

set_property PACKAGE_PIN N4 [get_ports {IO_D[12]}]		;# D15 / N4~IO_L19P_T3_35
set_property IOSTANDARD LVCMOS33 [get_ports {IO_D[12]}]

set_property PACKAGE_PIN J4 [get_ports {IO_D[13]}]		;# D19 / J4~IO_L13N_T2_MRCC_35
set_property IOSTANDARD LVCMOS33 [get_ports {IO_D[13]}]

set_property PACKAGE_PIN K4 [get_ports {IO_D[14]}]		;# D20 / K4~IO_L13P_T2_MRCC_35
set_property IOSTANDARD LVCMOS33 [get_ports {IO_D[14]}]

set_property PACKAGE_PIN K1 [get_ports {IO_D[15]}]		;# D21 / K1~IO_L7P_T1_AD6P_35
set_property IOSTANDARD LVCMOS33 [get_ports {IO_D[15]}]

set_property PACKAGE_PIN J1 [get_ports {IO_D[16]}]		;# D22 / J1~IO_L7N_T1_AD6N_35
set_property IOSTANDARD LVCMOS33 [get_ports {IO_D[16]}]

set_property PACKAGE_PIN H2 [get_ports {IO_D[17]}]		;# D23 / H2~IO_L8P_T1_AD14P_35
set_property IOSTANDARD LVCMOS33 [get_ports {IO_D[17]}]

set_property PACKAGE_PIN G2 [get_ports {IO_D[18]}]		;# D24 / G2~IO_L8N_T1_AD14N_35
set_property IOSTANDARD LVCMOS33 [get_ports {IO_D[18]}]

set_property PACKAGE_PIN G1 [get_ports {IO_D[19]}]		;# D25 / G1~IO_L5P_T0_AD13P_35
set_property IOSTANDARD LVCMOS33 [get_ports {IO_D[19]}]

set_property PACKAGE_PIN F1 [get_ports {IO_D[20]}]		;# D26 / F1~IO_L5N_T0_AD13N_35
set_property IOSTANDARD LVCMOS33 [get_ports {IO_D[20]}]

set_property PACKAGE_PIN E1 [get_ports {IO_D[21]}]		;# D27 / E1~IO_L3P_T0_DQS_AD5P_35
set_property IOSTANDARD LVCMOS33 [get_ports {IO_D[21]}]

set_property PACKAGE_PIN D1 [get_ports {IO_D[22]}]		;# D28 / D1~IO_L3N_T0_DQS_AD5N_35
set_property IOSTANDARD LVCMOS33 [get_ports {IO_D[22]}]

set_property PACKAGE_PIN B1 [get_ports {IO_D[23]}]		;# D29 / B1~IO_L1P_T0_AD4P_35
set_property IOSTANDARD LVCMOS33 [get_ports {IO_D[23]}]

set_property PACKAGE_PIN A1 [get_ports {IO_D[24]}]		;# D30 / A1~IO_L1N_T0_AD4N_35
set_property IOSTANDARD LVCMOS33 [get_ports {IO_D[24]}]
