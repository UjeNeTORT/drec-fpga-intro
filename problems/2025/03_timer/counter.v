module counter #(
  parameter CNT_FROM = 600,
  parameter CNT_TO   = 0,
  parameter CNT_WIDTH = 10
)(
  input  wire clk,
  input  wire rst_n,
  output wire [CNT_WIDTH-1:0] out
);

reg [CNT_WIDTH-1:0] cnt;

assign out = cnt;

always @(posedge clk or negedge rst_n) begin
  if (!rst_n) begin
    cnt <= CNT_FROM;
  end else begin
    if (cnt == CNT_TO) begin
      cnt <= CNT_FROM;
    end else begin
      cnt <= cnt - 1;
    end
  end
end

endmodule
