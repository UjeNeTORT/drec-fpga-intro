module fpga_top (
  input wire   CLK,
  input wire [15:0] i_a,
  input wire [15:0] i_b,
  output reg [15:0] o_res
);

reg  [15:0] a, b;
wire [15:0] res;

always @(posedge CLK) begin
  a <= i_a;
  b <= i_b;
  o_res <= res;
end

fp16add fp16add (
  .clk(CLK),
  .i_a(a),
  .i_b(b),
  .o_res(res)
);

endmodule
