.section .text
.global is_pangram
is_pangram:
    cbz x0, .Lnot_pangram
    mov x1, #0
.Lcheck_char:
    ldrb w2, [x0], #1
    cbz w2, .Lcheck_done
    cmp w2, #'A'
    blt .Lnext_char
    cmp w2, #'Z'
    bgt .Lcheck_lower
    sub w2, w2, #'A'
    b .Lset_bit
.Lcheck_lower:
    cmp w2, #'a'
    blt .Lnext_char
    cmp w2, #'z'
    bgt .Lnext_char
    sub w2, w2, #'a'
.Lset_bit:
    mov w3, #1
    lsl w3, w3, w2
    orr x1, x1, x3
.Lnext_char:
    b .Lcheck_char
.Lcheck_done:
    mov w3, #0x3FFFFFF
    cmp x1, x3
    cset w0, eq
    ret
.Lnot_pangram:
    mov w0, #0
    ret
