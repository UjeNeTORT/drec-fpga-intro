module fpga_top (
  input wire CLK,
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
wire [15:0] rnd_num;

lfsr #(.WIDTH(16)) lfsr_inst (
  .clk(CLK),
  .rst_n(rst_n),
  .i_we(1'b0),
  .i_wr(16'b0),
  .o_num(rnd_num)
);

hex_to_7seg hex_to_7seg_inst (
  .clk(CLK),
  .rst_n(rst_n),
  .i_data(rnd_num),
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
