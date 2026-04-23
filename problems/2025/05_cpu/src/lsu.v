module lsu # (
  parameter ALU_RES_WIDTH = 32, // width of address value received from alu
  parameter ADDR_WIDTH = 30
)(
  input wire [ALU_RES_WIDTH-1:0] i_addr,
  input wire [31:0]              i_data,

  output reg [ADDR_WIDTH-1:0] o_addr, // to dmem
  output reg [31:0]           o_data,
  output reg                  o_we,
  output reg [3:0]            o_mask
);

always @(*) begin
  o_addr = i_addr[ADDR_WIDTH-1:0];
  o_data = i_data;
end

endmodule
