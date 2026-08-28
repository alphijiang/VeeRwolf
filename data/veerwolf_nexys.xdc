create_clock -add -name sys_clk_pin -period 10.00 -waveform {0 5} [get_ports {clk}];
create_clock -add -name jtag_tck_pin -period 100.00 -waveform {0 50} [get_ports {JTAG_TCK}];

# Nexys A7 / Nexys 4 DDR configuration bank is powered from 3.3 V.
set_property CFGBVS VCCO [current_design]
set_property CONFIG_VOLTAGE 3.3 [current_design]

# Pmod JC1 (K1) is not a clock-capable input. Keep the low-speed FT232H TCK
# on fabric routing instead of inferring a BUFG fed through a non-dedicated
# clock path.
set_property CLOCK_BUFFER_TYPE NONE [get_ports {JTAG_TCK}]

# The official Cores-VeeR DMI wrapper holds its address/data payload while its
# rden/wren request strobes are synchronized into clk_core. JTAG TCK and
# clocks derived from the board oscillator are unrelated.
set_clock_groups -asynchronous \
    -group [get_clocks -include_generated_clocks {jtag_tck_pin}] \
    -group [get_clocks -include_generated_clocks {sys_clk_pin}]

# These are the existing three-stage request synchronizers in the official
# Cores-VeeR DMI wrapper. With -regexp, match the complete hierarchical NAME;
# do not combine -hierarchical with a pattern containing hierarchy separators.
# The property guides placement; it does not introduce a new transport
# protocol or waive CDC analysis.
set_property ASYNC_REG TRUE [get_cells -regexp \
    {.*tap/i_dmi_jtag_to_core_sync/(rden|wren)_reg\[[0-2]\]$}]

# The PULP AXI CDC uses Gray-pointer asynchronous FIFOs between the core
# domain and LiteDRAM's 100 MHz user domain. Its implementation requires the
# cross-domain datapath delay to be no greater than the shorter clock period,
# while asynchronous hold checks must be disabled. Keep the 10 ns datapath
# bound instead of hiding setup paths with a clock-group waiver.
#
# Both clocks are auto-derived. Resolve them from their PLL output pins rather
# than their generated names so this constraint remains valid if Vivado
# changes an auto-derived clock name (methodology DRC TIMING-28).
set clk_core_cdc [get_clocks -of_objects \
    [get_pins {clk_gen/PLLE2_BASE_inst/CLKOUT0}]]
set clk_ddr_cdc [get_clocks -of_objects \
    [get_pins {ddr2/ldc/PLLE2_ADV/CLKOUT1}]]
set_max_delay -datapath_only 10.000 \
    -from $clk_core_cdc -to $clk_ddr_cdc
set_max_delay -datapath_only 10.000 \
    -from $clk_ddr_cdc -to $clk_core_cdc
set_false_path -hold \
    -from $clk_core_cdc -to $clk_ddr_cdc
set_false_path -hold \
    -from $clk_ddr_cdc -to $clk_core_cdc

set_false_path -from  [get_cells ddr2/serial_tx_reg]

set_property -dict { PACKAGE_PIN E3    IOSTANDARD LVCMOS33 } [get_ports { clk }];

set_property -dict { PACKAGE_PIN C12   IOSTANDARD LVCMOS33 } [get_ports { rstn }];

set_property -dict { PACKAGE_PIN C4    IOSTANDARD LVCMOS33 } [get_ports i_uart_rx]
set_property -dict { PACKAGE_PIN D4    IOSTANDARD LVCMOS33 } [get_ports o_uart_tx]


set_property -dict { PACKAGE_PIN K17   IOSTANDARD LVCMOS33 } [get_ports o_flash_mosi]; #IO_L1P_T0_D00_MOSI_14 Sch=qspi_dq[0]
set_property -dict { PACKAGE_PIN K18   IOSTANDARD LVCMOS33 } [get_ports i_flash_miso]; #IO_L1N_T0_D01_DIN_14 Sch=qspi_dq[1]
#set_property -dict { PACKAGE_PIN L14   IOSTANDARD LVCMOS33 } [get_ports { QSPI_DQ[2] }]; #IO_L2P_T0_D02_14 Sch=qspi_dq[2]
#set_property -dict { PACKAGE_PIN M14   IOSTANDARD LVCMOS33 } [get_ports { QSPI_DQ[3] }]; #IO_L2N_T0_D03_14 Sch=qspi_dq[3]
set_property -dict { PACKAGE_PIN L13   IOSTANDARD LVCMOS33 } [get_ports o_flash_cs_n];

