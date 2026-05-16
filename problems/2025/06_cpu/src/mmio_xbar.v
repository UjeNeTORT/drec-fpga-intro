`include "config.vh"

module mmio_xbar #(
  parameter ADDR_WIDTH = `DMEM_ADDR_WIDTH
)(
  input  wire [ADDR_WIDTH-1:0] i_mmio_addr,
  input  wire [31:0]           i_mmio_data,
  input  wire                  i_mmio_wren,
  input  wire [3:0]            i_mmio_mask,

  output wire [31:0]           o_mmio_data,

  output reg  [15:0]           o_hexd_data,
  output reg                   o_hexd_wren
);

assign o_mmio_data = 32'b0;

always @(*) begin
  o_hexd_data = 16'b0;
  o_hexd_wren = 1'b0;

  if (i_mmio_addr == `XBAR_HEXD_ADDR0) begin
    o_hexd_data <= i_mmio_data[15:0];
    o_hexd_wren <= i_mmio_wren;
  end
end
endmodule
