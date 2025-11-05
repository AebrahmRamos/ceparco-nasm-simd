; GROUP 2 - Manaois, Ramos, Reyes

bits 64
default rel
section .text
global asmfunc

asmfunc:
    push rbp
    push r12
    push r13
    push r14
    push r15
    mov rbp, rsp
    sub rsp, 32

    mov r10, rcx      ; A
    mov r11, rdx      ; x
    mov r12, r8       ; y
    mov r13d, r9d     ; n

    xor r14d, r14d    ; i = 0

ROW_LOOP:
    cmp r14d, r13d
    jge DONE

    ; sum = 0.0
    xorps xmm0, xmm0

    ; compute row_offset = i * n
    mov eax, r14d
    imul eax, r13d
    mov r15d, eax     ; row_offset

    xor r9d, r9d      ; j = 0
COL_LOOP:
    cmp r9d, r13d
    jge STORE_ROW

    mov eax, r15d
    add eax, r9d
    imul eax, 4
    movss xmm1, dword [r10 + rax]  ; A[i*n + j]
    mov eax, r9d
    imul eax, 4
    movss xmm2, dword [r11 + rax]  ; x[j]

    mulss xmm1, xmm2
    addss xmm0, xmm1

    inc r9d
    jmp COL_LOOP

STORE_ROW:
    mov eax, r14d
    imul eax, 4
    movss dword [r12 + rax], xmm0

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
