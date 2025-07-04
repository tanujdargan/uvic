; a2-signalling.asm
; CSC 230: Fall 2022
;
; Student name: Tanuj Dargan
; Student ID: V01040822
; Date of completed work: June 22nd, 2025
;
; *******************************
; Code provided for Assignment #2
;
; Author: Mike Zastre (2022-Oct-15)
;
 
; This skeleton of an assembly-language program is provided to help you
; begin with the programming tasks for A#2. As with A#1, there are "DO
; NOT TOUCH" sections. You are *not* to modify the lines within these
; sections. The only exceptions are for specific changes changes
; announced on Brightspace or in written permission from the course
; instructor. *** Unapproved changes could result in incorrect code
; execution during assignment evaluation, along with an assignment grade
; of zero. ****

.include "m2560def.inc"
.cseg
.org 0

; ***************************************************
; **** BEGINNING OF FIRST "STUDENT CODE" SECTION ****
; ***************************************************

	; initializion code will need to appear in this
    ; section
    ; Performing the initial hardware and memory setup.
	.def temp_reg=r20
	.def portL_val=r21
	.def portB_val=r23

	; Configure Port L and Port B data direction registers for output.
	ldi temp_reg, 0xFF
	sts DDRL, temp_reg
	out DDRB, temp_reg

	; Initialize the stack pointer to the highest address in RAM.
	ldi r17, low(RAMEND)
	out SPL, r17
	ldi r17, high(RAMEND)
	out SPH, r17


; ***************************************************
; **** END OF FIRST "STUDENT CODE" SECTION **********
; ***************************************************

; ---------------------------------------------------
; ---- TESTING SECTIONS OF THE CODE -----------------
; ---- TO BE USED AS FUNCTIONS ARE COMPLETED. -------
; ---------------------------------------------------
; ---- YOU CAN SELECT WHICH TEST IS INVOKED ---------
; ---- BY MODIFY THE rjmp INSTRUCTION BELOW. --------
; -----------------------------------------------------

	rjmp test_part_a
	; Test code


test_part_a:
	ldi r16, 0b00100001
	rcall set_leds
	rcall delay_long

	clr r16
	rcall set_leds
	rcall delay_long

	ldi r16, 0b00111000
	rcall set_leds
	rcall delay_short

	clr r16
	rcall set_leds
	rcall delay_long

	ldi r16, 0b00100001
	rcall set_leds
	rcall delay_long

	clr r16
	rcall set_leds

	rjmp end


test_part_b:
	ldi r17, 0b00101010
	rcall slow_leds
	ldi r17, 0b00010101
	rcall slow_leds
	ldi r17, 0b00101010
	rcall slow_leds
	ldi r17, 0b00010101
	rcall slow_leds

	rcall delay_long
	rcall delay_long

	ldi r17, 0b00101010
	rcall fast_leds
	ldi r17, 0b00010101
	rcall fast_leds
	ldi r17, 0b00101010
	rcall fast_leds
	ldi r17, 0b00010101
	rcall fast_leds
	ldi r17, 0b00101010
	rcall fast_leds
	ldi r17, 0b00010101
	rcall fast_leds
	ldi r17, 0b00101010
	rcall fast_leds
	ldi r17, 0b00010101
	rcall fast_leds

	rjmp end

test_part_c:
	ldi r16, 0b11111000
	push r16
	rcall leds_with_speed
	pop r16

	ldi r16, 0b11011100
	push r16
	rcall leds_with_speed
	pop r16

	ldi r20, 0b00100000
test_part_c_loop:
	push r20
	rcall leds_with_speed
	pop r20
	lsr r20
	brne test_part_c_loop

	rjmp end


test_part_d:
	ldi r21, 'E'
	push r21
	rcall encode_letter
	pop r21
	push r25
	rcall leds_with_speed
	pop r25

	rcall delay_long

	ldi r21, 'A'
	push r21
	rcall encode_letter
	pop r21
	push r25
	rcall leds_with_speed
	pop r25

	rcall delay_long


	ldi r21, 'M'
	push r21
	rcall encode_letter
	pop r21
	push r25
	rcall leds_with_speed
	pop r25

	rcall delay_long

	ldi r21, 'H'
	push r21
	rcall encode_letter
	pop r21
	push r25
	rcall leds_with_speed
	pop r25

	rcall delay_long

	rjmp end


