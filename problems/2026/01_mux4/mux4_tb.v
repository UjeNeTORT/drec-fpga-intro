`timescale 1ns/1ps

module mux4_tb;

localparam WIDTH = 8;
reg [WIDTH-1:0] inputs [0:3];
reg [1:0] sel = 2'b00;
integer i;

wire [WIDTH-1:0] res;

always begin
  $display("[%t] i_1=%b, i_2=%b, i_3=%b, i_4=%b", $realtime, inputs[0], inputs[1], inputs[2], inputs[3]);
  for (i = 0; i < 4; i = i + 1) begin
    #1 sel = i;

    #1 if (res == inputs[i])
      $display("[%t] PASS: sel=%b, res=%b", $realtime, sel, res);
    else
      $display("[%t] FAIL: sel=%b, res=%b, expected=%b", $realtime, sel, res, inputs[i]);
  end

  for (i = 0; i < 4; i = i + 1) begin
    inputs[i] = inputs[i] + 1;
  end

  #1;

  if (inputs[0] == 0) begin
    $display("[%t] Done", $realtime);
    $finish;
  end
end

mux4 #(.WIDTH(WIDTH)) mux4_inst (
  .i_1(inputs[0]),
  .i_2(inputs[1]),
  .i_3(inputs[2]),
  .i_4(inputs[3]),
  .i_sel(sel),
  .o_res(res)
);

initial begin
  inputs[0] = 0;
  inputs[1] = 1;
  inputs[2] = 2;
  inputs[3] = 3;

  $dumpvars;
  $display("[%t] Start", $realtime);
  #10000 $finish;
end

endmodule
