; x86-64 NASM SSE4.1 / AVX2 SIMD Assembly for Ternary Matrix Contraction (3 kyu)
; System V AMD64 ABI:
;   rdi = const int16_t *acts
;   rsi = const int8_t  *trits
;   rdx = size_t         len
; Returns:
;   eax = int32_t dot product

section .text
global ternary_dot_simd_i16

ternary_dot_simd_i16:
    pxor    xmm4, xmm4              ; xmm4 = 4 x i32 accumulator
    cmp     rdx, 8
    jb      .scalar_tail

.simd_loop:
    movdqu  xmm0, [rdi]             ; xmm0 = 8 x i16 activations
    movq    xmm1, [rsi]             ; low 8 bytes = 8 x i8 trits
    pmovsxbw xmm1, xmm1             ; sign-extend 8 x i8 -> 8 x i16
    psignw  xmm0, xmm1              ; branchless sign-apply: -act if trit<0, 0 if trit==0, +act if trit>0
    movdqa  xmm2, xmm0
    pcmpgtw xmm3, xmm3              ; zero
    pxor    xmm3, xmm3
    pcmpgtw xmm3, xmm0              ; sign extension mask for 8 x i16 -> 2 x 4 x i32
    movdqa  xmm5, xmm0
    punpcklwd xmm0, xmm3
    punpckhwd xmm5, xmm3
    paddd   xmm4, xmm0
    paddd   xmm4, xmm5
    add     rdi, 16
    add     rsi, 8
    sub     rdx, 8
    cmp     rdx, 8
    jae     .simd_loop

.scalar_tail:
    movdqa  xmm0, xmm4
    psrldq  xmm0, 8
    paddd   xmm4, xmm0
    movdqa  xmm0, xmm4
    psrldq  xmm0, 4
    paddd   xmm4, xmm0
    movd    eax, xmm4               ; eax = horizontal sum of 4 x i32

    test    rdx, rdx
    jz      .done

.tail_loop:
    movsx   ecx, word [rdi]
    movsx   r8d, byte [rsi]
    mov     r9d, r8d
    sar     r9d, 31                 ; sign mask
    and     r8d, 1
    neg     r8d                     ; non-zero mask
    xor     ecx, r9d
    sub     ecx, r9d
    and     ecx, r8d
    add     eax, ecx
    add     rdi, 2
    add     rsi, 1
    dec     rdx
    jnz     .tail_loop

.done:
    ret