test_part_e:
	ldi r25, HIGH(WORD02 << 1)
	ldi r24, LOW(WORD02 << 1)
	rcall display_message
	rjmp end

end:
    rjmp end


; ****************************************************
; **** BEGINNING OF SECOND "STUDENT CODE" SECTION ****
; ****************************************************

set_leds:
	; This function takes a bitmask in r16 and sets the state of 
	; six LEDs connected to PORTL and PORTB.
	clr portL_val
	clr portB_val

	; Check bit 5 of r16, controls PL7 (via PB1)
	sbrc r16, 5
	ori portB_val, (1<<PB1)

	; Check bit 4 of r16, controls PL5 (via PB3)
	sbrc r16, 4
	ori portB_val, (1<<PB3)
	
	; Check bit 3 of r16, controls PL3 (via PL1)
	sbrc r16, 3
	ori portL_val, (1<<PL1)

	; Check bit 2 of r16, controls PL1 (via PL3)
	sbrc r16, 2
	ori portL_val, (1<<PL3)

	; Check bit 1 of r16, controls PB3 (via PL5)
	sbrc r16, 1
	ori portL_val, (1<<PL5)

	; Check bit 0 of r16, controls PB1 (via PL7)
	sbrc r16, 0
	ori portL_val, (1<<PL7)

	; Write the calculated values to the ports
	sts PORTL, portL_val
	out PORTB, portB_val

	ret


slow_leds:
	; Blinks LEDs slowly based on a pattern from r17.
	mov r16, r17      ; Use r17 pattern for set_leds
	rcall set_leds
	rcall delay_long
	clr r16           ; Turn off LEDs
	rcall set_leds
	ret


fast_leds:
	; Blinks LEDs quickly based on a pattern from r17.
	mov r16, r17      ; Use r17 pattern for set_leds
	rcall set_leds
	rcall delay_short
	clr r16           ; Turn off LEDs
	rcall set_leds
	ret


leds_with_speed:
	; Selects blink speed based on the high bits of a value from the stack.
	push YH
	push YL

	in YH, SPH      ; Use Y as a frame pointer
	in YL, SPL
	
	; Argument on stack is at Y+4 (Y pointing to YL, YH, ret_L, ret_H, arg)
	ldd r17, Y+4      ; Load argument, which contains pattern and speed.
	
	mov r16, r17      ; Copy to r16 to test speed bits
	andi r16, 0b11000000
	
	tst r16
	breq exec_fast_blink

exec_slow_blink:
	rcall slow_leds
	rjmp end_leds_with_speed
	
exec_fast_blink: 
	rcall fast_leds
	
end_leds_with_speed:
	pop YL
	pop YH
	ret


encode_letter:
	; Encodes a character into a 6-bit LED pattern and a speed setting.
	; The result is returned in r25.
	clr r25

	; Set up Y as a frame pointer to access the character from the stack.
	push YH
	push YL
	in YH, SPH
	in YL, SPL

	; Set up Z to point to the PATTERNS table.
	ldi ZH, HIGH(PATTERNS<<1)
	ldi ZL, LOW(PATTERNS<<1)
	
	; Load the character from the stack. Arg is at Y+4.
	ldd temp_reg, Y+4

search_pattern_loop:
	lpm r16, Z ; Get character from table.
	cp r16, temp_reg
	breq pattern_found
	
	adiw Z, 8 ; Go to the next 8-byte entry in the table.
	
	cpi r16, '-' ; Stop if we hit the end-of-table marker.
	brne search_pattern_loop
	
	rjmp encoding_done ; Character not found, r25 is 0.

pattern_found:
	adiw Z, 1 ; Move pointer to the start of the 6-char pattern string.

	ldi r16, 6 ; There are 6 bits to generate.
	ldi temp_reg, 0b00100000 ; Initial mask for the most significant bit.

generate_bitmask_loop:
	lpm r17, Z+ ; Get char from pattern string.
	cpi r17, '.'
	breq led_off
	or r25, temp_reg

