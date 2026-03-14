`timescale 1ns/1ps

module cmp_tb;

reg [31:0] rs1, rs2;
reg [2:0]  cnd;
wire res;

always begin
  #1;
  $display("[%t] rs1=%b rs2=%b", $realtime, rs1, rs2);
  cnd = 3'b000;
  #1 $display("[%t] beq  res=%b %s", $realtime, res, res == (rs1 == rs2) ? "OK" : "FAIL");
  cnd = 3'b001;
  #1 $display("[%t] bne  res=%b %s", $realtime, res, res == (rs1 != rs2) ? "OK" : "FAIL");
  cnd = 3'b100;
  #1 $display("[%t] blt  res=%b %s", $realtime, res, res == ($signed(rs1) < $signed(rs2)) ? "OK" : "FAIL");
  cnd = 3'b101;
  #1 $display("[%t] bge  res=%b %s", $realtime, res, res == ($signed(rs1) >= $signed(rs2)) ? "OK" : "FAIL");
  cnd = 3'b110;
  #1 $display("[%t] bltu res=%b %s", $realtime, res, res == (rs1 < rs2) ? "OK" : "FAIL");
  cnd = 3'b111;
  #1 $display("[%t] bgeu res=%b %s", $realtime, res, res == (rs1 >= rs2) ? "OK" : "FAIL");

  #1;
  rs1 = rs1 + 1;
  rs2 = rs2 + 2;

  #1 if (rs1 == 32) begin
    $display("[%t] Done", $realtime);
    $finish;
  end

end

cmp cmp_inst (
  .rs1(rs1), .rs2(rs2),
  .cnd(cnd),
  .res(res)
);

initial begin
  rs1 = 0;
  rs2 = 0;
  $dumpvars;
  $display("[%t] Start", $realtime);
  #1000 $finish;
end

endmodule;
