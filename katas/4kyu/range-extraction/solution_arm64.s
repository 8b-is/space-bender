// Codewars 4 kyu — Range Extraction (Apple Silicon AArch64 Assembly)
// ID: 51ba717bb08c1cd60f00002f
//
// ABI (AAPCS64):
//   size_t range_extraction_asm(const int64_t *arr, size_t n, char *out_buf)
//   x0 = pointer to sorted int64_t array
//   x1 = number of elements `n`
//   x2 = output buffer for null-terminated range string
//   x0 (return) = length of formatted string

.section __TEXT,__text,regular,pure_instructions
.globl _range_extraction_asm
.globl range_extraction_asm
.p2align 2
_range_extraction_asm:
range_extraction_asm:
    stp x29, x30, [sp, #-64]!
    mov x29, sp
    stp x19, x20, [sp, #16]
    stp x21, x22, [sp, #32]
    stp x23, x24, [sp, #48]

    mov x19, x0                         // x19 = arr
    mov x20, x1                         // x20 = n
    mov x21, x2                         // x21 = out_ptr (cursor)
    mov x22, x2                         // x22 = out_buf base

    cbz x20, Ldone

    mov x23, #0                         // x23 = i = 0
Lrun_loop:
    cmp x23, x20
    b.hs Ldone

    cbz x23, Lfind_end
    mov w3, #','
    strb w3, [x21], #1

Lfind_end:
    mov x24, x23                        // x24 = j = i
Lextend_run:
    add x4, x24, #1
    cmp x4, x20
    b.hs Lformat_run
    ldr x5, [x19, x24, lsl #3]
    ldr x6, [x19, x4, lsl #3]
    add x5, x5, #1
    cmp x6, x5
    b.ne Lformat_run
    mov x24, x4
    b Lextend_run

Lformat_run:
    ldr x0, [x19, x23, lsl #3]
    bl Lemit_i64

    sub x4, x24, x23                    // span = j - i
    cbz x4, Ladvance_i
    cmp x4, #1
    b.eq Lpair_run

    mov w3, #'-'
    strb w3, [x21], #1
    ldr x0, [x19, x24, lsl #3]
    bl Lemit_i64
    b Ladvance_i

Lpair_run:
    mov w3, #','
    strb w3, [x21], #1
    ldr x0, [x19, x24, lsl #3]
    bl Lemit_i64

Ladvance_i:
    add x23, x24, #1
    b Lrun_loop

Ldone:
    strb wzr, [x21]
    sub x0, x21, x22

    ldp x19, x20, [sp, #16]
    ldp x21, x22, [sp, #32]
    ldp x23, x24, [sp, #48]
    ldp x29, x30, [sp], #64
    ret

// Helper: Lemit_i64
// Input: x0 = signed 64-bit integer, x21 = out_ptr
// Output: x21 advanced past emitted digits
Lemit_i64:
    sub sp, sp, #32
    tbz x0, #63, 1f
    mov w1, #'-'
    strb w1, [x21], #1
    neg x0, x0
1:
    add x2, sp, #32
    mov x3, #10
2:
    udiv x4, x0, x3
    msub x5, x4, x3, x0
    add w5, w5, #'0'
    strb w5, [x2, #-1]!
    mov x0, x4
    cbnz x0, 2b

    add x6, sp, #32
3:
    cmp x2, x6
    b.hs 4f
    ldrb w5, [x2], #1
    strb w5, [x21], #1
    b 3b
4:
    add sp, sp, #32
    ret
