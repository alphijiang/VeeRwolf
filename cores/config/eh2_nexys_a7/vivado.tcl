# SPDX-License-Identifier: Apache-2.0

# EH2 configuration headers must be visible in every SystemVerilog compilation
# unit. Vivado otherwise treats the .vh files as headers without propagating
# their macros and the eh2_param_t typedef to separately compiled RTL files.
set eh2_common_defines [get_files -quiet config/common_defines.vh]
set eh2_pdef           [get_files -quiet config/eh2_pdef.vh]

# This script also runs as the synth_design pre-hook. In that subordinate
# process the working directory is the synthesis run directory, so the
# project-relative file names above do not resolve. The properties have
# already been stored in the project and must only be set when the objects are
# present in the current process.
if {[llength $eh2_common_defines] > 0} {
    set_property is_global_include true $eh2_common_defines
}

if {[llength $eh2_pdef] > 0} {
    set_property is_global_include true $eh2_pdef
    set_property file_type SystemVerilog $eh2_pdef
}

# Vivado emits synthesis messages in a subordinate process. Install this
# core-specific file as the synthesis pre-hook so the same precise rules are
# active in that process. This file is selected only by the EH2 provider. Do
# not rewrite the run property when this file is itself executing as the hook.
set eh2_synth_run [get_runs -quiet synth_1]
if {[llength $eh2_synth_run] > 0 &&
    [get_property STATUS $eh2_synth_run] eq "Not started"} {
    set_property STEPS.SYNTH_DESIGN.TCL.PRE [file normalize [info script]] \
        $eh2_synth_run
}

# A clean FuseSoC build has no incremental reference checkpoint, so Vivado
# intentionally falls back to standard synthesis. The vectorless power report
# also assumes reset activity that does not represent normal running firmware.
# Scope both report-only waivers to the EH2 target by keeping them in this file.
set_msg_config -id {Vivado 12-7122} -suppress
set_msg_config -id {Power 33-332} -suppress

puts "INFO: Enabled VeeR EH2 configuration headers as Vivado global includes"
puts "INFO: Applying audited VeeR EH2 synthesis warning rules"

# Keep EH2 warning waivers narrow. Configuration-dependent trimming,
# multiplier trimming and BRAM async-control DRCs remain visible until their
# directed tests qualify the exact synthesized objects.

# LiteDRAM-generated Xilinx primitive ports and training registers.
set_msg_config -id {[Synth 8-7071]} -regexp -string {.*port '.*' of module '(IDELAYCTRL|IDELAYE2|ISERDESE2|OSERDESE2)' is unconnected.*litedram_core\.v.*} -suppress
set_msg_config -id {[Synth 8-7023]} -regexp -string {.*instance '.*' of module '(IDELAYCTRL|IDELAYE2|ISERDESE2|OSERDESE2|IOBUFDS|PLLE2_ADV)' has [0-9]+ connections declared, but only [0-9]+ given.*litedram_core\.v.*} -suppress
set_msg_config -id {[Synth 8-3936]} -regexp -string {.*a7ddrphy_bitslip[0-9]+_reg.*trimmed from '8' to '4' bits.*litedram_core\.v.*} -suppress
set_msg_config -id {[Synth 8-3936]} -regexp -string {.*(memdat_2_reg.*trimmed from '10' to '8'|memdat_4_reg.*trimmed from '10' to '8'|memdat_18_reg.*trimmed from '74' to '66') bits.*litedram_core\.v.*} -suppress
set_msg_config -id {[Synth 8-4446]} -regexp -string {.*all outputs are unconnected.*litedram_core\.v.*} -suppress

# Generated AXI/Wishbone glue and the Xilinx STARTUPE2 instance have
# intentionally unused optional fields or outputs.
set_msg_config -id {[Synth 8-3848]} -regexp -string {.*veerwolf-intercon.*axi_intercon\.v.*} -suppress
set_msg_config -id {[Synth 8-11065]} -regexp -string {.*parameter '(master_sel_bits|slave_sel_bits)'.*in '(wb_arbiter|wb_mux)'.*} -suppress
set_msg_config -id {[Synth 8-6014]} -regexp -string {.*rtl/axi2wb\.v.*} -suppress
set_msg_config -id {[Synth 8-4446]} -regexp -string {.*all outputs are unconnected.*rtl/veerwolf_nexys\.v.*} -suppress

