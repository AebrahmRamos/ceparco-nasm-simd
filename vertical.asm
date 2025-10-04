;GROUP 2 - Manois, Ramos, Reyes - S11


bits 64
default rel

section .text
global vertical

; void vertical(const float* x, const float* y, float* z, int n)
; Win64 ABI: RCX=x, RDX=y, R8=z, R9=n
vertical:
    mov     r10, rcx               ; r10 = x
    mov     r11, rdx               ; r11 = y
    mov     r12, r8                ; r12 = z
    mov     eax, r9d               ; eax = n
    mov     ecx, eax
    shr     ecx, 3                 ; ecx = n/8 blocks

L1:
    test    ecx, ecx
    jz      L_tail

    vmovups ymm0, [r10]            ; load 8 floats from x
    vmovups ymm1, [r11]            ; load 8 floats from y
    vaddps  ymm0, ymm0, ymm1       ; vertical add
    vmovups [r12], ymm0            ; store to z

    add     r10, 32
    add     r11, 32
    add     r12, 32
    dec     ecx
    jmp     L1

L_tail:
    and     eax, 7                 ; remainder = n % 8
    jz      L_done
Lt:
    movss   xmm0, dword [r10]
    addss   xmm0, dword [r11]
    movss   dword [r12], xmm0
    add     r10, 4
    add     r11, 4
    add     r12, 4
    dec     eax
    jnz     Lt

L_done:
    vzeroupper
    ret
