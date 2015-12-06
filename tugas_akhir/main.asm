; This is the main program. Used to load routines, and to define variables.

.include "m8515def.inc"
.include "init.asm"
.include "game.asm"
.include "gameover.asm"

.def temp = r16 ; Temporary variable. Be sure to turn interrupt off before using !!
.def gamestate = r17 ; 0 = titlescreen, 1 = game playing, 2 = gameover
.def level = r18
.def score = r19
.def time = r20
.def led_position = r21

.equ WIN_POSITION = 0b00001000 ; winning light addresss


; Arbitrary CPU clock timing component
.def timing1 = r23 
.def timing2 = r24

.org $00
	rjmp reset
.org $01
	rjmp buttonpress ; Redirects buttonpress interrupt
.org $04
	;insert timer0 compare event here

reset:
	ldi temp,low(RAMEND)
	out SPL,temp
	ldi temp,high(RAMEND)
	out SPH,temp
	rcall reset_lcd
	rjmp main

; Wait for input.
wait:
rjmp wait

reset_lcd:
	cbi PORTA,1 ; CLR RS
	ldi temp,0x38 ; MOV DATA,0x38 --> 8bit, 2line, 5x7
	out PORTB,temp
	rcall enable
	ldi temp,$0E ; MOV DATA,0x0E --> disp ON, cursor ON, blink OFF
	out PORTB,temp
	rcall enable
	ldi PB,$01 ; MOV DATA,0x01
	out PORTB,PB
	rcall enable
	ldi temp,$06 ; MOV DATA,0x06 --> increase cursor, display sroll OFF
	out PORTB,temp
	rcall enable
	ret

enable:
	sbi PORTA,0 ; SETB EN
	cbi PORTA,0 ; CLR EN
	ret

buttonpress: ; Reads button input, and act accordingly
	mov r2, temp
	pop temp ; Disables interrupt return.
	mov temp, r2

	ldi temp,0
	cp temp, gamestate
	breq game

	ldi temp,1
	cp temp, gamestate
	breq gamelogic

	ldi temp,2
	cp temp, gamestate
	breq titlescreen
	
	rjmp error ; Make sure they never reach this line

error:
; Displays error on LCD
