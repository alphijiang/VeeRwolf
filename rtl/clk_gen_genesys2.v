// SPDX-License-Identifier: Apache-2.0
// Genesys2 core clock/reset generator.  Preserve the V53-proven reset discipline
// with LiteDRAM's 100 MHz user clock.  Keep the 1200 MHz VCO invariant:
// 100 MHz * 12 / 1 = 1200 MHz VCO; EH2 CLKOUT0 divider 48 = 25 MHz.

`default_nettype none
module clk_gen_genesys2
  #(parameter CPU_TYPE = "EH1")
   (input  wire i_clk,
    input  wire i_rst,
    input  wire i_hold_rst,
    output wire o_clk_core,
    output wire o_rst_core);

   localparam integer CORE_DIV = (CPU_TYPE == "EL2") ? 48 :
                                 (CPU_TYPE == "EH2") ? 48 : 24;

   wire clkfb;
   wire locked;

   // Only i_rst/R19 is an asynchronous assertion source.  The LiteDRAM hold
   // reset is synchronized into clk_core below and never enters the PLL reset.
   PLLE2_BASE
     #(.BANDWIDTH("OPTIMIZED"),
       .CLKFBOUT_MULT(12),
       .CLKIN1_PERIOD(10.0),
       .CLKOUT0_DIVIDE(CORE_DIV),
       .DIVCLK_DIVIDE(1),
       .STARTUP_WAIT("FALSE"))
   PLLE2_BASE_inst
     (.CLKIN1  (i_clk),
      .CLKOUT0 (o_clk_core),
      .CLKFBOUT(clkfb),
      .CLKFBIN (clkfb),
      .LOCKED  (locked),
      .PWRDWN  (1'b0),
      .RST     (1'b0));

   (* ASYNC_REG = "TRUE", SHREG_EXTRACT = "NO" *) reg [1:0] hold_rst_sync = 2'b11;
   (* ASYNC_REG = "TRUE", SHREG_EXTRACT = "NO" *) reg [2:0] reset_sync    = 3'b111;

   // i_hold_rst is a 100 MHz LiteDRAM-domain status.  It is a synchronous
   // hold request after this two-flop clk_core synchronizer.
   always @(posedge o_clk_core or posedge i_rst) begin
      if (i_rst)
        hold_rst_sync <= 2'b11;
      else
        hold_rst_sync <= {hold_rst_sync[0], i_hold_rst};
   end

   // R19 assertion is asynchronous; deassertion requires three clk_core edges.
   always @(posedge o_clk_core or posedge i_rst) begin
      if (i_rst)
        reset_sync <= 3'b111;
      else if (hold_rst_sync[1] || !locked)
        reset_sync <= 3'b111;
      else
        reset_sync <= {reset_sync[1:0], 1'b0};
   end

   assign o_rst_core = reset_sync[2];
endmodule
`default_nettype wire
