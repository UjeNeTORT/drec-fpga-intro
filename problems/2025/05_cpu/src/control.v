`include "opcodes.vh"

module control (
  input wire [31:0] i_instr_data,

  output reg [3:0] o_aluop,
  output reg [2:0] o_cmpop,
  output reg       o_branch,
  output reg [1:0] o_alusel1,
  output reg [1:0] o_alusel2,
  output reg       o_rf_wren,
  output reg       o_lsu_wren
);

wire [6:0]  opcode   = i_instr_data[6:0];
wire [2:0]  funct3   = i_instr_data[14:12];
wire [6:0]  funct7   = i_instr_data[14:12];
wire [20:0] JALImm   = {i_instr_data[31],    i_instr_data[19:12],
                        i_instr_data[20],    i_instr_data[30:21], 1'b0};

assign use_b30 = (opcode == `OPCODE_OP) ||
                 (opcode == `OPCODE_OP_IMM && funct3 == 3'b101);
assign ALUOp_b4 = use_b30 ? i_instr_data[30] : 1'b0;

always @(*) begin
  o_lsu_wren = 1'b0;
  case (opcode)
    `OPCODE_STORE: begin
      o_aluop = 3'b0; // add
      o_lsu_wren = 1'b1;
    end
    `OPCODE_BRANCH: begin
      o_aluop = 3'b0; // add
    end
    default: begin
      o_aluop = {ALUOp_b4, funct3};
      o_lsu_wren = 1'b0;
    end
  endcase
  o_rf_wren = 1'b1;
  case (opcode)
    `OPCODE_OP_IMM,
    `OPCODE_OP,
    `OPCODE_STORE:  o_alusel1 = 2'd0; // choose rs1
    `OPCODE_BRANCH: o_alusel1 = 2'd1; // choose Bimm
    default:        o_alusel1 = 0; // todo remove
  endcase

  case (opcode)
    `OPCODE_OP_IMM: o_alusel2 = 2'd0; // choose Iimm
    `OPCODE_OP:     o_alusel2 = 2'd1; // choose rs2
    `OPCODE_STORE:  o_alusel2 = 2'd2; // choose Simm
    `OPCODE_BRANCH: o_alusel2 = 2'd3; // choose pc
    default:        o_alusel2 = 0; // todo remove
  endcase

  o_cmpop = funct3;
  o_branch = opcode == `OPCODE_BRANCH ? 1'b1 : 1'b0;
end

endmodule
