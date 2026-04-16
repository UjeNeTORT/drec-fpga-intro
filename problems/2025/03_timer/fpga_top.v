module fpga_top (
  input wire CLK,
  input wire RSTN,
  output wire STCP, SHCP, DS, OE
);

reg rst_n, RSTN_D;
wire clk_10Hz;

wire [9:0] cnt;

wire [7:0] segments;
wire [3:0] anodes;

always @(posedge CLK) begin
  rst_n <= RSTN_D;
  RSTN_D <= RSTN;
end

clkdiv #(.F0(50_000_000), .F1(10)) clkdiv_inst (
  .clk(CLK),
  .rst_n(rst_n),
  .out(clk_10Hz)
);

counter #(.CNT_FROM(600), .CNT_TO(0)) counter_inst (
  .clk(clk_10Hz),
  .rst_n(rst_n),
  .out(cnt)
);

hex_to_7seg hex_to_7seg_inst (
  .clk(CLK),
  .rst_n(rst_n),
  .i_data(cnt),
  .o_anodes(anodes),
  .o_seg(segments)
);

ctrl_74hc595 ctrl_74hc595_inst (
    .clk    (CLK                ),
    .rst_n  (rst_n              ),
    .i_data ({segments, anodes} ),
    .o_stcp (STCP               ),
    .o_shcp (SHCP               ),
    .o_ds   (DS                 ),
    .o_oe   (OE                 )
);

endmodule
