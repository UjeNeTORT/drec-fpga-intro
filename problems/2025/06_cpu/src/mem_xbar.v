`include "config.vh"

module mem_xbar #(
  parameter DATA_START = `XBAR_DATA_START,
  parameter DATA_LIMIT = `XBAR_DATA_LIMIT,
  parameter MMIO_START = `XBAR_MMIO_START,
  parameter MMIO_LIMIT = `XBAR_MMIO_LIMIT
)(
  input wire                        clk,
  input wire [`DMEM_ADDR_WIDTH-1:0] i_addr,
  input wire [31:0]                 i_data,
  input wire                        i_wren,
  input wire [3:0]                  i_mask,

  // to core
  output reg [31:0] o_data,

  // to mmio xbar
  output reg [`DMEM_ADDR_WIDTH-1:0] o_mmio_addr,
  output reg [31:0]                 o_mmio_data,
  output reg                        o_mmio_wren,
  output reg [3:0]                  o_mmio_mask,
  input wire [31:0]                 i_mmio_data,

  // to data memory
  output reg [`DMEM_ADDR_WIDTH-1:0] o_dmem_addr,
  output reg [31:0]                 o_dmem_data,
  output reg                        o_dmem_wren,
  output reg [3:0]                  o_dmem_mask,
  input wire [31:0]                 i_dmem_data
);

always @(*) begin
  o_mmio_addr = i_addr;
  o_mmio_data = i_data;
  o_mmio_mask = i_mask;
  o_mmio_wren = 0;

  o_dmem_addr = i_addr;
  o_dmem_data = i_data;
  o_dmem_mask = i_mask;
  o_dmem_wren = 0;
  o_data = i_dmem_data;

  if (MMIO_START <= i_addr && i_addr < MMIO_LIMIT) begin
    o_mmio_wren = i_wren;
    o_data = i_mmio_data;
  end else if (DATA_START <= i_addr && i_addr < DATA_LIMIT) begin
    o_dmem_wren = i_wren;
    o_data = i_dmem_data;
  end
end

endmodule
