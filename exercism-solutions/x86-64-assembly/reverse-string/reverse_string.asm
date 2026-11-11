default rel

section .text
global reverse
reverse:
    ; void reverse(char *str)
    ; rdi = str
    
    test rdi, rdi
    jz .done
    
    mov rsi, rdi
    dec rsi
.find_end:
    inc rsi
    cmp byte [rsi], 0
    jne .find_end
    dec rsi
    
.swap_loop:
    cmp rdi, rsi
    jae .done
    
    mov al, [rdi]
    mov ah, [rsi]
    mov [rdi], ah
    mov [rsi], al
    
    inc rdi
    dec rsi
    jmp .swap_loop

.done:
    ret

%ifidn __OUTPUT_FORMAT__,elf64
section .note.GNU-stack noalloc noexec nowrite progbits
%endif
