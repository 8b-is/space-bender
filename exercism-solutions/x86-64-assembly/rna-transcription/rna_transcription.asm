default rel

section .text
global to_rna
to_rna:
    test rdi, rdi
    jz .done
    test rsi, rsi
    jz .done
    
.loop:
    movzx eax, byte [rdi]
    test al, al
    jz .done
    
    cmp al, 'C'
    je .out_G
    cmp al, 'G'
    je .out_C
    cmp al, 'T'
    je .out_A
    cmp al, 'A'
    je .out_U
    mov [rsi], al
    inc rdi
    inc rsi
    jmp .loop
    
.out_G:
    mov byte [rsi], 'G'
    inc rdi
    inc rsi
    jmp .loop
.out_C:
    mov byte [rsi], 'C'
    inc rdi
    inc rsi
    jmp .loop
.out_A:
    mov byte [rsi], 'A'
    inc rdi
    inc rsi
    jmp .loop
.out_U:
    mov byte [rsi], 'U'
    inc rdi
    inc rsi
    jmp .loop

.done:
    mov byte [rsi], 0
    ret

%ifidn __OUTPUT_FORMAT__,elf64
section .note.GNU-stack noalloc noexec nowrite progbits
%endif
