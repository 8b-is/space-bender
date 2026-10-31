// Codewars 2 kyu — Break the pieces (Apple Silicon AArch64 Assembly)
// ID: 527fde8d24b9309d9b000c4e
//
// ABI (AAPCS64):
//   size_t break_piece_asm(const char *shape, const char **out_pieces)
//   x0 = pointer to null-terminated input ASCII diagram
//   x1 = pointer to caller array of `const char *` to receive extracted pieces
//   x0 (return) = number of extracted minimal pieces

.section __TEXT,__const
.p2align 4
Ldir8_offsets:
    .long -129, -128, -127, -1, 1, 127, 128, 129

.zerofill __DATA,__bss,Lgrid_buf,16384,4
.zerofill __DATA,__bss,Lvis_buf,16384,4
.zerofill __DATA,__bss,Lbnd_stamp,65536,4
.zerofill __DATA,__bss,Lbfs_queue,65536,4
.zerofill __DATA,__bss,Lout_buf,262144,4

.section __TEXT,__text,regular,pure_instructions
.globl _break_piece_asm
.globl break_piece_asm
.p2align 2
_break_piece_asm:
break_piece_asm:
    stp x29, x30, [sp, #-96]!
    mov x29, sp
    stp x19, x20, [sp, #16]
    stp x21, x22, [sp, #32]
    stp x23, x24, [sp, #48]
    stp x25, x26, [sp, #64]
    stp x27, x28, [sp, #80]

    mov x19, x1                         // x19 = out_pieces
    mov x20, #0                         // x20 = num_pieces
    adrp x21, Lgrid_buf@PAGE
    add x21, x21, Lgrid_buf@PAGEOFF     // x21 = grid_buf
    adrp x22, Lvis_buf@PAGE
    add x22, x22, Lvis_buf@PAGEOFF      // x22 = vis_buf
    adrp x23, Lbnd_stamp@PAGE
    add x23, x23, Lbnd_stamp@PAGEOFF    // x23 = bnd_stamp
    adrp x24, Lbfs_queue@PAGE
    add x24, x24, Lbfs_queue@PAGEOFF    // x24 = bfs_queue
    adrp x25, Lout_buf@PAGE
    add x25, x25, Lout_buf@PAGEOFF      // x25 = out_ptr
    mov w28, #0                         // w28 = stamp_id

    // 1. Initialize grid_buf to ' ', vis_buf to 1, bnd_stamp to 0
    mov x2, #0
    mov w3, #0x20
    mov w4, #1
1:
    strb w3, [x21, x2]
    strb w4, [x22, x2]
    str wzr, [x23, x2, lsl #2]
    add x2, x2, #1
    cmp x2, #16384
    b.lo 1b

    // 2. Parse `shape` (x0) into grid_buf at (r = 2.., c = 2..)
    mov w2, #2                          // r = 2
    mov w3, #2                          // c = 2
    mov w26, #0                         // max_r = 0
    mov w27, #0                         // max_c = 0
2:
    ldrb w4, [x0], #1
    cbz w4, 5f
    cmp w4, #13                         // '\r'
    b.eq 2b
    cmp w4, #10                         // '\n'
    b.ne 3f
    add w2, w2, #1
    mov w3, #2
    b 2b
3:
    add w5, w3, w2, lsl #7              // idx = (r << 7) + c
    strb w4, [x21, w5, uxtw]
    cmp w2, w26
    csel w26, w2, w26, gt
    cmp w3, w27
    csel w27, w3, w27, gt
    add w3, w3, #1
    b 2b

5:
    cbz w26, Ldone
    add w26, w26, #1                    // H_max = max_r + 1
    add w27, w27, #1                    // W_max = max_c + 1

    // 3. Clear vis_buf = 0 for r in [1..H_max], c in [1..W_max]
    mov w2, #1
6:
    cmp w2, w26
    b.gt 9f
    mov w3, #1
7:
    cmp w3, w27
    b.gt 8f
    add w5, w3, w2, lsl #7
    strb wzr, [x22, w5, uxtw]
    add w3, w3, #1
    b 7b
8:
    add w2, w2, #1
    b 6b
9:

    // 4. Flood-fill exterior water from (1, 1) -> idx = 129
    mov w0, #129
    bl Lbfs_spaces

    // 5. Scan interior for unvisited ' ' cells
    mov w14, #2                         // r = 2
Lscan_r:
    cmp w14, w26
    b.ge Ldone
    mov w15, #2                         // c = 2
Lscan_c:
    cmp w15, w27
    b.ge Lscan_next_r

    add w0, w15, w14, lsl #7
    ldrb w1, [x21, w0, uxtw]
    cmp w1, #0x20
    b.ne Lscan_next_c
    ldrb w1, [x22, w0, uxtw]
    cbnz w1, Lscan_next_c

    // Found unvisited interior room; run BFS
    stp w14, w15, [sp, #-16]!
    bl Lbfs_spaces
    ldp w14, w15, [sp], #16
    mov w16, w0                         // w16 = q_len

    add w28, w28, #1                    // ++stamp_id
    mov w8, #127                        // min_r
    mov w9, #0                          // max_r
    mov w10, #127                       // min_c
    mov w11, #0                         // max_c

    adrp x7, Ldir8_offsets@PAGE
    add x7, x7, Ldir8_offsets@PAGEOFF

    mov w2, #0                          // i = 0
Lbnd_outer:
    cmp w2, w16
    b.ge Lbnd_done
    ldr w3, [x24, w2, uxtw #2]          // s_idx = bfs_queue[i]
    mov w4, #0                          // k = 0..7
Lbnd_inner:
    ldr w5, [x7, w4, uxtw #2]
    add w5, w3, w5                      // nb = s_idx + dir8[k]
    ldrb w6, [x21, w5, uxtw]
    cmp w6, #0x20
    b.eq Lbnd_next_k
    ldr w6, [x23, w5, uxtw #2]
    cmp w6, w28
    b.eq Lbnd_next_k

    str w28, [x23, w5, uxtw #2]
    lsr w6, w5, #7                      // br = nb >> 7
    and w5, w5, #127                    // bc = nb & 127
    cmp w6, w8
    csel w8, w6, w8, lt
    cmp w6, w9
    csel w9, w6, w9, gt
    cmp w5, w10
    csel w10, w5, w10, lt
    cmp w5, w11
    csel w11, w5, w11, gt

Lbnd_next_k:
    add w4, w4, #1
    cmp w4, #8
    b.lt Lbnd_inner
    add w2, w2, #1
    b Lbnd_outer

Lbnd_done:
    // Record piece start pointer in out_pieces[num_pieces++]
    str x25, [x19, x20, lsl #3]
    add x20, x20, #1

    mov w2, w8                          // br = min_r
Lrender_r:
    cmp w2, w9
    b.gt Lrender_done

    // Find last_c (w12) in [min_c..max_c] with bnd_stamp == w28
    mov w12, w11                        // bc = max_c
Lfind_last_c:
    cmp w12, w10
    b.lt Lrow_printed
    add w5, w12, w2, lsl #7
    ldr w6, [x23, w5, uxtw #2]
    cmp w6, w28
    b.eq Lfound_last_c
    sub w12, w12, #1
    b Lfind_last_c

Lfound_last_c:
    mov w3, w10                         // bc = min_c
Lrender_c:
    cmp w3, w12
    b.gt Lrow_printed
    add w5, w3, w2, lsl #7
    ldr w6, [x23, w5, uxtw #2]
    cmp w6, w28
    b.eq Lis_bnd_cell
    mov w4, #0x20
    strb w4, [x25], #1
    add w3, w3, #1
    b Lrender_c

Lis_bnd_cell:
    // Horizontal neighbors: w5 - 1, w5 + 1
    sub w6, w5, #1
    ldr w6, [x23, w6, uxtw #2]
    cmp w6, w28
    cset w13, eq
    add w6, w5, #1
    ldr w6, [x23, w6, uxtw #2]
    cmp w6, w28
    cset w17, eq
    orr w13, w13, w17                   // w13 = has_h

    // Vertical neighbors: w5 - 128, w5 + 128
    sub w6, w5, #128
    ldr w6, [x23, w6, uxtw #2]
    cmp w6, w28
    cset w17, eq
    add w6, w5, #128
    ldr w6, [x23, w6, uxtw #2]
    cmp w6, w28
    cset w0, eq
    orr w17, w17, w0                    // w17 = has_v

    cbz w13, Lonly_v
    cbz w17, Lonly_h
    mov w4, #'+'
    b Lemit_char
Lonly_h:
    mov w4, #'-'
    b Lemit_char
Lonly_v:
    mov w4, #'|'
Lemit_char:
    strb w4, [x25], #1
    add w3, w3, #1
    b Lrender_c

Lrow_printed:
    cmp w2, w9
    b.ge Lnext_render_r
    mov w4, #10                         // '\n'
    strb w4, [x25], #1
Lnext_render_r:
    add w2, w2, #1
    b Lrender_r

Lrender_done:
    strb wzr, [x25], #1

Lscan_next_c:
    add w15, w15, #1
    b Lscan_c
Lscan_next_r:
    add w14, w14, #1
    b Lscan_r

Ldone:
    mov x0, x20
    ldp x19, x20, [sp, #16]
    ldp x21, x22, [sp, #32]
    ldp x23, x24, [sp, #48]
    ldp x25, x26, [sp, #64]
    ldp x27, x28, [sp, #80]
    ldp x29, x30, [sp], #96
    ret

// Helper: Lbfs_spaces
// Input: w0 = start index
// Output: w0 = count of cells in bfs_queue
Lbfs_spaces:
    mov w1, #1
    strb w1, [x22, w0, uxtw]
    str w0, [x24]
    mov w2, #0                          // head = 0
    mov w0, #1                          // tail = 1
1:
    cmp w2, w0
    b.ge 6f
    ldr w3, [x24, w2, uxtw #2]          // cur = bfs_queue[head++]
    add w2, w2, #1

    // Neighbor 1: cur - 128
    sub w4, w3, #128
    ldrb w5, [x21, w4, uxtw]
    cmp w5, #0x20
    b.ne 2f
    ldrb w5, [x22, w4, uxtw]
    cbnz w5, 2f
    strb w1, [x22, w4, uxtw]
    str w4, [x24, w0, uxtw #2]
    add w0, w0, #1
2:
    // Neighbor 2: cur + 128
    add w4, w3, #128
    ldrb w5, [x21, w4, uxtw]
    cmp w5, #0x20
    b.ne 3f
    ldrb w5, [x22, w4, uxtw]
    cbnz w5, 3f
    strb w1, [x22, w4, uxtw]
    str w4, [x24, w0, uxtw #2]
    add w0, w0, #1
3:
    // Neighbor 3: cur - 1
    sub w4, w3, #1
    ldrb w5, [x21, w4, uxtw]
    cmp w5, #0x20
    b.ne 4f
    ldrb w5, [x22, w4, uxtw]
    cbnz w5, 4f
    strb w1, [x22, w4, uxtw]
    str w4, [x24, w0, uxtw #2]
    add w0, w0, #1
4:
    // Neighbor 4: cur + 1
    add w4, w3, #1
    ldrb w5, [x21, w4, uxtw]
    cmp w5, #0x20
    b.ne 5f
    ldrb w5, [x22, w4, uxtw]
    cbnz w5, 5f
    strb w1, [x22, w4, uxtw]
    str w4, [x24, w0, uxtw #2]
    add w0, w0, #1
5:
    b 1b
6:
    ret
