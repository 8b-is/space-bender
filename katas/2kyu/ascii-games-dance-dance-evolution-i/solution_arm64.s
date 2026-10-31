// Codewars 2 kyu — ASCII Games: Dance Dance Evolution I (Apple Silicon AArch64 Assembly)
// ID: 58f58dc3663082a4ba000033
//
// ABI (AAPCS64):
//   size_t dance_asm(const char *map_utf8, char *out_utf8)
//   x0 = pointer to null-terminated UTF-8 maze string
//   x1 = pointer to output buffer receiving null-terminated UTF-8 arrow string
//   x0 (return) = number of steps in the longest simple cycle returning to S

.section __TEXT,__const
.p2align 4
Lutf8_to_dir:
    .byte 0, 2, 4, 6, 255, 255, 1, 3, 5, 7
Ldir_to_utf8_b3:
    .byte 0x90, 0x96, 0x91, 0x97, 0x92, 0x98, 0x93, 0x99
.p2align 2
Ldr_tab:
    .long 0, -1, -1, -1, 0, 1, 1, 1
Ldc_tab:
    .long -1, -1, 0, 1, 1, 1, 0, -1

.zerofill __DATA,__bss,Ltiles_buf,64,4
.zerofill __DATA,__bss,Lout_mask,512,4
.zerofill __DATA,__bss,Lin_mask,512,4
.zerofill __DATA,__bss,Ledge_dir,4096,4
.zerofill __DATA,__bss,Lcur_dirs,64,4
.zerofill __DATA,__bss,Lbest_dirs,64,4
.zerofill __DATA,__bss,Lstart_idx,8,3
.zerofill __DATA,__bss,Lall_arrows,8,3
.zerofill __DATA,__bss,Lbest_len,8,3

