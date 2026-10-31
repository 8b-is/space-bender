; Codewars 2 kyu — ASCII Games: Dance Dance Evolution I (x86-64 NASM Assembly)
; ID: 58f58dc3663082a4ba000033
;
; ABI (System V AMD64):
;   size_t dance_asm(const char *map_utf8, char *out_utf8)
;   rdi = pointer to null-terminated UTF-8 maze string
;   rsi = pointer to output buffer receiving null-terminated UTF-8 arrow string
;   rax = number of steps in the longest simple cycle returning to S
;
; Algorithm:
;   1. Decodes 3-byte UTF-8 arrows (0xE2 0x86 0x90..0x99) via a 10-byte LUT into
;      compass indices 0..7 ('←','↖','↑','↗','→','↘','↓','↙') and 'S' -> 8.
;   2. Precomputes 64-bit adjacency masks `out_mask[u]`, `in_mask[v]`, and direction
;      matrix `edge_dir[u*64 + v]` for all valid <=90° transitions.
;   3. Runs DFS with hardware `tzcnt`/`bsf` bidirectional reachability flood-fill
;      (`can_reach_s` backwards from S, `reachable` forwards from u) and `popcnt`
;      upper-bound pruning.

default rel
global dance_asm
global _dance_asm

section .rodata
align 16
utf8_to_dir:
    db 0, 2, 4, 6, 0xFF, 0xFF, 1, 3, 5, 7

dir_to_utf8_b3:
    db 0x90, 0x96, 0x91, 0x97, 0x92, 0x98, 0x93, 0x99

dr_tab:
    dd 0, -1, -1, -1, 0, 1, 1, 1

dc_tab:
    dd -1, -1, 0, 1, 1, 1, 0, -1

section .bss
align 16
tiles_buf:    resb 64
out_mask:     resq 64
in_mask:      resq 64
edge_dir:     resb 4096
cur_dirs:     resb 64
best_dirs:    resb 64
start_idx:    resq 1
all_arrows:   resq 1
best_len:     resq 1

section .text
_dance_asm:
dance_asm:
    push rbp
    mov rbp, rsp
    push rbx
    push r12
    push r13
    push r14
    push r15
    sub rsp, 24

    mov [rbp - 48], rsi          ; save out_utf8

    ; 1. Parse UTF-8 grid into tiles_buf
    lea r8, [rel tiles_buf]
    lea r9, [rel utf8_to_dir]
    xor ecx, ecx                 ; n = 0 (total cells)
    xor edx, edx                 ; rows = 0
    xor r10d, r10d               ; cur_col = 0
    xor r11d, r11d               ; cols = 0
    mov qword [rel start_idx], -1

.parse_loop:
    movzx eax, byte [rdi]
    test al, al
    jz .parse_done
    cmp al, 10                   ; '\n'
    je .parse_nl
    cmp al, 13                   ; '\r'
    je .parse_skip1
    cmp al, 'S'
    je .parse_start
    cmp al, 0xE2
    jne .parse_skip1

    ; 3-byte UTF-8 arrow: 0xE2 0x86 (0x90..0x99)
    movzx eax, byte [rdi + 2]
    sub eax, 0x90
    movzx eax, byte [r9 + rax]
    mov [r8 + rcx], al
    inc ecx
    inc r10d
    add rdi, 3
    jmp .parse_loop

.parse_start:
    mov byte [r8 + rcx], 8
    mov [rel start_idx], rcx
    inc ecx
    inc r10d
    inc rdi
    jmp .parse_loop

.parse_nl:
    test r10d, r10d
    jz .parse_skip1
    mov r11d, r10d
    xor r10d, r10d
    inc edx
.parse_skip1:
    inc rdi
    jmp .parse_loop

.parse_done:
    test r10d, r10d
    jz .check_dims
    mov r11d, r10d
    inc edx
