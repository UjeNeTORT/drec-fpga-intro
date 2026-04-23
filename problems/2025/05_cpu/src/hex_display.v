module hex_display (
  input  wire        clk,
  input  wire        rst_n,
  input  wire [15:0] i_data,
  input  wire        i_we,

  output wire [3:0]  o_anodes,
  output reg  [7:0]  o_segments
);

reg [13:0] cnt;
wire [1:0] pos = cnt[13:12];

always @(posedge clk or negedge rst_n) begin
  if (!rst_n) begin
    cnt <= 14'b0;
  end else begin
    cnt <= cnt + 1'b1;
  end
end

reg [3:0] digit;

assign o_anodes = ~(4'b1 << pos);

always @(*) begin
  digit = 4'b0;
  o_segments = 8'b0;
  if (i_we) begin
    case (pos)
      2'b00: digit = i_data[3:0];
      2'b01: digit = i_data[7:4];
      2'b10: digit = i_data[11:8];
      2'b11: digit = i_data[15:12];
    endcase

    case (digit)
      4'h0: o_segments = 8'b1111_1100;
      4'h1: o_segments = 8'b0110_0000;
      4'h2: o_segments = 8'b1101_1010;
      4'h3: o_segments = 8'b1111_0010;
      4'h4: o_segments = 8'b0110_0110;
      4'h5: o_segments = 8'b1011_0110;
      4'h6: o_segments = 8'b1011_1110;
      4'h7: o_segments = 8'b1110_0000;
      4'h8: o_segments = 8'b1111_1110;
      4'h9: o_segments = 8'b1111_0110;
      4'hA: o_segments = 8'b1110_1110;
      4'hB: o_segments = 8'b0011_1110;
      4'hC: o_segments = 8'b1001_1100;
      4'hD: o_segments = 8'b0111_1010;
      4'hE: o_segments = 8'b1001_1110;
      4'hF: o_segments = 8'b1000_1110;
      default: o_segments = 8'b0000_0000;
    endcase
  end
end

endmodule
