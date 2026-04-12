module fpga_top (
  input wire CLK, // CLOCK
  input wire RST_N,
  output wire STCP, SHCP, DS, OE
);

reg rst_n, RSTN_D;

always @(posedge CLK) begin
  rst_n <= RSTN_D;
  RSTN_D <= RST_N;
end

wire [3:0] anodes;
wire [7:0] segments;

hex_to_7seg hex_to_7seg_inst (
  .clk(CLK),
  .rst_n(rst_n),
  .i_data(16'h0a0d),
  .o_anodes(anodes),
  .o_seg(segments)
);

ctrl_74hc595 ctrl(
    .clk    (CLK                ),
    .rst_n  (rst_n              ),
    .i_data ({segments, anodes} ),
    .o_stcp (STCP               ),
    .o_shcp (SHCP               ),
    .o_ds   (DS                 ),
    .o_oe   (OE                 )
);

endmodule