.check_dims:
    test ecx, ecx
    jz .ret_empty
    cmp qword [rel start_idx], 0
    jl .ret_empty

    ; r12d = rows (edx), r13d = cols (r11d), r14d = n (ecx)
    mov r12d, edx
    mov r13d, r11d
    mov r14d, ecx

    ; Clear out_mask and in_mask
    lea rdi, [rel out_mask]
    mov ecx, 64
    xor eax, eax
    rep stosq

    lea rdi, [rel in_mask]
    mov ecx, 64
    rep stosq

    ; 2. Build directed adjacency masks for <=90° compatible moves
    lea r8, [rel tiles_buf]
    lea r9, [rel out_mask]
    lea r10, [rel in_mask]
    lea r11, [rel edge_dir]

    xor ebx, ebx                 ; r = 0
.build_r:
    cmp ebx, r12d
    jge .build_done
    xor r15d, r15d               ; c = 0
.build_c:
    cmp r15d, r13d
    jge .build_next_r

    mov eax, ebx
    imul eax, r13d
    add eax, r15d                ; u = r * cols + c
    mov [rbp - 56], eax
    movzx esi, byte [r8 + rax]   ; tu = tiles[u]

    xor ecx, ecx                 ; d = 0..7
.build_d:
    lea rdi, [rel dr_tab]
    mov edx, [rdi + rcx*4]
    add edx, ebx                 ; nr = r + dr[d]
    jl .build_next_d
    cmp edx, r12d
    jge .build_next_d

    lea rdi, [rel dc_tab]
    mov eax, [rdi + rcx*4]
    add eax, r15d                ; nc = c + dc[d]
    jl .build_next_d
    cmp eax, r13d
    jge .build_next_d

    imul edx, r13d
    add edx, eax                 ; v = nr * cols + nc

    ; Check compatibility(tu, d)
    cmp esi, 8
    je .tu_ok
    mov eax, esi
    sub eax, ecx
    jns .tu_abs
    neg eax
.tu_abs:
    cmp eax, 2
    jle .tu_ok
    cmp eax, 6
    jl .build_next_d
.tu_ok:
    ; Check compatibility(tv, d)
    movzx eax, byte [r8 + rdx]   ; tv = tiles[v]
    cmp eax, 8
    je .tv_ok
    sub eax, ecx
    jns .tv_abs
    neg eax
.tv_abs:
    cmp eax, 2
    jle .tv_ok
    cmp eax, 6
    jl .build_next_d
.tv_ok:
    mov eax, [rbp - 56]          ; u
    bts qword [r9 + rax*8], rdx  ; out_mask[u] |= (1 << v)
    bts qword [r10 + rdx*8], rax ; in_mask[v]  |= (1 << u)
    shl eax, 6
    add eax, edx
    mov [r11 + rax], cl          ; edge_dir[u*64 + v] = d

.build_next_d:
    inc ecx
    cmp ecx, 8
    jl .build_d

    inc r15d
    jmp .build_c
.build_next_r:
    inc ebx
    jmp .build_r

.build_done:
    ; Compute all_arrows_mask = ((1ULL << n) - 1) ^ (1ULL << start)
    mov ecx, r14d
    mov rax, -1
    cmp ecx, 64
    je .mask_ready
    mov eax, 1
    shl rax, cl
    dec rax
.mask_ready:
    mov rcx, [rel start_idx]
    btr rax, rcx
    mov [rel all_arrows], rax
    mov qword [rel best_len], 0

    ; 3. Run DFS(u = start, visited = 0, depth = 0)
    mov rdi, rcx                 ; u = start
    xor esi, esi                 ; visited = 0
    xor edx, edx                 ; depth = 0
    call .dfs

    ; 4. Encode best_dirs[0..best_len-1] as 3-byte UTF-8 arrows
    mov rcx, [rel best_len]
    mov rdi, [rbp - 48]          ; out_utf8
    lea rsi, [rel best_dirs]
    lea r8, [rel dir_to_utf8_b3]
    xor edx, edx
.encode_loop:
    cmp rdx, rcx
    jge .encode_done
    movzx eax, byte [rsi + rdx]
    movzx eax, byte [r8 + rax]
    mov byte [rdi], 0xE2
    mov byte [rdi + 1], 0x86
    mov [rdi + 2], al
    add rdi, 3
    inc rdx
    jmp .encode_loop

.encode_done:
    mov byte [rdi], 0
    mov rax, rcx
    jmp .exit

