; Codewars 2 kyu — Break the pieces (x86-64 NASM Assembly)
; ID: 527fde8d24b9309d9b000c4e
;
; ABI (System V AMD64):
;   size_t break_piece_asm(const char *shape, const char **out_pieces)
;   rdi = pointer to null-terminated input ASCII diagram
;   rsi = pointer to caller array of `const char *` to receive extracted pieces
;   rax = number of extracted minimal pieces
;
; Algorithm:
;   - Embeds the diagram at offset (r+2, c+2) inside a 128x128 power-of-two stride grid
;     so every 2D coordinate (r, c) is a single 14-bit index `idx = (r << 7) + c`.
;   - Surrounds the active region [1..H_max] x [1..W_max] with a `visited = 1` sentinel
;     moat so 4-neighbor BFS requires zero bounds checks in the inner loop.
;   - Flood-fills exterior water from (1, 1) (idx = 129), then extracts each interior
;     dry pocket, marks its 8-neighbor wall cells in `bnd_stamp`, heals T-junction
;     corners (`+` -> `-` or `|`), and streams trimmed lines directly into `out_buf`.

default rel
global break_piece_asm
global _break_piece_asm

section .rodata
align 16
dir4_offsets:
    dd -128, 128, -1, 1

dir8_offsets:
    dd -129, -128, -127, -1, 1, 127, 128, 129

section .bss
align 16
grid_buf:    resb 16384          ; 128 x 128 ASCII grid
vis_buf:     resb 16384          ; 128 x 128 visited flags (1 = wall/moat/visited)
bnd_stamp:   resd 16384          ; 128 x 128 boundary stamp IDs
bfs_queue:   resd 16384          ; BFS queue of 14-bit cell indices
out_buf:     resb 262144         ; Contiguous null-terminated output piece strings

section .text
_break_piece_asm:
break_piece_asm:
    push rbp
    mov rbp, rsp
    push rbx
    push r12
    push r13
    push r14
    push r15
    sub rsp, 56                  ; local stack slots

    ; [rbp - 48] = out_pieces (rsi)
    ; [rbp - 56] = num_pieces
    ; [rbp - 64] = H_max
    ; [rbp - 72] = W_max
    ; [rbp - 80] = stamp_id
    ; [rbp - 88] = out_ptr (cursor in out_buf)
    mov [rbp - 48], rsi
    mov qword [rbp - 56], 0
    mov qword [rbp - 80], 0
    lea rax, [rel out_buf]
    mov [rbp - 88], rax

    mov r8, rdi                  ; r8 = shape ptr

    ; 1. Initialize grid_buf to ' ' (0x20), vis_buf to 1 (sentinel moat), bnd_stamp to 0
    lea rdi, [rel grid_buf]
    mov ecx, 16384
    mov al, 0x20
    rep stosb

    lea rdi, [rel vis_buf]
    mov ecx, 16384
    mov al, 1
    rep stosb

    lea rdi, [rel bnd_stamp]
    mov ecx, 16384
    xor eax, eax
    rep stosd

    ; 2. Parse `shape` into grid_buf at (r = 2.., c = 2..)
    lea r12, [rel grid_buf]
    mov edx, 2                   ; r = 2
    mov ecx, 2                   ; c = 2
    xor r9d, r9d                 ; max_r = 0
    xor r10d, r10d               ; max_c = 0

.parse_loop:
    movzx eax, byte [r8]
    test al, al
    jz .parse_done
    inc r8
    cmp al, 13                   ; '\r'
    je .parse_loop
    cmp al, 10                   ; '\n'
    jne .parse_char
    inc edx
    mov ecx, 2
    jmp .parse_loop

.parse_char:
    mov esi, edx
    shl esi, 7
    add esi, ecx
    mov [r12 + rsi], al
    cmp edx, r9d
    cmovg r9d, edx
    cmp ecx, r10d
    cmovg r10d, ecx
    inc ecx
    jmp .parse_loop

