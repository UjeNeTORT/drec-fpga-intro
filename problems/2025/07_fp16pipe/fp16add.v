module lead_one_detector (
  input  wire [14:0] i_src,
  output reg         o_found,
  output reg   [3:0] o_shift
);

always @(*) begin
  o_found = 1'b1;
  casex (i_src)
    15'b01x_xxxx_xxxx_xxxx: o_shift = 4'd0;
    15'b001_xxxx_xxxx_xxxx: o_shift = 4'd1;
    15'b000_1xxx_xxxx_xxxx: o_shift = 4'd2;
    15'b000_01xx_xxxx_xxxx: o_shift = 4'd3;
    15'b000_001x_xxxx_xxxx: o_shift = 4'd4;
    15'b000_0001_xxxx_xxxx: o_shift = 4'd5;
    15'b000_0000_1xxx_xxxx: o_shift = 4'd6;
    15'b000_0000_01xx_xxxx: o_shift = 4'd7;
    15'b000_0000_001x_xxxx: o_shift = 4'd8;
    15'b000_0000_0001_xxxx: o_shift = 4'd9;
    15'b000_0000_0000_1xxx: o_shift = 4'd10;
    15'b000_0000_0000_01xx: o_shift = 4'd11;
    15'b000_0000_0000_001x: o_shift = 4'd12;
    15'b000_0000_0000_0001: o_shift = 4'd13;
    default: begin
      o_found = 1'b0;
      o_shift = 4'd0;
    end
  endcase
end
endmodule

module fp16add (
  input wire        clk,
  input wire [15:0] i_a, i_b,
  output reg [15:0] o_res
);

reg [4:0] exp_diff;
reg [5:0] exp_diff_wide;
reg [14:0] mw_1, mw_2; // wide mantissa: (1).M -> 001.M00
reg [14:0] mw_sum; // wide mantissa sum: (1).M -> 001.M00
reg [14:0] mw_sum_abs; // wide mantissa sum abs
reg [14:0] mw_sum_abs_norm; // wide mantissa sum abs normalized
reg sgn_1, sgn_2;
reg [4:0] exp_1, exp_2;

wire [3:0] m_shift;
wire flo_found;

lead_one_detector lead_one_detector_inst (
  .i_src(mw_sum_abs),
  .o_found(flo_found),
  .o_shift(m_shift)
);

reg [9:0] m_res_norm;
reg [4:0] exp_res;
reg sgn_res;

// pipeline registers
reg [14:0] ppl_reg_mw_1, ppl_reg_mw_2;
reg        ppl_reg_sgn_1, ppl_reg_sgn_2;
reg  [4:0] ppl_reg_exp_1;
reg [15:0] next_res;

always @(posedge clk) begin
  ppl_reg_mw_1  <= mw_1;
  ppl_reg_mw_2  <= mw_2;
  ppl_reg_sgn_1 <= sgn_1;
  ppl_reg_sgn_2 <= sgn_2;
  ppl_reg_exp_1 <= exp_1;
  o_res         <= next_res;
end

// Stage 1
always @(*) begin
  if (i_a[14:10] < i_b[14:10]) begin
    // i_a < i_b
    // then swap a and b so that mw_1 corresponds to greater (absolutely) number
    mw_1 = {3'b001, i_b[9:0], 2'b00};
    mw_2 = {3'b001, i_a[9:0], 2'b00};
    exp_1 = i_b[14:10];
    exp_2 = i_a[14:10];
    sgn_1 = i_b[15];
    sgn_2 = i_a[15];
  end else begin
    mw_1 = {3'b001, i_a[9:0], 2'b00};
    mw_2 = {3'b001, i_b[9:0], 2'b00};
    exp_1 = i_a[14:10];
    exp_2 = i_b[14:10];
    sgn_1 = i_a[15];
    sgn_2 = i_b[15];
  end

  // denormal as zero
  if (exp_1 == 0) mw_1[11:0] = 0;
  if (exp_2 == 0) mw_2[11:0] = 0;

  exp_diff = exp_1 - exp_2;
  mw_2 = mw_2 >> exp_diff;
end

// Stage 2
always @(*) begin
  // sign magnitude adder
  mw_sum = ppl_reg_sgn_1 == 0 ?  $signed(ppl_reg_mw_1)
                              : -$signed(ppl_reg_mw_1);
  mw_sum = ppl_reg_sgn_2 == 0 ? $signed(mw_sum) + $signed(ppl_reg_mw_2)
                              : $signed(mw_sum) - $signed(ppl_reg_mw_2);
  sgn_res = mw_sum[14];
  mw_sum_abs = sgn_res == 1 ? -$signed(mw_sum) : mw_sum;

  if (ppl_reg_exp_1 == 5'b11111) begin
    exp_res = 0;
    next_res = {ppl_reg_sgn_1, ppl_reg_exp_1, ppl_reg_mw_1[11:2]};
  end else begin
    // find leading one

    if (flo_found != 0) begin
      // 01x.xxxxxxxxxxxx
      //   +---------+
      mw_sum_abs_norm = mw_sum_abs << m_shift;
      m_res_norm = mw_sum_abs_norm[12:3]; // round towards zero

      if (ppl_reg_exp_1 + 1 > m_shift) begin
        exp_res = ppl_reg_exp_1 + 5'b1 - m_shift;
      end else begin
        exp_res = 0; // exp < 0 -> denormal case
      end

      // flush denormals to zero
      if (exp_res == 0) begin
        m_res_norm = 0;
      end
    end else begin
      // no leading one => result is 0
      exp_res = 0;
      m_res_norm = 0;
      sgn_res = 0;
    end
    next_res = {sgn_res, exp_res, m_res_norm};
  end
end
endmodule
