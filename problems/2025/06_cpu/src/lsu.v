module lsu # (
  parameter ALU_RES_WIDTH = 32, // width of address value received from alu
  parameter ADDR_WIDTH    = `DMEM_ADDR_WIDTH
)(
  input wire                     clk,
  input wire                     rst_n,
  input wire [ALU_RES_WIDTH-1:0] i_addr,
  input wire [31:0]              i_data,
  input wire                     i_we,
  input wire                     i_sgxt, // 1=lb or 0=lbu
  input wire [3:0]               i_mask,

  input wire [31:0]              i_mem_data,

  output reg [ADDR_WIDTH-1:0]    o_mem_addr,
  output reg [31:0]              o_mem_data,
  output reg                     o_mem_we,
  output reg [3:0]               o_mem_mask,

  output reg [31:0]              o_data
);

reg [ALU_RES_WIDTH-1:0] addr_d;
reg               [3:0] mask_d;

always @(posedge clk or negedge rst_n) begin
  if (!rst_n) begin
    addr_d <= 32'd0;
    mask_d <=  4'd0;
  end else begin
    addr_d <= i_addr;
    mask_d <= i_mask;
  end
end

wire [31:0] mem_data = addr_d[1:0] == 2'b11 ? i_mem_data >> 24
                     : addr_d[1:0] == 2'b10 ? i_mem_data >> 16
                     : addr_d[1:0] == 2'b01 ? i_mem_data >> 8
                     :                        i_mem_data;

always @(*) begin
  o_mem_data = i_data;
  o_mem_we   = i_we;
  o_data     = 32'd0;

  // load for 2 cycles
  if (!i_we) begin
    o_mem_addr = addr_d[ADDR_WIDTH+1:2];
    o_mem_mask = mask_d << addr_d[1:0];

    if (mask_d[0]) o_data[7:0]   = mem_data[7:0];
    if (mask_d[1]) o_data[15:8]  = mem_data[15:8];
    if (mask_d[2]) o_data[23:16] = mem_data[23:16];
    if (mask_d[3]) o_data[31:24] = mem_data[31:24];
  end else begin
    o_mem_addr = i_addr[ADDR_WIDTH+1:2];
    o_mem_mask = i_mask << i_addr[1:0];
  end
  // sign extend only on loads - accomplished because we
  // ignore o_data on stores
  if (i_sgxt) begin
    casex (i_mask)
      4'b01xx: o_data[31:24] = {8 {mem_data[23]}};
      4'b001x: o_data[31:16] = {16{mem_data[15]}};
      4'b0001: o_data[31:8]  = {24{mem_data[7]}};
      default: o_data[31:0]  = mem_data;
    endcase
  end
end

endmodule
