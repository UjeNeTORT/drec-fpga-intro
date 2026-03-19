`timescale 1ns/1ps;

module rf_tb;

reg clk;
reg wr_en;

reg [4:0]  wr_addr;
reg [31:0] wr_data;

reg  [4:0]  rd_addr_1;
wire [31:0] rd_data_1;

reg  [4:0]  rd_addr_2;
wire [31:0] rd_data_2;

always begin
  #1 clk = ~clk;

end

initial begin
  $dumpvars();

  clk = 0;
  wr_en = 0;
  wr_addr = 0;
  wr_data = 0;
  rd_addr_1 = 0;
  rd_addr_2 = 0;

  // test writes
  for (integer i = 0; i < 32; i = i + 1) begin
    @(posedge clk) begin
      wr_en <= 1;
      wr_addr <= i;
      wr_data <= i;
      $display("[%t] write, wr_en=%b, rf[%d] <- %d", $realtime,
        wr_en, wr_addr, wr_data);
    end
  end

  @(posedge clk);
  $display("[%t] write, wr_en=%b, rf[%d] <- %d", $realtime,
    wr_en, wr_addr, wr_data);

  // test reads
  @(posedge clk);
  wr_en <= 0;

  rd_addr_1 <= 0;
  rd_addr_2 <= 31;
  @(posedge clk);
  $display("[%t] read,  wr_en=%b, rf[%d] (port 1) = %d, rf[%d] (port 2) = %d", $realtime,
    wr_en, rd_addr_1, rd_data_1, rd_addr_2, rd_data_2);

  rd_addr_1 <= 2;
  rd_addr_2 <= 16;
  @(posedge clk);
  $display("[%t] read,  wr_en=%b, rf[%d] (port 1) = %d, rf[%d] (port 2) = %d", $realtime,
    wr_en, rd_addr_1, rd_data_1, rd_addr_2, rd_data_2);

  #1000 $finish();
end

rf_2r1w rf_2r1w_inst (
  .clk(clk),
  .i_wr_en(wr_en),
  .i_wr_addr(wr_addr),
  .i_wr_data(wr_data),
  .i_rd_addr_1(rd_addr_1),
  .i_rd_addr_2(rd_addr_2),
  .o_rd_data_1(rd_data_1),
  .o_rd_data_2(rd_data_2)
);

endmodule
