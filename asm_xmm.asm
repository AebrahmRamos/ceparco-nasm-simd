; GROUP 2 - Manaois, Ramos, Reyes
; A = RCX, RDX = x, R8 = y, R9 = n

bits 64
default rel
section .text
global asm_xmm

asm_xmm:
    push rbp
    push rbx
    push r12
    push r13
    push r14
    push r15
    sub rsp, 32

    mov r10, rcx
    mov r11, rdx
    mov r12, r8
    mov r13d, r9d
    
    ; i = 0
    xor r14d, r14d

LOOP_ROW:
    cmp r14d, r13d
    jge DONE

    mov eax, r14d
    imul eax, r13d
    mov rax, rax
    shl rax, 2
    mov rbx, r10
    add rbx, rax

    xorps xmm0, xmm0

    mov eax, r13d
    shr eax, 2
    test eax, eax
    jz VTAIL_SCALAR

    xor rsi, rsi

VLOOP:
    movups xmm1, [r11 + rsi*4]
    movups xmm2, [r11 + rsi*4]
    mulps xmm2, xmm1
    addps xmm0, xmm2
    add rsi, 4
    dec eax
    jnz VLOOP

VTAIL_SCALAR:
    movaps xmm1, xmm0
    haddps xmm1, xmm1
    haddps xmm1, xmm1
    movss xmm2, xmm1

    mov eax, r13d
    sub eax, esi
    test eax, eax
    jz STORE_SCALAR

TAIL_LOOP:
    movss xmm3, dword [rbx + rsi*4]
    movss xmm4, dword [r11 + rsi*4]
    mulss xmm3, xmm4
    addss xmm2, xmm3
    add rsi, 1
    dec eax
    jnz TAIL_LOOP

STORE_SCALAR:
    movss dword [r12 + r14*4], xmm2

    inc r14d
    jmp LOOP_ROW

DONE:
    add rsp, 32
    pop r15
    pop r14
    pop r13
    pop r12
    pop rbx
    pop rbp
    ret