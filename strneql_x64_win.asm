;https://www.intel.com/content/dam/www/public/us/en/documents/manuals/64-ia-32-architectures-software-developer-vol-2b-manual.pdf
default rel
section .text

section .rodata align=16
idx_table: db 0,1,2,3,4,5,6,7,8,9,10,11,12,13,14,15
broadcast: db 0,0,0,0, 0,0,0,0, 0,0,0,0, 0,0,0,0

global strneql_x64_win


%define N r8
%define REMAINING r9
%define STR1 r10
%define STR2 r11

strneql_x64_win:
    ;first str in: rcx
    ;second str in: rdx
    xor rax, rax    ; clear rax
    xor rbx, rbx    ; clear rbx
    xor r13, r13    ; clear r13
    mov r10, rcx ;move str1 to r10
    mov r11, rdx ;move str2 to r11
    xor rcx, rcx ;clear rx
.loop:
; // https://www.intel.com/content/www/us/en/docs/intrinsics-guide/index.html#ig_expand=4842,1047&text=cmpistr
    mov REMAINING, N
    sub REMAINING, rbx

    ; -- clamp remainder to 16 --
    MOV r12, 16 ;CMOVcc only be used between registers, thus constant must be moved
    CMP REMAINING, 16
    CMOVA REMAINING, r12     ;compare move above (move if greater)
    
    ; set explicit length
    MOV eax, r9d ; lower half of REMAINING
    MOV edx, r9d ; lower half of REMAINING
   
    MOVDQU     xmm1, [STR1 + rbx]
    ; pcmpistri will store the index of the null terminator in rcx
    PCMPESTRI   xmm1, [STR2 + rbx], 0x58 ;https://www.intel.com/content/www/us/en/docs/intrinsics-guide/index.html#text=PCMPGTB&ig_expand=305,4903
    MOV r12, rcx ; store null terminator index in r12

    PCMPESTRI   xmm1, [STR2 + rbx], 0x18 ;https://www.intel.com/content/www/us/en/docs/intrinsics-guide/index.html#text=PCMPGTB&ig_expand=305,4903
    ; rcx now holds the index of first difference
   
    setc al      ; AL = 1 if CF=1, else 0

    ; check if r12 (null-index) is less than rcx(first-diff-index), jump to diff
    CMP rcx, r12
    JL .diff

    cmp al, 0
    jne      .diff
    je      .eql

    ADD     rbx, 16
    JMP     .loop

.eql:
    inc        r13
.diff:
    mov rax, r13
    ret ; ret value is rax


;PSHUFB — Packed Shuffle Bytes
;first MM register: destination operand
;second MM registrer: shuffle control register
;
; PSHUFB works by iterating over the two given MM registers.
; if the 7th-level bit at byte at index i (where i ranges from 0..16) is set
; in the shuffle control mask, the byte at index i in the destination register will be
; zeroed, otherwise the byte in the control mask is used to index into the
; destination register: dst[i] = dst[mask[i] & 0x0F] 
; in other words:
; For i in 0..15:
; If (xmm2[i] & 0x80) != 0:
;     xmm1[i] := 0x00
; Else:
;     xmm1[i] := xmm1[xmm2[i] & 0x0F]
;
; Example:
; xmm1 contains:  A0 A1 A2 A3 A4 A5 A6 A7  A8 A9 AA AB AC AD AE AF
; xmm2 contains:  00 01 02 03  FF FF FF FF  0C 0D 0E 0F  80 80 80 80
;
; xmm1 (result):  A0 A1 A2 A3  00 00 00 00  AC AD AE AF  00 00 00 00