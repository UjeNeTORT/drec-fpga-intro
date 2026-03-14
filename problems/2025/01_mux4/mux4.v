module mux4 #(
  parameter WIDTH = 4
)(
  input  wire [WIDTH-1:0] i_1, i_2, i_3, i_4,
  input  wire [1:0]       i_sel,
  output reg  [WIDTH-1:0] o_res
);

always @(*) begin
  case (i_sel)
    2'b00:   o_res = i_1;
    2'b01:   o_res = i_2;
    2'b10:   o_res = i_3;
    2'b11:   o_res = i_4;
    default: o_res = 2'bxx;
  endcase;
end

endmodule
