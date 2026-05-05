module lsu # (
  parameter ALU_RES_WIDTH = 32, // width of address value received from alu
  parameter ADDR_WIDTH    = `DMEM_ADDR_WIDTH
)(
  input wire [ALU_RES_WIDTH-1:0] i_addr,
  input wire [31:0]              i_data,
  input wire                     i_we,
  input wire                     i_sgxt, // 1=lb or 0=lbu
  input wire [3:0]               i_mask,

  input wire [31:0]              i_dmem_data,

  output reg [ADDR_WIDTH-1:0]    o_dmem_addr,
  output reg [31:0]              o_dmem_data,
  output reg                     o_dmem_we,
  output reg [3:0]               o_dmem_mask,

  output reg [31:0]              o_data
);

wire [31:0] dmem_data = i_addr[1:0] == 2'b11 ? i_dmem_data >> 24
                      : i_addr[1:0] == 2'b10 ? i_dmem_data >> 16
                      : i_addr[1:0] == 2'b01 ? i_dmem_data >> 8
                      :                        i_dmem_data;

// TODO: not finished
always @(*) begin
  o_dmem_addr = i_addr[ADDR_WIDTH+1:2];
  o_dmem_data = i_data;
  o_dmem_we   = i_we;
  o_dmem_mask = i_mask << i_addr[1:0];

  o_data = 32'd0;

  if (!i_we) begin
    if (i_mask[0]) o_data[7:0]   = dmem_data[7:0];
    if (i_mask[1]) o_data[15:8]  = dmem_data[15:8];
    if (i_mask[2]) o_data[23:16] = dmem_data[23:16];
    if (i_mask[3]) o_data[31:24] = dmem_data[31:24];
  end

  // sign extend only on loads
  if (i_sgxt) begin
    casex (i_mask)
      4'b01xx: o_data[31:24] = {8 {dmem_data[23]}};
      4'b001x: o_data[31:16] = {16{dmem_data[15]}};
      4'b0001: o_data[31:8]  = {24{dmem_data[7]}};
      default: o_data[31:0]  = 32'b0;
    endcase
  end
end

endmodule
