`timescale 1ns/1ps

module clkdiv_tb;

localparam F0 = 50_000_000;

reg clk;
reg rst_n;
reg [31:0] sum_orig;
reg [31:0] sum_1;
reg [31:0] sum_2;
reg [31:0] sum_3;

wire out_9600;
wire out_38400;
wire out_115200;

initial begin
  $dumpvars;
  clk = 0;
  rst_n = 0;
  sum_orig = 0;
  sum_1 = 0;
  sum_2 = 0;
  sum_3 = 0;

  #1 rst_n = 1;

end

always begin
  #20 clk <= ~clk; // 50MHz

  sum_orig = sum_orig + 1;

  if (out_9600) begin
    sum_1 = sum_1 + 1;
  end

  if (out_38400) begin
    sum_2 = sum_2 + 1;
  end

  if (out_115200) begin
    sum_3 = sum_3 + 1;
  end

  $display("[%t]", $realtime);

  if (sum_orig == 1_000_000) begin
    $display("[%t] Done, sum_orig=%d, sum_1=%d, sum_2=%d, sum_3=%d", $realtime, sum_orig, sum_1, sum_2, sum_3);
    $finish();
  end
end

clkdiv #(.F0(F0), .F1(9_600)) clkdiv_9600_inst (
  .clk(clk),
  .rst_n(rst_n),
  .out(out_9600)
);

clkdiv #(.F0(F0), .F1(38_400)) clkdiv_38400_inst (
  .clk(clk),
  .rst_n(rst_n),
  .out(out_38400)
);

clkdiv #(.F0(F0), .F1(115_200)) clkdiv_115200_inst (
  .clk(clk),
  .rst_n(rst_n),
  .out(out_115200)
);

endmodule
