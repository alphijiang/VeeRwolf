// SPDX-License-Identifier: Apache-2.0
// Copyright 2019 Western Digital Corporation or its affiliates.
//
// Genesys 2 top-level using the same LiteDRAM integration pattern as upstream
// VeeRwolf: AXI64 in the core clock domain -> PULP axi_cdc_intf -> AXI64 in
// LiteDRAM user_clk domain -> generated LiteDRAM core.

`default_nettype none
module veerwolf_genesys2
  #(parameter bootrom_file = "bootloader.vh",
    parameter cpu_type = "EH1")
   (input wire         sysclk_p,
    input wire         sysclk_n,
    input wire         cpu_resetn,
    input wire         i_jtag_tck,
    input wire         i_jtag_tms,
    input wire         i_jtag_tdi,
    output wire        o_jtag_tdo,
    output wire [14:0] ddram_a,
    output wire [2:0]  ddram_ba,
    output wire        ddram_ras_n,
    output wire        ddram_cas_n,
    output wire        ddram_we_n,
    output wire        ddram_cs_n,
    output wire [3:0]  ddram_dm,
    inout wire [31:0]  ddram_dq,
    inout wire [3:0]   ddram_dqs_p,
    inout wire [3:0]   ddram_dqs_n,
    output wire        ddram_clk_p,
    output wire        ddram_clk_n,
    output wire        ddram_cke,
    output wire        ddram_odt,
    output wire        ddram_reset_n,
    output wire        o_flash_cs_n,
    output wire        o_flash_mosi,
    input wire         i_flash_miso,
    input wire         i_uart_rx,
    output wire        o_uart_tx,
    input wire [7:0]   i_sw,
    output reg [7:0]   o_led);

   wire [63:0] gpio_out;
   reg [7:0] led_int_r;
   (* ASYNC_REG = "TRUE", SHREG_EXTRACT = "NO" *) reg [7:0] sw_r  = 8'd0;
   (* ASYNC_REG = "TRUE", SHREG_EXTRACT = "NO" *) reg [7:0] sw_2r = 8'd0;

   wire cpu_tx;
   wire litedram_tx;
   wire flash_sclk;

   // Genesys 2 provides a 200 MHz differential system clock.
   wire clk200;
   IBUFDS
     #(.DIFF_TERM("FALSE"),
       .IBUF_LOW_PWR("TRUE"),
       .IOSTANDARD("LVDS"))
   sysclk_ibuf
     (.I  (sysclk_p),
      .IB (sysclk_n),
      .O  (clk200));

   wire user_clk;
   wire user_rst;
   wire litedram_init_done;
   wire litedram_init_error;

   wire clk_core;
   wire rst_core;
   wire soc_resetn = ~rst_core;

   // Preserve the V53-proven reset discipline.  R19 is the asynchronous reset
   // source; LiteDRAM user_rst is synchronized as a core-domain hold request.
   clk_gen_genesys2
     #(.CPU_TYPE(cpu_type))
   clk_gen
     (.i_clk      (user_clk),
      .i_rst      (~cpu_resetn),
      .i_hold_rst (user_rst),
      .o_clk_core (clk_core),
      .o_rst_core (rst_core));

   // Synchronize LiteDRAM training status into the VeeRwolf/core domain.
   (* ASYNC_REG = "TRUE", SHREG_EXTRACT = "NO" *) reg [1:0] litedram_init_done_sync  = 2'b00;
   (* ASYNC_REG = "TRUE", SHREG_EXTRACT = "NO" *) reg [1:0] litedram_init_error_sync = 2'b00;
   always @(posedge clk_core or negedge soc_resetn) begin
      if (!soc_resetn) begin
         litedram_init_done_sync  <= 2'b00;
         litedram_init_error_sync <= 2'b00;
      end else begin
         litedram_init_done_sync  <= {litedram_init_done_sync[0],  litedram_init_done};
         litedram_init_error_sync <= {litedram_init_error_sync[0], litedram_init_error};
      end
   end

   // Match upstream VeeRwolf LiteDRAM topology and bus widths.
   AXI_BUS #(32, 64, 6, 1) mem();
   AXI_BUS #(32, 64, 6, 1) cpu();

   assign cpu.aw_atop = 6'd0;
   assign cpu.aw_user = 1'b0;
   assign cpu.ar_user = 1'b0;
   assign cpu.w_user  = 1'b0;
   assign cpu.b_user  = 1'b0;
   assign cpu.r_user  = 1'b0;
   assign mem.b_user  = 1'b0;
   assign mem.r_user  = 1'b0;

   axi_cdc_intf
     #(.AXI_USER_WIDTH (1),
       .AXI_ADDR_WIDTH (32),
       .AXI_DATA_WIDTH (64),
       .AXI_ID_WIDTH   (6))
   axi_cdc
     (.src_clk_i  (clk_core),
      .src_rst_ni (soc_resetn),
      .src        (cpu),
      .dst_clk_i  (user_clk),
      .dst_rst_ni (~user_rst),
      .dst        (mem));

   // The generated LiteDRAM core owns block_until_ready, AXI2Native and the
   // internal NativePort width conversion.  Keep the SoC-facing AXI at D64.
   litedram_genesys2_top
     #(.ID_WIDTH(6))
   ddr2
     (.serial_tx    (litedram_tx),
      .serial_rx    (i_uart_rx),
      .clk200       (clk200),
      .rst_n        (cpu_resetn),
      .pll_locked   (),
      .user_clk     (user_clk),
      .user_rst     (user_rst),
      .ddram_a      (ddram_a),
      .ddram_ba     (ddram_ba),
      .ddram_ras_n  (ddram_ras_n),
      .ddram_cas_n  (ddram_cas_n),
      .ddram_we_n   (ddram_we_n),
      .ddram_cs_n   (ddram_cs_n),
      .ddram_dm     (ddram_dm),
      .ddram_dq     (ddram_dq),
      .ddram_dqs_p  (ddram_dqs_p),
      .ddram_dqs_n  (ddram_dqs_n),
      .ddram_clk_p  (ddram_clk_p),
      .ddram_clk_n  (ddram_clk_n),
      .ddram_cke    (ddram_cke),
      .ddram_odt    (ddram_odt),
      .ddram_reset_n(ddram_reset_n),
      .init_done    (litedram_init_done),
      .init_error   (litedram_init_error),
      .i_awid       (mem.aw_id),
      .i_awaddr     (mem.aw_addr[29:0]),
      .i_awlen      (mem.aw_len),
      .i_awsize     (mem.aw_size),
      .i_awburst    (mem.aw_burst),
      .i_awvalid    (mem.aw_valid),
      .o_awready    (mem.aw_ready),
      .i_arid       (mem.ar_id),
      .i_araddr     (mem.ar_addr[29:0]),
      .i_arlen      (mem.ar_len),
      .i_arsize     (mem.ar_size),
      .i_arburst    (mem.ar_burst),
      .i_arvalid    (mem.ar_valid),
      .o_arready    (mem.ar_ready),
      .i_wdata      (mem.w_data),
      .i_wstrb      (mem.w_strb),
      .i_wlast      (mem.w_last),
      .i_wvalid     (mem.w_valid),
      .o_wready     (mem.w_ready),
      .o_bid        (mem.b_id),
      .o_bresp      (mem.b_resp),
      .o_bvalid     (mem.b_valid),
      .i_bready     (mem.b_ready),
      .o_rid        (mem.r_id),
      .o_rdata      (mem.r_data),
      .o_rresp      (mem.r_resp),
      .o_rlast      (mem.r_last),
      .o_rvalid     (mem.r_valid),
      .i_rready     (mem.r_ready));

   wire        dmi_reg_en;
   wire [6:0]  dmi_reg_addr;
   wire        dmi_reg_wr_en;
   wire [31:0] dmi_reg_wdata;
   wire [31:0] dmi_reg_rdata;
   wire        dmi_hard_reset;

   STARTUPE2 STARTUPE2
     (.CFGCLK    (),
      .CFGMCLK   (),
      .EOS       (),
      .PREQ      (),
      .CLK       (1'b0),
      .GSR       (1'b0),
      .GTS       (1'b0),
      .KEYCLEARB (1'b1),
      .PACK      (1'b0),
      .USRCCLKO  (flash_sclk),
      .USRCCLKTS (1'b0),
      .USRDONEO  (1'b1),
      .USRDONETS (1'b0));

   // Direct official VeeR DMI transport. The four JTAG signals are exposed
   // at the top level for the external FT232H connection on Pmod JC.
   dmi_wrapper dmi_wrapper
     (.trst_n        (~rst_core),
      .tck           (i_jtag_tck),
      .tms           (i_jtag_tms),
      .tdi           (i_jtag_tdi),
      .tdo           (o_jtag_tdo),
      .tdoEnable     (),
      .core_rst_n    (~rst_core),
      .core_clk      (clk_core),
      .jtag_id       (31'd0),
      .rd_data       (dmi_reg_rdata),
      .reg_wr_data   (dmi_reg_wdata),
      .reg_wr_addr   (dmi_reg_addr),
      .reg_en        (dmi_reg_en),
      .reg_wr_en     (dmi_reg_wr_en),
      .dmi_hard_reset(dmi_hard_reset));

   veerwolf_core
     #(.bootrom_file (bootrom_file),
       .clk_freq_hz  ((cpu_type == "EL2") ? 32'd25_000_000 :
                      (cpu_type == "EH2") ? 32'd25_000_000 : 32'd50_000_000))
   veerwolf
     (.clk  (clk_core),
      .rstn (soc_resetn),
      .dmi_reg_rdata  (dmi_reg_rdata),
      .dmi_reg_wdata  (dmi_reg_wdata),
      .dmi_reg_addr   (dmi_reg_addr),
      .dmi_reg_en     (dmi_reg_en),
      .dmi_reg_wr_en  (dmi_reg_wr_en),
      .dmi_hard_reset (dmi_hard_reset),
      .o_flash_sclk   (flash_sclk),
      .o_flash_cs_n   (o_flash_cs_n),
      .o_flash_mosi   (o_flash_mosi),
      .i_flash_miso   (i_flash_miso),
      .i_uart_rx      (i_uart_rx),
      .o_uart_tx      (cpu_tx),
      .o_ram_awid     (cpu.aw_id),
      .o_ram_awaddr   (cpu.aw_addr),
      .o_ram_awlen    (cpu.aw_len),
      .o_ram_awsize   (cpu.aw_size),
      .o_ram_awburst  (cpu.aw_burst),
      .o_ram_awlock   (cpu.aw_lock),
      .o_ram_awcache  (cpu.aw_cache),
      .o_ram_awprot   (cpu.aw_prot),
      .o_ram_awregion (cpu.aw_region),
      .o_ram_awqos    (cpu.aw_qos),
      .o_ram_awvalid  (cpu.aw_valid),
      .i_ram_awready  (cpu.aw_ready),
      .o_ram_arid     (cpu.ar_id),
      .o_ram_araddr   (cpu.ar_addr),
      .o_ram_arlen    (cpu.ar_len),
      .o_ram_arsize   (cpu.ar_size),
      .o_ram_arburst  (cpu.ar_burst),
      .o_ram_arlock   (cpu.ar_lock),
      .o_ram_arcache  (cpu.ar_cache),
      .o_ram_arprot   (cpu.ar_prot),
      .o_ram_arregion (cpu.ar_region),
      .o_ram_arqos    (cpu.ar_qos),
      .o_ram_arvalid  (cpu.ar_valid),
      .i_ram_arready  (cpu.ar_ready),
      .o_ram_wdata    (cpu.w_data),
      .o_ram_wstrb    (cpu.w_strb),
      .o_ram_wlast    (cpu.w_last),
      .o_ram_wvalid   (cpu.w_valid),
      .i_ram_wready   (cpu.w_ready),
      .i_ram_bid      (cpu.b_id),
      .i_ram_bresp    (cpu.b_resp),
      .i_ram_bvalid   (cpu.b_valid),
      .o_ram_bready   (cpu.b_ready),
      .i_ram_rid      (cpu.r_id),
      .i_ram_rdata    (cpu.r_data),
      .i_ram_rresp    (cpu.r_resp),
      .i_ram_rlast    (cpu.r_last),
      .i_ram_rvalid   (cpu.r_valid),
      .o_ram_rready   (cpu.r_ready),
      .i_ram_init_done  (litedram_init_done_sync[1]),
      .i_ram_init_error (litedram_init_error_sync[1]),
      // VeeRwolf boot ROM reads the upper halfword of GPIO and uses bits
      // 15:14.  Place physical SW7:SW6 at overall GPIO[31:30].
      .i_gpio           ({32'd0, sw_2r, 24'd0}),
      .o_gpio           (gpio_out));

   always @(posedge clk_core) begin
      if (rst_core) begin
         sw_r      <= 8'd0;
         sw_2r     <= 8'd0;
         led_int_r <= 8'd0;
         o_led     <= 8'd0;
      end else begin
         sw_r      <= i_sw;
         sw_2r     <= sw_r;
         led_int_r <= gpio_out[7:0];
         o_led     <= led_int_r;
      end
   end

   // SW0 selects LiteDRAM training/BIOS UART; boot mode remains on SW7:SW6.
   assign o_uart_tx = sw_2r[0] ? litedram_tx : cpu_tx;

endmodule
`default_nettype wire
