bits 64
default rel
section .text
global asm_ymm

asm_ymm:
    push rbp
    push r12
    push r13
    push r14
    push r15
    push rsi
    sub rsp, 24

    mov r10, rcx      ; A base
    mov r11, rdx      ; x base
    mov r12, r8       ; y base
    mov r13d, r9d     ; n

    xor r14d, r14d    ; i = 0


row_loop:
    cmp r14d, r13d
    jge done

    mov rax, r14
    imul rax, r13
    shl rax, 2
    lea rsi, [r10 + rax]

    vpxor ymm0, ymm0, ymm0

    mov ecx, r13d
    shr ecx, 3
    test ecx, ecx
    jz scalar_tail

    xor rdx, rdx
vec_loop:
    vmovups ymm1, [rsi + rdx]
    vmovups ymm2, [r11 + rdx]
    vfmadd231ps ymm0, ymm1, ymm2
    add rdx, 32
    dec rcx
    jnz vec_loop

scalar_tail:
    vextractf128 xmm1, ymm0, 1
    vextractf128 xmm0, ymm0, 0
    vaddps xmm0, xmm0, xmm1
    movaps xmm1, xmm0
    shufps xmm1, xmm1, 0x4E
    addps xmm0, xmm1
    movaps xmm1, xmm0
    shufps xmm1, xmm1, 0x11
    addss xmm0, xmm1

    mov rax, r13
    and rax, 7
    test rax, rax
    jz store_result

    mov ecx, r13d
    shr ecx, 3
    shl ecx, 5
    mov rdx, rcx
scalar_loop:
    movss xmm3, dword [rsi + rdx]
    movss xmm4, dword [r11 + rdx]
    mulss xmm3, xmm4
    addss xmm0, xmm3
    add rdx, 4
    dec rax
    jnz scalar_loop

store_result:
    mov rax, r14
    imul rax, 4
    movss dword [r12 + rax], xmm0

    inc r14d
    jmp row_loop

done:
    vzeroupper
    add rsp, 24
    pop rsi
    pop r15
    pop r14
    pop r13
    pop r12
    pop rbp
    ret
