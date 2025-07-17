;https://www.intel.com/content/dam/www/public/us/en/documents/manuals/64-ia-32-architectures-software-developer-vol-2b-manual.pdf
default rel
section .text

global strneql_x64_win

%define N r8
%define REMAINING r9
%define STR1 r10
%define STR2 r11
%define STR_OFFSET RBX

; INPUTS:
; first string in RCX
; second string in RDX
; N in R8

; RETURN VALUES:
; rax: 1 or 0

strneql_x64_win:
    PUSH R12 ; callee saved
    PUSH RBX ; callee saved
    mov STR1, RCX
    mov STR2, RDX
    xor RCX, RCX ; clear rcx
    xor STR_OFFSET, STR_OFFSET ; clear RBX
    pxor xmm3, xmm3 ;clear xmm3
.loop:
; https://www.intel.com/content/www/us/en/docs/intrinsics-guide/index.html#ig_expand=4842,1047&text=cmpistr
    mov REMAINING, N
    sub REMAINING, STR_OFFSET

    ; -- clamp remainder to 16 --
    MOV RDX, 16 ;CMOVcc only be used between registers, thus constant must be moved
    CMP REMAINING, 16
    CMOVA REMAINING, RDX     ;compare move above (move if greater)
    

    MOVDQU     XMM0, [STR1 + STR_OFFSET]
    MOVDQU     XMM1, [STR2 + STR_OFFSET]

    ; find null terminator
    pcmpistri XMM0, XMM3, 0x0A
    mov RDX, RCX
    pcmpistri XMM1, XMM3, 0x0A
    mov R12, RCX

    CMP     RDX, R12
    JE      .skip_jump        ; If RDX == R12, skip the null terminator index checks
    
    ; check if null terminator 1 is less than remaining
    CMP     RDX, REMAINING
    JB      .diff_ret         ; Unsigned jump if below

    ; check if null terminator 2 is less than remaining
    CMP     R12, REMAINING
    JB      .diff_ret         ; Unsigned jump if below


.skip_jump:

    CMP REMAINING, RDX ; clamp remaining to null terminator index 1
    CMOVA REMAINING, RDX
    CMP REMAINING, R12 ; clamp remaining to null terminator index 2
    CMOVA REMAINING, R12

    MOV RAX, REMAINING
    MOV RDX, REMAINING
    ; ecx will be 16 is there is no difference, and the carry flag will be 0 is there's no difference
    ; Zero Flag (ZF) will be set if all chars matched and a null terminator was found
    ; Carry Flag set if a mismatch was found before null terminator
    PCMPESTRI  XMM0, XMM1, 0x18 ;https://john-lazzaro.github.io/class/special/pdf/string_opcodes.pdf
    ; ECX now holds the index of first difference

    JC      .diff_ret
    JZ      .eql_ret

    ADD     STR_OFFSET, 16
    JMP     .loop

.eql_ret:
    POP RBX
    POP R12
    MOV RAX, 1
    RET
.diff_ret:
    POP RBX
    POP R12
    MOV RAX, 0
    RET