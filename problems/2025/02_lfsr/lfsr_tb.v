`timescale 1ns/1ps

module lfsr_tb;

reg clk;
reg rst_n;
reg we;
reg  [7:0] wr;
wire [7:0] out;

always begin
  #1 clk = ~clk;
end

initial begin
  $dumpvars();

  clk   <= 0;
  rst_n <= 0;
  we    <= 0;
  wr    <= 0;

  repeat(2) @(posedge clk);

  rst_n <= 1;

  @(posedge clk) begin
    we <= 1;
    wr <= 8'b1010_1000;
  end

  @(posedge clk)
    $display("[%t] input lfsr <- %b", $realtime, wr);

  @(posedge clk) we <= 0;

  repeat(257) @(posedge clk) begin
    $display("[%t] output lfsr -> %d = %b", $realtime, out, out);
  end

  #100 $finish();
end

lfsr lfsr_inst (
  .clk(clk),
  .rst_n(rst_n),
  .i_we(we),
  .i_wr(wr),
  .o_num(out)
);

endmodule
