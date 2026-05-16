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
reg [15:0] display_reg;

always @(posedge clk or negedge rst_n) begin
  if (!rst_n) cnt <= 14'b0;
  else        cnt <= cnt + 1'b1;
end

always @(posedge clk or negedge rst_n) begin
  if (!rst_n)    display_reg <= 16'b0;
  else if (i_we) display_reg <= i_data;
end

reg [3:0] digit;

assign o_anodes = ~(4'b1 << pos);

always @(*) begin
  case (pos)
    2'b00:   digit = display_reg[3:0];
    2'b01:   digit = display_reg[7:4];
    2'b10:   digit = display_reg[11:8];
    2'b11:   digit = display_reg[15:12];
    default: digit = 4'b0;
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

endmodule
