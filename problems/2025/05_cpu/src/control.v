`include "opcodes.vh"

module control (
  input wire [31:0] i_instr_data,

  output reg [3:0] o_aluop,
  output reg [2:0] o_cmpop,
  output reg       o_branch,
  output reg [1:0] o_alusel1,
  output reg [1:0] o_alusel2,
  output reg       o_rf_wren,
  output reg       o_lsu_wren,
  output reg [1:0] o_wb_sel
);

wire [6:0]  opcode   = i_instr_data[6:0];
wire [2:0]  funct3   = i_instr_data[14:12];

wire use_b30;
wire ALUOp_b4;

assign use_b30 = (opcode == `OPCODE_OP) ||
                 (opcode == `OPCODE_OP_IMM && funct3 == 3'b101);
assign ALUOp_b4 = use_b30 ? i_instr_data[30] : 1'b0;

always @(*) begin
  o_lsu_wren = 1'b0;
  o_rf_wren  = 1'b1;

  case (opcode)
    `OPCODE_STORE: begin
      o_aluop    = 3'b0; // add
      o_lsu_wren = 1'b1;
    end
    `OPCODE_BRANCH,
    `OPCODE_LOAD,
    `OPCODE_JALR,
    `OPCODE_JAL,
    `OPCODE_AUIPC: o_aluop = 3'b0; // add
    default:       o_aluop = {ALUOp_b4, funct3};
  endcase

  case (opcode)
    `OPCODE_OP_IMM,
    `OPCODE_OP,
    `OPCODE_STORE,
    `OPCODE_LOAD,
    `OPCODE_JALR:   o_alusel1 = 2'd0; // choose rs1
    `OPCODE_BRANCH: o_alusel1 = 2'd1; // choose Bimm (sgxt)
    `OPCODE_JAL:    o_alusel1 = 2'd2; // choose Jimm (sgxt)
    `OPCODE_AUIPC:  o_alusel1 = 2'd3; // choose Uimm
    default:        o_alusel1 = 0; // todo remove
  endcase

  case (opcode)
    `OPCODE_OP_IMM,
    `OPCODE_LOAD:   o_alusel2 = 2'd0; // choose Iimm (sgxt)
    `OPCODE_OP:     o_alusel2 = 2'd1; // choose rs2
    `OPCODE_STORE,
    `OPCODE_JALR:   o_alusel2 = 2'd2; // choose Simm (sgxt)
    `OPCODE_BRANCH,
    `OPCODE_JAL,
    `OPCODE_AUIPC:  o_alusel2 = 2'd3; // choose pc
    default:        o_alusel2 = 0; // todo remove
  endcase

  case (opcode)
    `OPCODE_STORE:  o_rf_wren = 1'd0;
    `OPCODE_BRANCH: o_rf_wren = 1'd0;
    default:        o_rf_wren = 1'd1;
  endcase

  case (opcode)
    `OPCODE_LOAD: o_wb_sel = 2'd1; // choose lsu_data
    `OPCODE_JALR,
    `OPCODE_JAL:  o_wb_sel = 2'd2; // choose pc_inc
    `OPCODE_LUI:  o_wb_sel = 2'd3; // choose Uimm (for lui)
    default:      o_wb_sel = 2'd0; // choose Alu_res
  endcase

  case (opcode)
    `OPCODE_BRANCH: o_branch = 1'b1;
    `OPCODE_JALR:   o_branch = 1'b1;
    default:        o_branch = 1'b0;
  endcase

  o_cmpop = funct3;
end

endmodule
