;https://www.intel.com/content/dam/www/public/us/en/documents/manuals/64-ia-32-architectures-software-developer-vol-2b-manual.pdf
default rel
section .text

global strneql_x64_win

%define N r8
%define REMAINING r9
%define STR1 r10
%define STR2 r11


; INPUTS:
; first string in RCX
; second string in RDX
; N in R8

; RETURN VALUES:
; rax: 1 or 0

strneql_x64_win:
    PUSH R12 ; callee saved
    PUSH RBX ; callee saved

    mov STR1, RCX ; move str1 to r10
    mov STR2, RDX ; move str2 to r11
    xor RCX, RCX ; clear rcx
    xor RBX, RBX ; clear RBX
.loop:
; // https://www.intel.com/content/www/us/en/docs/intrinsics-guide/index.html#ig_expand=4842,1047&text=cmpistr
    mov REMAINING, N
    sub REMAINING, RBX ; rbx is current offset from strings

    ; -- clamp remainder to 16 --
    MOV RDX, 16 ;CMOVcc only be used between registers, thus constant must be moved
    CMP REMAINING, 16
    CMOVA REMAINING, RDX     ;compare move above (move if greater)
    
    ; set explicit length
    MOV EAX, REMAINING%+d  ; lower half of REMAINING
    MOV EDX, REMAINING%+d  ; lower half of REMAINING
   
    MOVDQU     XMM1, [STR1 + RBX]
    ; pcmpistri will store the index of the null terminator in rcx
    PCMPESTRI   XMM1, [STR2 + RBX], 0x58 ;https://www.intel.com/content/www/us/en/docs/intrinsics-guide/index.html#text=PCMPGTB&ig_expand=305,4903
    MOV R12, RCX ; store null terminator index in


    ; ecx will be 16 is there is no difference, and the carry flag will be 0 is there's no difference
    ; Zero Flag (ZF) will be set if all chars matched and a null terminator was found
    ; Carry Flag set if a mismatch was found before null terminator
    PCMPESTRI   XMM1, [STR2 + RBX], 0x18 ;https://www.intel.com/content/www/us/en/docs/intrinsics-guide/index.html#text=PCMPGTB&ig_expand=305,4903
    ; ECX now holds the index of first difference

    SETC al      ; AL = 1 if CF=1, else 0

    ; check if null-index is less than first-diff-index, if so jump to diff
    CMP R12, RCX
    JL .diff
    JE .eql

    ; check carry flag
    CMP AL, 0
    JNE      .diff
    JE      .eql

    ADD     RBX, 16
    JMP     .loop

.eql:
    MOV RAX, 1    
    ; prevent out of bounds
    CMP ECX, 16
    JL .ret

    POP RBX
    POP R12 ; callee saved
    RET;
.diff:
    MOV RAX, 0
    POP RBX
    POP R12 ; callee saved
    ret
.ret:
    POP RBX
    POP R12 ; callee saved
    ret ; ret value is rax