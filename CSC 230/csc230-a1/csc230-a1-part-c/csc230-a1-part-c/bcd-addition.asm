; bcd-addition.asm
; CSC 230: Fall 2022
;
; Code provided for Assignment #1
;
; Mike Zastre (2022-Sept-22)

; This skeleton of an assembly-language program is provided to help you
; begin with the programming task for A#1, part (c). In this and other
; files provided through the semester, you will see lines of code
; indicating "DO NOT TOUCH" sections. You are *not* to modify the
; lines within these sections. The only exceptions are for specific
; changes announced on conneX or in written permission from the course
; instructor. *** Unapproved changes could result in incorrect code
; execution during assignment evaluation, along with an assignment grade
; of zero. ****
;
; In a more positive vein, you are expected to place your code with the
; area marked "STUDENT CODE" sections.

; ==== BEGINNING OF "DO NOT TOUCH" SECTION ====
; Your task: Two packed-BCD numbers are provided in R16
; and R17. You are to add the two numbers together, such
; the the rightmost two BCD "digits" are stored in R25
; while the carry value (0 or 1) is stored R24.
;
; For example, we know that 94 + 9 equals 103. If
; the digits are encoded as BCD, we would have
;    * 0x94 in R16
;    * 0x09 in R17
; with the result of the addition being:
;    * 0x03 in R25
;    * 0x01 in R24
;
; Similarly, we know than 35 + 49 equals 84. If
; the digits are encoded as BCD, we would have
;    * 0x35 in R16
;    * 0x49 in R17
; with the result of the addition being:
;    * 0x84 in R25
;    * 0x00 in R24
;

; ANY SIGNIFICANT IDEAS YOU FIND ON THE WEB THAT HAVE HELPED
; YOU DEVELOP YOUR SOLUTION MUST BE CITED AS A COMMENT (THAT
; IS, WHAT THE IDEA IS, PLUS THE URL).

    .cseg
    .org 0

    ; Some test cases below for you to try. And as usual
    ; your solution is expected to work with values other
    ; than those provided here.
    ;
    ; Your code will always be tested with legal BCD
    ; values in r16 and r17 (i.e. no need for error checking).

    ; 94 + 9 = 03, carry = 1
    ; ldi r16, 0x94
    ; ldi r17, 0x09

    ; 86 + 79 = 65, carry = 1
    ; ldi r16, 0x86
    ; ldi r17, 0x79

    ; 35 + 49 = 84, carry = 0
    ; ldi r16, 0x35
    ; ldi r17, 0x49

    ; 32 + 41 = 73, carry = 0
    ;ldi r16, 0x32
    ;ldi r17, 0x41

; ==== END OF "DO NOT TOUCH" SECTION ==========

; **** BEGINNING OF "STUDENT CODE" SECTION ****

    ; Initialize output registers
    CLR R24         ; R24 = final BCD carry (0 or 1 for 100s place)
    CLR R25         ; R25 = packed BCD sum (digits for 1s and 10s)

    ; Temporary register for carry between low and high nibble addition
    CLR R20         ; R20 = BCD carry from low nibble to high nibble (0 or 1)

    ; Save registers that might be used by testing harness or are commonly callee-saved.
    ; R0, R1 are used as general scratch registers.
    ; R22, R23 are used to hold sums for adjustment.
    PUSH R0
    PUSH R1
    PUSH R18        ; Added for ANDI workaround
    PUSH R19        ; Added for ANDI workaround
    PUSH R22
    PUSH R23

    ; --- Part 1: Add Lower Nibbles ---
    ; R18 will hold LN1 (Lower Nibble of R16), R19 will hold LN2 (Lower Nibble of R17)
    ; R0 will hold their sum. R22 will hold the sum for BCD adjustment.
    MOV R18, R16    ; Copy R16 to R18
    ANDI R18, 0x0F  ; R18 = LN1 (Lower Nibble of R16)
    MOV R19, R17    ; Copy R17 to R19
    ANDI R19, 0x0F  ; R19 = LN2 (Lower Nibble of R17)

    MOV R0, R18     ; R0 = LN1 (R18 is in R16-R31, R0 is scratch for ADD)
    ADD R0, R19     ; R0 = LN1 + LN2. SREG H (Half Carry) flag is updated.
    MOV R22, R0     ; Copy sum to R22 for adjustment.

    ; BCD Adjustment for Lower Nibble:
    ; If (sum > 9) OR (Half Carry was set), then sum_bcd = sum + 6, and set BCD carry to next digit.
    BRHC low_nibble_H_clear ; Branch if Half Carry (H from ADD R0,R1) is Clear
    ; H is set: (e.g., 8+8=0x10, H=1; 5+5=0x0A, H=1)
    SUBI R22, 0xFA    ; Adjust sum: R22 = R22 + 6 (R22 = R22 - (-6))
    LDI R20, 0x01     ; Set BCD carry to high nibble stage
    JMP low_nibble_adjusted_value

