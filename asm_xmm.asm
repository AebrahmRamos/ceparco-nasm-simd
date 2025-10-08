bits 64
default rel
section .text
global asm_xmm

asm_xmm:
    push rbp
    push r12
    push r13
    push r14
    push r15
    mov rbp, rsp
    sub rsp, 32

    mov r10, rcx
    mov r11, rdx
    mov r12, r8
    mov r13d, r9d

    xor r14d, r14d

ROW_LOOP:
    cmp r14d, r13d
    jge DONE

    xorps xmm0, xmm0

    mov eax, r14d
    imul eax, r13d
    mov r15d, eax

    mov ecx, r13d
    shr ecx, 2
    test ecx, ecx
    jz COL_SCALAR_LOOP

    xor r9d, r9d
VEC_COL_LOOP:
    mov eax, r15d
    add eax, r9d
    imul eax, 4
    movups xmm1, [r10 + rax]
    mov eax, r9d
    imul eax, 4
    movups xmm2, [r11 + rax]
    mulps xmm1, xmm2
    addps xmm0, xmm1
    add r9d, 4
    dec ecx
    jnz VEC_COL_LOOP

COL_SCALAR_LOOP:
    mov eax, r13d
    and eax, 3
    test eax, eax
    jz STORE_ROW

SCALAR_COL_LOOP:
    cmp r9d, r13d
    jge STORE_ROW
    mov edx, r15d
    add edx, r9d
    imul edx, 4
    movss xmm3, [r10 + rdx]
    mov eax, r9d
    imul eax, 4
    movss xmm4, [r11 + rax]
    mulss xmm3, xmm4
    addss xmm0, xmm3
    inc r9d
    jmp SCALAR_COL_LOOP

STORE_ROW:
    movhlps xmm1, xmm0
    addps xmm0, xmm1
    movaps xmm1, xmm0
    shufps xmm1, xmm1, 0x01
    addss xmm0, xmm1
    mov eax, r14d
    imul eax, 4
    movss [r12 + rax], xmm0

    inc r14d
    jmp ROW_LOOP

DONE:
    add rsp, 32
    pop r15
    pop r14
    pop r13
    pop r12
    pop rbp
    ret