.ret_empty:
    mov rdi, [rbp - 48]
    mov byte [rdi], 0
    xor eax, eax

.exit:
    add rsp, 24
    pop r15
    pop r14
    pop r13
    pop r12
    pop rbx
    pop rbp
    ret

; Recursive DFS with bidirectional bitmask reachability pruning
; rdi = u, rsi = visited, rdx = depth
.dfs:
    push rbx
    push r12
    push r13
    push r14
    push r15

    mov r12, rdi                 ; r12 = u
    mov r13, rsi                 ; r13 = visited
    mov r14, rdx                 ; r14 = depth

    mov r8, r13
    not r8
    and r8, [rel all_arrows]     ; r8 = avail

    ; Backward flood-fill from start: can_reach_s
    lea r9, [rel in_mask]
    mov rcx, [rel start_idx]
    mov r10, [r9 + rcx*8]
    and r10, r8                  ; r10 = can_reach_s
.bw_loop:
    mov r11, r10                 ; next = can_reach_s
    mov rax, r10                 ; m = can_reach_s
.bw_inner:
    test rax, rax
    jz .bw_check
    tzcnt rcx, rax
    blsr rax, rax
    mov rbx, [r9 + rcx*8]
    and rbx, r8
    or r11, rbx
    jmp .bw_inner
.bw_check:
    cmp r11, r10
    je .bw_done
    mov r10, r11
    jmp .bw_loop
.bw_done:

    ; Forward flood-fill from u inside can_reach_s: reachable
    lea r9, [rel out_mask]
    mov r15, [r9 + r12*8]
    and r15, r10                 ; r15 = reachable
.fw_loop:
    mov r11, r15
    mov rax, r15
.fw_inner:
    test rax, rax
    jz .fw_check
    tzcnt rcx, rax
    blsr rax, rax
    mov rbx, [r9 + rcx*8]
    and rbx, r10
    or r11, rbx
    jmp .fw_inner
.fw_check:
    cmp r11, r15
    je .fw_done
    mov r15, r11
    jmp .fw_loop
.fw_done:

    ; Check direct return edge u -> start when depth > 0
    test r14, r14
    jz .skip_return_s
    mov rcx, [rel start_idx]
    mov rax, [r9 + r12*8]
    bt rax, rcx
    jnc .skip_return_s

    lea rax, [r14 + 1]
    cmp rax, [rel best_len]
    jle .skip_return_s

    mov [rel best_len], rax
    ; Copy cur_dirs[0..depth-1] to best_dirs and append edge_dir[u*64 + start]
    lea rsi, [rel cur_dirs]
    lea rdi, [rel best_dirs]
    mov rcx, r14
    rep movsb
    mov rax, r12
    shl rax, 6
    add rax, [rel start_idx]
    lea rbx, [rel edge_dir]
    movzx eax, byte [rbx + rax]
    mov [rdi], al

.skip_return_s:
    ; Upper-bound check: depth + popcnt(reachable) + 1 <= best_len
    popcnt rax, r15
    lea rax, [rax + r14 + 1]
    cmp rax, [rel best_len]
    jle .dfs_ret

    ; Branch over neighbors v in (out_mask[u] & reachable)
    mov rbx, [r9 + r12*8]
    and rbx, r15                 ; rbx = candidate neighbors bitmask
.branch_loop:
    test rbx, rbx
    jz .dfs_ret
    tzcnt rdi, rbx               ; v = trailing_zeros(rbx)
    blsr rbx, rbx

    ; cur_dirs[depth] = edge_dir[u*64 + v]
    mov rax, r12
    shl rax, 6
    add rax, rdi
    lea rcx, [rel edge_dir]
    movzx eax, byte [rcx + rax]
    lea rcx, [rel cur_dirs]
    mov [rcx + r14], al

    mov rsi, r13
    bts rsi, rdi                 ; visited | (1ULL << v)
    lea rdx, [r14 + 1]
    call .dfs

    popcnt rax, r15
    lea rax, [rax + r14 + 1]
    cmp rax, [rel best_len]
    jle .dfs_ret
    jmp .branch_loop

.dfs_ret:
    pop r15
    pop r14
    pop r13
    pop r12
    pop rbx
    ret
