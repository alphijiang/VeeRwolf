// SPDX-License-Identifier: Apache-2.0
// Copyright 2020 Western Digital Corporation or its affiliates.
//
// Licensed under the Apache License, Version 2.0 (the "License");
// you may not use this file except in compliance with the License.
// You may obtain a copy of the License at
//
// http://www.apache.org/licenses/LICENSE-2.0
//
// Unless required by applicable law or agreed to in writing, software
// distributed under the License is distributed on an "AS IS" BASIS,
// WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
// See the License for the specific language governing permissions and
// limitations under the License.

//********************************************************************************
// $Id$
//
// Function: Top wrapper file with eh2_swerv/mem instantiated inside
// Comments:
//
//********************************************************************************
`default_nettype wire
module veer_wrapper_dmi
import eh2_pkg::*;
#(
`include "eh2_param.vh"
) (
   input logic                       clk,
   input logic                       rst_l,
   input logic                       dbg_rst_l,
   input logic [31:1]                rst_vec,
   input logic                       nmi_int,
   input logic [31:1]                nmi_vec,


   output logic [63:0] trace_rv_i_insn_ip,
   output logic [63:0] trace_rv_i_address_ip,
   output logic [2:0]  trace_rv_i_valid_ip,
   output logic [2:0]  trace_rv_i_exception_ip,
   output logic [4:0]  trace_rv_i_ecause_ip,
   output logic [2:0]  trace_rv_i_interrupt_ip,
   output logic [31:0] trace_rv_i_tval_ip,

   // Bus signals

`ifdef RV_BUILD_AXI4
   //-------------------------- LSU AXI signals--------------------------
   // AXI Write Channels
   output logic                            lsu_axi_awvalid,
   input  logic                            lsu_axi_awready,
   output logic [pt.LSU_BUS_TAG-1:0]       lsu_axi_awid,
   output logic [31:0]                     lsu_axi_awaddr,
   output logic [3:0]                      lsu_axi_awregion,
   output logic [7:0]                      lsu_axi_awlen,
   output logic [2:0]                      lsu_axi_awsize,
   output logic [1:0]                      lsu_axi_awburst,
   output logic                            lsu_axi_awlock,
   output logic [3:0]                      lsu_axi_awcache,
   output logic [2:0]                      lsu_axi_awprot,
   output logic [3:0]                      lsu_axi_awqos,

   output logic                            lsu_axi_wvalid,
   input  logic                            lsu_axi_wready,
   output logic [63:0]                     lsu_axi_wdata,
   output logic [7:0]                      lsu_axi_wstrb,
   output logic                            lsu_axi_wlast,

   input  logic                            lsu_axi_bvalid,
   output logic                            lsu_axi_bready,
   input  logic [1:0]                      lsu_axi_bresp,
   input  logic [pt.LSU_BUS_TAG-1:0]       lsu_axi_bid,

   // AXI Read Channels
   output logic                            lsu_axi_arvalid,
   input  logic                            lsu_axi_arready,
   output logic [pt.LSU_BUS_TAG-1:0]       lsu_axi_arid,
   output logic [31:0]                     lsu_axi_araddr,
   output logic [3:0]                      lsu_axi_arregion,
   output logic [7:0]                      lsu_axi_arlen,
   output logic [2:0]                      lsu_axi_arsize,
   output logic [1:0]                      lsu_axi_arburst,
   output logic                            lsu_axi_arlock,
   output logic [3:0]                      lsu_axi_arcache,
   output logic [2:0]                      lsu_axi_arprot,
   output logic [3:0]                      lsu_axi_arqos,

   input  logic                            lsu_axi_rvalid,
   output logic                            lsu_axi_rready,
   input  logic [pt.LSU_BUS_TAG-1:0]       lsu_axi_rid,
   input  logic [63:0]                     lsu_axi_rdata,
   input  logic [1:0]                      lsu_axi_rresp,
   input  logic                            lsu_axi_rlast,

   //-------------------------- IFU AXI signals--------------------------
   // AXI Write Channels
   output logic                            ifu_axi_awvalid,
   input  logic                            ifu_axi_awready,
   output logic [pt.IFU_BUS_TAG-1:0]       ifu_axi_awid,
   output logic [31:0]                     ifu_axi_awaddr,
   output logic [3:0]                      ifu_axi_awregion,
   output logic [7:0]                      ifu_axi_awlen,
   output logic [2:0]                      ifu_axi_awsize,
   output logic [1:0]                      ifu_axi_awburst,
   output logic                            ifu_axi_awlock,
   output logic [3:0]                      ifu_axi_awcache,
   output logic [2:0]                      ifu_axi_awprot,
   output logic [3:0]                      ifu_axi_awqos,

   output logic                            ifu_axi_wvalid,
   input  logic                            ifu_axi_wready,
   output logic [63:0]                     ifu_axi_wdata,
   output logic [7:0]                      ifu_axi_wstrb,
   output logic                            ifu_axi_wlast,

   input  logic                            ifu_axi_bvalid,
   output logic                            ifu_axi_bready,
   input  logic [1:0]                      ifu_axi_bresp,
   input  logic [pt.IFU_BUS_TAG-1:0]       ifu_axi_bid,

   // AXI Read Channels
   output logic                            ifu_axi_arvalid,
   input  logic                            ifu_axi_arready,
   output logic [pt.IFU_BUS_TAG-1:0]       ifu_axi_arid,
   output logic [31:0]                     ifu_axi_araddr,
   output logic [3:0]                      ifu_axi_arregion,
   output logic [7:0]                      ifu_axi_arlen,
   output logic [2:0]                      ifu_axi_arsize,
   output logic [1:0]                      ifu_axi_arburst,
   output logic                            ifu_axi_arlock,
   output logic [3:0]                      ifu_axi_arcache,
   output logic [2:0]                      ifu_axi_arprot,
   output logic [3:0]                      ifu_axi_arqos,

   input  logic                            ifu_axi_rvalid,
   output logic                            ifu_axi_rready,
   input  logic [pt.IFU_BUS_TAG-1:0]       ifu_axi_rid,
   input  logic [63:0]                     ifu_axi_rdata,
   input  logic [1:0]                      ifu_axi_rresp,
   input  logic                            ifu_axi_rlast,

   //-------------------------- SB AXI signals--------------------------
   // AXI Write Channels
   output logic                            sb_axi_awvalid,
   input  logic                            sb_axi_awready,
   output logic [pt.SB_BUS_TAG-1:0]        sb_axi_awid,
   output logic [31:0]                     sb_axi_awaddr,
   output logic [3:0]                      sb_axi_awregion,
   output logic [7:0]                      sb_axi_awlen,
   output logic [2:0]                      sb_axi_awsize,
   output logic [1:0]                      sb_axi_awburst,
   output logic                            sb_axi_awlock,
   output logic [3:0]                      sb_axi_awcache,
   output logic [2:0]                      sb_axi_awprot,
   output logic [3:0]                      sb_axi_awqos,

   output logic                            sb_axi_wvalid,
   input  logic                            sb_axi_wready,
   output logic [63:0]                     sb_axi_wdata,
   output logic [7:0]                      sb_axi_wstrb,
   output logic                            sb_axi_wlast,

   input  logic                            sb_axi_bvalid,
   output logic                            sb_axi_bready,
   input  logic [1:0]                      sb_axi_bresp,
   input  logic [pt.SB_BUS_TAG-1:0]        sb_axi_bid,

   // AXI Read Channels
   output logic                            sb_axi_arvalid,
   input  logic                            sb_axi_arready,
   output logic [pt.SB_BUS_TAG-1:0]        sb_axi_arid,
   output logic [31:0]                     sb_axi_araddr,
   output logic [3:0]                      sb_axi_arregion,
   output logic [7:0]                      sb_axi_arlen,
   output logic [2:0]                      sb_axi_arsize,
   output logic [1:0]                      sb_axi_arburst,
   output logic                            sb_axi_arlock,
   output logic [3:0]                      sb_axi_arcache,
   output logic [2:0]                      sb_axi_arprot,
   output logic [3:0]                      sb_axi_arqos,

   input  logic                            sb_axi_rvalid,
   output logic                            sb_axi_rready,
   input  logic [pt.SB_BUS_TAG-1:0]        sb_axi_rid,
   input  logic [63:0]                     sb_axi_rdata,
   input  logic [1:0]                      sb_axi_rresp,
   input  logic                            sb_axi_rlast,

   //-------------------------- DMA AXI signals--------------------------
   // AXI Write Channels
   input  logic                         dma_axi_awvalid,
   output logic                         dma_axi_awready,
   input  logic [pt.DMA_BUS_TAG-1:0]    dma_axi_awid,
   input  logic [31:0]                  dma_axi_awaddr,
   input  logic [2:0]                   dma_axi_awsize,
   input  logic [2:0]                   dma_axi_awprot,
   input  logic [7:0]                   dma_axi_awlen,
   input  logic [1:0]                   dma_axi_awburst,


   input  logic                         dma_axi_wvalid,
   output logic                         dma_axi_wready,
   input  logic [63:0]                  dma_axi_wdata,
   input  logic [7:0]                   dma_axi_wstrb,
   input  logic                         dma_axi_wlast,

   output logic                         dma_axi_bvalid,
   input  logic                         dma_axi_bready,
   output logic [1:0]                   dma_axi_bresp,
   output logic [pt.DMA_BUS_TAG-1:0]    dma_axi_bid,

   // AXI Read Channels
   input  logic                         dma_axi_arvalid,
   output logic                         dma_axi_arready,
   input  logic [pt.DMA_BUS_TAG-1:0]    dma_axi_arid,
   input  logic [31:0]                  dma_axi_araddr,
   input  logic [2:0]                   dma_axi_arsize,
   input  logic [2:0]                   dma_axi_arprot,
   input  logic [7:0]                   dma_axi_arlen,
   input  logic [1:0]                   dma_axi_arburst,

   output logic                         dma_axi_rvalid,
   input  logic                         dma_axi_rready,
   output logic [pt.DMA_BUS_TAG-1:0]    dma_axi_rid,
   output logic [63:0]                  dma_axi_rdata,
   output logic [1:0]                   dma_axi_rresp,
   output logic                         dma_axi_rlast,

`endif


`ifdef RV_BUILD_AHB_LITE
 //// AHB LITE BUS
   output logic [31:0]               haddr,
   output logic [2:0]                hburst,
   output logic                      hmastlock,
   output logic [3:0]                hprot,
   output logic [2:0]                hsize,
   output logic [1:0]                htrans,
   output logic                      hwrite,

   input logic [63:0]                hrdata,
   input logic                       hready,
   input logic                       hresp,

   // LSU AHB Master
   output logic [31:0]               lsu_haddr,
   output logic [2:0]                lsu_hburst,
   output logic                      lsu_hmastlock,
   output logic [3:0]                lsu_hprot,
   output logic [2:0]                lsu_hsize,
   output logic [1:0]                lsu_htrans,
   output logic                      lsu_hwrite,
   output logic [63:0]               lsu_hwdata,

   input logic [63:0]                lsu_hrdata,
   input logic                       lsu_hready,
   input logic                       lsu_hresp,
   // Debug Syster Bus AHB
   output logic [31:0]               sb_haddr,
   output logic [2:0]                sb_hburst,
   output logic                      sb_hmastlock,
   output logic [3:0]                sb_hprot,
   output logic [2:0]                sb_hsize,
   output logic [1:0]                sb_htrans,
   output logic                      sb_hwrite,
   output logic [63:0]               sb_hwdata,

   input  logic [63:0]               sb_hrdata,
   input  logic                      sb_hready,
   input  logic                      sb_hresp,

   // DMA Slave
   input logic                       dma_hsel,
   input logic [31:0]                dma_haddr,
   input logic [2:0]                 dma_hburst,
   input logic                       dma_hmastlock,
   input logic [3:0]                 dma_hprot,
   input logic [2:0]                 dma_hsize,
   input logic [1:0]                 dma_htrans,
   input logic                       dma_hwrite,
   input logic [63:0]                dma_hwdata,
   input logic                       dma_hreadyin,

   output logic [63:0]               dma_hrdata,
   output logic                      dma_hreadyout,
   output logic                      dma_hresp,

`endif


   // clk ratio signals
   input logic                       lsu_bus_clk_en, // Clock ratio b/w cpu core clk & AHB master interface
   input logic                       ifu_bus_clk_en, // Clock ratio b/w cpu core clk & AHB master interface
   input logic                       dbg_bus_clk_en, // Clock ratio b/w cpu core clk & AHB master interface
   input logic                       dma_bus_clk_en, // Clock ratio b/w cpu core clk & AHB slave interface

   input  logic                      timer_int,
   input  logic [7:0]                extintsrc_req,

   output logic                      dec_tlu_perfcnt0,
   output logic                      dec_tlu_perfcnt1,
   output logic                      dec_tlu_perfcnt2,
   output logic                      dec_tlu_perfcnt3,

   // DMI is supplied by the VeeRwolf board-level external JTAG transport.
   input  logic                      dmi_reg_en,
   input  logic [6:0]                dmi_reg_addr,
   input  logic                      dmi_reg_wr_en,
   input  logic [31:0]               dmi_reg_wdata,
   output logic [31:0]               dmi_reg_rdata,
   input  logic                      dmi_hard_reset,


   // external MPC halt/run interface
   input  logic                      mpc_debug_halt_req,
   input  logic                      mpc_debug_run_req,
   input  logic                      mpc_reset_run_req,
   output logic                      mpc_debug_halt_ack,
   output logic                      mpc_debug_run_ack,
   output logic                      debug_brkpt_status,

   output logic                      dec_tlu_mhartstart,

   input  logic                      i_cpu_halt_req,
   output logic                      o_cpu_halt_ack,
   output logic                      o_cpu_halt_status,
   output logic                      o_debug_mode_status,
   input  logic                      i_cpu_run_req,
   output logic                      o_cpu_run_ack,
   input logic                       scan_mode, // To enable scan mode
   input logic                       mbist_mode // to enable mbist
);

   // VeeRwolf does not expose the MBIST test packets at SoC level.
   eh2_dccm_ext_in_pkt_t [pt.DCCM_NUM_BANKS-1:0] dccm_ext_in_pkt;
   eh2_ccm_ext_in_pkt_t [pt.ICCM_NUM_BANKS/4-1:0][1:0][1:0] iccm_ext_in_pkt;
   eh2_ccm_ext_in_pkt_t [1:0] btb_ext_in_pkt;
   eh2_ic_data_ext_in_pkt_t [pt.ICACHE_NUM_WAYS-1:0][pt.ICACHE_BANKS_WAY-1:0] ic_data_ext_in_pkt;
   eh2_ic_tag_ext_in_pkt_t [pt.ICACHE_NUM_WAYS-1:0] ic_tag_ext_in_pkt;

   logic [pt.NUM_THREADS-1:0] timer_int_core;
   logic [pt.NUM_THREADS-1:0] soft_int;
   logic [pt.PIC_TOTAL_INT:1] extintsrc_req_core;
   logic [31:4] core_id;

   logic [pt.NUM_THREADS-1:0][63:0] trace_rv_i_insn_core;
   logic [pt.NUM_THREADS-1:0][63:0] trace_rv_i_address_core;
   logic [pt.NUM_THREADS-1:0][1:0]  trace_rv_i_valid_core;
   logic [pt.NUM_THREADS-1:0][1:0]  trace_rv_i_exception_core;
   logic [pt.NUM_THREADS-1:0][4:0]  trace_rv_i_ecause_core;
   logic [pt.NUM_THREADS-1:0][1:0]  trace_rv_i_interrupt_core;
   logic [pt.NUM_THREADS-1:0][31:0] trace_rv_i_tval_core;

   logic [pt.NUM_THREADS-1:0][1:0] dec_tlu_perfcnt0_core;
   logic [pt.NUM_THREADS-1:0][1:0] dec_tlu_perfcnt1_core;
   logic [pt.NUM_THREADS-1:0][1:0] dec_tlu_perfcnt2_core;
   logic [pt.NUM_THREADS-1:0][1:0] dec_tlu_perfcnt3_core;
   logic [pt.NUM_THREADS-1:0] mpc_debug_halt_req_core;
   logic [pt.NUM_THREADS-1:0] mpc_debug_run_req_core;
   logic [pt.NUM_THREADS-1:0] mpc_reset_run_req_core;
   logic [pt.NUM_THREADS-1:0] mpc_debug_halt_ack_core;
   logic [pt.NUM_THREADS-1:0] mpc_debug_run_ack_core;
   logic [pt.NUM_THREADS-1:0] debug_brkpt_status_core;
   logic [pt.NUM_THREADS-1:0] dec_tlu_mhartstart_core;
   logic [pt.NUM_THREADS-1:0] i_cpu_halt_req_core;
   logic [pt.NUM_THREADS-1:0] o_cpu_halt_ack_core;
   logic [pt.NUM_THREADS-1:0] o_cpu_halt_status_core;
   logic [pt.NUM_THREADS-1:0] o_debug_mode_status_core;
   logic [pt.NUM_THREADS-1:0] i_cpu_run_req_core;
   logic [pt.NUM_THREADS-1:0] o_cpu_run_ack_core;

   assign dccm_ext_in_pkt  = '0;
   assign iccm_ext_in_pkt  = '0;
   assign btb_ext_in_pkt   = '0;
   assign ic_data_ext_in_pkt = '0;
   assign ic_tag_ext_in_pkt  = '0;
   // VeeRwolf provides one platform timer interrupt.  EH2 permits the two
   // per-hart timer inputs to be tied together, so make the shared interrupt
   // visible to both harts.  Each hart still masks it independently with mtie.
   assign timer_int_core = {pt.NUM_THREADS{timer_int}};
   assign soft_int = '0;
   assign extintsrc_req_core = {{(pt.PIC_TOTAL_INT-8){1'b0}}, extintsrc_req};
   assign core_id  = '0;

   // The upstream VeeRwolf wrapper exposes scalar PMU/MPC controls.  Apply
   // those controls to every instantiated EH2 hart.  In particular, the EH2
   // PRM requires every unused mpc_reset_run_req input to be tied high.
   assign mpc_debug_halt_req_core = {pt.NUM_THREADS{mpc_debug_halt_req}};
   assign mpc_debug_run_req_core  = {pt.NUM_THREADS{mpc_debug_run_req}};
   assign mpc_reset_run_req_core  = {pt.NUM_THREADS{mpc_reset_run_req}};
   assign i_cpu_halt_req_core     = {pt.NUM_THREADS{i_cpu_halt_req}};
   assign i_cpu_run_req_core      = {pt.NUM_THREADS{i_cpu_run_req}};

   assign dec_tlu_perfcnt0    = dec_tlu_perfcnt0_core[0][0];
   assign dec_tlu_perfcnt1    = dec_tlu_perfcnt1_core[0][0];
   assign dec_tlu_perfcnt2    = dec_tlu_perfcnt2_core[0][0];
   assign dec_tlu_perfcnt3    = dec_tlu_perfcnt3_core[0][0];
   assign mpc_debug_halt_ack  = mpc_debug_halt_ack_core[0];
   assign mpc_debug_run_ack   = mpc_debug_run_ack_core[0];
   assign debug_brkpt_status  = debug_brkpt_status_core[0];
   assign dec_tlu_mhartstart  = dec_tlu_mhartstart_core[0];
   assign o_cpu_halt_ack      = o_cpu_halt_ack_core[0];
   assign o_cpu_halt_status   = o_cpu_halt_status_core[0];
   assign o_debug_mode_status = o_debug_mode_status_core[0];
   assign o_cpu_run_ack       = o_cpu_run_ack_core[0];

   // VeeRwolf's trace port is single-hart; expose hart 0 and pad issue slot 2.
   assign trace_rv_i_insn_ip      = trace_rv_i_insn_core[0];
   assign trace_rv_i_address_ip   = trace_rv_i_address_core[0];
   assign trace_rv_i_valid_ip     = {1'b0, trace_rv_i_valid_core[0]};
   assign trace_rv_i_exception_ip = {1'b0, trace_rv_i_exception_core[0]};
   assign trace_rv_i_ecause_ip    = trace_rv_i_ecause_core[0];
   assign trace_rv_i_interrupt_ip = {1'b0, trace_rv_i_interrupt_core[0]};
   assign trace_rv_i_tval_ip      = trace_rv_i_tval_core[0];

   // DMI hard reset resets only the external DTM; the core DM reset is dbg_rst_l.
   logic unused_dmi_hard_reset;
   assign unused_dmi_hard_reset = dmi_hard_reset;

   // DCCM ports
   logic         dccm_wren;
   logic         dccm_rden;
   logic [pt.DCCM_BITS-1:0]  dccm_wr_addr_lo;
   logic [pt.DCCM_BITS-1:0]  dccm_wr_addr_hi;
   logic [pt.DCCM_BITS-1:0]  dccm_rd_addr_lo;
   logic [pt.DCCM_BITS-1:0]  dccm_rd_addr_hi;
   logic [pt.DCCM_FDATA_WIDTH-1:0]  dccm_wr_data_lo;
   logic [pt.DCCM_FDATA_WIDTH-1:0]  dccm_wr_data_hi;

   logic [pt.DCCM_FDATA_WIDTH-1:0]  dccm_rd_data_lo;
   logic [pt.DCCM_FDATA_WIDTH-1:0]  dccm_rd_data_hi;

   // PIC ports

   // Icache & Itag ports
   logic [31:1]  ic_rw_addr;
   logic [pt.ICACHE_NUM_WAYS-1:0]   ic_wr_en  ;     // Which way to write
   logic         ic_rd_en ;


   logic [pt.ICACHE_NUM_WAYS-1:0]   ic_tag_valid;   // Valid from the I$ tag valid outside (in flops).

   logic [pt.ICACHE_NUM_WAYS-1:0]   ic_rd_hit;
   logic         ic_tag_perr;    // Ic tag parity error

   logic [pt.ICACHE_INDEX_HI:3]  ic_debug_addr;      // Read/Write addresss to the Icache.
   logic         ic_debug_rd_en;     // Icache debug rd
   logic         ic_debug_wr_en;     // Icache debug wr
   logic         ic_debug_tag_array; // Debug tag array
   logic [pt.ICACHE_NUM_WAYS-1:0]   ic_debug_way;       // Debug way. Rd or Wr.

   logic [pt.ICACHE_BANKS_WAY-1:0] [70:0] ic_wr_data;           // Data to fill to the Icache. With ECC
   logic [63:0]                           ic_rd_data;          // Data read from Icache. 2x64bits + parity bits. F2 stage. With ECC
   logic [70:0]                           ic_debug_rd_data;    // Data read from Icache. 2x64bits + parity bits. F2 stage. With ECC
   logic [25:0]                           ictag_debug_rd_data;  // Debug icache tag.
   logic [70:0]                           ic_debug_wr_data;     // Debug wr cache.
   logic [pt.ICACHE_BANKS_WAY-1:0]        ic_eccerr;
    //
   logic [pt.ICACHE_BANKS_WAY-1:0]        ic_parerr;


   logic [63:0]  ic_premux_data;
   logic         ic_sel_premux_data;

   // ICCM ports
   logic [pt.ICCM_BITS-1:1]  iccm_rw_addr;
   logic [pt.NUM_THREADS-1:0]iccm_buf_correct_ecc_thr;                // ICCM is doing a single bit error correct cycle
   logic                     iccm_correction_state, iccm_corr_scnd_fetch;
   logic                     iccm_stop_fetch;                     // ICCM hits need to ignored for replacement purposes as we have fetched ahead.. dont want to stop fetch through dma_active as it causes timing issues there

   logic           ifc_select_tid_f1;
   logic           iccm_wren;
   logic           iccm_rden;
   logic [2:0]     iccm_wr_size;
   logic [77:0]    iccm_wr_data;
   logic [63:0]    iccm_rd_data;
   logic [116:0]   iccm_rd_data_ecc;

   // BTB
   eh2_btb_sram_pkt btb_sram_pkt;
   logic [pt.BTB_TOFFSET_SIZE+pt.BTB_BTAG_SIZE+5-1:0] btb_vbank0_rd_data_f1;
   logic [pt.BTB_TOFFSET_SIZE+pt.BTB_BTAG_SIZE+5-1:0] btb_vbank1_rd_data_f1;
   logic [pt.BTB_TOFFSET_SIZE+pt.BTB_BTAG_SIZE+5-1:0] btb_vbank2_rd_data_f1;
   logic [pt.BTB_TOFFSET_SIZE+pt.BTB_BTAG_SIZE+5-1:0] btb_vbank3_rd_data_f1;
   logic                                              btb_wren;
   logic                                              btb_rden;
   logic [1:0] [pt.BTB_ADDR_HI:1]             btb_rw_addr;  // per bank
   logic [1:0] [pt.BTB_ADDR_HI:1]             btb_rw_addr_f1;  // per bank
   logic [pt.BTB_TOFFSET_SIZE+pt.BTB_BTAG_SIZE+5-1:0] btb_sram_wr_data;
   logic [1:0] [pt.BTB_BTAG_SIZE-1:0]                 btb_sram_rd_tag_f1;

   logic           active_l2clk;
   logic           free_l2clk;

   logic        core_rst_l;     // Core reset including rst_l and dbg_rst_l

   logic        dccm_clk_override;
   logic        icm_clk_override;
   logic        dec_tlu_core_ecc_disable;
   logic        btb_clk_override;

   // zero out the signals not presented at the wrapper instantiation level
`ifdef RV_BUILD_AXI4

 //// AHB LITE BUS
   logic [31:0]                 haddr;
   logic [2:0]                  hburst;
   logic                        hmastlock;
   logic [3:0]                  hprot;
   logic [2:0]                  hsize;
   logic [1:0]                  htrans;
   logic                        hwrite;

   logic [63:0]                 hrdata;
   logic                        hready;
   logic                        hresp;

   // LSU AHB Master
   logic [31:0]                 lsu_haddr;
   logic [2:0]                  lsu_hburst;
   logic                        lsu_hmastlock;
   logic [3:0]                  lsu_hprot;
   logic [2:0]                  lsu_hsize;
   logic [1:0]                  lsu_htrans;
   logic                        lsu_hwrite;
   logic [63:0]                 lsu_hwdata;

   logic [63:0]                 lsu_hrdata;
   logic                        lsu_hready;
   logic                        lsu_hresp;

   // Debug Syster Bus AHB
   logic [31:0]                 sb_haddr;
   logic [2:0]                  sb_hburst;
   logic                        sb_hmastlock;
   logic [3:0]                  sb_hprot;
   logic [2:0]                  sb_hsize;
   logic [1:0]                  sb_htrans;
   logic                        sb_hwrite;
   logic [63:0]                 sb_hwdata;

   logic [63:0]                 sb_hrdata;
   logic                        sb_hready;
   logic                        sb_hresp;

   // DMA Slave
   logic                        dma_hsel;
   logic [31:0]                 dma_haddr;
   logic [2:0]                  dma_hburst;
   logic                        dma_hmastlock;
   logic [3:0]                  dma_hprot;
   logic [2:0]                  dma_hsize;
   logic [1:0]                  dma_htrans;
   logic                        dma_hwrite;
   logic [63:0]                 dma_hwdata;
   logic                        dma_hreadyin;

   logic [63:0]                 dma_hrdata;
   logic                        dma_hreadyout;
   logic                        dma_hresp;

   // IFU
   assign  hrdata[63:0]                           = '0;
   assign  hready                                 = '0;
   assign  hresp                                  = '0;
   // LSU
   assign  lsu_hrdata[63:0]                       = '0;
   assign  lsu_hready                             = '0;
   assign  lsu_hresp                              = '0;
   // SB
   assign  sb_hrdata[63:0]                        = '0;
   assign  sb_hready                              = '0;
   assign  sb_hresp                               = '0;

   // DMA
   assign  dma_hsel                               = '0;
   assign  dma_haddr[31:0]                        = '0;
   assign  dma_hburst[2:0]                        = '0;
   assign  dma_hmastlock                          = '0;
   assign  dma_hprot[3:0]                         = '0;
   assign  dma_hsize[2:0]                         = '0;
   assign  dma_htrans[1:0]                        = '0;
   assign  dma_hwrite                             = '0;
   assign  dma_hwdata[63:0]                       = '0;
   assign  dma_hreadyin                           = '0;

`endif //  `ifdef RV_BUILD_AXI4


`ifdef RV_BUILD_AHB_LITE
   logic                           lsu_axi_awvalid;
   logic                           lsu_axi_awready;
   logic [pt.LSU_BUS_TAG-1:0]      lsu_axi_awid;
   logic [31:0]                    lsu_axi_awaddr;
   logic [3:0]                     lsu_axi_awregion;
   logic [7:0]                     lsu_axi_awlen;
   logic [2:0]                     lsu_axi_awsize;
   logic [1:0]                     lsu_axi_awburst;
   logic                           lsu_axi_awlock;
   logic [3:0]                     lsu_axi_awcache;
   logic [2:0]                     lsu_axi_awprot;
   logic [3:0]                     lsu_axi_awqos;

   logic                           lsu_axi_wvalid;
   logic                           lsu_axi_wready;
   logic [63:0]                    lsu_axi_wdata;
   logic [7:0]                     lsu_axi_wstrb;
   logic                           lsu_axi_wlast;

   logic                           lsu_axi_bvalid;
   logic                           lsu_axi_bready;
   logic [1:0]                     lsu_axi_bresp;
   logic [pt.LSU_BUS_TAG-1:0]      lsu_axi_bid;

   // AXI Read Channels
   logic                           lsu_axi_arvalid;
   logic                           lsu_axi_arready;
   logic [pt.LSU_BUS_TAG-1:0]      lsu_axi_arid;
   logic [31:0]                    lsu_axi_araddr;
   logic [3:0]                     lsu_axi_arregion;
   logic [7:0]                     lsu_axi_arlen;
   logic [2:0]                     lsu_axi_arsize;
   logic [1:0]                     lsu_axi_arburst;
   logic                           lsu_axi_arlock;
   logic [3:0]                     lsu_axi_arcache;
   logic [2:0]                     lsu_axi_arprot;
   logic [3:0]                     lsu_axi_arqos;

   logic                           lsu_axi_rvalid;
   logic                           lsu_axi_rready;
   logic [pt.LSU_BUS_TAG-1:0]      lsu_axi_rid;
   logic [63:0]                    lsu_axi_rdata;
   logic [1:0]                     lsu_axi_rresp;
   logic                           lsu_axi_rlast;

   //-------------------------- IFU AXI signals--------------------------
   // AXI Write Channels
   logic                           ifu_axi_awvalid;
   logic                           ifu_axi_awready;
   logic [pt.IFU_BUS_TAG-1:0]      ifu_axi_awid;
   logic [31:0]                    ifu_axi_awaddr;
   logic [3:0]                     ifu_axi_awregion;
   logic [7:0]                     ifu_axi_awlen;
   logic [2:0]                     ifu_axi_awsize;
   logic [1:0]                     ifu_axi_awburst;
   logic                           ifu_axi_awlock;
   logic [3:0]                     ifu_axi_awcache;
   logic [2:0]                     ifu_axi_awprot;
   logic [3:0]                     ifu_axi_awqos;

   logic                           ifu_axi_wvalid;
   logic                           ifu_axi_wready;
   logic [63:0]                    ifu_axi_wdata;
   logic [7:0]                     ifu_axi_wstrb;
   logic                           ifu_axi_wlast;

   logic                           ifu_axi_bvalid;
   logic                           ifu_axi_bready;
   logic [1:0]                     ifu_axi_bresp;
   logic [pt.IFU_BUS_TAG-1:0]      ifu_axi_bid;

   // AXI Read Channels
   logic                           ifu_axi_arvalid;
   logic                           ifu_axi_arready;
   logic [pt.IFU_BUS_TAG-1:0]      ifu_axi_arid;
   logic [31:0]                    ifu_axi_araddr;
   logic [3:0]                     ifu_axi_arregion;
   logic [7:0]                     ifu_axi_arlen;
   logic [2:0]                     ifu_axi_arsize;
   logic [1:0]                     ifu_axi_arburst;
   logic                           ifu_axi_arlock;
   logic [3:0]                     ifu_axi_arcache;
   logic [2:0]                     ifu_axi_arprot;
   logic [3:0]                     ifu_axi_arqos;

   logic                           ifu_axi_rvalid;
   logic                           ifu_axi_rready;
   logic [pt.IFU_BUS_TAG-1:0]      ifu_axi_rid;
   logic [63:0]                    ifu_axi_rdata;
   logic [1:0]                     ifu_axi_rresp;
   logic                           ifu_axi_rlast;

   //-------------------------- SB AXI signals--------------------------
   // AXI Write Channels
   logic                           sb_axi_awvalid;
   logic                           sb_axi_awready;
   logic [pt.SB_BUS_TAG-1:0]       sb_axi_awid;
   logic [31:0]                    sb_axi_awaddr;
   logic [3:0]                     sb_axi_awregion;
   logic [7:0]                     sb_axi_awlen;
   logic [2:0]                     sb_axi_awsize;
   logic [1:0]                     sb_axi_awburst;
   logic                           sb_axi_awlock;
   logic [3:0]                     sb_axi_awcache;
   logic [2:0]                     sb_axi_awprot;
   logic [3:0]                     sb_axi_awqos;

   logic                           sb_axi_wvalid;
   logic                           sb_axi_wready;
   logic [63:0]                    sb_axi_wdata;
   logic [7:0]                     sb_axi_wstrb;
   logic                           sb_axi_wlast;

   logic                           sb_axi_bvalid;
   logic                           sb_axi_bready;
   logic [1:0]                     sb_axi_bresp;
   logic [pt.SB_BUS_TAG-1:0]       sb_axi_bid;

   // AXI Read Channels
   logic                           sb_axi_arvalid;
   logic                           sb_axi_arready;
   logic [pt.SB_BUS_TAG-1:0]       sb_axi_arid;
   logic [31:0]                    sb_axi_araddr;
   logic [3:0]                     sb_axi_arregion;
   logic [7:0]                     sb_axi_arlen;
   logic [2:0]                     sb_axi_arsize;
   logic [1:0]                     sb_axi_arburst;
   logic                           sb_axi_arlock;
   logic [3:0]                     sb_axi_arcache;
   logic [2:0]                     sb_axi_arprot;
   logic [3:0]                     sb_axi_arqos;

   logic                           sb_axi_rvalid;
   logic                           sb_axi_rready;
   logic [pt.SB_BUS_TAG-1:0]       sb_axi_rid;
   logic [63:0]                    sb_axi_rdata;
   logic [1:0]                     sb_axi_rresp;
   logic                           sb_axi_rlast;

   //-------------------------- DMA AXI signals--------------------------
   // AXI Write Channels
   logic                           dma_axi_awvalid;
   logic                           dma_axi_awready;
   logic [pt.DMA_BUS_TAG-1:0]      dma_axi_awid;
   logic [31:0]                    dma_axi_awaddr;
   logic [2:0]                     dma_axi_awsize;
   logic [2:0]                     dma_axi_awprot;
   logic [7:0]                     dma_axi_awlen;
   logic [1:0]                     dma_axi_awburst;


   logic                           dma_axi_wvalid;
   logic                           dma_axi_wready;
   logic [63:0]                    dma_axi_wdata;
   logic [7:0]                     dma_axi_wstrb;
   logic                           dma_axi_wlast;

   logic                           dma_axi_bvalid;
   logic                           dma_axi_bready;
   logic [1:0]                     dma_axi_bresp;
   logic [pt.DMA_BUS_TAG-1:0]      dma_axi_bid;

   // AXI Read Channels
   logic                           dma_axi_arvalid;
   logic                           dma_axi_arready;
   logic [pt.DMA_BUS_TAG-1:0]      dma_axi_arid;
   logic [31:0]                    dma_axi_araddr;
   logic [2:0]                     dma_axi_arsize;
   logic [2:0]                     dma_axi_arprot;
   logic [7:0]                     dma_axi_arlen;
   logic [1:0]                     dma_axi_arburst;

   logic                           dma_axi_rvalid;
   logic                           dma_axi_rready;
   logic [pt.DMA_BUS_TAG-1:0]      dma_axi_rid;
   logic [63:0]                    dma_axi_rdata;
   logic [1:0]                     dma_axi_rresp;
   logic                           dma_axi_rlast;

   // LSU AXI
   assign lsu_axi_awready                         = '0;
   assign lsu_axi_wready                          = '0;
   assign lsu_axi_bvalid                          = '0;
   assign lsu_axi_bresp[1:0]                      = '0;
   assign lsu_axi_bid[pt.LSU_BUS_TAG-1:0]         = '0;

   assign lsu_axi_arready                         = '0;
   assign lsu_axi_rvalid                          = '0;
   assign lsu_axi_rid[pt.LSU_BUS_TAG-1:0]         = '0;
   assign lsu_axi_rdata[63:0]                     = '0;
   assign lsu_axi_rresp[1:0]                      = '0;
   assign lsu_axi_rlast                           = '0;

   // IFU AXI
   assign ifu_axi_awready                         = '0;
   assign ifu_axi_wready                          = '0;
   assign ifu_axi_bvalid                          = '0;
   assign ifu_axi_bresp[1:0]                      = '0;
   assign ifu_axi_bid[pt.IFU_BUS_TAG-1:0]         = '0;

   assign ifu_axi_arready                         = '0;
   assign ifu_axi_rvalid                          = '0;
   assign ifu_axi_rid[pt.IFU_BUS_TAG-1:0]         = '0;
   assign ifu_axi_rdata[63:0]                     = '0;
   assign ifu_axi_rresp[1:0]                      = '0;
   assign ifu_axi_rlast                           = '0;

   // Debug AXI
   assign sb_axi_awready                          = '0;
   assign sb_axi_wready                           = '0;
   assign sb_axi_bvalid                           = '0;
   assign sb_axi_bresp[1:0]                       = '0;
   assign sb_axi_bid[pt.SB_BUS_TAG-1:0]           = '0;

   assign sb_axi_arready                          = '0;
   assign sb_axi_rvalid                           = '0;
   assign sb_axi_rid[pt.SB_BUS_TAG-1:0]           = '0;
   assign sb_axi_rdata[63:0]                      = '0;
   assign sb_axi_rresp[1:0]                       = '0;
   assign sb_axi_rlast                            = '0;

   // DMA AXI
   assign  dma_axi_awvalid = '0;
   assign  dma_axi_awid[pt.DMA_BUS_TAG-1:0]       = '0;
   assign  dma_axi_awaddr[31:0]                   = '0;
   assign  dma_axi_awsize[2:0]                    = '0;
   assign  dma_axi_awprot[2:0]                    = '0;
   assign  dma_axi_awlen[7:0]                     = '0;
   assign  dma_axi_awburst[1:0]                   = '0;

   assign  dma_axi_wvalid                         = '0;
   assign  dma_axi_wdata[63:0]                    = '0;
   assign  dma_axi_wstrb[7:0]                     = '0;
   assign  dma_axi_wlast                          = '0;

   assign  dma_axi_bready                         = '0;

   assign  dma_axi_arvalid                        = '0;
   assign  dma_axi_arid[pt.DMA_BUS_TAG-1:0]       = '0;
   assign  dma_axi_araddr[31:0]                   = '0;
   assign  dma_axi_arsize[2:0]                    = '0;
   assign  dma_axi_arprot[2:0]                    = '0;
   assign  dma_axi_arlen[7:0]                     = '0;
   assign  dma_axi_arburst[1:0]                   = '0;

   assign  dma_axi_rready                         = '0;

`endif //  `ifdef RV_BUILD_AHB_LITE

   // Instantiate the eh2_swerv core
   eh2_swerv #(.pt(pt)) swerv (
                                .timer_int               (timer_int_core),
                                .soft_int                (soft_int),
                                .extintsrc_req           (extintsrc_req_core),
                                .dec_tlu_perfcnt0        (dec_tlu_perfcnt0_core),
                                .dec_tlu_perfcnt1        (dec_tlu_perfcnt1_core),
                                .dec_tlu_perfcnt2        (dec_tlu_perfcnt2_core),
                                .dec_tlu_perfcnt3        (dec_tlu_perfcnt3_core),
                                .mpc_debug_halt_req      (mpc_debug_halt_req_core),
                                .mpc_debug_run_req       (mpc_debug_run_req_core),
                                .mpc_reset_run_req       (mpc_reset_run_req_core),
                                .mpc_debug_halt_ack      (mpc_debug_halt_ack_core),
                                .mpc_debug_run_ack       (mpc_debug_run_ack_core),
                                .debug_brkpt_status      (debug_brkpt_status_core),
                                .dec_tlu_mhartstart      (dec_tlu_mhartstart_core),
                                .i_cpu_halt_req          (i_cpu_halt_req_core),
                                .i_cpu_run_req           (i_cpu_run_req_core),
                                .o_cpu_halt_ack          (o_cpu_halt_ack_core),
                                .o_cpu_halt_status       (o_cpu_halt_status_core),
                                .o_debug_mode_status     (o_debug_mode_status_core),
                                .o_cpu_run_ack           (o_cpu_run_ack_core),
                                .trace_rv_i_insn_ip      (trace_rv_i_insn_core),
                                .trace_rv_i_address_ip   (trace_rv_i_address_core),
                                .trace_rv_i_valid_ip     (trace_rv_i_valid_core),
                                .trace_rv_i_exception_ip (trace_rv_i_exception_core),
                                .trace_rv_i_ecause_ip    (trace_rv_i_ecause_core),
                                .trace_rv_i_interrupt_ip (trace_rv_i_interrupt_core),
                                .trace_rv_i_tval_ip      (trace_rv_i_tval_core),
                                .*
                               );

   // Instantiate the mem
   eh2_mem #(.pt(pt)) mem (
        .clk(active_l2clk),
        .rst_l(core_rst_l),
        .*
        );

`ifdef RV_ASSERT_ON
initial begin
    $assertoff(0, swerv);
    @ (negedge clk) $asserton(0, swerv);
end
`endif

endmodule
