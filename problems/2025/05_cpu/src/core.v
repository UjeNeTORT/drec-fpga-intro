`include "opcodes.vh"

module core (
  input wire clk,
  input wire rst_n,

  input wire [31:0] i_instr_data, // imem 2 core
  input wire [31:0] i_mem_data,   // xbar 2 core

  output wire [`IMEM_ADDR_WIDTH-1:0] o_instr_addr, // core 2 imem
  output wire [`DMEM_ADDR_WIDTH-1:0] o_mem_addr,   // core 2 xbar
  output wire [31:0]                 o_mem_data,
  output wire                        o_mem_we,
  output wire [3:0]                  o_mem_mask
);

wire [6:0] opcode = i_instr_data[6:0];
wire [2:0] funct3 = i_instr_data[14:12];

wire [11:0] Iimm = i_instr_data[31:20];
wire [31:0] Uimm = {i_instr_data[31:12], 12'b0};
wire [11:0] Simm = {i_instr_data[31:25], i_instr_data[11:7]};
wire [12:0] Bimm = {i_instr_data[31],    i_instr_data[7],
                    i_instr_data[30:25], i_instr_data[11:8], 1'b0};
wire [20:0] Jimm = {i_instr_data[31], i_instr_data[19:12],
                    i_instr_data[20], i_instr_data[30:21], 1'b0};

wire [31:0] Iimm_sgxt = {{20{Iimm[11]}}, Iimm};
wire [31:0] Simm_sgxt = {{20{Simm[11]}}, Simm};
wire [31:0] Jimm_sgxt = {{11{Jimm[20]}}, Jimm};

// >>> 2 to obtain instr number, not addr
wire [31:0] Bimm_shft = $signed({{19{Bimm[12]}}, Bimm}) >>> 2;

reg  [`IMEM_ADDR_WIDTH-1:0] pc = 0;
wire [`IMEM_ADDR_WIDTH-1:0] pc_inc;
wire [`IMEM_ADDR_WIDTH-1:0] pc_next;

wire [3:0] ALUOp;
wire [2:0] CmpOp;
wire [1:0] ALU_sel1;
wire [1:0] ALU_sel2;
wire [1:0] wb_sel;
wire       rf_wren;
wire       lsu_we;

wire br_taken;
wire branch;
wire cmp_res;

wire [31:0] rs1;
wire [31:0] rs2;

// alu inputs and outputs
wire [31:0] src1;
wire [31:0] src2;
wire [31:0] ALU_res;

wire [31:0] rf_dst_data;
wire [4:0] rs1_addr = i_instr_data[19:15];
wire [4:0] rs2_addr = i_instr_data[24:20];
wire [4:0] rd_addr  = i_instr_data[11:7];

mux4 #(.WIDTH(32)) rs1_mux (
  .i_1(rs1),
  .i_2(Bimm_shft),
  .i_3(Jimm_sgxt),
  .i_4(Uimm),
  .i_sel(ALU_sel1),
  .o_res(src1)
);

mux4 #(.WIDTH(32)) rs2_mux (
  .i_1(Iimm_sgxt),
  .i_2(rs2),
  .i_3(opcode == `OPCODE_JALR || opcode == `OPCODE_JAL
       ? Iimm_sgxt : Simm_sgxt),
  .i_4({{(32-`IMEM_ADDR_WIDTH){1'b0}}, pc}),
  .i_sel(ALU_sel2),
  .o_res(src2)
);

rf_2r1w rf_2r1w (
  .clk        (clk),
  .i_wr_en    (rf_wren),
  .i_wr_addr  (rd_addr),
  .i_wr_data  (rf_dst_data),
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
  .o_cmpop(CmpOp),
  .o_branch(branch),
  .o_alusel1(ALU_sel1),
  .o_alusel2(ALU_sel2),
  .o_rf_wren(rf_wren),
  .o_lsu_wren(lsu_we),
  .o_wb_sel(wb_sel)
);

wire [3:0] mem_mask;

maskgen maskgen (
  .i_opcode (opcode),
  .i_funct3 (funct3),
  .o_mask   (mem_mask)
);

wire [31:0] lsu_data;

lsu #(
  .ALU_RES_WIDTH(32),
  .ADDR_WIDTH(`DMEM_ADDR_WIDTH)
) lsu (
  .i_addr      (ALU_res),
  .i_data      (rs2),
  .i_we        (lsu_we),
  .i_sgxt      (~funct3[2]),
  .i_mask      (mem_mask),
  .i_dmem_data (i_mem_data),
  .o_dmem_addr (o_mem_addr),
  .o_dmem_data (o_mem_data),
  .o_dmem_we   (o_mem_we),
  .o_dmem_mask (o_mem_mask),
  .o_data      (lsu_data)
);

cmp cmp (
  .i_rs1(rs1),
  .i_rs2(rs2),
  .i_cnd(CmpOp),
  .o_res(cmp_res)
);

mux4 #(.WIDTH(32)) rd_mux (
  .i_1(ALU_res),
  .i_2(lsu_data),
  .i_3({{(32-`IMEM_ADDR_WIDTH){1'b0}}, pc_inc}),
  .i_4(Uimm),
  .i_sel(wb_sel),
  .o_res(rf_dst_data)
);

wire jmp;

assign br_taken = branch && cmp_res;
assign jmp = opcode == `OPCODE_JALR || opcode == `OPCODE_JAL;
assign o_instr_addr = pc;
assign pc_inc = pc + 7'b1;
assign pc_next = br_taken ? ALU_res         :
                 jmp      ? ALU_res         : pc_inc;

always @(posedge clk or negedge rst_n) begin
  if (!rst_n) begin
    pc <= 7'b0;
  end else begin
    pc <= pc_next;
  end
end

endmodule
