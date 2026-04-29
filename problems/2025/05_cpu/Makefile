TB_LIST := src/cpu_top_tb.v

RTL_LIST := 		\
	src/cpu_top.v	\
	src/core.v		\
	src/alu.v		\
	src/cmp.v		\
	src/rf_2r1w.v	\
	src/control.v	\
	src/imem.v		\
	src/dmem.v		\
	src/maskgen.v	\
	src/mem_xbar.v	\
	src/mmio_xbar.v	\
	src/hex_display.v	\
	src/mux4.v		\
	src/lsu.v		\

sim: $(TB_LIST) $(RTL_LIST)
	iverilog -I./src/ $^ -o sim
	./sim

waves: dump.vcd
	gtkwave dump.vcd -A &

samples:
	$(MAKE) -C samples/

syn:
	~/altera_lite/25.1std/quartus/bin/quartus_sh --flow compile fpga

gui:
	~/altera_lite/25.1std/quartus/bin/quartus fpga &

pgm:
	~/altera_lite/25.1std/quartus/bin/quartus_pgm -c "USB-Blaster" -m JTAG -o "p;output/fpga.sof"

clean:
	rm -rf sim dump.vcd
	rm -rf db incremental_db output fpga.qws greybox_tmp *.bak
	$(MAKE) -C samples/ clean

.PHONY: syn fpga clean samples gui sim waves