set_property -dict { PACKAGE_PIN J15   IOSTANDARD LVCMOS33 } [get_ports { i_sw[0] }]
set_property -dict { PACKAGE_PIN L16   IOSTANDARD LVCMOS33 } [get_ports { i_sw[1] }]
set_property -dict { PACKAGE_PIN M13   IOSTANDARD LVCMOS33 } [get_ports { i_sw[2] }]
set_property -dict { PACKAGE_PIN R15   IOSTANDARD LVCMOS33 } [get_ports { i_sw[3] }]
set_property -dict { PACKAGE_PIN R17   IOSTANDARD LVCMOS33 } [get_ports { i_sw[4] }]
set_property -dict { PACKAGE_PIN T18   IOSTANDARD LVCMOS33 } [get_ports { i_sw[5] }]
set_property -dict { PACKAGE_PIN U18   IOSTANDARD LVCMOS33 } [get_ports { i_sw[6] }]
set_property -dict { PACKAGE_PIN R13   IOSTANDARD LVCMOS33 } [get_ports { i_sw[7] }]
set_property -dict { PACKAGE_PIN T8    IOSTANDARD LVCMOS18 } [get_ports { i_sw[8] }]
set_property -dict { PACKAGE_PIN U8    IOSTANDARD LVCMOS18 } [get_ports { i_sw[9] }]
set_property -dict { PACKAGE_PIN R16   IOSTANDARD LVCMOS33 } [get_ports { i_sw[10] }]
set_property -dict { PACKAGE_PIN T13   IOSTANDARD LVCMOS33 } [get_ports { i_sw[11] }]
set_property -dict { PACKAGE_PIN H6    IOSTANDARD LVCMOS33 } [get_ports { i_sw[12] }]
set_property -dict { PACKAGE_PIN U12   IOSTANDARD LVCMOS33 } [get_ports { i_sw[13] }]
set_property -dict { PACKAGE_PIN U11   IOSTANDARD LVCMOS33 } [get_ports { i_sw[14] }]
set_property -dict { PACKAGE_PIN V10   IOSTANDARD LVCMOS33 } [get_ports { i_sw[15] }]

set_property -dict { PACKAGE_PIN H17   IOSTANDARD LVCMOS33 } [get_ports { o_led[0] }]
set_property -dict { PACKAGE_PIN K15   IOSTANDARD LVCMOS33 } [get_ports { o_led[1] }]
set_property -dict { PACKAGE_PIN J13   IOSTANDARD LVCMOS33 } [get_ports { o_led[2] }]
set_property -dict { PACKAGE_PIN N14   IOSTANDARD LVCMOS33 } [get_ports { o_led[3] }]
set_property -dict { PACKAGE_PIN R18   IOSTANDARD LVCMOS33 } [get_ports { o_led[4] }]
set_property -dict { PACKAGE_PIN V17   IOSTANDARD LVCMOS33 } [get_ports { o_led[5] }]
set_property -dict { PACKAGE_PIN U17   IOSTANDARD LVCMOS33 } [get_ports { o_led[6] }]
set_property -dict { PACKAGE_PIN U16   IOSTANDARD LVCMOS33 } [get_ports { o_led[7] }]
set_property -dict { PACKAGE_PIN V16   IOSTANDARD LVCMOS33 } [get_ports { o_led[8] }]
set_property -dict { PACKAGE_PIN T15   IOSTANDARD LVCMOS33 } [get_ports { o_led[9] }]
set_property -dict { PACKAGE_PIN U14   IOSTANDARD LVCMOS33 } [get_ports { o_led[10] }]
set_property -dict { PACKAGE_PIN T16   IOSTANDARD LVCMOS33 } [get_ports { o_led[11] }]
set_property -dict { PACKAGE_PIN V15   IOSTANDARD LVCMOS33 } [get_ports { o_led[12] }]
set_property -dict { PACKAGE_PIN V14   IOSTANDARD LVCMOS33 } [get_ports { o_led[13] }]
set_property -dict { PACKAGE_PIN V12   IOSTANDARD LVCMOS33 } [get_ports { o_led[14] }]
set_property -dict { PACKAGE_PIN V11   IOSTANDARD LVCMOS33 } [get_ports { o_led[15] }]

## External JTAG on Pmod JC
set_property -dict { PACKAGE_PIN K1    IOSTANDARD LVCMOS33 } [get_ports { JTAG_TCK }]; # JC1
set_property -dict { PACKAGE_PIN F6    IOSTANDARD LVCMOS33 } [get_ports { JTAG_TDI }]; # JC2
set_property -dict { PACKAGE_PIN J2    IOSTANDARD LVCMOS33 } [get_ports { JTAG_TDO }]; # JC3
set_property -dict { PACKAGE_PIN G6    IOSTANDARD LVCMOS33 } [get_ports { JTAG_TMS }]; # JC4
