`include "config.vh"

module fpga_top(
    input  wire CLK,
    input  wire RSTN,

    output wire STCP,
    output wire SHCP,
    output wire DS,
    output wire OE
);

reg rst_n, RSTN_d;

wire pll_locked;
wire clk_pll;

pll_50_to_40 pll_inst (
	.areset (~RSTN),
	.inclk0 (CLK),
	.c0     (clk_pll),
	.locked (pll_locked)
);

always @(posedge clk_pll) begin
    rst_n  <= RSTN_d;
	RSTN_d <= RSTN;
end

system_top system_top(
    .clk    (clk_pll  ),
    .rst_n  (rst_n    ),
    .o_stcp (STCP     ),
    .o_shcp (SHCP     ),
    .o_ds   (DS       ),
    .o_oe   (OE       )
);

endmodule
