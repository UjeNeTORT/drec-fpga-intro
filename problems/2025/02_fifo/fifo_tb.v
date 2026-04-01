`timescale 1ns/1ps;

module sync_fifo_tb;

reg clk, rst_n;
reg wr_en, rd_en;
reg [31:0] wr_data;
wire rd_empty, wr_full;
wire [31:0] rd_data;

initial begin
  clk <= 0;
  rst_n <= 0;
  wr_en <= 0;
  rd_en <= 0;
end

always @(*) begin
  #1 clk <= ~clk;

  $display("[%t] wr_data=%d, wr_en=%b, rd_en=%b, wr_full=%b, rd_empty=%b, rd_data=%d",
              $realtime, wr_data, wr_en, rd_en, wr_full, rd_empty, rd_data);
end

initial begin
  $dumpvars();
  repeat(2) @(posedge clk);

  rst_n <= 1;

  // test read on empty fifo
  @(posedge clk) rd_en <= 1;
  @(posedge clk) rd_en <= 0;

  // test wr then read
  @(posedge clk) begin
    wr_en <= 1;
    wr_data <= 'd12345;
  end

  // wr again
  @(posedge clk);

  @(posedge clk) begin
    wr_en <= 0;
    wr_data <= 0;
  end

  @(posedge clk) begin
    rd_en <= 1;
  end

  #100 $finish();
end

sync_fifo sync_fifo_inst (
  .clk(clk),
  .rst_n(rst_n),
  .i_wr_data(wr_data),
  .i_wr_en(wr_en),
  .i_rd_en(rd_en),
  .o_wr_full(wr_full),
  .o_rd_empty(rd_empty),
  .o_rd_data(rd_data)
);

endmodule
