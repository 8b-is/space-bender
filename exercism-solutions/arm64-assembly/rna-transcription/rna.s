.section .text
.global to_rna
to_rna:
    cbz x0, .Ldone
    cbz x1, .Ldone
.Lloop:
    ldrb w2, [x0], #1
    cbz w2, .Ldone
    cmp w2, #'C'
    beq .Lout_G
    cmp w2, #'G'
    beq .Lout_C
    cmp w2, #'T'
    beq .Lout_A
    cmp w2, #'A'
    beq .Lout_U
    strb w2, [x1], #1
    b .Lloop
.Lout_G:
    mov w2, #'G'
    strb w2, [x1], #1
    b .Lloop
.Lout_C:
    mov w2, #'C'
    strb w2, [x1], #1
    b .Lloop
.Lout_A:
    mov w2, #'A'
    strb w2, [x1], #1
    b .Lloop
.Lout_U:
    mov w2, #'U'
    strb w2, [x1], #1
    b .Lloop
.Ldone:
    strb wzr, [x1]
    ret
