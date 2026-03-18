module clkdiv #(
  parameter F0 = 50_000_000,
  parameter F1 = 12_500_000
)(
  input clk,
  input rst_n,
  output out
);

localparam CNT_WIDTH = $clog2(F0/F1);
localparam MAX_CNT = F0/F1;

reg [CNT_WIDTH-1:0] cnt;

assign out = cnt == MAX_CNT;

always @(posedge clk or negedge rst_n) begin
  if (!rst_n) begin
    cnt <= {CNT_WIDTH{1'b0}};
  end else begin
    if (cnt <= MAX_CNT) begin
      cnt <= cnt + 1;
    end else begin
      cnt <= 0;
    end
  end
end

endmodule
