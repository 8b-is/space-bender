.section .rodata
default_msg: .asciz "One for you, one for me."
prefix_msg: .asciz "One for "
suffix_msg: .asciz ", one for me."

.section .text
.global two_fer
two_fer:
    cbz x0, .Lno_name
    adrp x2, prefix_msg@PAGE
    add x2, x2, prefix_msg@PAGEOFF
    bl _copy_16
    mov x2, x0
    bl _copy_str
    adrp x2, suffix_msg@PAGE
    add x2, x2, suffix_msg@PAGEOFF
    bl _copy_16
    ret

.Lno_name:
    adrp x2, default_msg@PAGE
    add x2, x2, default_msg@PAGEOFF
    b _copy_16_fixed

_copy_16:
    ldr q0, [x2]
    str q0, [x1]
    ldr q0, [x2, #16]
    str q0, [x1, #16]
    ret

_copy_str:
    stp x1, x2, [sp, #-16]!
.Lloop:
    ldrb w3, [x2], #1
    strb w3, [x1], #1
    cbnz w3, .Lloop
    ldp x1, x2, [sp], #16
    ret

_copy_str_fixed:
    ldrb w3, [x2], #1
    strb w3, [x1], #1
    cbnz w3, .Lcopy_str_fixed
    ret

_copy_16_fixed:
    ldr q0, [x2]
    str q0, [x1]
    ldr q0, [x2, #16]
    str q0, [x1, #16]
    ret
