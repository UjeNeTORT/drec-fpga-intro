`timescale 1ns/1ps

module counter_tb;

reg clk, rst_n;
wire [9:0] val;

initial begin
  $dumpvars();

  clk <= 1'b0;
  rst_n <= 1'b0;

  repeat(1) @(posedge clk);
  rst_n <= 1'b1;

  #1500 $finish();
end

always begin
  #1 clk <= ~clk;

  $display("[%t] out=%d", $realtime, val);
end

counter counter_inst (
  .clk(clk),
  .rst_n(rst_n),
  .out(val)
);

endmodule
