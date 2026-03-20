module lfsr #(
  parameter WIDTH = 8
)(
  input  wire clk,
  input  wire rst_n,
  input  wire i_we,
  input  wire [WIDTH-1:0] i_wr,
  output wire [WIDTH-1:0] o_num
);

reg [WIDTH-1:0] lf_shft_reg;

assign o_num = lf_shft_reg;

always @(posedge clk or negedge rst_n) begin
  if (!rst_n) begin
    lf_shft_reg <= {WIDTH{1'b0}};
  end else if (i_we) begin
    lf_shft_reg <= i_wr;
  end else begin
    // fibonacci configuration
    lf_shft_reg <= {lf_shft_reg[WIDTH-2:0],
      lf_shft_reg[WIDTH-1] ^ lf_shft_reg[WIDTH-2] ^ lf_shft_reg[0] ^ 1'b1}; // x**7 + x**6 + x + 1
  end
end
endmodule
