default rel
section .text

global strneql_x64_win

%define N r8
%define REMAINING r9
%define STR1 RDI
%define STR2 RSI

; INPUTS:
; first string in RDI
; second string in RSI
; N in R8

; RETURN VALUES:
; rax: 1 or 0

strneql_x64_win:
    push R12            ; callee saved
    push RBX            ; callee saved

    xor RCX, RCX        ; clear rcx (used by PCMPESTRI)
    xor RBX, RBX        ; offset into strings

.loop:
    mov REMAINING, N
    sub REMAINING, RBX   ; calculate remaining bytes to compare

    ; clamp REMAINING to max 16
    mov RDX, 16
    cmp REMAINING, RDX
    cmova REMAINING, RDX

    ; increment lengths to catch null terminator (max 16)
    mov eax, r9d        ; REMAINING low 32 bits
    mov edx, r9d
    inc eax
    inc edx
    cmp eax, 17
    cmovae eax, 16
    cmp edx, 17
    cmovae edx, 16

    movdqu xmm1, [STR1 + RBX]

    ; Find null terminator in STR2 + RBX
    pcmpeistri xmm1, [STR2 + RBX], 0x58
    mov R12, RCX        ; null terminator index

    ; Find first difference index between strings
    pcmpeistri xmm1, [STR2 + RBX], 0x18
    ; ECX = first difference index

    setc al             ; AL=1 if CF=1 (mismatch before null)

    ; check if null terminator index < first difference index
    cmp RCX, R12
    jl .diff
    je .eql

    cmp al, 0
    jne .diff
    je .eql

    add RBX, 16
    jmp .loop

.eql:
    mov RAX, 1
    pop RBX
    pop R12
    ret

.diff:
    mov RAX, 0
    pop RBX
    pop R12
    ret