.parse_done:
    test r9d, r9d
    jz .done_empty

    inc r9d                      ; H_max = max_r + 1 (1-cell water border on bottom)
    inc r10d                     ; W_max = max_c + 1 (1-cell water border on right)
    mov [rbp - 64], r9
    mov [rbp - 72], r10

    ; 3. Clear vis_buf = 0 for active region r in [1..H_max], c in [1..W_max]
    lea r13, [rel vis_buf]
    mov edx, 1
.clear_vis_r:
    cmp edx, r9d
    jg .clear_vis_done
    mov ecx, 1
.clear_vis_c:
    cmp ecx, r10d
    jg .clear_vis_next_r
    mov esi, edx
    shl esi, 7
    add esi, ecx
    mov byte [r13 + rsi], 0
    inc ecx
    jmp .clear_vis_c
.clear_vis_next_r:
    inc edx
    jmp .clear_vis_r
.clear_vis_done:

    ; 4. Exterior flood-fill from (1, 1) -> idx = 129
    mov edi, 129
    call .bfs_spaces

    ; 5. Scan interior for unvisited ' ' cells
    mov r14d, 2                  ; r = 2
.scan_r:
    cmp r14d, [rbp - 64]
    jge .done
    mov r15d, 2                  ; c = 2
.scan_c:
    cmp r15d, [rbp - 72]
    jge .scan_next_r

    mov edi, r14d
    shl edi, 7
    add edi, r15d
    cmp byte [r12 + rdi], 0x20
    jne .scan_next_c
    cmp byte [r13 + rdi], 0
    jne .scan_next_c

    ; Found a new closed minimal piece! Run BFS to collect its space cells in bfs_queue[0..eax-1]
    call .bfs_spaces
    mov ebx, eax                 ; ebx = q_len (number of space cells in component)

    inc qword [rbp - 80]
    mov r8d, [rbp - 80]          ; r8d = current stamp_id

    ; Collect 8-neighbor non-space boundary cells and bounding box
    lea rsi, [rel bfs_queue]
    lea rdi, [rel bnd_stamp]
    lea r9, [rel dir8_offsets]

    mov r10d, 127                ; min_r
    xor r11d, r11d               ; max_r
    mov dword [rbp - 92], 127    ; min_c
    mov dword [rbp - 96], 0      ; max_c

    xor ecx, ecx                 ; i = 0
.bnd_outer:
    cmp ecx, ebx
    jge .bnd_done
    mov edx, [rsi + rcx*4]       ; s_idx
    xor eax, eax                 ; k = 0..7
.bnd_inner:
    mov r12d, edx
    add r12d, [r9 + rax*4]       ; nb = s_idx + dir8_offsets[k]
    lea r13, [rel grid_buf]
    cmp byte [r13 + r12], 0x20
    je .bnd_next_k
    cmp [rdi + r12*4], r8d
    je .bnd_next_k

    mov [rdi + r12*4], r8d
    ; br = r12d >> 7, bc = r12d & 127
    mov r13d, r12d
    shr r13d, 7
    and r12d, 127

    cmp r13d, r10d
    cmovl r10d, r13d
    cmp r13d, r11d
    cmovg r11d, r13d

    cmp r12d, [rbp - 92]
    jge .check_max_c
    mov [rbp - 92], r12d
.check_max_c:
    cmp r12d, [rbp - 96]
    jle .bnd_next_k
    mov [rbp - 96], r12d

.bnd_next_k:
    inc eax
    cmp eax, 8
    jl .bnd_inner

    inc ecx
    jmp .bnd_outer

.bnd_done:
    lea r12, [rel grid_buf]
    lea r13, [rel vis_buf]

    ; Record start of piece string in out_pieces[num_pieces++]
    mov rax, [rbp - 88]          ; out_ptr
    mov rcx, [rbp - 48]          ; out_pieces
    mov rdx, [rbp - 56]          ; num_pieces
    mov [rcx + rdx*8], rax
    inc rdx
    mov [rbp - 56], rdx

    ; Render rows br = r10d (min_r) .. r11d (max_r)
    mov ecx, r10d                ; br = min_r
