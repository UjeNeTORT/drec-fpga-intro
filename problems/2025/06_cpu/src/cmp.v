module cmp #(
  parameter REG_WIDTH = 32,
  parameter CND_WIDTH = 3
)(
  input wire [REG_WIDTH-1:0] i_rs1, i_rs2,
  input wire [CND_WIDTH-1:0] i_cnd,
  output reg o_res // 1 - branch, 0 - fallthrough
);

always @(*) begin
  case (i_cnd)
    3'b000 : o_res = i_rs1 == i_rs2; // beq
    3'b001 : o_res = i_rs1 != i_rs2; // bne
    3'b100 : o_res = $signed(i_rs1) <  $signed(i_rs2); // blt (signed)
    3'b101 : o_res = $signed(i_rs1) >= $signed(i_rs2); // bge (signed)
    3'b110 : o_res = i_rs1 < i_rs2; // bltu (unsigned)
    3'b111 : o_res = i_rs1 >= i_rs2; // bgeu (unsigned)
    default: o_res = i_rs1 == i_rs2; // default
  endcase
end

endmodule
