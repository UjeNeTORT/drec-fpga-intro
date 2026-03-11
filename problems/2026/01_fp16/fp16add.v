module fp16add (
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

reg [9:0] m_res_norm;
reg [4:0] exp_res;
reg sgn_res;

always @(i_a, i_b) begin
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

  exp_diff = exp_1 - exp_2;

  mw_2 = mw_2 >> exp_diff;

  mw_sum = sgn_1 == 0 ?  $signed(mw_1)
                      : -$signed(mw_1);
  mw_sum = sgn_2 == 0 ? $signed(mw_sum) + $signed(mw_2)
                      : $signed(mw_sum) - $signed(mw_2);

  sgn_res = mw_sum[14];
  mw_sum_abs = sgn_res == 1 ? -$signed(mw_sum)
                            : mw_sum;

  // find leading one
  flo_found = 0;
  m_shift = 0;
  for (integer i = 0; i < 13; i++) begin
    // mw_sum_abs[14] == 0 because the number is positive
    if (mw_sum_abs[13 - i] == 1 && !flo_found) begin
      flo_found = 1;
      m_shift = i;
    end
  end

  // 01x.xxxxxxxxxxxx
  //   +---------+
  mw_sum_abs_norm = mw_sum_abs << m_shift;
  m_res_norm = mw_sum_abs_norm[12:3]; // round towards zero
  exp_res = exp_1 + 1 - m_shift; // + 1 to handle 1.0 + 1.1 = 11.1 case (msb)

  o_res = {sgn_res, exp_res, m_res_norm};
end
endmodule