low_nibble_H_clear:
    ; H is clear: check if sum in R22 is > 9 (e.g. 7+4=0x0B, H=0; 9+1=0x0A, H=0)
    CPI R22, 0x0A
    BRLO low_nibble_no_adjustment ; Branch if R22 < 0x0A (sum is 0-9, H was clear, so no adjustment needed)
    ; Sum is >= 0x0A (and H was clear)
    SUBI R22, 0xFA    ; Adjust sum: R22 = R22 + 6 (R22 = R22 - (-6))
    LDI R20, 0x01     ; Set BCD carry to high nibble stage
    JMP low_nibble_adjusted_value

low_nibble_no_adjustment:
    ; No adjustment needed for the lower nibble. R20 remains 0.
    NOP               ; Explicitly show no operation here.

low_nibble_adjusted_value:
    ; R22 now contains the BCD adjusted sum (e.g., if 9+9, R0=0x12, H=1 -> R22=0x12+0x06=0x18)
    ; The lower nibble of R22 is the BCD digit for the 1's place.
    ANDI R22, 0x0F    ; R22 = BCD digit for 1's place (e.g., 0x18 -> 0x08)
    OR R25, R22       ; Store this digit in the lower nibble of R25. (R25 initially 0)


    ; --- Part 2: Add Upper Nibbles + Carry from Lower Nibble (R20) ---
    ; R18 will hold HN1 (Higher Nibble of R16), R19 will hold HN2 (Higher Nibble of R17)
    ; R0 will hold their sum (plus R20). R23 will hold this sum for BCD adjustment.
    MOV R18, R16    ; Copy R16 to R18
    SWAP R18        ; Isolate HN1 in lower nibble of R18
    ANDI R18, 0x0F  ; R18 = HN1 (Higher Nibble of R16)

    MOV R19, R17    ; Copy R17 to R19
    SWAP R19        ; Isolate HN2 in lower nibble of R19
    ANDI R19, 0x0F  ; R19 = HN2 (Higher Nibble of R17)

    MOV R0, R18     ; R0 = HN1
    ADD R0, R19     ; R0 = HN1 + HN2
    ADD R0, R20     ; R0 = HN1 + HN2 + R20 (BCD carry from low nibble stage). SREG H flag updated by this.
    MOV R23, R0     ; Copy sum to R23 for adjustment.

    ; BCD Adjustment for Upper Nibble:
    ; If (sum > 9) OR (Half Carry was set for THIS sum), then sum_bcd = sum + 6, and set final BCD carry (R24).
    BRHC high_nibble_H_clear ; Branch if Half Carry (H from ADD R0,R20) is Clear
    ; H is set:
    SUBI R23, 0xFA    ; Adjust sum: R23 = R23 + 6 (R23 = R23 - (-6))
    LDI R24, 0x01     ; Set final BCD carry (for 100s place)
    JMP high_nibble_adjusted_value

high_nibble_H_clear:
    ; H is clear: check if sum in R23 is > 9
    CPI R23, 0x0A
    BRLO high_nibble_no_adjustment ; Branch if R23 < 0x0A (sum is 0-9, H clear, no adjustment)
    ; Sum is >= 0x0A (and H was clear)
    SUBI R23, 0xFA    ; Adjust sum: R23 = R23 + 6 (R23 = R23 - (-6))
    LDI R24, 0x01     ; Set final BCD carry (for 100s place)
    JMP high_nibble_adjusted_value

high_nibble_no_adjustment:
    ; No adjustment needed for the upper nibble. R24 remains 0 if not set above.
    NOP
		
high_nibble_adjusted_value:
    ; R23 now contains the BCD adjusted sum for the 10's place.
    ANDI R23, 0x0F    ; R23 = BCD digit for 10's place
    SWAP R23          ; Move digit to upper nibble position (e.g., 0x08 -> 0x80)
    OR R25, R23       ; Combine with the 1's place BCD digit in R25.

    ; Restore saved registers
    POP R23
    POP R22
    POP R19         ; Added for ANDI workaround
    POP R18         ; Added for ANDI workaround
    POP R1
    POP R0

; **** END OF "STUDENT CODE" SECTION **********

; ==== BEGINNING OF "DO NOT TOUCH" SECTION ====
bcd_addition_end:
    rjmp bcd_addition_end
; ==== END OF "DO NOT TOUCH" SECTION ==========