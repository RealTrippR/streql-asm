;https://www.intel.com/content/dam/www/public/us/en/documents/manuals/64-ia-32-architectures-software-developer-vol-2b-manual.pdf
default rel
section .text

section .rodata align=16
idx_table: db 0,1,2,3,4,5,6,7,8,9,10,11,12,13,14,15
broadcast: db 0,0,0,0, 0,0,0,0, 0,0,0,0, 0,0,0,0

global strneql_x64_win

%define STR1 rcx
%define STR2 rdx
%define N r8
%define REMAINING r9

strneql_x64_win:
    ;first str in: rcx
    ;second str in: rdx
    xor rax, rax    ; set rax to 0
    xor rbx, rbx    ; set rbx to 0
    
.loop:
; // https://www.intel.com/content/www/us/en/docs/intrinsics-guide/index.html#ig_expand=4842,1047&text=cmpistr
    mov REMAINING, N
    sub REMAINING, rbx

    ; -- clamp remainder to 16 --
    mov r10, 16;CMOVcc only be used between registers, thus constant must be moved
    cmp REMAINING, 16
    cmova REMAINING, r10      ;compare move above (move if greater)
    
    ; -- create byte mask -- 
    ; fill xmm1 with REMAINING
    movq xmm1, REMAINING
    movdqa xmm0, [broadcast]
    pshufb xmm1, xmm0 ; https://www.felixcloutier.com/x86/pshufb A somewhat confusing instruction, see comment at the bottom for explaination

    movdqa xmm2, [idx_table]
    movdqa xmm0, xmm1
    ;Compare Packed Signed Integers for Greater Than - https://www.felixcloutier.com/x86/pcmpgtb:pcmpgtw:pcmpgtd
    pcmpgtb xmm0, xmm2     ; xmm0[i] = (xmm0[i] > xmm1[i]) ? 0xFF : 0x00


    movdqu      xmm1, [STR1 + rbx]
    movdqu      xmm2, [STR2 + rbx]
    
    ; -- logical and w/ byte mask --
    ;https://www.intel.com/content/www/us/en/docs/intrinsics-guide/index.html#text=_mm_and_si128&ig_expand=305
    pand xmm1, xmm0
    pand xmm2, xmm0

    pcmpistri   xmm1, xmm2, 0x18    ; EQUAL_EACH | NEGATIVE_POLARITY
    ; pcmpistri will set the carry flag: https://www.intel.com/content/dam/www/public/us/en/documents/manuals/64-ia-32-architectures-software-developer-vol-2b-manual.pdf#page=255
    jc      .diff
    jz      .eql
    add     rbx, 16
    jmp     .loop

.eql:
    inc        rax
.diff:
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