`define IMEM_FILE_TXT   "samples/lui.txt"

`define IMEM_ADDR_WIDTH 7

`define DMEM_ADDR_WIDTH 30

`define XBAR_MMIO_START 30'h0000
`define XBAR_MMIO_LIMIT 30'h00028 >> 2 // 0x0a
`define XBAR_DATA_START 30'h0002c >> 2 // 0x0b
`define XBAR_DATA_LIMIT 30'h3FFF  >> 2

`define MMIO_7SEG_START 30'h20 >> 2 // 0x08
