`define STRUCTURAL

`ifdef BEHAVIORAL
module signext #(
  parameter N = 12,
  parameter M = 32
)(
  input  wire [N-1:0] i_src,
  output wire [M-1:0] o_dst
);

parameter SHAMT = M - N;
assign o_dst = { {SHAMT{i_src[N-1]}}, i_src };

endmodule

`else

module bit_cpy (
  input  wire i_x,
  output wire o_y
);

assign o_y = i_x;

endmodule

module signext #(
  parameter N = 12,
  parameter M = 32
)(
  input  wire [N-1:0] i_src,
  output wire [M-1:0] o_dst
);

genvar i;
generate
  for (i = 0; i < N; i = i + 1) begin : copy_lower_bits
    bit_cpy bit_cpy_inst1(.i_x(i_src[i]), .o_y(o_dst[i]));
  end

  for (i = N; i < M; i = i + 1) begin : copy_sign_bit
    bit_cpy bit_cpy_inst2(.i_x(i_src[N-1]), .o_y(o_dst[i]));
  end

endgenerate

endmodule

`endif
