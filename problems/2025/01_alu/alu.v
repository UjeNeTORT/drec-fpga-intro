module alu #(
  parameter WIDTH = 32
)(
  input  wire [WIDTH-1:0] i_rs1, i_rs2,
  input  wire [3:0]  i_op,
  output reg  [WIDTH-1:0] o_res
);

always @(*) begin
  case (i_op)
    0 : o_res = i_rs1 + i_rs2;                   // add
    1 : o_res = i_rs1 - i_rs2;                   // sub
    2 : o_res = i_rs1 << i_rs2[4:0];             // sll
    3 : o_res = $signed(i_rs1) < $signed(i_rs2); // slt
    4 : o_res = i_rs1 < i_rs2;                   // sltu
    5 : o_res = i_rs1 ^ i_rs2;                   // xor
    6 : o_res = i_rs1 >> i_rs2[4:0];             // srl
    7 : o_res = i_rs1 >>> i_rs2[4:0];            // sra
    8 : o_res = i_rs1 | i_rs2;                   // or
    9 : o_res = i_rs1 & i_rs2;                   // and
  endcase
end

endmodule;
