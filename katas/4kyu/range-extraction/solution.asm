; Codewars 4 kyu — Range Extraction (x86-64 NASM Assembly)
; ID: 51ba717bb08c1cd60f00002f
;
; ABI (System V AMD64):
;   size_t range_extraction_asm(const int64_t *arr, size_t n, char *out_buf)
;   rdi = pointer to sorted int64_t array
;   rsi = number of elements `n`
;   rdx = output buffer for null-terminated range string
;   rax = length of formatted string (excluding null terminator)
;
; Pure register state machine with zero libc/sprintf dependencies.

default rel
global range_extraction_asm
global _range_extraction_asm

section .text
_range_extraction_asm:
range_extraction_asm:
    push rbp
    mov rbp, rsp
    push rbx
    push r12
    push r13
    push r14
    push r15

    mov r12, rdi                 ; r12 = arr
    mov r13, rsi                 ; r13 = n
    mov r14, rdx                 ; r14 = out_ptr (cursor)
    mov r15, rdx                 ; r15 = out_buf base

    test r13, r13
    jz .done

    xor ebx, ebx                 ; i = 0
.run_loop:
    cmp rbx, r13
    jge .done

    ; Comma separator before run if i > 0
    test rbx, rbx
    jz .find_run_end
    mov byte [r14], ','
    inc r14

.find_run_end:
    mov r8, rbx                  ; j = i
.extend_run:
    lea r9, [r8 + 1]
    cmp r9, r13
    jge .format_run
    mov rax, [r12 + r8*8]
    inc rax
    cmp [r12 + r9*8], rax
    jne .format_run
    mov r8, r9
    jmp .extend_run

.format_run:
    ; Emit arr[i]
    mov rdi, [r12 + rbx*8]
    push r8
    call .emit_i64
    pop r8

    mov rax, r8
    sub rax, rbx                 ; run_span = j - i
    test rax, rax
    jz .advance_i
    cmp rax, 1
    je .pair_run

    ; Span >= 2 (at least 3 consecutive integers): emit '-' + arr[j]
    mov byte [r14], '-'
    inc r14
    mov rdi, [r12 + r8*8]
    push r8
    call .emit_i64
    pop r8
    jmp .advance_i

.pair_run:
    ; Span == 1 (exactly 2 consecutive integers): emit ',' + arr[j]
    mov byte [r14], ','
    inc r14
    mov rdi, [r12 + r8*8]
    push r8
    call .emit_i64
    pop r8

.advance_i:
    lea rbx, [r8 + 1]
    jmp .run_loop

.done:
    mov byte [r14], 0
    mov rax, r14
    sub rax, r15                 ; length = out_ptr - out_buf

    pop r15
    pop r14
    pop r13
    pop r12
    pop rbx
    pop rbp
    ret

; Internal helper: .emit_i64
; Input: rdi = signed 64-bit integer, r14 = out_ptr
; Output: r14 advanced past emitted ASCII digits
.emit_i64:
    sub rsp, 32
    mov rax, rdi
    test rax, rax
    jns .positive
    mov byte [r14], '-'
    inc r14
    neg rax
.positive:
    lea rcx, [rsp + 32]
    mov r9d, 10
.digit_loop:
    xor edx, edx
    div r9                       ; rax = quot, rdx = rem
    add dl, '0'
    dec rcx
    mov [rcx], dl
    test rax, rax
    jnz .digit_loop

    lea rdx, [rsp + 32]
.copy_digits:
    cmp rcx, rdx
    jge .emit_ret
    movzx eax, byte [rcx]
    mov [r14], al
    inc r14
    inc rcx
    jmp .copy_digits

.emit_ret:
    add rsp, 32
    ret
