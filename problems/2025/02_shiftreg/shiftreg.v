module shiftreg #(
  parameter WIDTH = 8
)(
  input wire clk,
  input wire rst_n,
  input wire i_we,
  input wire [WIDTH-1:0] i_wr,
  output wire o_msb
);

reg [WIDTH-1:0] shft_reg;

assign o_msb = shft_reg[WIDTH-1];

always @(posedge clk or negedge rst_n) begin
  if (!rst_n) begin
    shft_reg <= {WIDTH{1'b0}};
  end else if (i_we) begin
    shft_reg <= i_wr;
    $display("reg %b <- %b", shft_reg, i_wr);
  end else begin
    shft_reg <= {shft_reg[WIDTH-2:0], 1'b0};
  end
end
endmodule
