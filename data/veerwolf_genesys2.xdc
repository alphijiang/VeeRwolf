## Digilent Genesys 2 constraints for VeeRwolf + fixed LiteDRAM DDR3 integration.
## Board I/O, clocks and VeeRwolf integration CDC constraints are intentionally kept in one file.

## -----------------------------------------------------------------------------
## Board/system clocks
## -----------------------------------------------------------------------------
## Genesys2 logical clock constraints for upstream-style LiteDRAM integration.
## Declarative XDC only.

create_clock -add -name sys_clk_200 -period 5.000 -waveform {0.000 2.500} [get_ports sysclk_p]

create_clock -add -name jtag_tck_pin -period 100.000 -waveform {0 50} [get_ports {i_jtag_tck}]

# FT232H MPSSE drives TMS/TDI after the falling TCK edge and samples TDO on
# the following rising edge.  Keep 20 ns for adapter plus board delay at the
# supported 10 MHz external DMI rate.
set_input_delay  -clock [get_clocks jtag_tck_pin] -clock_fall -min 0.000  [get_ports {i_jtag_tms i_jtag_tdi}]
set_input_delay  -clock [get_clocks jtag_tck_pin] -clock_fall -max 20.000 [get_ports {i_jtag_tms i_jtag_tdi}]
set_output_delay -clock [get_clocks jtag_tck_pin]             -min 0.000  [get_ports {o_jtag_tdo}]
set_output_delay -clock [get_clocks jtag_tck_pin]             -max 20.000 [get_ports {o_jtag_tdo}]

## -----------------------------------------------------------------------------
## Board pins / DDR3 electrical constraints
## -----------------------------------------------------------------------------

