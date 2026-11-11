default rel

section .text
global is_pangram
is_pangram:
    test rdi, rdi
    jz .not_pangram
    
    xor rax, rax
    
.check_char:
    movzx ecx, byte [rdi]
    test cl, cl
    jz .check_done
    
    cmp cl, 'A'
    jl .next_char
    cmp cl, 'Z'
    jg .check_lower
    sub cl, 'A'
    jmp .set_bit
    
.check_lower:
    cmp cl, 'a'
    jl .next_char
    cmp cl, 'z'
    jg .next_char
    sub cl, 'a'
    
.set_bit:
    bts rax, rcx
    
.next_char:
    inc rdi
    jmp .check_char
    
.check_done:
    cmp rax, 0x3FFFFFF
    sete al
    movzx eax, al
    ret
    
.not_pangram:
    xor eax, eax
    ret

%ifidn __OUTPUT_FORMAT__,elf64
section .note.GNU-stack noalloc noexec nowrite progbits
%endif
