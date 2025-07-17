;https://www.intel.com/content/dam/www/public/us/en/documents/manuals/64-ia-32-architectures-software-developer-vol-2b-manual.pdf
default rel
section .text
global streql_x64_win

%define STR1 RDI
%define STR2 RSI

streql_x64_unix:
    ;first str in: RDI
    ;second str in: RSI
    xor rax, rax ; set rax to 0
    xor rbx, rbx ; set rbx to 0

.loop:
;         // https://www.intel.com/content/www/us/en/docs/intrinsics-guide/index.html#ig_expand=4842,1047&text=cmpistr
    MOVDQU     xmm1, [STR1 + rbx]
    PCMPISTRI  xmm1, [STR2 + rbx], 0x18    ; EQUAL_EACH | NEGATIVE_POLARITY
    ; ecx will be 16 is there is no difference, and the carry flag will be 0 is there's no difference
    ; Zero Flag (ZF) will be set if all chars matched and a null terminator was found
    ; Carry Flag set if a mismatch was found before null terminator
    ; See more about the carry flag and imm8 values: https://www.intel.com/content/dam/www/public/us/en/documents/manuals/64-ia-32-architectures-software-developer-vol-2b-manual.pdf#page=255
    JC      .diff_ret
    JZ      .eql_ret

    ADD     rbx, 16
    JMP     .loop

.eql_ret:
    MOV rax, 1
    RET
.diff_ret:
    MOV rax, 0
    RET