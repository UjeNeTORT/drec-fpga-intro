li x5, 0x20 # mmio 7 segment display
addi x10, x0, %lo(target)
addi x10, x10, -1
jalr x1, 1(x10)

addi x6, x0, 0xE # 0xE for "Error"
sw x6, 0(x5)

target:
    addi x6, x0, 0x1 # 0x1 for "Success"
    sw x6, 0(x5)
