module rf_2r1w # (
  parameter ADDR_WIDTH = 5,
  parameter DATA_WIDTH = 32
)(
  input  wire clk,
  input  wire i_wr_en,
  input  wire [ADDR_WIDTH-1:0] i_wr_addr,
  input  wire [DATA_WIDTH-1:0] i_wr_data,
  input  wire [ADDR_WIDTH-1:0] i_rd_addr_1,
  input  wire [ADDR_WIDTH-1:0] i_rd_addr_2,
  output wire [DATA_WIDTH-1:0] o_rd_data_1,
  output wire [DATA_WIDTH-1:0] o_rd_data_2
);

reg [DATA_WIDTH-1:0] registers [0:DATA_WIDTH-1];

assign o_rd_data_1 = registers[i_rd_addr_1];
assign o_rd_data_2 = registers[i_rd_addr_2];

always @(posedge clk) begin
  if (i_wr_en) begin
    registers[i_wr_addr] <= i_wr_data;
    // $display("[%t] rf[%d] <-- %d", $realtime, i_wr_addr, i_wr_data);
  end
end
endmodule
