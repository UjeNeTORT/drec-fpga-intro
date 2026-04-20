`timescale 1ns/1ps

module uart_rx_tb;

reg clk = 1'b0;
reg rst_n = 1'b0;

reg [7:0] data;
reg tx_vld = 1'b0;
wire bus;

always begin
  #1 clk <= ~clk;
end

initial begin
  repeat(3) @(posedge clk);
  rst_n <= 1'b1;
end

always begin
  repeat (130) @(posedge clk);
  data   <= 7'h67;
  tx_vld <= 1'b1;
  @(posedge clk);
  data   <= 7'hXX;
  tx_vld <= 1'b0;
end

initial begin
  $dumpvars;
  #1000 $finish;
end

uart_tx #(
  .FREQ(1_000_000),
  .RATE(115200)
) uart_tx_inst (
  .clk(clk), .rst_n(rst_n),
  .i_data(data),
  .i_vld(tx_vld),
  .o_tx(bus)
);

wire [7:0] o_data;
wire o_vld;

uart_rx #(
  .FREQ(1_000_000),
  .RATE(115200)
) uart_rx_inst (
  .clk(clk), .rst_n(rst_n),
  .i_rx(bus),
  .o_data(o_data),
  .o_vld(o_vld)
);

endmodule
