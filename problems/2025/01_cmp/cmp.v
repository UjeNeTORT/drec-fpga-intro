module cmp #(
  parameter REG_WIDTH = 32,
  parameter CND_WIDTH = 3
)(
  input wire [REG_WIDTH-1:0] rs1, rs2,
  input wire [CND_WIDTH-1:0] cnd,
  output reg res // 1 - branch, 0 - fallthrough
);

always @(*) begin
  case (cnd)
    3'b000 : res = rs1 == rs2; // beq
    3'b001 : res = rs1 != rs2; // bne
    3'b100 : res = $signed(rs1) <  $signed(rs2); // blt (signed)
    3'b101 : res = $signed(rs1) >= $signed(rs2); // bge (signed)
    3'b110 : res = rs1 < rs2; // bltu (unsigned)
    3'b111 : res = rs1 >= rs2; // bgeu (unsigned)
  endcase
end

endmodule;
