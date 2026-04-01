module sync_fifo #(
  parameter DATAW = 32,
  parameter ADDRW = 8
)(
  input wire [DATAW-1:0] i_wr_data,
  input wire i_wr_en,
  input wire i_rd_en,
  input wire clk,
  input wire rst_n,
  output wire o_wr_full,
  output wire o_rd_empty,
  output reg [DATAW-1:0] o_rd_data
);

reg [DATAW-1:0] buff [ADDRW-1:0];
reg [ADDRW:0] rd_ptr;
reg [ADDRW:0] wr_ptr;
wire [ADDRW-1:0] rd_addr;
wire [ADDRW-1:0] wr_addr;

assign rd_addr = rd_ptr[ADDRW-1:0];
assign wr_addr = wr_ptr[ADDRW-1:0];

assign o_rd_empty = wr_addr == rd_addr &&
                    wr_ptr[ADDRW] == rd_ptr[ADDRW];

assign o_wr_full = wr_addr == rd_addr &&
                   wr_ptr[ADDRW] != rd_ptr[ADDRW];

always @(posedge clk or negedge rst_n) begin
  if (!rst_n) begin
    rd_ptr <= 0;
    wr_ptr <= 0;
  end else begin
    if (i_rd_en && !o_rd_empty) begin
      o_rd_data <= buff[rd_addr];
      rd_ptr <= rd_ptr + 1;
    end

    if (i_wr_en) begin
      buff[wr_addr] <= i_wr_data;
      wr_ptr <= wr_ptr + 1;
    end
  end
end

endmodule