set_property -dict {PACKAGE_PIN AD12 IOSTANDARD LVDS} [get_ports sysclk_p]
set_property -dict {PACKAGE_PIN AD11 IOSTANDARD LVDS} [get_ports sysclk_n]
set_property -dict {PACKAGE_PIN R19 IOSTANDARD LVCMOS33} [get_ports cpu_resetn]
set_property -dict {PACKAGE_PIN Y20 IOSTANDARD LVCMOS33} [get_ports i_uart_rx]
set_property -dict {PACKAGE_PIN Y23 IOSTANDARD LVCMOS33} [get_ports o_uart_tx]
set_property -dict {PACKAGE_PIN U19 IOSTANDARD LVCMOS33} [get_ports o_flash_cs_n]
set_property -dict {PACKAGE_PIN P24 IOSTANDARD LVCMOS33} [get_ports o_flash_mosi]
set_property -dict {PACKAGE_PIN R25 IOSTANDARD LVCMOS33} [get_ports i_flash_miso]
set_property -dict {PACKAGE_PIN G19 IOSTANDARD LVCMOS12} [get_ports {i_sw[0]}]
set_property -dict {PACKAGE_PIN G25 IOSTANDARD LVCMOS12} [get_ports {i_sw[1]}]
set_property -dict {PACKAGE_PIN H24 IOSTANDARD LVCMOS12} [get_ports {i_sw[2]}]
set_property -dict {PACKAGE_PIN K19 IOSTANDARD LVCMOS12} [get_ports {i_sw[3]}]
set_property -dict {PACKAGE_PIN N19 IOSTANDARD LVCMOS12} [get_ports {i_sw[4]}]
set_property -dict {PACKAGE_PIN P19 IOSTANDARD LVCMOS12} [get_ports {i_sw[5]}]
set_property -dict {PACKAGE_PIN P26 IOSTANDARD LVCMOS33} [get_ports {i_sw[6]}]
set_property -dict {PACKAGE_PIN P27 IOSTANDARD LVCMOS33} [get_ports {i_sw[7]}]
set_property -dict {PACKAGE_PIN T28 IOSTANDARD LVCMOS33} [get_ports {o_led[0]}]
set_property -dict {PACKAGE_PIN V19 IOSTANDARD LVCMOS33} [get_ports {o_led[1]}]
set_property -dict {PACKAGE_PIN U30 IOSTANDARD LVCMOS33} [get_ports {o_led[2]}]
set_property -dict {PACKAGE_PIN U29 IOSTANDARD LVCMOS33} [get_ports {o_led[3]}]
set_property -dict {PACKAGE_PIN V20 IOSTANDARD LVCMOS33} [get_ports {o_led[4]}]
set_property -dict {PACKAGE_PIN V26 IOSTANDARD LVCMOS33} [get_ports {o_led[5]}]
set_property -dict {PACKAGE_PIN W24 IOSTANDARD LVCMOS33} [get_ports {o_led[6]}]
set_property -dict {PACKAGE_PIN W23 IOSTANDARD LVCMOS33} [get_ports {o_led[7]}]
## External DMI JTAG on Pmod JC (FT232H ADBUS0..3).
set_property -dict {PACKAGE_PIN AC26 IOSTANDARD LVCMOS33} [get_ports {i_jtag_tck}]; # JC1
set_property -dict {PACKAGE_PIN AJ27 IOSTANDARD LVCMOS33} [get_ports {i_jtag_tdi}]; # JC2
set_property -dict {PACKAGE_PIN AH30 IOSTANDARD LVCMOS33} [get_ports {o_jtag_tdo}]; # JC3
set_property -dict {PACKAGE_PIN AK29 IOSTANDARD LVCMOS33} [get_ports {i_jtag_tms}]; # JC4
# JC1 is not a clock-capable input.  Keep this low-speed external DMI TCK on
# fabric routing without naming an implementation-generated IBUF net.
set_property CLOCK_BUFFER_TYPE NONE [get_ports {i_jtag_tck}]
set_property PACKAGE_PIN AC12 [get_ports {ddram_a[0]}]
set_property PACKAGE_PIN AE8  [get_ports {ddram_a[1]}]
set_property PACKAGE_PIN AD8  [get_ports {ddram_a[2]}]
set_property PACKAGE_PIN AC10 [get_ports {ddram_a[3]}]
set_property PACKAGE_PIN AD9  [get_ports {ddram_a[4]}]
set_property PACKAGE_PIN AA13 [get_ports {ddram_a[5]}]
set_property PACKAGE_PIN AA10 [get_ports {ddram_a[6]}]
set_property PACKAGE_PIN AA11 [get_ports {ddram_a[7]}]
set_property PACKAGE_PIN Y10  [get_ports {ddram_a[8]}]
set_property PACKAGE_PIN Y11  [get_ports {ddram_a[9]}]
set_property PACKAGE_PIN AB8  [get_ports {ddram_a[10]}]
set_property PACKAGE_PIN AA8  [get_ports {ddram_a[11]}]
set_property PACKAGE_PIN AB12 [get_ports {ddram_a[12]}]
set_property PACKAGE_PIN AA12 [get_ports {ddram_a[13]}]
set_property PACKAGE_PIN AH9  [get_ports {ddram_a[14]}]
set_property PACKAGE_PIN AE9  [get_ports {ddram_ba[0]}]
set_property PACKAGE_PIN AB10 [get_ports {ddram_ba[1]}]
set_property PACKAGE_PIN AC11 [get_ports {ddram_ba[2]}]
set_property PACKAGE_PIN AE11 [get_ports ddram_ras_n]
set_property PACKAGE_PIN AF11 [get_ports ddram_cas_n]
set_property PACKAGE_PIN AG13 [get_ports ddram_we_n]
set_property PACKAGE_PIN AH12 [get_ports ddram_cs_n]
set_property PACKAGE_PIN AJ9  [get_ports ddram_cke]
set_property PACKAGE_PIN AK9  [get_ports ddram_odt]
set_property PACKAGE_PIN AG5  [get_ports ddram_reset_n]
set_property PACKAGE_PIN AB9  [get_ports ddram_clk_p]
set_property PACKAGE_PIN AC9  [get_ports ddram_clk_n]
set_property PACKAGE_PIN AD4 [get_ports {ddram_dm[0]}]
set_property PACKAGE_PIN AF3 [get_ports {ddram_dm[1]}]
set_property PACKAGE_PIN AH4 [get_ports {ddram_dm[2]}]
set_property PACKAGE_PIN AF8 [get_ports {ddram_dm[3]}]
set_property PACKAGE_PIN AD3 [get_ports {ddram_dq[0]}]
set_property PACKAGE_PIN AC2 [get_ports {ddram_dq[1]}]
set_property PACKAGE_PIN AC1 [get_ports {ddram_dq[2]}]
set_property PACKAGE_PIN AC5 [get_ports {ddram_dq[3]}]
set_property PACKAGE_PIN AC4 [get_ports {ddram_dq[4]}]
set_property PACKAGE_PIN AD6 [get_ports {ddram_dq[5]}]
set_property PACKAGE_PIN AE6 [get_ports {ddram_dq[6]}]
set_property PACKAGE_PIN AC7 [get_ports {ddram_dq[7]}]
set_property PACKAGE_PIN AF2 [get_ports {ddram_dq[8]}]
set_property PACKAGE_PIN AE1 [get_ports {ddram_dq[9]}]
set_property PACKAGE_PIN AF1 [get_ports {ddram_dq[10]}]
set_property PACKAGE_PIN AE4 [get_ports {ddram_dq[11]}]
set_property PACKAGE_PIN AE3 [get_ports {ddram_dq[12]}]
set_property PACKAGE_PIN AE5 [get_ports {ddram_dq[13]}]
set_property PACKAGE_PIN AF5 [get_ports {ddram_dq[14]}]
set_property PACKAGE_PIN AF6 [get_ports {ddram_dq[15]}]
set_property PACKAGE_PIN AJ4 [get_ports {ddram_dq[16]}]
set_property PACKAGE_PIN AH6 [get_ports {ddram_dq[17]}]
set_property PACKAGE_PIN AH5 [get_ports {ddram_dq[18]}]
set_property PACKAGE_PIN AH2 [get_ports {ddram_dq[19]}]
set_property PACKAGE_PIN AJ2 [get_ports {ddram_dq[20]}]
set_property PACKAGE_PIN AJ1 [get_ports {ddram_dq[21]}]
set_property PACKAGE_PIN AK1 [get_ports {ddram_dq[22]}]
set_property PACKAGE_PIN AJ3 [get_ports {ddram_dq[23]}]
set_property PACKAGE_PIN AF7 [get_ports {ddram_dq[24]}]
set_property PACKAGE_PIN AG7 [get_ports {ddram_dq[25]}]
set_property PACKAGE_PIN AJ6 [get_ports {ddram_dq[26]}]
set_property PACKAGE_PIN AK6 [get_ports {ddram_dq[27]}]
set_property PACKAGE_PIN AJ8 [get_ports {ddram_dq[28]}]
set_property PACKAGE_PIN AK8 [get_ports {ddram_dq[29]}]
set_property PACKAGE_PIN AK5 [get_ports {ddram_dq[30]}]
set_property PACKAGE_PIN AK4 [get_ports {ddram_dq[31]}]
set_property PACKAGE_PIN AD2 [get_ports {ddram_dqs_p[0]}]
set_property PACKAGE_PIN AG4 [get_ports {ddram_dqs_p[1]}]
set_property PACKAGE_PIN AG2 [get_ports {ddram_dqs_p[2]}]
set_property PACKAGE_PIN AH7 [get_ports {ddram_dqs_p[3]}]
set_property PACKAGE_PIN AD1 [get_ports {ddram_dqs_n[0]}]
set_property PACKAGE_PIN AG3 [get_ports {ddram_dqs_n[1]}]
set_property PACKAGE_PIN AH1 [get_ports {ddram_dqs_n[2]}]
set_property PACKAGE_PIN AJ7 [get_ports {ddram_dqs_n[3]}]
set_property IOSTANDARD SSTL15 [get_ports {ddram_a[*] ddram_ba[*] ddram_ras_n ddram_cas_n ddram_we_n ddram_cs_n ddram_cke ddram_odt ddram_dm[*]}]
set_property IOSTANDARD SSTL15_T_DCI [get_ports {ddram_dq[*]}]
set_property IOSTANDARD DIFF_SSTL15 [get_ports {ddram_dqs_p[*] ddram_dqs_n[*] ddram_clk_p ddram_clk_n}]
set_property IOSTANDARD LVCMOS15 [get_ports ddram_reset_n]
set_property SLEW FAST [get_ports {ddram_a[*] ddram_ba[*] ddram_ras_n ddram_cas_n ddram_we_n ddram_cs_n ddram_cke ddram_odt ddram_reset_n ddram_dm[*] ddram_dq[*] ddram_dqs_p[*] ddram_dqs_n[*] ddram_clk_p ddram_clk_n}]
set_property VCCAUX_IO HIGH [get_ports {ddram_a[*] ddram_ba[*] ddram_ras_n ddram_cas_n ddram_we_n ddram_cs_n ddram_cke ddram_odt ddram_reset_n ddram_dm[*] ddram_dq[*] ddram_dqs_p[*] ddram_dqs_n[*] ddram_clk_p ddram_clk_n}]
set_property INTERNAL_VREF 0.750 [get_iobanks 34]
set_property CFGBVS VCCO [current_design]
set_property CONFIG_VOLTAGE 3.3 [current_design]

