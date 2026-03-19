`timescale 1ns/1ps

module shiftreg_tb;

reg clk;
reg rst_n;
reg we;
reg [7:0] wr;
wire out;

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
    wr <= 8'b0110_0110;
  end

  @(posedge clk) we <= 0;

  repeat(8) @(posedge clk);

  @(posedge clk) begin
    we <= 1;
    wr <= 8'b0101_0101;
  end

  @(posedge clk) we <= 0;

  repeat(8) @(posedge clk);

  #100 $finish();
end

shiftreg shiftreg_inst (
  .clk(clk),
  .rst_n(rst_n),
  .i_we(we),
  .i_wr(wr),
  .o_msb(out)
);

endmodule
