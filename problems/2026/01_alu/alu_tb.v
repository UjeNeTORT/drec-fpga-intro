`timescale 1ns/1ps

module alu_tb;
localparam WIDTH = 32;

reg [WIDTH-1:0] i_1;
reg [WIDTH-1:0] i_2;
reg [3:0] i_op = 4'b0000;

wire [WIDTH-1:0] res;

always begin
  $display("[%t] i_1=%b, i_2=%b", $realtime);
  i_op = 4'b0000;
  #1 if (i_1 + i_2 == res)
      $display("[%t] s1=%b + s2=%b dst=%b OK",   $realtime, i_1, i_2, res);
    else
      $display("[%t] s1=%b + s2=%b dst=%b FAIL", $realtime, i_1, i_2, res);
  i_op = 4'b0001;
  #1 if (i_1 - i_2 == res)
      $display("[%t] s1=%b - s2=%b dst=%b OK",   $realtime, i_1, i_2, res);
    else
      $display("[%t] s1=%b - s2=%b dst=%b FAIL", $realtime, i_1, i_2, res);
  i_op = 4'b0010;
  #1 if (i_1 << i_2[4:0] == res)
      $display("[%t] s1=%b << s2=%b dst=%b OK",   $realtime, i_1, i_2, res);
    else
      $display("[%t] s1=%b << s2=%b dst=%b FAIL", $realtime, i_1, i_2, res);
  i_op = 4'b0011;
  #1 if ($signed(i_1) < $signed(i_2) == res)
      $display("[%t] s1=%b <s s2=%b dst=%b OK",   $realtime, i_1, i_2, res);
    else
      $display("[%t] s1=%b <s s2=%b dst=%b FAIL", $realtime, i_1, i_2, res);
  #1 i_1 = i_1 + 1;
  #1 i_2 = i_2 + 1;
  if (i_1 == 33) begin
    $display("[%t] Done", $realtime);
    $finish;
  end
end

alu #(.WIDTH(WIDTH)) alu_inst (
  .i_rs1(i_1),
  .i_rs2(i_2),
  .i_op(i_op),
  .o_res(res)
);

initial begin
  i_1 = 0;
  i_2 = 1;

  $dumpvars;
  $display("[%t] Start", $realtime);
  #1000 $finish;
end

endmodule
