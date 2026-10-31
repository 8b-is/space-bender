// Codewars 3 kyu — Bloxorz Solver (Apple Silicon AArch64 Assembly)
// ID: 5a2a597a8882f392020005e5
//
// ABI (AAPCS64):
//   size_t blox_solver_asm(const char *grid_str, char *out_moves)
//   x0 = newline-separated grid string ('1', '0', 'B', 'X')
//   x1 = output buffer for null-terminated minimal move string ('U','D','L','R')
//   x0 (return) = length of minimal move sequence

.section __TEXT,__const
.p2align 4
_blox_next_orient:
    .byte 2, 2, 1, 1
    .byte 1, 1, 0, 0
    .byte 0, 0, 2, 2
.p2align 2
_blox_next_delta:
    .long -64, 32, -2, 1
    .long -32, 32, -1, 2
    .long -32, 64, -1, 1
_blox_second_off:
    .long 0, 1, 32
_blox_move_chars:
    .byte 'U', 'D', 'L', 'R'

.zerofill __DATA,__bss,_blox_grid_buf,1024,4
.zerofill __DATA,__bss,_blox_vis_buf,4096,4
.zerofill __DATA,__bss,_blox_prev_state,16384,4
.zerofill __DATA,__bss,_blox_prev_move,4096,4
.zerofill __DATA,__bss,_blox_bfs_queue,16384,4

.section __TEXT,__text,regular,pure_instructions
.globl _blox_solver_asm
.globl blox_solver_asm
.p2align 2
_blox_solver_asm:
blox_solver_asm:
    stp x29, x30, [sp, #-80]!
    mov x29, sp
    stp x19, x20, [sp, #16]
    stp x21, x22, [sp, #32]
    stp x23, x24, [sp, #48]
    stp x25, x26, [sp, #64]

    mov x19, x1                         // x19 = out_moves
    adrp x20, _blox_grid_buf@PAGE
    add x20, x20, _blox_grid_buf@PAGEOFF
    adrp x21, _blox_vis_buf@PAGE
    add x21, x21, _blox_vis_buf@PAGEOFF
    adrp x22, _blox_prev_state@PAGE
    add x22, x22, _blox_prev_state@PAGEOFF
    adrp x23, _blox_prev_move@PAGE
    add x23, x23, _blox_prev_move@PAGEOFF
    adrp x24, _blox_bfs_queue@PAGE
    add x24, x24, _blox_bfs_queue@PAGEOFF

    // 1. Clear grid_buf (1024B) and vis_buf (4096B)
    mov x2, #0
1:
    str xzr, [x20, x2]
    add x2, x2, #8
    cmp x2, #1024
    b.lo 1b

    mov x2, #0
2:
    str xzr, [x21, x2]
    add x2, x2, #8
    cmp x2, #4096
    b.lo 2b

    // 2. Parse grid_str (x0) at (r = 2.., c = 2..)
    mov w2, #2                          // r = 2
    mov w3, #2                          // c = 2
    mov w25, #0                         // start_state
    mov w26, #0                         // goal_state
3:
    ldrb w4, [x0], #1
    cbz w4, 7f
    cmp w4, #13                         // '\r'
    b.eq 3b
    cmp w4, #10                         // '\n'
    b.ne 4f
    add w2, w2, #1
    mov w3, #2
    b 3b
4:
    add w5, w3, w2, lsl #5              // idx = (r << 5) + c
    cmp w4, #'0'
    b.eq 6f
    mov w6, #1
    strb w6, [x20, w5, uxtw]
    cmp w4, #'B'
    b.ne 5f
    mov w25, w5
5:
    cmp w4, #'X'
    b.ne 6f
    mov w26, w5
6:
    add w3, w3, #1
    b 3b

7:
    // 3. BFS from start_state (w25) to goal_state (w26)
    mov w2, #1
    strb w2, [x21, w25, uxtw]
    mov w2, #-1
    str w2, [x22, w25, uxtw #2]
    str w25, [x24]
    mov w2, #0                          // head = 0
    mov w3, #1                          // tail = 1

    adrp x8, _blox_next_orient@PAGE
    add x8, x8, _blox_next_orient@PAGEOFF
    adrp x9, _blox_next_delta@PAGE
    add x9, x9, _blox_next_delta@PAGEOFF
    adrp x10, _blox_second_off@PAGE
    add x10, x10, _blox_second_off@PAGEOFF
    adrp x11, _blox_move_chars@PAGE
    add x11, x11, _blox_move_chars@PAGEOFF

Lbfs_loop:
    cmp w2, w3
    b.ge Lnot_found
    ldr w4, [x24, w2, uxtw #2]          // cur = bfs_queue[head++]
    add w2, w2, #1
    cmp w4, w26
    b.eq Lreconstruct

    lsr w5, w4, #10                     // orient = cur >> 10
    and w6, w4, #1023                   // idx = cur & 1023
    mov w7, #0                          // d = 0..3

Ldir_loop:
    add w12, w7, w5, lsl #2             // lut_idx = orient * 4 + d
    ldrb w13, [x8, w12, uxtw]           // n_orient
    ldr w14, [x9, w12, uxtw #2]         // delta
    add w14, w6, w14                    // n_idx = idx + delta

    ldrb w15, [x20, w14, uxtw]
    cbz w15, Lnext_dir
    ldr w16, [x10, w13, uxtw #2]
    add w16, w14, w16                   // idx2 = n_idx + second_off[n_orient]
    ldrb w15, [x20, w16, uxtw]
    cbz w15, Lnext_dir

    orr w15, w14, w13, lsl #10          // n_state = (n_orient << 10) | n_idx
    ldrb w16, [x21, w15, uxtw]
    cbnz w16, Lnext_dir

    mov w16, #1
    strb w16, [x21, w15, uxtw]
    str w4, [x22, w15, uxtw #2]         // prev_state[n_state] = cur
    ldrb w16, [x11, w7, uxtw]
    strb w16, [x23, w15, uxtw]          // prev_move[n_state] = move_chars[d]
    str w15, [x24, w3, uxtw #2]
    add w3, w3, #1

Lnext_dir:
    add w7, w7, #1
    cmp w7, #4
    b.lt Ldir_loop
    b Lbfs_loop

Lreconstruct:
    mov w0, #0                          // len = 0
    mov w4, w26                         // cur = goal_state
Lwalk_back:
    cmp w4, w25
    b.eq Lreverse
    ldrb w5, [x23, w4, uxtw]
    strb w5, [x19, w0, uxtw]
    add w0, w0, #1
    ldr w4, [x22, w4, uxtw #2]
    b Lwalk_back

Lreverse:
    strb wzr, [x19, w0, uxtw]
    mov w2, #0                          // lo = 0
    sub w3, w0, #1                      // hi = len - 1
Lrev_loop:
    cmp w2, w3
    b.ge Lexit
    ldrb w4, [x19, w2, uxtw]
    ldrb w5, [x19, w3, uxtw]
    strb w5, [x19, w2, uxtw]
    strb w4, [x19, w3, uxtw]
    add w2, w2, #1
    sub w3, w3, #1
    b Lrev_loop

Lnot_found:
    strb wzr, [x19]
    mov w0, #0

Lexit:
    uxtw x0, w0
    ldp x19, x20, [sp, #16]
    ldp x21, x22, [sp, #32]
    ldp x23, x24, [sp, #48]
    ldp x25, x26, [sp, #64]
    ldp x29, x30, [sp], #80
    ret
