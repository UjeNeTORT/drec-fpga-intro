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

assign o_rd_data_1 = i_rd_addr_1 == 0 ? 32'b0 : registers[i_rd_addr_1];
assign o_rd_data_2 = i_rd_addr_2 == 0 ? 32'b0 : registers[i_rd_addr_2];

always @(posedge clk) begin
  if (i_wr_en) begin
    if (i_wr_addr != 0) begin
      registers[i_wr_addr] <= i_wr_data;
    end
    // $display("[%t] rf[%d] <-- %d", $realtime, i_wr_addr, i_wr_data);
  end
end

integer i;
initial begin
    for (i = 0; i < 32; i = i + 1) begin
        registers[i] = 32'h0;
    end
end

endmodule
