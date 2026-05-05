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

always @(posedge CLK) begin
    rst_n  <= RSTN_d;
    RSTN_d <= RSTN;
end

wire  [3:0] anodes;
wire  [7:0] segments;

wire pll_locked;
wire clk_pll;

pll	pll_inst (
	.areset (~RSTN),
	.inclk0 (CLK),
	.c0     (clk_pll),
	.locked (pll_locked)
);

wire rst_n_pll = rst_n & pll_locked;

system_top system_top (
    .clk         (clk_pll   ),
    .rst_n       (rst_n_pll ),
    .anodes      (anodes    ),
    .segments    (segments  )
);

ctrl_74hc595 ctrl_74hc595 (
    .clk        (clk_pll            ),
    .rst_n      (rst_n_pll          ),
    .i_data     ({segments, anodes} ),
    .o_stcp     (STCP               ),
    .o_shcp     (SHCP               ),
    .o_ds       (DS                 ),
    .o_oe       (OE                 )
);

endmodule
