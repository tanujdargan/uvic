; reset-rightmost.asm
; CSC 230: Fall 2022
;
; Code provided for Assignment #1
;
; Mike Zastre (2022-Sept-22)

; This skeleton of an assembly-language program is provided to help you
; begin with the programming task for A#1, part (b). In this and other
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
; Your task: You are to take the bit sequence stored in R16,
; and to reset the rightmost contiguous sequence of set
; by storing this new value in R25. For example, given
; the bit sequence 0b01011100, resetting the right-most
; contigous sequence of set bits will produce 0b01000000.
; As another example, given the bit sequence 0b10110110,
; the result will be 0b10110000.
;
; Your solution must work, of course, for bit sequences other
; than those provided in the example. (How does your
; algorithm handle a value with no set bits? with all set bits?)

; ANY SIGNIFICANT IDEAS YOU FIND ON THE WEB THAT HAVE HELPED
; YOU DEVELOP YOUR SOLUTION MUST BE CITED AS A COMMENT (THAT
; IS, WHAT THE IDEA IS, PLUS THE URL).

    .cseg
    .org 0

; ==== END OF "DO NOT TOUCH" SECTION ==========

	ldi R16, 0b01011100
	; ldi R16, 0b10110110


	; THE RESULT **MUST** END UP IN R25

; **** BEGINNING OF "STUDENT CODE" SECTION **** 

; Student: Tanuj Dargan
; Date: June 1, 2025
; Algorithm to reset the rightmost contiguous sequence of set bits:
; result = x & ( (x | (x-1)) + 1 )
; This idea is a known bit manipulation hack.
; Source: Stanford Bit Twiddling Hacks (adapted)
; URL: https://graphics.stanford.edu/~seander/bithacks.html#TurnOffContiguous
; (The page describes "Turn off the rightmost contiguous block of 1s in a word" as w = (w | (w - 1)) + 1 & w;)

    ; R16 contains the input x
    ; R25 will store the result
    ; R17 will be used as a temporary register to hold (x-1)

    ; Step 1: Calculate x-1
    ; R17 = x - 1
    MOV R17, R16  ; Copy x (R16) to R17
    SUBI R17, 1   ; R17 = R17 - 1, so R17 = x - 1

    ; Step 2: Calculate x | (x-1)
    ; We will use R25 for the intermediate result of (x | (x-1))
    MOV R25, R16  ; Copy x (R16) to R25
    OR R25, R17   ; R25 = R25 | R17, so R25 = x | (x-1)

    ; Step 3: Calculate (x | (x-1)) + 1
    ; R25 now holds (x | (x-1)), increment it
    INC R25       ; R25 = R25 + 1, so R25 = (x | (x-1)) + 1

    ; Step 4: Calculate x & ((x | (x-1)) + 1)
    ; R25 currently holds ((x | (x-1)) + 1)
    ; R16 holds the original x
    AND R25, R16  ; R25 = R25 & R16. This is the final result.

; **** END OF "STUDENT CODE" SECTION ********** 


; ==== BEGINNING OF "DO NOT TOUCH" SECTION ====
reset_rightmost_stop:
    rjmp reset_rightmost_stop


; ==== END OF "DO NOT TOUCH" SECTION ==========
