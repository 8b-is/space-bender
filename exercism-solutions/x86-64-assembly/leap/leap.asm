default rel

section .text
global leap_year
leap_year:
    mov eax, edi
    mov ecx, 400
    xor edx, edx
    div ecx
    test edx, edx
    jz .is_leap
    
    mov eax, edi
    mov ecx, 100
    xor edx, edx
    div ecx
    test edx, edx
    jz .not_leap
    
    mov eax, edi
    mov ecx, 4
    xor edx, edx
    div ecx
    test edx, edx
    jz .is_leap
    
.not_leap:
    xor eax, eax
    ret
    
.is_leap:
    mov eax, 1
    ret

%ifidn __OUTPUT_FORMAT__,elf64
section .note.GNU-stack noalloc noexec nowrite progbits
%endif
