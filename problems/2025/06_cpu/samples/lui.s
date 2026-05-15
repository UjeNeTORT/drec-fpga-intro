# RISC-V 32I LUI Test with 7-Segment MMIO
.section .text
.globl _start

_start:
    # Set up MMIO address in x10
    li  x10, 0x20

    # --- Test 1: Standard Pattern ---
    lui x1, 0x55555
    li  x2, 0x55555000
    bne x1, x2, fail

    # --- Test 2: All 1s ---
    lui x3, 0xFFFFF
    li  x4, 0xFFFFF000
    bne x3, x4, fail

    # --- Test 3: All 0s ---
    lui x5, 0x00000
    bne x5, x0, fail

    # --- Test 4: Overwrite check ---
    li  x6, -1
    lui x6, 0x12345
    li  x7, 0x12345000
    bne x6, x7, fail

pass:
    # Output '1' to MMIO address 0x20
    li  x8, 1
    sw  x8, 0(x10)

spin_pass:
    j spin_pass

fail:
    # Output 'e' (or 0xE) to MMIO address 0x20
    # Depending on your decoder, 0xE usually represents 'E' for Error
    li  x8, 0xE
    sw  x8, 0(x10)

spin_fail:
    j spin_fail
