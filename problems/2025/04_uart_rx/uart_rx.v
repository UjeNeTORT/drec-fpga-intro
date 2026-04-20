module uart_rx # (
  parameter FREQ = 50_000_000,
  parameter RATE =  2_000_000
)(
  input wire clk,
  input wire rst_n,
  input wire i_rx,

  output wire [7:0] o_data,
  output wire o_vld
);

reg [7:0] data;
reg rx_buf;
reg shift_en;

wire rx_fall;
wire en;

reg [3:0] state, next_state;

localparam [3:0] IDLE  = {1'b0, 3'd0},
                 START = {1'b0, 3'd1},
                 STOP  = {1'b0, 3'd2},
                 BIT0  = {1'b1, 3'd0},
                 BIT1  = {1'b1, 3'd1},
                 BIT2  = {1'b1, 3'd2},
                 BIT3  = {1'b1, 3'd3},
                 BIT4  = {1'b1, 3'd4},
                 BIT5  = {1'b1, 3'd5},
                 BIT6  = {1'b1, 3'd6},
                 BIT7  = {1'b1, 3'd7};

counter #(
    .CNT_WIDTH  ($clog2(FREQ/RATE)),
    .CNT_LOAD   (0                ),
    .CNT_MAX    (FREQ/RATE-1      )
) cnt (
    .clk        (clk  ),
    .rst_n      (rst_n),
    .i_load     (rx_fall && state == IDLE),
    .o_en       (en   )
);

assign rx_fall =
  rx_buf == 1 && i_rx == 0;

assign o_data = data;
assign o_vld  = i_rx && state == STOP;

always @(posedge clk or negedge rst_n) begin
  if (!rst_n) begin
    state <= IDLE;
  end else begin
    state <= next_state;
    rx_buf <= i_rx;
    if (shift_en) begin
      data <= {i_rx, data[7:1]};
    end
  end
end

always @(*) begin
  case (state)
    IDLE:  next_state = rx_fall ? START : state;
    START: next_state = en      ? BIT0  : state;
    BIT0:  next_state = en      ? BIT1  : state;
    BIT1:  next_state = en      ? BIT2  : state;
    BIT2:  next_state = en      ? BIT3  : state;
    BIT3:  next_state = en      ? BIT4  : state;
    BIT4:  next_state = en      ? BIT5  : state;
    BIT5:  next_state = en      ? BIT6  : state;
    BIT6:  next_state = en      ? BIT7  : state;
    BIT7:  next_state = en      ? STOP  : state;
    STOP:  next_state = en      ? IDLE  : state;
    default: next_state = state;
  endcase
end

always @(*) begin
  case (state)
    IDLE, STOP, BIT7:  shift_en = 1'b0;
    default:           shift_en = en;
  endcase
end

endmodule
