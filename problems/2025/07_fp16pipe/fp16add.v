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
reg [3:0] m_shift;
reg flo_found;
integer i;

reg [9:0] m_res_norm;
reg [4:0] exp_res;
reg sgn_res;

// pipeline registers
reg [14:0] ppl_reg_mw_1, ppl_reg_mw_2;
reg        ppl_reg_sgn_1, ppl_reg_sgn_2;
reg  [4:0] ppl_reg_exp_1;

always @(posedge clk) begin
  ppl_reg_mw_1  <= mw_1;
  ppl_reg_mw_2  <= mw_2;
  ppl_reg_sgn_1 <= sgn_1;
  ppl_reg_sgn_2 <= sgn_2;
  ppl_reg_exp_1 <= exp_1;
end

always @(*) begin
  o_res = 16'b0;
  // exp_diff = i_a[14:10] - i_b[14:10];
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

  // sign magnitude adder
  mw_sum = ppl_reg_sgn_1 == 0 ?  $signed(ppl_reg_mw_1)
                              : -$signed(ppl_reg_mw_1);
  mw_sum = ppl_reg_sgn_2 == 0 ? $signed(mw_sum) + $signed(ppl_reg_mw_2)
                              : $signed(mw_sum) - $signed(ppl_reg_mw_2);
  sgn_res = mw_sum[14];
  mw_sum_abs = sgn_res == 1 ? -$signed(mw_sum) : mw_sum;

  if (ppl_reg_exp_1 == 5'b11111) begin
    o_res = {ppl_reg_sgn_1, ppl_reg_exp_1, ppl_reg_mw_1};
  end else begin
    // find leading one
    flo_found = 0;
    m_shift = 0;
    for (i = 0; i < 13; i = i + 1) begin
      // mw_sum_abs[14] == 0 because the number is positive
      if (mw_sum_abs[13 - i] == 1 && !flo_found) begin
        flo_found = 1;
        m_shift = i;
      end
    end

    if (flo_found != 0) begin
      // 01x.xxxxxxxxxxxx
      //   +---------+
      mw_sum_abs_norm = mw_sum_abs << m_shift;
      m_res_norm = mw_sum_abs_norm[12:3]; // round towards zero

      if (ppl_reg_exp_1 + 1 > m_shift) begin
        exp_res = ppl_reg_exp_1 + 1 - m_shift;
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
    o_res = {sgn_res, exp_res, m_res_norm};
  end

end
endmodule
