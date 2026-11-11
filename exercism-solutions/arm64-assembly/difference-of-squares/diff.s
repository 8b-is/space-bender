.section .text
.global square_of_sum
square_of_sum:
    mov w1, w0
    add w1, w1, #1
    mul w0, w0, w1
    lsr w0, w0, #1
    mul w0, w0, w0
    ret

.global sum_of_squares
sum_of_squares:
    mov w1, w0
    add w1, w1, #1
    mov w2, w0
    add w2, w2, w0
    add w2, w2, #1
    mul w0, w0, w1
    mul w0, w0, w2
    mov w1, #6
    udiv w0, w0, w1
    ret

.global difference_of_squares
difference_of_squares:
    mov w20, w0
    mov w1, w0
    add w1, w1, #1
    mul w0, w0, w1
    lsr w0, w0, #1
    mul w0, w0, w0
    mov w19, w0
    mov w0, w20
    mov w1, w0
    add w1, w1, #1
    mov w2, w0
    add w2, w2, w0
    add w2, w2, #1
    mul w0, w0, w1
    mul w0, w0, w2
    mov w1, #6
    udiv w0, w0, w1
    sub w0, w19, w0
    ret