## -----------------------------------------------------------------------------
## VeeRwolf / PULP CDC integration constraints
## -----------------------------------------------------------------------------
## Genesys2 LiteDRAM integration constraints.
## Keep only CDC constraints required by the reset discipline, direct DMI JTAG,
## and the upstream PULP cdc_fifo_gray architecture.  No debug observer paths.

set_property ASYNC_REG TRUE [get_cells -quiet -hierarchical -regexp {.*(sw_r|sw_2r)_reg\[[0-7]\]$}]
set_property ASYNC_REG TRUE [get_cells -quiet -hierarchical -regexp {.*clk_gen/hold_rst_sync_reg\[[0-1]\]$}]
set_property ASYNC_REG TRUE [get_cells -quiet -hierarchical -regexp {.*clk_gen/reset_sync_reg\[[0-2]\]$}]
set_property ASYNC_REG TRUE [get_cells -quiet -hierarchical -regexp {.*litedram_init_(done|error)_sync_reg\[[01]\]$}]
set_property ASYNC_REG TRUE [get_cells -quiet -hierarchical -regexp {.*dmi_wrapper/i_dmi_jtag_to_core_sync/(rden|wren)_reg\[[0-2]\]$}]

# PULP common_cells sync.sv has no Xilinx-specific attributes, so preserve the
# Gray-pointer synchronizers explicitly in the FPGA integration constraints.
set_property ASYNC_REG TRUE [get_cells -quiet -hierarchical -regexp {.*axi_cdc/i_axi_cdc/i_cdc_fifo_gray_(aw|w|b|ar|r)/(i_src|i_dst)/gen_sync\[[0-9]+\]\.i_sync/reg_q_reg\[[01]\]$}]
set_property SHREG_EXTRACT NO [get_cells -quiet -hierarchical -regexp {.*axi_cdc/i_axi_cdc/i_cdc_fifo_gray_(aw|w|b|ar|r)/(i_src|i_dst)/gen_sync\[[0-9]+\]\.i_sync/reg_q_reg\[[01]\]$}]

