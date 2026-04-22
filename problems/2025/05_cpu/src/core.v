`include "opcodes.vh"

module core (
  input wire clk,
  input wire rst_n,

  input wire [31:0] i_instr_data, // imem 2 core

  input wire [31:0] i_mem_data,   // xbar 2 core

  output reg [`IMEM_ADDR_WIDTH-1:0] o_instr_addr, // core 2 imem
  output reg [`DMEM_ADDR_WIDTH-1:0] o_mem_addr,   // core 2 xbar
  output reg [31:0]                 o_mem_data,
  output reg                        o_mem_we,
  output reg [3:0]                  o_mem_mask
);

wire [11:0] Iimm = i_instr_data[31:20];
wire [11:0] Uimm = i_instr_data[31:12];

reg [29:0] pc;

wire [3:0] ALUOp;
wire       ALU_sel2;
wire       rf_wren;

wire [31:0] rs1;
wire [31:0] rs2;

wire [31:0] ALU_rs1 = rs1;
wire [31:0] ALU_rs2 = ALU_sel2 ? rs2 : {{20{Iimm[11]}}, Iimm};
wire [31:0] ALU_res;

wire [4:0] rs1_addr = i_instr_data[19:15];
wire [4:0] rs2_addr = i_instr_data[24:20];
wire [4:0] rd_addr  = i_instr_data[11:7];

rf_2r1w rf_2r1w (
  .clk        (clk),
  .i_wr_en    (rf_wren),
  .i_wr_addr  (rd_addr),
  .i_wr_data  (ALU_res),
  .i_rd_addr_1(rs1_addr),
  .i_rd_addr_2(rs2_addr),
  .o_rd_data_1(rs1),
  .o_rd_data_2(rs2)
);

alu alu (
  .i_rs1(ALU_rs1),
  .i_rs2(ALU_rs2),
  .i_op (ALUOp),
  .o_res(ALU_res)
);

control control (
  .i_instr_data(i_instr_data),
  .o_aluop(ALUOp),
  .o_alusel2(ALU_sel2),
  .o_rf_wren(rf_wren)
);

wire [`IMEM_ADDR_WIDTH-1:0] pc_next = pc + 1;

always @(posedge clk or negedge rst_n) begin
  if (!rst_n) begin
    pc <= 1'b0;
    o_instr_addr <= 1'b0;
  end else begin
    pc <= pc_next;
    o_instr_addr <= pc;
  end
end

endmodule
