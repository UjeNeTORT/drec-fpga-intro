`include "opcodes.vh"

module control (
  input wire [31:0] i_instr_data,

  output reg [3:0] o_aluop,
  output reg [1:0] o_alusel2,
  output reg       o_rf_wren
);

wire [6:0]  opcode   = i_instr_data[6:0];
wire [2:0]  funct3   = i_instr_data[14:12];
wire [6:0]  funct7   = i_instr_data[14:12];
wire [12:0] BRImm    = {i_instr_data[31],    i_instr_data[7],
                        i_instr_data[30:25], i_instr_data[11:8], 1'b0};
wire [20:0] JALImm   = {i_instr_data[31],    i_instr_data[19:12],
                        i_instr_data[20],    i_instr_data[30:21], 1'b0};

assign use_b30 = (opcode == `OPCODE_OP) ||
                 (opcode == `OPCODE_OP_IMM && funct3 == 3'b101);
assign ALUOp_b4 = use_b30 ? i_instr_data[30] : 1'b0;

always @(*) begin
  o_aluop = {ALUOp_b4, funct3};
  o_rf_wren = 1'b1;
  case (opcode)
    `OPCODE_OP_IMM: o_alusel2 = 2'd0; // choose Iimm
    `OPCODE_OP:     o_alusel2 = 2'd1; // choose rs2
    `OPCODE_STORE:  o_alusel2 = 2'd2; // choose Simm
    default:        o_alusel2 = 0; // todo remove
  endcase
end

endmodule