# LiteDRAM user_rst/init status -> clk_core: cut only first synchronizer stage.
set_false_path -to [get_pins -quiet -of_objects [get_cells -quiet -hierarchical -regexp {.*clk_gen/hold_rst_sync_reg\[0\]$}] -filter {REF_PIN_NAME == D}]
set_false_path -to [get_pins -quiet -of_objects [get_cells -quiet -hierarchical -regexp {.*litedram_init_done_sync_reg\[0\]$}] -filter {REF_PIN_NAME == D}]
set_false_path -to [get_pins -quiet -of_objects [get_cells -quiet -hierarchical -regexp {.*litedram_init_error_sync_reg\[0\]$}] -filter {REF_PIN_NAME == D}]

# Physical switches are asynchronous controls.
set_false_path -from [get_ports {i_sw[*]}] -to [get_pins -quiet -of_objects [get_cells -quiet -regexp {sw_r_reg\[[0-7]\]}] -filter {REF_PIN_NAME == D}]

# R19 is the asynchronous reset assertion source for the core-domain synchronizers.
set_false_path -from [get_ports cpu_resetn] -to [get_pins -quiet -of_objects [get_cells -quiet -hierarchical -regexp {.*clk_gen/(hold_rst_sync|reset_sync)_reg\[[0-2]\]$}] -filter {REF_PIN_NAME == CLR || REF_PIN_NAME == PRE}]

# Direct DMI TCK is asynchronous to both the core and LiteDRAM user clocks.
set_clock_groups -asynchronous \
    -group [get_clocks -quiet jtag_tck_pin] \
    -group [get_clocks -quiet -include_generated_clocks -of_objects [get_ports {sysclk_p}]]

# LiteDRAM standalone-core reset feedback boundary.
set_false_path -from [get_clocks -quiet -of_objects [get_pins -quiet {ddr2/ldc/PLLE2_ADV/CLKOUT1}]] -to [get_pins -quiet {ddr2/ldc/FDCE/D}]