.render_r:
    cmp ecx, r11d
    jg .render_done

    ; Find last_c on row `br` with bnd_stamp == r8d
    mov edx, [rbp - 96]          ; bc = max_c
.find_last_c:
    cmp edx, [rbp - 92]
    jl .row_printed
    mov esi, ecx
    shl esi, 7
    add esi, edx
    cmp [rdi + rsi*4], r8d
    je .found_last_c
    dec edx
    jmp .find_last_c

.found_last_c:
    ; Emit characters from bc = min_c .. edx (last_c)
    mov ebx, [rbp - 92]          ; bc = min_c
.render_c:
    cmp ebx, edx
    jg .row_printed
    mov esi, ecx
    shl esi, 7
    add esi, ebx
    cmp [rdi + rsi*4], r8d
    je .is_bnd_cell
    mov byte [rax], 0x20         ; ' '
    inc rax
    inc ebx
    jmp .render_c

.is_bnd_cell:
    ; Check horizontal neighbors (rsi - 1, rsi + 1)
    xor r9d, r9d                 ; has_h = 0
    cmp [rdi + rsi*4 - 4], r8d
    sete r9b
    cmp [rdi + rsi*4 + 4], r8d
    sete r10b
    or r9b, r10b

    ; Check vertical neighbors (rsi - 128, rsi + 128)
    xor r10d, r10d               ; has_v = 0
    cmp [rdi + rsi*4 - 512], r8d
    sete r10b
    cmp [rdi + rsi*4 + 512], r8d
    je .set_v1
    jmp .choose_char
.set_v1:
    mov r10b, 1

.choose_char:
    test r9b, r9b
    jz .only_v
    test r10b, r10b
    jz .only_h
    mov byte [rax], '+'
    jmp .emit_adv
.only_h:
    mov byte [rax], '-'
    jmp .emit_adv
.only_v:
    mov byte [rax], '|'
.emit_adv:
    inc rax
    inc ebx
    jmp .render_c

.row_printed:
    cmp ecx, r11d
    jge .next_render_r
    mov byte [rax], 10           ; '\n'
    inc rax
.next_render_r:
    inc ecx
    jmp .render_r

.render_done:
    mov byte [rax], 0            ; null-terminate piece
    inc rax
    mov [rbp - 88], rax

.scan_next_c:
    inc r15d
    jmp .scan_c
.scan_next_r:
    inc r14d
    jmp .scan_r

.done_empty:
.done:
    mov rax, [rbp - 56]
    add rsp, 56
    pop r15
    pop r14
    pop r13
    pop r12
    pop rbx
    pop rbp
    ret

; Internal helper: .bfs_spaces
; Input: edi = start cell index, r12 = grid_buf, r13 = vis_buf
; Output: eax = number of cells in component (stored in bfs_queue[0..eax-1])
.bfs_spaces:
    lea rsi, [rel bfs_queue]
    lea r8, [rel dir4_offsets]
    mov byte [r13 + rdi], 1
    mov [rsi], edi
    xor ecx, ecx                 ; head = 0
    mov eax, 1                   ; tail = 1
.bfs_loop:
    cmp ecx, eax
    jge .bfs_ret
    mov edx, [rsi + rcx*4]       ; cur = bfs_queue[head++]
    inc ecx

    ; Unrolled 4-neighbor expansion
    %assign i 0
    %rep 4
        mov r9d, edx
        add r9d, [r8 + i*4]
        cmp byte [r12 + r9], 0x20
        jne .skip_%[i]
        cmp byte [r13 + r9], 0
        jne .skip_%[i]
        mov byte [r13 + r9], 1
        mov [rsi + rax*4], r9d
        inc eax
    .skip_%[i]:
        %assign i i+1
    %endrep
    jmp .bfs_loop
.bfs_ret:
    ret
