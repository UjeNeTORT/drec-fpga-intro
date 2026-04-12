`timescale 1ns/1ps

module hex_to_7seg_tb;

reg clk, rst_n;

reg [15:0] data;
wire [3:0] anodes;
wire [7:0] seg;

initial begin
  $dumpvars();

  clk = 0;
  rst_n = 0;
  data = 16'h0a0d;

end

always begin
  #1 clk = ~clk;
end

always begin
  repeat(2) @(posedge clk);
  rst_n = 1;

  repeat(2) @(posedge clk);

  #10000 $finish();
end

hex_to_7seg hex_to_7seg_inst (
  .clk(clk),
  .rst_n(rst_n),
  .i_data(data),
  .o_anodes(anodes),
  .o_seg(seg)
);

endmodule
