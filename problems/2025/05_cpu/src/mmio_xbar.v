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

reg [15:0] data_to_7seg;

always @(*) begin
  if (i_mmio_addr == `MMIO_7SEG_START) begin
    if (i_mmio_wren) begin
      o_hexd_data <= i_mmio_data[15:0];
    end
  end
end
endmodule
