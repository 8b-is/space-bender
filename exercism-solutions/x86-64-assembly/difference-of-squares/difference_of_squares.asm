default rel

section .text
global square_of_sum
square_of_sum:
    mov eax, edi
    lea ecx, [rax + 1]
    imul eax, ecx
    sar eax, 1
    imul eax, eax
    ret

global sum_of_squares
sum_of_squares:
    mov eax, edi
    lea ecx, [rax + 1]
    lea edx, [rax + rax + 1]
    imul eax, ecx
    imul eax, edx
    mov ecx, 6
    cdq
    idiv ecx
    ret

global difference_of_squares
difference_of_squares:
    push rdi
    call square_of_sum
    mov esi, eax
    pop rdi
    call sum_of_squares
    sub esi, eax
    mov eax, esi
    ret

%ifidn __OUTPUT_FORMAT__,elf64
section .note.GNU-stack noalloc noexec nowrite progbits
%endif
