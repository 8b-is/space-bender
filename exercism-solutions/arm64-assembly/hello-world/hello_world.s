.section .text
.global hello
hello:
    adrp x0, msg@PAGE
    add x0, x0, msg@PAGEOFF
    ret

.section .rodata
msg: .asciz "Hello, World!"
