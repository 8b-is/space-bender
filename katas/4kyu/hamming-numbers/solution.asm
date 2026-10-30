; Hamming Numbers (4 kyu) — Codewars 526d84b98f428f14a60008da
; Compute the n-th smallest Hamming number (2^i * 3^j * 5^k) for 1 <= n <= 13282.
; System V AMD64 ABI: input n in edi, output in rax (uint64_t).

default rel

global hamming
global hamber

%define MAX_N 13282

section .text

hamming:
hamber:
    mov     edi, edi                ; zero-extend 32-bit int n to 64-bit rdi
    lea     r8, [table]             ; RIP-relative base address of table[0..13281]
    cmp     qword [r8], 0           ; check whether table has been populated
    je      .init                   ; populate once on the first call
    mov     rax, [r8 + rdi*8 - 8]   ; O(1) lookup: table[n - 1]
    ret

.init:
    push    rdi                     ; preserve n while rdi holds x5
    mov     qword [r8], 1           ; table[0] = 1 (2^0 * 3^0 * 5^0)
    mov     ecx, 1                  ; k  = 1 (write index)
    xor     esi, esi                ; i2 = 0 (2x stream index)
    xor     edx, edx                ; i3 = 0 (3x stream index)
    xor     r9d, r9d                ; i5 = 0 (5x stream index)
    mov     r10d, 2                 ; x2 = 2
    mov     r11d, 3                 ; x3 = 3
    mov     edi, 5                  ; x5 = 5

.loop:
    mov     rax, r10                ; m = x2
    cmp     r11, rax                ; compare x3 with m (unsigned 64-bit)
    cmovb   rax, r11                ; if x3 < m, m = x3
    cmp     rdi, rax                ; compare x5 with m (unsigned 64-bit)
    cmovb   rax, rdi                ; if x5 < m, m = x5

    mov     [r8 + rcx*8], rax       ; table[k] = m

    cmp     rax, r10                ; did x2 match m?
    jne     .check3
    inc     esi                     ; ++i2
    mov     r10, [r8 + rsi*8]       ; table[i2]
    add     r10, r10                ; x2 = table[i2] * 2

.check3:
    cmp     rax, r11                ; did x3 match m?
    jne     .check5
    inc     edx                     ; ++i3
    mov     r11, [r8 + rdx*8]       ; table[i3]
    lea     r11, [r11 + r11*2]      ; x3 = table[i3] * 3

.check5:
    cmp     rax, rdi                ; did x5 match m?
    jne     .next
    inc     r9d                     ; ++i5
    mov     rdi, [r8 + r9*8]        ; table[i5]
    lea     rdi, [rdi + rdi*4]      ; x5 = table[i5] * 5

.next:
    inc     ecx                     ; ++k
    cmp     ecx, MAX_N
    jb      .loop

    pop     rdi                     ; restore n
    mov     rax, [r8 + rdi*8 - 8]   ; return table[n - 1]
    ret

section .bss
alignb 8
table:
    resq    MAX_N
