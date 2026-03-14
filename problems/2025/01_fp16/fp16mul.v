module fp16mul (
  input wire [15:0] i_a, i_b,
  output reg [15:0] o_res
);

localparam BIAS = 15;

reg sign_res;
reg [5:0]  exp_sum; // do i have to explain?
reg [11:0] mw_1; // wide mantissa of i_a (+2 bits)
reg [11:0] mw_2; // wide mantissa of i_b (+2 bits)
reg [1:0]  shift_amt; // tmp storage for mantissa normalization
reg [5:0]  expw;   // wide exponent
reg [23:0] mw_res; // wide mantissa
reg [23:0] m_normalized; // stores {4'b0001, normalized mantissa, extra bits}

always @(i_a, i_b) begin
  o_res = 16'b0;

  sign_res = i_a[15] ^ i_b[15];

  if (i_a[14:10] == 0 || i_b[14:10] == 0) begin
    // +-0 * x = +-0
    // denormal * x = +-0 (DAZ)
    o_res[14:10] = 5'b0;
    o_res[9:0] = 10'b0;
  end else if (i_a[14:10] == 5'b11111 && i_a[9:0] != 0) begin
    // nan * x = nan
    o_res = i_a;
  end else if (i_b[14:10] == 5'b11111 && i_b[9:0] != 0) begin
    // x * nan = nan
    o_res = i_b;
  end else begin
    // E = E1 + E2 - BIAS
    exp_sum = i_a[14:10] + i_b[14:10] - BIAS;

    // (1).M -> MW = 01.M
    mw_1 = {2'b01, i_a[9:0]}; // wide mantissa 1
    mw_2 = {2'b01, i_b[9:0]}; // wide mantissa 2
    mw_res = mw_1 * mw_2;

    // normalize mantissa
    shift_amt = mw_res[23] == 1 ? 3 :
                mw_res[22] == 1 ? 2 :
                mw_res[21] == 1 ? 1 : 0;

    expw = (exp_sum + shift_amt);

    if (expw == 0) begin
      // ftz: denormal = 0
      o_res[14:10] = 5'b0;
      o_res[9:0] = 10'b0;
    end else if (expw >= 31) begin
      // inf
      o_res[14:10] = 5'b11111;
      o_res[9:0] = 10'b0;
    end else begin

    o_res[14:10] = expw[4:0];
    m_normalized = mw_res >> shift_amt;
    o_res[9:0] = m_normalized[19:10]; // round towards zero
    end
  end

  o_res[15] = sign_res;
end

endmodule
