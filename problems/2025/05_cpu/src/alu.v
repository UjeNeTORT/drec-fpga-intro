module alu #(
  parameter WIDTH = 32
)(
  input  wire [WIDTH-1:0] i_rs1, i_rs2,
  input  wire [3:0]  i_op,
  output reg  [WIDTH-1:0] o_res
);

always @(*) begin
  case (i_op)
    4'b0000 : o_res = i_rs1 + i_rs2;                   // add
    4'b1000 : o_res = i_rs1 - i_rs2;                   // sub
    4'b0001 : o_res = i_rs1 << i_rs2[4:0];             // sll
    4'b0010 : o_res = $signed(i_rs1) < $signed(i_rs2); // slt
    4'b0011 : o_res = i_rs1 < i_rs2;                   // sltu
    4'b0100 : o_res = i_rs1 ^ i_rs2;                   // xor
    4'b0101 : o_res = i_rs1 >> i_rs2[4:0];             // srl
    4'b1101 : o_res = i_rs1 >>> i_rs2[4:0];            // sra
    4'b0110 : o_res = i_rs1 | i_rs2;                   // or
    4'b0111 : o_res = i_rs1 & i_rs2;                   // and
  endcase
end

endmodule
