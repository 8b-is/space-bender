// Apple Silicon AArch64 NEON SIMD Assembly for Ternary Matrix Contraction (3 kyu)
// Exports:
//   int32_t ternary_dot_neon_i16(const int16_t *acts, const int8_t *trits, size_t len);
//
// Zero-multiplier 8-lane NEON kernel:
//   v0.8h = acts[i..i+8]
//   v1.8b = trits[i..i+8] -> sshll v1.8h, v1.8b, #0
//   v2.8h = sshr v1.8h, #15          (sign mask: 0xFFFF if -1, 0x0000 otherwise)
//   v3.8h = cmtst v1.8h, v1.8h       (non-zero mask: 0xFFFF if != 0, 0x0000 if 0)
//   v0.8h = eor v0.8h, v2.8h
//   v0.8h = sub v0.8h, v0.8h, v2.8h  ((act ^ sign) - sign)
//   v0.8h = and v0.8h, v0.8h, v3.8h  (zero out lanes where trit == 0)
//   v4.4s = sadalp v4.4s, v0.8h      (pairwise signed widen & accumulate into 4 x i32)

    .section __TEXT,__text,regular,pure_instructions
    .globl _ternary_dot_neon_i16
    .p2align 2
_ternary_dot_neon_i16:
    movi    v4.4s, #0
    cmp     x2, #8
    b.lo    .Lscalar_tail

.Lneon_loop:
    ldr     q0, [x0], #16           // v0.8h = 8 x int16_t activations
    ldr     d1, [x1], #8            // v1.8b = 8 x int8_t trits (-1, 0, +1)
    sshll   v1.8h, v1.8b, #0        // sign-extend 8 x i8 -> 8 x i16
    sshr    v2.8h, v1.8h, #15       // v2.8h = sign mask (0xFFFF for -1, 0x0000 else)
    cmtst   v3.8h, v1.8h, v1.8h     // v3.8h = non-zero mask (0xFFFF for +/-1, 0x0000 for 0)
    eor     v0.16b, v0.16b, v2.16b  // act ^ sign
    sub     v0.8h, v0.8h, v2.8h     // (act ^ sign) - sign
    and     v0.16b, v0.16b, v3.16b  // mask by non-zero trit
    sadalp  v4.4s, v0.8h            // pairwise widen i16 -> i32 & accumulate
    subs    x2, x2, #8
    cmp     x2, #8
    b.hs    .Lneon_loop

.Lscalar_tail:
    addv    s4, v4.4s               // horizontal sum of 4 x i32 lanes
    fmov    w3, s4                  // w3 = running i32 total
    cbz     x2, .Ldone

.Ltail_loop:
    ldrsh   w4, [x0], #2            // w4 = act (sign-extended i16 -> i32)
    ldrsb   w5, [x1], #1            // w5 = trit (-1, 0, +1)
    asr     w6, w5, #31             // w6 = sign mask
    and     w7, w5, #1
    neg     w7, w7                  // w7 = non-zero mask
    eor     w4, w4, w6
    sub     w4, w4, w6
    and     w4, w4, w7
    add     w3, w3, w4
    subs    x2, x2, #1
    b.ne    .Ltail_loop

.Ldone:
    mov     w0, w3
    ret
