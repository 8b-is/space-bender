.section .text
.global leap_year
leap_year:
    mov w1, #400
    udiv w2, w0, w1
    msub w2, w2, w1, w0
    cbz w2, .is_leap
    
    mov w1, #100
    udiv w2, w0, w1
    msub w2, w2, w1, w0
    cbz w2, .not_leap
    
    mov w1, #4
    udiv w2, w0, w1
    msub w2, w2, w1, w0
    cbz w2, .is_leap
    
.not_leap:
    mov w0, #0
    ret
    
.is_leap:
    mov w0, #1
    ret
