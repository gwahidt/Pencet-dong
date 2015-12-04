; This is the main program. Used to load routines, and to define variables.

.include "m8515def.inc"
.include "init.asm"
.include "game.asm"
.include "gameover.asm"

.def temp = r16 ; Temporary variable. Be sure to turn interrupt off before using !!
.def gamestate = r17 ; 0 = init, 1 = game playing, 2 = gameover
.def level = r18
.def score = r19
.def time = r20
.def led_position = r21
.def 

; Arbitrary CPU clock timing component
.def timing1 = r23 
.def timing2 = r24

.org $00
	rjmp reset
.org $01
	rjmp buttonpress ; Redirects buttonpress interrupt

reset:
	ldi temp,low(RAMEND)
	out SPL,temp
	ldi temp,high(RAMEND)
	out SPH,temp
	rjmp main


main:
	rjmp init
	rjmp main

buttonpress: ; Reads button input, and act accordingly
	mov r02, temp
	pop temp ; Disables interrupt return, thus saving stack space
	mov temp, r02

	ldi temp,0
	cp temp, gamestate
	breq game

	ldi temp,1
	cp temp, gamestate
	breq gamelogic

	ldi temp,2
	cp temp, gamestate
	breq init
	
	rjmp error ; Make sure they never reach this line

error:
; Displays error on LCD
