; Codewars 3 kyu — Bloxorz Solver (x86-64 NASM Assembly)
; ID: 5a2a597a8882f392020005e5
;
; ABI (System V AMD64):
;   size_t blox_solver_asm(const char *grid_str, char *out_moves)
;   rdi = newline-separated grid string ('1', '0', 'B', 'X')
;   rsi = output buffer for null-terminated minimal move string ('U','D','L','R')
;   rax = length of minimal move sequence
;
; Architecture:
;   - Embeds the board at (r+2, c+2) inside a 32x32 zero-moat grid (`idx = (r << 5) + c`).
;   - Encodes every cuboid pose as a 12-bit integer `state = (orient << 10) | idx` in 0..3071
;     where orient 0 = Upright (1x1), 1 = Horz (1x2), 2 = Vert (2x1).
;   - Branchless orientation transition via 12-entry LUTs (`next_orient`, `next_delta`)
;     and unified 2-tile support check (`grid[idx] & grid[idx + second_off[orient]]`).

default rel
global blox_solver_asm
global _blox_solver_asm

section .rodata
align 16
next_orient:
    db 2, 2, 1, 1                ; from Upright (0): U->Vert, D->Vert, L->Horz, R->Horz
    db 1, 1, 0, 0                ; from Horz    (1): U->Horz, D->Horz, L->Upright, R->Upright
    db 0, 0, 2, 2                ; from Vert    (2): U->Upright, D->Upright, L->Vert, R->Vert

align 16
next_delta:
    dd -64, 32, -2, 1            ; from Upright (0)
    dd -32, 32, -1, 2            ; from Horz    (1)
    dd -32, 64, -1, 1            ; from Vert    (2)

align 16
second_off:
    dd 0, 1, 32                  ; second tile offset for orient 0, 1, 2

move_chars:
    db 'U', 'D', 'L', 'R'

section .bss
align 16
grid_buf:    resb 1024           ; 32 x 32 board (1 = solid, 0 = air)
vis_buf:     resb 4096           ; visited[3072]
prev_state:  resd 4096           ; parent state[3072]
prev_move:   resb 4096           ; move char[3072]
bfs_queue:   resd 4096           ; BFS queue of 12-bit states

section .text
_blox_solver_asm:
blox_solver_asm:
    push rbp
    mov rbp, rsp
    push rbx
    push r12
    push r13
    push r14
    push r15

    mov r15, rsi                 ; r15 = out_moves
    mov r8, rdi                  ; r8 = grid_str

    ; 1. Clear grid_buf (1024 bytes) and vis_buf (4096 bytes)
    lea rdi, [rel grid_buf]
    mov ecx, 128
    xor eax, eax
    rep stosq

    lea rdi, [rel vis_buf]
    mov ecx, 512
    rep stosq

    ; 2. Parse grid_str into grid_buf at (r = 2.., c = 2..)
    lea r9, [rel grid_buf]
    mov edx, 2                   ; r = 2
    mov ecx, 2                   ; c = 2
    xor r12d, r12d               ; start_state
    xor r13d, r13d               ; goal_state

.parse_loop:
    movzx eax, byte [r8]
    test al, al
    jz .parse_done
    inc r8
    cmp al, 13                   ; '\r'
    je .parse_loop
    cmp al, 10                   ; '\n'
    jne .parse_tile
    inc edx
    mov ecx, 2
    jmp .parse_loop

.parse_tile:
    mov esi, edx
    shl esi, 5
    add esi, ecx                 ; idx = (r << 5) + c
    cmp al, '0'
    je .next_col
    mov byte [r9 + rsi], 1
    cmp al, 'B'
    jne .check_x
    mov r12d, esi                ; start_state = (0 << 10) | idx
.check_x:
    cmp al, 'X'
    jne .next_col
    mov r13d, esi                ; goal_state  = (0 << 10) | idx
.next_col:
    inc ecx
    jmp .parse_loop

.parse_done:
    ; 3. Initialize BFS from start_state (r12d) to goal_state (r13d)
    lea r8, [rel bfs_queue]
    lea r10, [rel vis_buf]
    lea r11, [rel prev_state]

    mov byte [r10 + r12], 1
    mov dword [r11 + r12*4], -1
    mov [r8], r12d
    xor ecx, ecx                 ; head = 0
    mov edx, 1                   ; tail = 1

.bfs_loop:
    cmp ecx, edx
    jge .not_found
    mov ebx, [r8 + rcx*4]        ; cur = bfs_queue[head++]
    inc ecx
    cmp ebx, r13d
    je .reconstruct

    ; Extract orient = cur >> 10, idx = cur & 1023
    mov esi, ebx
    shr esi, 10                  ; orient in 0..2
    mov edi, ebx
    and edi, 1023                ; idx in 0..1023

    xor r14d, r14d               ; d = 0..3
.dir_loop:
    mov eax, esi
    shl eax, 2
    add eax, r14d                ; lut_idx = orient * 4 + d

    lea r9, [rel next_orient]
    movzx eax, byte [r9 + rax]   ; n_orient
    push rax

    mov eax, esi
    shl eax, 2
    add eax, r14d
    lea r9, [rel next_delta]
    mov eax, [r9 + rax*4]
    add eax, edi                 ; n_idx = idx + next_delta[orient*4 + d]
    pop r9                       ; r9d = n_orient

    ; Check both tiles of (n_orient, n_idx) in grid_buf
    lea rsi, [rel grid_buf]
    cmp byte [rsi + rax], 0
    je .next_dir

    push rdi
    lea rdi, [rel second_off]
    mov edi, [rdi + r9*4]
    add edi, eax                 ; idx2 = n_idx + second_off[n_orient]
    cmp byte [rsi + rdi], 0
    pop rdi
    je .next_dir

    ; Compute n_state = (n_orient << 10) | n_idx
    shl r9d, 10
    or r9d, eax
    cmp byte [r10 + r9], 0
    jne .next_dir

    mov byte [r10 + r9], 1
    mov [r11 + r9*4], ebx        ; prev_state[n_state] = cur
    lea rsi, [rel move_chars]
    movzx eax, byte [rsi + r14]
    lea rsi, [rel prev_move]
    mov [rsi + r9], al           ; prev_move[n_state] = move_chars[d]

    mov [r8 + rdx*4], r9d
    inc edx

.next_dir:
    mov esi, ebx
    shr esi, 10
    inc r14d
    cmp r14d, 4
    jl .dir_loop
    jmp .bfs_loop

.reconstruct:
    ; Walk backwards from goal_state (r13d) to start_state (r12d)
    xor ecx, ecx                 ; len = 0
    mov eax, r13d
    lea r9, [rel prev_move]
.walk_back:
    cmp eax, r12d
    je .reverse_out
    movzx edx, byte [r9 + rax]
    mov [r15 + rcx], dl
    inc ecx
    mov eax, [r11 + rax*4]
    jmp .walk_back

.reverse_out:
    mov byte [r15 + rcx], 0
    mov eax, ecx                 ; return value = len
    xor edx, edx                 ; lo = 0
    lea esi, [rcx - 1]           ; hi = len - 1
.rev_loop:
    cmp edx, esi
    jge .exit
    movzx ebx, byte [r15 + rdx]
    movzx r8d, byte [r15 + rsi]
    mov [r15 + rdx], r8b
    mov [r15 + rsi], bl
    inc edx
    dec esi
    jmp .rev_loop

.not_found:
    mov byte [r15], 0
    xor eax, eax

.exit:
    pop r15
    pop r14
    pop r13
    pop r12
    pop rbx
    pop rbp
    ret
