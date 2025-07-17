;https://www.intel.com/content/dam/www/public/us/en/documents/manuals/64-ia-32-architectures-software-developer-vol-2b-manual.pdf
default rel
section .text
global streql_x64_win

%define STR1 rcx
%define STR2 rdx

streql_x64_win:
    ;first str in: rcx
    ;second str in: rdx
    xor rax, rax    ; set rax to 0
    xor rbx, rbx    ; set rbx to 0

.loop:
;         // https://www.intel.com/content/www/us/en/docs/intrinsics-guide/index.html#ig_expand=4842,1047&text=cmpistr
    movdqu     xmm1, [STR1 + rbx]
    pcmpistri  xmm1, [STR2 + rbx], 0x18    ; EQUAL_EACH | NEGATIVE_POLARITY
    ; pcmpistri will set the carry flag: https://www.intel.com/content/dam/www/public/us/en/documents/manuals/64-ia-32-architectures-software-developer-vol-2b-manual.pdf#page=255
    jc      .diff
    jz      .eql
    add     rbx, 16
    jmp     .loop

.eql:
    inc        rax
.diff:
    ret ; ret value is rax