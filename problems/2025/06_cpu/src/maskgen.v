`include "opcodes.vh"

module maskgen (
  input wire [6:0] i_opcode,
  input wire [2:0] i_funct3,
  output reg [3:0] o_mask
);

always @(*) begin
  o_mask = 4'd0;

  if (i_opcode == `OPCODE_STORE || i_opcode == `OPCODE_LOAD) begin
    case (i_funct3)
      3'b000:  o_mask = 4'b0001;
      3'b100:  o_mask = 4'b0001;
      3'b001:  o_mask = 4'b0011;
      3'b101:  o_mask = 4'b0011;
      3'b010:  o_mask = 4'b1111;
      default: o_mask = 4'b0000;
    endcase
  end

end

endmodule