# PULP cdc_fifo_gray requires bounded propagation of async payload and Gray
# pointers to the minimum source/destination period.  clk_core=40 ns and
# user_clk=10 ns, therefore 10 ns is the bound.  Hold checks are disabled only
# on the same explicit asynchronous crossings, matching the upstream guidance.
set_max_delay -datapath_only -from [get_pins -quiet -of_objects [get_cells -quiet -hierarchical -regexp {.*axi_cdc/i_axi_cdc/i_cdc_fifo_gray_(aw|w|b|ar|r)/i_src/gen_word\[[0-9]+\]\.data_q_reg.*}] -filter {REF_PIN_NAME == C}] -to [get_pins -quiet -of_objects [get_cells -quiet -hierarchical -regexp {.*axi_cdc/i_axi_cdc/i_cdc_fifo_gray_(aw|w|b|ar|r)/i_dst/i_spill_register/.*data_q_reg.*}] -filter {REF_PIN_NAME == D}] 10.000
set_false_path -hold -from [get_pins -quiet -of_objects [get_cells -quiet -hierarchical -regexp {.*axi_cdc/i_axi_cdc/i_cdc_fifo_gray_(aw|w|b|ar|r)/i_src/gen_word\[[0-9]+\]\.data_q_reg.*}] -filter {REF_PIN_NAME == C}] -to [get_pins -quiet -of_objects [get_cells -quiet -hierarchical -regexp {.*axi_cdc/i_axi_cdc/i_cdc_fifo_gray_(aw|w|b|ar|r)/i_dst/i_spill_register/.*data_q_reg.*}] -filter {REF_PIN_NAME == D}]

set_max_delay -datapath_only -from [get_pins -quiet -of_objects [get_cells -quiet -hierarchical -regexp {.*axi_cdc/i_axi_cdc/i_cdc_fifo_gray_(aw|w|b|ar|r)/i_src/wptr_q_reg\[[0-9]+\]$}] -filter {REF_PIN_NAME == C}] -to [get_pins -quiet -of_objects [get_cells -quiet -hierarchical -regexp {.*axi_cdc/i_axi_cdc/i_cdc_fifo_gray_(aw|w|b|ar|r)/i_dst/gen_sync\[[0-9]+\]\.i_sync/reg_q_reg\[0\]$}] -filter {REF_PIN_NAME == D}] 10.000
set_false_path -hold -from [get_pins -quiet -of_objects [get_cells -quiet -hierarchical -regexp {.*axi_cdc/i_axi_cdc/i_cdc_fifo_gray_(aw|w|b|ar|r)/i_src/wptr_q_reg\[[0-9]+\]$}] -filter {REF_PIN_NAME == C}] -to [get_pins -quiet -of_objects [get_cells -quiet -hierarchical -regexp {.*axi_cdc/i_axi_cdc/i_cdc_fifo_gray_(aw|w|b|ar|r)/i_dst/gen_sync\[[0-9]+\]\.i_sync/reg_q_reg\[0\]$}] -filter {REF_PIN_NAME == D}]

set_max_delay -datapath_only -from [get_pins -quiet -of_objects [get_cells -quiet -hierarchical -regexp {.*axi_cdc/i_axi_cdc/i_cdc_fifo_gray_(aw|w|b|ar|r)/i_dst/rptr_q_reg\[[0-9]+\]$}] -filter {REF_PIN_NAME == C}] -to [get_pins -quiet -of_objects [get_cells -quiet -hierarchical -regexp {.*axi_cdc/i_axi_cdc/i_cdc_fifo_gray_(aw|w|b|ar|r)/i_src/gen_sync\[[0-9]+\]\.i_sync/reg_q_reg\[0\]$}] -filter {REF_PIN_NAME == D}] 10.000
set_false_path -hold -from [get_pins -quiet -of_objects [get_cells -quiet -hierarchical -regexp {.*axi_cdc/i_axi_cdc/i_cdc_fifo_gray_(aw|w|b|ar|r)/i_dst/rptr_q_reg\[[0-9]+\]$}] -filter {REF_PIN_NAME == C}] -to [get_pins -quiet -of_objects [get_cells -quiet -hierarchical -regexp {.*axi_cdc/i_axi_cdc/i_cdc_fifo_gray_(aw|w|b|ar|r)/i_src/gen_sync\[[0-9]+\]\.i_sync/reg_q_reg\[0\]$}] -filter {REF_PIN_NAME == D}]