led_off:
	lsr temp_reg
	dec r16
	brne generate_bitmask_loop

	; Z now points to the speed flag.
	lpm r16, Z
	cpi r16, 1
	brne encoding_done
	
	ori r25, 0b11000000 ; Set slow speed bits if flag is 1.

encoding_done:
	pop YL
	pop YH
	ret


display_message:
	; Displays a null-terminated string from memory using the encoded LED patterns.
	push r24
	push r25
	push temp_reg

	movw ZH:ZL, r25:r24 ; Use Z as the pointer to the message string.

process_message_loop:
	lpm temp_reg, Z+ ; Read a character and advance the pointer.
	tst temp_reg
	breq all_chars_displayed
	
	push ZH
	push ZL

	mov r21, temp_reg
	push r21
	rcall encode_letter
	pop r21
		
	push r25
	rcall leds_with_speed
	pop r25
		
	rcall delay_long
	pop ZL
	pop ZH
	rjmp process_message_loop

all_chars_displayed: 
	pop temp_reg
	pop r25
	pop r24

	ret

; ****************************************************
; **** END OF SECOND "STUDENT CODE" SECTION **********
; ****************************************************


; =============================================
; ==== BEGINNING OF "DO NOT TOUCH" SECTION ====
; =============================================

; about one second
delay_long:
	push r16

	ldi r16, 14
delay_long_loop:
	rcall delay
	dec r16
	brne delay_long_loop

	pop r16
	ret


; about 0.25 of a second
delay_short:
	push r16

	ldi r16, 4
delay_short_loop:
	rcall delay
	dec r16
	brne delay_short_loop

	pop r16
	ret

; When wanting about a 1/5th of a second delay, all other
; code must call this function
;
delay:
	rcall delay_busywait
	ret


; This function is ONLY called from "delay", and
; never directly from other code. Really this is
; nothing other than a specially-tuned triply-nested
; loop. It provides the delay it does by virtue of
; running on a mega2560 processor.
;
delay_busywait:
	push r16
	push r17
	push r18

	ldi r16, 0x08
delay_busywait_loop1:
	dec r16
	breq delay_busywait_exit

	ldi r17, 0xff
delay_busywait_loop2:
	dec r17
	breq delay_busywait_loop1

	ldi r18, 0xff
delay_busywait_loop3:
	dec r18
	breq delay_busywait_loop2
	rjmp delay_busywait_loop3

delay_busywait_exit:
	pop r18
	pop r17
	pop r16
	ret


; Some tables
;.cseg
;.org 0x600

PATTERNS:
	; LED pattern shown from left to right: "." means off, "o" means
    ; on, 1 means long/slow, while 2 means short/fast.
	.db "A", "..oo..", 1
	.db "B", ".o..o.", 2
	.db "C", "o.o...", 1
	.db "D", ".....o", 1
	.db "E", "oooooo", 1
	.db "F", ".oooo.", 2
	.db "G", "oo..oo", 2
	.db "H", "..oo..", 2
	.db "I", ".o..o.", 1
	.db "J", ".....o", 2
	.db "K", "....oo", 2
	.db "L", "o.o.o.", 1
	.db "M", "oooooo", 2
	.db "N", "oo....", 1
	.db "O", ".oooo.", 1
	.db "P", "o.oo.o", 1
	.db "Q", "o.oo.o", 2
	.db "R", "oo..oo", 1
	.db "S", "....oo", 1
	.db "T", "..oo..", 1
	.db "U", "o.....", 1
	.db "V", "o.o.o.", 2
	.db "W", "o.o...", 2
	.db "W", "oo....", 2
	.db "Y", "..oo..", 2
	.db "Z", "o.....", 2
	.db "-", "o...oo", 1   ; Just in case!

WORD00: .db "HELLOWORLD", 0, 0
WORD01: .db "THE", 0
WORD02: .db "QUICK", 0
WORD03: .db "BROWN", 0
WORD04: .db "FOX", 0
WORD05: .db "JUMPED", 0, 0
WORD06: .db "OVER", 0, 0
WORD07: .db "THE", 0
WORD08: .db "LAZY", 0, 0
WORD09: .db "DOG", 0

; =======================================
; ==== END OF "DO NOT TOUCH" SECTION ====
; =======================================