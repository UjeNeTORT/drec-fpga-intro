module fpga_top (
  input wire CLK,
  input wire RSTN,

  // uart
  input wire RXD,

  // 7 seg shift reg ctrl
  output wire STCP,
  output wire SHCP,
  output wire DS,
  output wire OE
);

reg rst_n;
reg RSTN_D;

// uart rx
wire [7:0] data;
wire data_vld;

reg [15:0] data_wide;

// 7seg display
wire [7:0] segments;
wire [3:0] anodes;

always @(posedge CLK) begin
  RSTN_D <= RSTN;
  rst_n  <= RSTN_D;
end

uart_rx #(
  .FREQ(50_000_000),
  .RATE(112500)
) uart_rx_inst (
  .clk(CLK),
  .rst_n(rst_n),
  .i_rx(RXD),
  .o_data(data),
  .o_vld(data_vld)
);

always @(posedge CLK or negedge rst_n) begin
  if (!rst_n) begin
    data_wide <= 16'b0;
  end else if (data_vld) begin
    data_wide <= {data_wide[7:0], data};
  end
end

hex_to_7seg hex_to_7seg_inst (
  .clk(CLK),
  .rst_n(rst_n),
  .i_data(data_wide),
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
