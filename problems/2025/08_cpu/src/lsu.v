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
reg                     sgxt_d;
reg                       we_d;
reg              [31:0] data_d;

always @(posedge clk or negedge rst_n) begin
  if (!rst_n) begin
    addr_d <= 32'd0;
    mask_d <=  4'd0;
    sgxt_d <=  1'd0;
    we_d   <=  1'd0;
    data_d <= 32'd0;
  end else begin
    addr_d <= i_addr;
    mask_d <= i_mask;
    sgxt_d <= i_sgxt;
    we_d   <= i_we;
    data_d <= i_data;
  end
end

wire [31:0] mem_data = addr_d[1:0] == 2'b11 ? i_mem_data >> 24
                     : addr_d[1:0] == 2'b10 ? i_mem_data >> 16
                     : addr_d[1:0] == 2'b01 ? i_mem_data >> 8
                     :                        i_mem_data;

always @(*) begin
  o_mem_data = data_d;
  o_mem_we   = we_d;
  o_data     = 32'd0;

  o_mem_addr = addr_d[ADDR_WIDTH+1:2];
  o_mem_mask = mask_d << addr_d[1:0];

  if (!we_d) begin
    if (mask_d[0]) o_data[7:0]   = mem_data[7:0];
    if (mask_d[1]) o_data[15:8]  = mem_data[15:8];
    if (mask_d[2]) o_data[23:16] = mem_data[23:16];
    if (mask_d[3]) o_data[31:24] = mem_data[31:24];
  end
  // sign extend only on loads
  if (!we_d && sgxt_d) begin
    casex (mask_d)
      4'b01xx: o_data[31:24] = {8 {mem_data[23]}};
      4'b001x: o_data[31:16] = {16{mem_data[15]}};
      4'b0001: o_data[31:8]  = {24{mem_data[7]}};
      default: o_data[31:0]  = mem_data;
    endcase
  end
end

endmodule