.section __TEXT,__text,regular,pure_instructions
.globl _dance_asm
.globl dance_asm
.p2align 2
_dance_asm:
dance_asm:
    stp x29, x30, [sp, #-96]!
    mov x29, sp
    stp x19, x20, [sp, #16]
    stp x21, x22, [sp, #32]
    stp x23, x24, [sp, #48]
    stp x25, x26, [sp, #64]
    stp x27, x28, [sp, #80]

    mov x19, x1                         // x19 = out_utf8

    // 1. Parse UTF-8 grid into Ltiles_buf
    adrp x8, Ltiles_buf@PAGE
    add x8, x8, Ltiles_buf@PAGEOFF
    adrp x9, Lutf8_to_dir@PAGE
    add x9, x9, Lutf8_to_dir@PAGEOFF

    mov w2, #0                          // n = 0
    mov w3, #0                          // rows = 0
    mov w4, #0                          // cur_col = 0
    mov w5, #0                          // cols = 0
    mov x6, #-1                         // start_idx = -1

1:
    ldrb w7, [x0]
    cbz w7, 5f
    cmp w7, #10                         // '\n'
    b.eq 3f
    cmp w7, #13                         // '\r'
    b.eq 4f
    cmp w7, #'S'
    b.eq 2f
    cmp w7, #0xE2
    b.ne 4f

    // 3-byte UTF-8 arrow
    ldrb w7, [x0, #2]
    sub w7, w7, #0x90
    ldrb w7, [x9, w7, uxtw]
    strb w7, [x8, w2, uxtw]
    add w2, w2, #1
    add w4, w4, #1
    add x0, x0, #3
    b 1b

2:
    mov w7, #8
    strb w7, [x8, w2, uxtw]
    uxtw x6, w2
    add w2, w2, #1
    add w4, w4, #1
    add x0, x0, #1
    b 1b

3:
    cbz w4, 4f
    mov w5, w4
    mov w4, #0
    add w3, w3, #1
4:
    add x0, x0, #1
    b 1b

5:
    cbz w4, 6f
    mov w5, w4
    add w3, w3, #1
6:
    cbz w2, Lret_empty
    tbnz x6, #63, Lret_empty

    adrp x10, Lstart_idx@PAGE
    add x10, x10, Lstart_idx@PAGEOFF
    str x6, [x10]

    // Clear Lout_mask and Lin_mask
    adrp x20, Lout_mask@PAGE
    add x20, x20, Lout_mask@PAGEOFF
    adrp x21, Lin_mask@PAGE
    add x21, x21, Lin_mask@PAGEOFF
    adrp x22, Ledge_dir@PAGE
    add x22, x22, Ledge_dir@PAGEOFF

    mov x7, #0
7:
    str xzr, [x20, x7, lsl #3]
    str xzr, [x21, x7, lsl #3]
    add x7, x7, #1
    cmp x7, #64
    b.lo 7b

    // 2. Build directed adjacency masks
    adrp x10, Ldr_tab@PAGE
    add x10, x10, Ldr_tab@PAGEOFF
    adrp x11, Ldc_tab@PAGE
    add x11, x11, Ldc_tab@PAGEOFF

    mov w12, #0                         // r = 0
Lbuild_r:
    cmp w12, w3
    b.ge Lbuild_done
    mov w13, #0                         // c = 0
Lbuild_c:
    cmp w13, w5
    b.ge Lbuild_next_r

    madd w14, w12, w5, w13              // u = r * cols + c
    ldrb w15, [x8, w14, uxtw]           // tu = tiles[u]

    mov w16, #0                         // d = 0..7
Lbuild_d:
    ldr w17, [x10, w16, uxtw #2]
    add w17, w12, w17                   // nr = r + dr[d]
    tbnz w17, #31, Lbuild_next_d
    cmp w17, w3
    b.ge Lbuild_next_d

    ldr w0, [x11, w16, uxtw #2]
    add w0, w13, w0                     // nc = c + dc[d]
    tbnz w0, #31, Lbuild_next_d
    cmp w0, w5
    b.ge Lbuild_next_d

    madd w17, w17, w5, w0               // v = nr * cols + nc

    // Check compatibility(tu, d)
    cmp w15, #8
    b.eq Ltu_ok
    sub w0, w15, w16
    cmp w0, #0
    cneg w0, w0, lt
    cmp w0, #2
    b.le Ltu_ok
    cmp w0, #6
    b.lt Lbuild_next_d
Ltu_ok:
    // Check compatibility(tv, d)
    ldrb w0, [x8, w17, uxtw]
    cmp w0, #8
    b.eq Ltv_ok
    sub w0, w0, w16
    cmp w0, #0
    cneg w0, w0, lt
    cmp w0, #2
    b.le Ltv_ok
    cmp w0, #6
    b.lt Lbuild_next_d
Ltv_ok:
    mov x0, #1
    uxtw x1, w17
    lsl x0, x0, x1
    ldr x7, [x20, w14, uxtw #3]
    orr x7, x7, x0
    str x7, [x20, w14, uxtw #3]         // out_mask[u] |= (1ULL << v)

    mov x0, #1
    uxtw x1, w14
    lsl x0, x0, x1
    ldr x7, [x21, w17, uxtw #3]
    orr x7, x7, x0
    str x7, [x21, w17, uxtw #3]         // in_mask[v] |= (1ULL << u)

    add w0, w17, w14, lsl #6
    strb w16, [x22, w0, uxtw]           // edge_dir[u*64 + v] = d

Lbuild_next_d:
    add w16, w16, #1
    cmp w16, #8
    b.lt Lbuild_d

    add w13, w13, #1
    b Lbuild_c
Lbuild_next_r:
    add w12, w12, #1
    b Lbuild_r

Lbuild_done:
    // Compute all_arrows_mask = ((1ULL << n) - 1) ^ (1ULL << start)
    mov x0, #-1
    cmp w2, #64
    b.eq 8f
    mov x0, #1
    uxtw x1, w2
    lsl x0, x0, x1
    sub x0, x0, #1
8:
    mov x1, #1
    lsl x1, x1, x6
    bic x23, x0, x1                     // x23 = all_arrows_mask
    mov x24, x6                         // x24 = start_idx
    mov x25, #0                         // x25 = best_len
    adrp x26, Lcur_dirs@PAGE
    add x26, x26, Lcur_dirs@PAGEOFF
    adrp x27, Lbest_dirs@PAGE
    add x27, x27, Lbest_dirs@PAGEOFF

    // 3. Run DFS(u = start, visited = 0, depth = 0)
    mov x0, x24
    mov x1, #0
    mov x2, #0
    bl Ldfs

    // 4. Encode best_dirs[0..best_len-1] as 3-byte UTF-8 arrows
    adrp x8, Ldir_to_utf8_b3@PAGE
    add x8, x8, Ldir_to_utf8_b3@PAGEOFF
    mov x2, #0
    mov x3, x19
Lencode_loop:
    cmp x2, x25
    b.ge Lencode_done
    ldrb w4, [x27, x2]
    ldrb w4, [x8, w4, uxtw]
    mov w5, #0xE2
    mov w6, #0x86
    strb w5, [x3]
    strb w6, [x3, #1]
    strb w4, [x3, #2]
    add x3, x3, #3
    add x2, x2, #1
    b Lencode_loop

Lencode_done:
    strb wzr, [x3]
    mov x0, x25
    b Lexit

Lret_empty:
    strb wzr, [x19]
    mov x0, #0

Lexit:
    ldp x19, x20, [sp, #16]
    ldp x21, x22, [sp, #32]
    ldp x23, x24, [sp, #48]
    ldp x25, x26, [sp, #64]
    ldp x27, x28, [sp, #80]
    ldp x29, x30, [sp], #96
    ret

// Recursive DFS:
// x0 = u, x1 = visited, x2 = depth
// Globals in callee-saved regs:
//   x20 = out_mask, x21 = in_mask, x22 = edge_dir,
//   x23 = all_arrows_mask, x24 = start_idx, x25 = best_len,
//   x26 = cur_dirs, x27 = best_dirs
Ldfs:
    stp x29, x30, [sp, #-64]!
    mov x29, sp
    stp x19, x28, [sp, #16]
    str x0, [sp, #32]                   // save u
    str x1, [sp, #40]                   // save visited
    str x2, [sp, #48]                   // save depth

    bic x3, x23, x1                     // x3 = avail = all_arrows_mask & ~visited

    // 1. Backward flood-fill from start: can_reach_s (x4)
    ldr x4, [x21, x24, lsl #3]
    and x4, x4, x3
1:
    mov x5, x4                          // next = can_reach_s
    mov x6, x4                          // m = can_reach_s
2:
    cbz x6, 3f
    rbit x7, x6
    clz x7, x7                          // v = ctz(m)
    sub x8, x6, #1
    and x6, x6, x8                      // m &= m - 1
    ldr x8, [x21, x7, lsl #3]
    and x8, x8, x3
    orr x5, x5, x8
    b 2b
3:
    cmp x5, x4
    b.eq 4f
    mov x4, x5
    b 1b
4:

    // 2. Forward flood-fill from u inside can_reach_s: reachable (x28)
    ldr x28, [x20, x0, lsl #3]
    and x28, x28, x4
5:
    mov x5, x28
    mov x6, x28
6:
    cbz x6, 7f
    rbit x7, x6
    clz x7, x7
    sub x8, x6, #1
    and x6, x6, x8
    ldr x8, [x20, x7, lsl #3]
    and x8, x8, x4
    orr x5, x5, x8
    b 6b
7:
    cmp x5, x28
    b.eq 8f
    mov x28, x5
    b 5b
8:

    // 3. Check direct return edge u -> start when depth > 0
    cbz x2, Lskip_return_s
    ldr x5, [x20, x0, lsl #3]
    lsr x5, x5, x24
    tbz x5, #0, Lskip_return_s

    add x6, x2, #1
    cmp x6, x25
    b.le Lskip_return_s

    mov x25, x6                         // best_len = depth + 1
    mov x7, #0
9:
    cmp x7, x2
    b.ge 10f
    ldrb w8, [x26, x7]
    strb w8, [x27, x7]
    add x7, x7, #1
    b 9b
10:
    add x7, x24, x0, lsl #6
    ldrb w8, [x22, x7]
    strb w8, [x27, x2]

Lskip_return_s:
    // 4. Upper-bound check: depth + popcnt(reachable) + 1 <= best_len
    fmov d0, x28
    cnt v0.8b, v0.8b
    uaddlv h0, v0.8b
    fmov w5, s0                         // w5 = popcnt(reachable)
    add x5, x2, w5, uxtw
    add x5, x5, #1
    cmp x5, x25
    b.le Ldfs_ret

    // 5. Branch over candidate neighbors in (out_mask[u] & reachable)
    ldr x19, [x20, x0, lsl #3]
    and x19, x19, x28                   // x19 = candidate neighbors bitmask
Lbranch_loop:
    cbz x19, Ldfs_ret
    rbit x7, x19
    clz x7, x7                          // x7 = v = ctz(x19)
    sub x8, x19, #1
    and x19, x19, x8

    ldr x0, [sp, #32]                   // u
    ldr x1, [sp, #40]                   // visited
    ldr x2, [sp, #48]                   // depth

    add x8, x7, x0, lsl #6
    ldrb w9, [x22, x8]
    strb w9, [x26, x2]                  // cur_dirs[depth] = edge_dir[u*64 + v]

    mov x8, #1
    lsl x8, x8, x7
    orr x1, x1, x8                      // visited | (1ULL << v)
    mov x0, x7                          // next u = v
    add x2, x2, #1                      // depth + 1
    bl Ldfs

    ldr x2, [sp, #48]                   // reload depth
    fmov d0, x28
    cnt v0.8b, v0.8b
    uaddlv h0, v0.8b
    fmov w5, s0
    add x5, x2, w5, uxtw
    add x5, x5, #1
    cmp x5, x25
    b.le Ldfs_ret
    b Lbranch_loop

Ldfs_ret:
    ldp x19, x28, [sp, #16]
    ldp x29, x30, [sp], #64
    ret