# Verified EH2 FPGA-optimization branches. RV_FPGA_OPTIMIZE replaces these
# gated clocks with rawclk plus clock enable; RV_BUILD_AXI4 leaves AHB nets
# unused; BTB_USE_SRAM=0 leaves the listed BTB SRAM nets unused. The V21 Nexys
# configuration has ICACHE_ENABLE=0, so its unused cache/debug nets are also
# expected here. Match exact module and net families, never the whole EH2 tree.
set_msg_config -id {[Synth 8-3848]} -regexp -string {.*Net IO_CLK_GRP\[[0-9]+\]\.grp_clk in module/entity eh2_pic_ctrl does not have driver.*} -suppress
set_msg_config -id {[Synth 8-3848]} -regexp -string {.*Net (haddr|hburst|hmastlock|hprot|hsize|htrans|hwrite|lsu_haddr|lsu_hburst|lsu_hmastlock|lsu_hprot|lsu_hsize|lsu_htrans|lsu_hwrite|lsu_hwdata|sb_haddr|sb_hburst|sb_hmastlock|sb_hprot|sb_hsize|sb_htrans|sb_hwrite|sb_hwdata|dma_hrdata|dma_hreadyout|dma_hresp) in module/entity eh2_swerv does not have driver.*} -suppress
set_msg_config -id {[Synth 8-3848]} -regexp -string {.*Net (ic_debug_rd_data|ic_eccerr|ic_parerr|btb_sram_pkt\[[^]]+\]|btb_vbank0_rd_data_f1) in module/entity eh2_mem does not have driver.*} -suppress
set_msg_config -id {[Synth 8-3848]} -regexp -string {.*Net (btb_sram_rw_addr(_f1)?\[[0-9]+\]|btb_sram_rd_tag_f1\[[0-9]+\]|btb_sram_wr_data|bht_bank_clk\[[0-9]+\]) in module/entity eh2_ifu_bp_ctl does not have driver.*} -suppress
set_msg_config -id {[Synth 8-3848]} -regexp -string {.*Net (bus_ic_wr_en|ifu_ic_rw_int_addr_ff) in module/entity eh2_ifu_mem_ctl does not have driver.*} -suppress
set_msg_config -id {[Synth 8-3848]} -regexp -string {.*Net bus_rsp_(valid|ready|write|error|rdata)_q in module/entity eh2_lsu_bus_intf does not have driver.*} -suppress

# Exact unused ports produced by the FPGA/ICCM/DCCM/no-I-cache configuration.
set_msg_config -id {[Synth 8-7129]} -regexp -string {.*Port (en|scan_mode) in module rvoclkhdr is either unconnected or has no load.*} -suppress
set_msg_config -id {[Synth 8-7129]} -regexp -string {.*Port (TEST1|RME|RM\[[0-3]\]|LS|DS|SD|TEST_RNM|BC1|BC2) in module ram_(2048|4096)x39 is either unconnected or has no load.*} -suppress
set_msg_config -id {[Synth 8-7129]} -regexp -string {.*Port (iccm_wr_size\[2\]|scan_mode) in module eh2_ifu_iccm_mem is either unconnected or has no load.*} -suppress
set_msg_config -id {[Synth 8-7129]} -regexp -string {.*Port (dccm_(rd|wr)_addr_(hi|lo)\[[01]\]|scan_mode) in module eh2_lsu_dccm_mem is either unconnected or has no load.*} -suppress
set_msg_config -id {[Synth 8-7129]} -regexp -string {.*Port (ic_debug_rd_data\[[0-9]+\]|ic_eccerr\[[01]\]|ic_parerr\[[01]\]) in module eh2_mem is either unconnected or has no load.*} -suppress
set_msg_config -id {[Synth 8-693]} -regexp -string {.*chipsalliance\.org_cores_VeeR_EH2_1\.4/design/lsu/eh2_lsu_stbuf\.sv.*} -suppress

# Do not suppress REQP-1839/1840 here. They concern asynchronous controls on
# inferred BRAMs and require post-opt object-level waivers after reset and
# ICCM/DCCM memory tests qualify the exact synthesized instances.
