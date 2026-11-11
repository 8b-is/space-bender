default rel

section .data
default_msg: db "One for you, one for me.", 0
prefix_msg: db "One for ", 0
suffix_msg: db ", one for me.", 0

section .text
global two_fer
two_fer:
    test rdi, rdi
    jz .no_name
    
    lea rdi, [rel prefix_msg]
    call strcpy
    mov rdi, rax
    call strcpy
    lea rdi, [rel suffix_msg]
    call strcpy
    ret

.no_name:
    lea rdi, [rel default_msg]
    call strcpy
    ret

strcpy:
    push rdi
    push rsi
.loop:
    mov al, [rdi]
    mov [rsi], al
    inc rdi
    inc rsi
    test al, al
    jnz .loop
    pop rsi
    pop rdi
    lea rax, [rsi - 1]
    ret

%ifidn __OUTPUT_FORMAT__,elf64
section .note.GNU-stack noalloc noexec nowrite progbits
%endif
