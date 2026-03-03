`timescale 1ns/1ps

module signext_tb;

localparam N = 12;
localparam M = 32;

reg  [N-1:0] src = {N{1'b0}};
wire [M-1:0] dst;

always begin
  #1 if ($signed(dst) == $signed(src))
      $display("[%t] src=%b dst=%b OK", $realtime, src, dst);
    else
      $display("[%t] src=%b dst=%b FAIL", $realtime, src, dst);
  #1 src = src + 1;
  if (src == 0) begin
    $display("[%t] Done", $realtime);
    $finish;
  end
end

signext #(.N(N), .M(M)) signext_inst(.i_src(src), .o_dst(dst));

initial begin
  $dumpvars;
  $display("[%t] Start", $realtime);
  #10000 $finish;
end

endmodule
