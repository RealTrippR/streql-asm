;https://www.intel.com/content/dam/www/public/us/en/documents/manuals/64-ia-32-architectures-software-developer-vol-2b-manual.pdf
default rel
section .text
global streql_x64_win

%define STR1 r10
%define STR2 r11

; INPUTS:
; first string in RCX
; second string in RDX

; RETURN VALUES:
; rax: 1 or 0

; MODIFIES:
; rax, ecx

streql_x64_win:
    mov r10, rcx ; move str1 to r10
    mov r11, rdx ; move str2 to r11
    
    xor rax, rax ; set rbx to 0

.loop:
;         // https://www.intel.com/content/www/us/en/docs/intrinsics-guide/index.html#ig_expand=4842,1047&text=cmpistr
    MOVDQU     xmm1, [STR1 + rax]
    PCMPISTRI  xmm1, [STR2 + rax], 0x18    ; EQUAL_EACH | NEGATIVE_POLARITY
    ; ecx will be 16 is there is no difference, and the carry flag will be 0 is there's no difference
    ; Zero Flag (ZF) will be set if all chars matched and a null terminator was found
    ; Carry Flag set if a mismatch was found before null terminator
    ; See more about the carry flag and imm8 values: https://www.intel.com/content/dam/www/public/us/en/documents/manuals/64-ia-32-architectures-software-developer-vol-2b-manual.pdf#page=255
    JC      .diff_ret
    JZ      .eql_ret

    ADD     rax, 16
    JMP     .loop

.eql_ret:
    MOV rax, 1
    RET
.diff_ret:
    MOV rax, 0
    RET