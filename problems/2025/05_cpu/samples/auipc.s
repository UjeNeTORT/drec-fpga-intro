# auipc_test.S - Standalone AUIPC verification for RISC-V 32I
# MMIO Output: 0x20 -> 1 (Pass), E (Fail)

.section .text
.globl _start

_start:
    # --- Setup ---
    li  x10, 0x20              # MMIO address for 7-segment display

    # --- Test 1: Basic PC + 0x1000 ---
test1:
    auipc x1, 0x00001          # x1 = current_pc + 0x1000
    la    x2, test1            # Load address of 'test1' label
    li    x3, 0x1000           # Use LI to avoid ADDI range issues
    add   x2, x2, x3           # x2 = address of test1 + 0x1000
    bne   x1, x2, fail         # If they don't match, hardware fail

    # --- Test 2: PC + 0 (Identity Check) ---
test2:
    auipc x4, 0x00000          # x4 = current_pc
    la    x5, test2            # x5 = address of 'test2' label
    bne   x4, x5, fail

    # --- Test 3: Large Immediate / Negative Offset ---
    # 0xFFFFF is treated as a 20-bit upper immediate.
    # When added to PC, it effectively subtracts 4096 bytes (2's complement).
test3:
    auipc x6, 0xFFFFF          # x6 = PC + 0xFFFFF000
    la    x7, test3
    lui   x8, 0xFFFFF          # Load 0xFFFFF into upper bits
    add   x7, x7, x8           # x7 = address of test3 + 0xFFFFF000
    bne   x6, x7, fail

    # --- Test 4: Register x0 Check ---
    # Writing any AUIPC result to x0 must result in 0
    auipc x0, 0x12345
    bne   x0, x0, fail

pass:
    li  x9, 1                  # Value for '1'
    sw  x9, 0(x10)             # Store to MMIO 0x20
    j   spin_pass

fail:
    li  x9, 0xE                # Value for 'E' (Error)
    sw  x9, 0(x10)             # Store to MMIO 0x20
    j   spin_fail

spin_pass:
    j   spin_pass

spin_fail:
    j   spin_fail
