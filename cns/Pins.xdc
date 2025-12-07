##Created for Digilent Cmod S7 board

## Clock 12 MHz on pin M9
set_property PACKAGE_PIN M9 [get_ports clk]
set_property IOSTANDARD LVCMOS33 [get_ports clk]
create_clock -period 83.333 -name sys_clk -waveform {0 41.666} [get_ports clk]

## Reset button on pin D2
set_property PACKAGE_PIN D2 [get_ports rst]
set_property IOSTANDARD LVCMOS33 [get_ports rst]

## Led diode on pin E2
set_property PACKAGE_PIN E2 [get_ports led]
set_property IOSTANDARD LVCMOS33 [get_ports led]

## UART TX on pin L12
set_property PACKAGE_PIN L12 [get_ports uart_txd_out]
set_property IOSTANDARD LVCMOS33 [get_ports uart_txd_out]
