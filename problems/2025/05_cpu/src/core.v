`include "opcodes.vh"

module core (
  input wire clk,
  input wire rst_n,

  input wire [31:0] i_instr_data, // imem 2 core

  input wire [31:0] i_mem_data,   // xbar 2 core

  output reg  [`IMEM_ADDR_WIDTH-1:0] o_instr_addr, // core 2 imem
  output wire [`DMEM_ADDR_WIDTH-1:0] o_mem_addr,   // core 2 xbar
  output wire [31:0]                 o_mem_data,
  output wire                        o_mem_we,
  output wire [3:0]                  o_mem_mask
);

wire [11:0] Iimm = i_instr_data[31:20];
wire [11:0] Uimm = i_instr_data[31:12];
wire [11:0] Simm = {i_instr_data[31:25], i_instr_data[11:7]};

reg [29:0] pc;

wire [3:0] ALUOp;
wire [1:0] ALU_sel2;
wire       rf_wren;

wire [31:0] rs1;
wire [31:0] rs2;

wire [31:0] src1 = rs1;
wire [31:0] src2;
wire [31:0] ALU_res;

wire [4:0] rs1_addr = i_instr_data[19:15];
wire [4:0] rs2_addr = i_instr_data[24:20];
wire [4:0] rd_addr  = i_instr_data[11:7];

mux4 #(.WIDTH(32)) rs2_mux (
  .i_1({{20{Iimm[11]}}, Iimm}),
  .i_2(rs2),
  .i_3({{20{Simm[11]}}, Simm}),
  .i_4(32'b0),
  .i_sel(ALU_sel2),
  .o_res(src2)
);

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
  .i_rs1(src1),
  .i_rs2(src2),
  .i_op (ALUOp),
  .o_res(ALU_res)
);

control control (
  .i_instr_data(i_instr_data),
  .o_aluop(ALUOp),
  .o_alusel2(ALU_sel2),
  .o_rf_wren(rf_wren)
);

lsu #(
  .ALU_RES_WIDTH(32),
  .ADDR_WIDTH(`DMEM_ADDR_WIDTH)
) lsu (
  .i_addr(ALU_res),
  .i_data(rs2),
  .o_addr(o_mem_addr),
  .o_data(o_mem_data),
  .o_we  (o_mem_we),
  .o_mask(o_mem_mask)
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
