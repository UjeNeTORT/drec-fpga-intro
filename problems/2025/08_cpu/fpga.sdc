## Generated SDC file "fpga.sdc"

## Copyright (C) 2025  Altera Corporation. All rights reserved.
## Your use of Altera Corporation's design tools, logic functions 
## and other software and tools, and any partner logic 
## functions, and any output files from any of the foregoing 
## (including device programming or simulation files), and any 
## associated documentation or information are expressly subject 
## to the terms and conditions of the Altera Program License 
## Subscription Agreement, the Altera Quartus Prime License Agreement,
## the Altera IP License Agreement, or other applicable license
## agreement, including, without limitation, that your use is for
## the sole purpose of programming logic devices manufactured by
## Altera and sold by Altera or its authorized distributors.  Please
## refer to the Altera Software License Subscription Agreements 
## on the Quartus Prime software download page.


## VENDOR  "Altera"
## PROGRAM "Quartus Prime"
## VERSION "Version 25.1std.0 Build 1129 10/21/2025 SC Lite Edition"

## DATE    "Thu May 21 13:34:44 2026"

##
## DEVICE  "EP4CE15F23C8"
##


#**************************************************************
# Time Information
#**************************************************************


#**************************************************************
# Create Clock
#**************************************************************

create_clock -period "50.0 MHz" [get_ports CLK]
#**************************************************************
# Create Generated Clock
#**************************************************************



#**************************************************************
# Set Clock Latency
#**************************************************************



#**************************************************************
# Set Clock Uncertainty
#**************************************************************

derive_clock_uncertainty


#**************************************************************
# Set Input Delay
#**************************************************************



#**************************************************************
# Set Output Delay
#**************************************************************



#**************************************************************
# Set Clock Groups
#**************************************************************



#**************************************************************
# Set False Path
#**************************************************************

set_false_path -to [get_ports {OE}]
set_false_path -to [get_ports {DS}]
set_false_path -to [get_ports {STCP}]
set_false_path -to [get_ports {SHCP}]
set_false_path -from [get_ports {RSTN}] -to [all_clocks]
set_false_path -from [get_keepers {system_top:system_top|cpu_top:cpu_top|imem:imem|imem1r32x256:imem1r32x256|altsyncram:altsyncram_component|altsyncram_5bc1:auto_generated|ram_block1a0~porta_address_reg0}] -to [get_keepers {system_top:system_top|cpu_top:cpu_top|imem:imem|imem1r32x256:imem1r32x256|altsyncram:altsyncram_component|altsyncram_5bc1:auto_generated|ram_block1a0~porta_address_reg0}]
set_false_path -from [get_keepers {system_top:system_top|cpu_top:cpu_top|dmem:dmem|ram1rw32x256:ram1rw32x256|altsyncram:altsyncram_component|altsyncram_01j1:auto_generated|ram_block1a8~porta_re_reg}] -to [get_keepers {system_top:system_top|cpu_top:cpu_top|imem:imem|imem1r32x256:imem1r32x256|altsyncram:altsyncram_component|altsyncram_5bc1:auto_generated|ram_block1a0~porta_address_reg0}]
set_false_path -from [get_keepers {system_top:system_top|cpu_top:cpu_top|core:core|lsu:lsu|addr_d[6]}] -to [get_keepers {system_top:system_top|cpu_top:cpu_top|imem:imem|imem1r32x256:imem1r32x256|altsyncram:altsyncram_component|altsyncram_5bc1:auto_generated|ram_block1a0~porta_address_reg0}]


#**************************************************************
# Set Multicycle Path
#**************************************************************



#**************************************************************
# Set Maximum Delay
#**************************************************************



#**************************************************************
# Set Minimum Delay
#**************************************************************



#**************************************************************
# Set Input Transition
#**************************************************************

