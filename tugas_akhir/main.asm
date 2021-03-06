; This is the main program. Used to load routines, and to define variables.

.include "m8515def.inc"
.include "init.asm"
.include "game.asm"
.include "gameover.asm"

.def temp = r16 ; Temporary variable. Be sure to turn interrupt off before using !!
.def gamestate = r17 ; 0 = titlescreen, 1 = game playing, 2 = gameover, 3 = "interrupt dump mode"
.def level0 = r18 ; low digit for level display
.def level1 = r19 ; high digit for level display
.def score0 = r20 ; low digit for score display
.def score1 = r21 ; high digit for score display
.def time = r22
.def life = r23
.def led_position = r24
.def bounce_flag = r11

.def delimiter = r3
.def win_position = r4
.def char_buffer = r5 ; For displaying character

.equ SCORE0_ADDR = 0x60 ; Memory address for score
.equ SCORE1_ADDR = 0x61

.equ WINPOS = 0b00001000 ; winning light addresss
.equ DELIM = 0xFF
.equ NUMBER_OFFSET = 0x30
.equ TOP_LINE_ADDR = 0x80
.equ BOTTOM_LINE_ADDR = 0xC0
.equ INITIAL_TIME = 0x03
.equ INITIAL_SPEED = 240
.equ SPEED_SCALING = 20
.equ SPEED_FACTOR = 100


; Arbitrary CPU clock timing component
.def delay1 = r6
.def delay2 = r7

; Used in timing. Set the delay above for use.
.def timing1 = r8
.def timing2 = r9

; Dynamic level speed controller
.def levelspeed = r10

; TEMPORARY HIGH SCORE STORAGE. TODO : Change to EEPROM-based storage
.def highscore1 = r12
.def highscore0 = r13

.org $00
	rjmp reset
.org $01
	rjmp buttonpress ; Redirects buttonpress interrupt
.org $0E
	rjmp compare_timer ; Overflow timer

reset:
	ldi temp,low(RAMEND)
	out SPL,temp
	ldi temp,high(RAMEND)
	out SPH,temp
	ldi temp, WINPOS
	mov win_position, temp
	ldi temp, DELIM
	mov delimiter, temp
	rcall init_lcd
	rcall init_button
	rcall init_led
	rcall init_timer
	rjmp titlescreen

; Wait for input.
wait:
rjmp wait

init_lcd:
	ldi temp, $ff
	out DDRA, temp
	out DDRB, temp
	cbi PORTA,1 ; CLR RS
	ldi temp,0x38 ; MOV DATA,0x38 --> 8bit, 2line, 5x7
	out PORTB,temp
	rcall enable
	ldi temp,$0C ; MOV DATA,0x0E --> disp ON, cursor OFF, blink OFF
	out PORTB,temp
	rcall enable
	ldi temp,$06 ; MOV DATA,0x06 --> increase cursor, display sroll OFF
	out PORTB,temp
	rcall enable
	rcall clear_display
	ret

init_button:
	ldi temp, $ff
	out DDRD, temp
	;out PORTD, temp
	ldi temp,0b00001010
	out MCUCR,temp
	ldi temp,0b11000000
	out GICR,temp
	ret

init_led:
	ldi temp, $ff
	out DDRC, temp
	ldi temp, 0x0
	out PORTC, temp
	ret

init_timer:
	ldi r16, 0x0 ; (1<<CS02)|(1<<CS00) Timer clock = system clock/1024
	out TCCR0,r16	
	ldi temp,1<<OCIE0
	out TIMSK,temp		; Enable Timer/Counter0 compare int
	ldi temp,1<<OCF0
	out TIFR,temp		; Interrupt if compare true in T/C0
	ldi temp,0xFF
	out OCR0,temp		; Set compared value
	ret

start_timer:
	ldi temp, (1<<CS02)|(1<<CS00) ; (1<<CS02)|(1<<CS00) Timer clock = system clock/1024
	out TCCR0,temp
	ret

stop_timer:
	ldi temp, (0<<CS02)&(0<<CS00)
	out TCCR0,r16
	ret

reset_timer:
	ldi temp, 0
	out TCNT0, temp
	ret

turn_off_display:
	ldi temp,$08 ; MOV DATA,0x0E --> disp ON, cursor OFF, blink OFF
	out PORTB,temp
	rcall enable
	ret

turn_on_display:
	ldi temp,$0C ; MOV DATA,0x0E --> disp ON, cursor OFF, blink OFF
	out PORTB,temp
	rcall enable
	ret


clear_display:
	ldi temp, 0x01 ; --> Clear display
	out PORTB,temp
	rcall enable
	ldi temp, 0x02 ; --> Reset cursor position
	out PORTB,temp
	rcall enable
	ret

enable:
	sbi PORTA,0 ; SETB EN
	cbi PORTA,0 ; CLR EN
	ret

write_top_line:
	ldi temp, TOP_LINE_ADDR
	out PORTB, temp
	rcall enable
	rjmp write_line

write_bottom_line:
	ldi temp, BOTTOM_LINE_ADDR
	out PORTB, temp
	rcall enable
	rjmp write_line

write_line:
	lpm
	cp delimiter, r0
	breq write_line_done
	adiw Z, 1
	mov char_buffer, r0
	rcall write_char
	rjmp write_line
write_line_done:
	ret
	
write_char:
	sbi PORTA,1
	mov temp, char_buffer
	out PORTB, temp
	rcall enable
	cbi PORTA,1
	ret

buttonpress: ; Reads button input, and act accordingly
	mov r2, temp
;	pop temp ; Disables interrupt return.
;	pop temp
	mov temp, r2

	ldi temp,0
	cp temp, gamestate
	breq game_relay

	ldi temp,1
	cp temp, gamestate
	breq gamelogic_relay

	ldi temp,2
	cp temp, gamestate
	breq titlescreen

	ldi temp,3
	cp temp, gamestate
	brne skip_dump
	reti	; Interrupt queue dump
skip_dump:
	rjmp titlescreen

compare_timer:
	rcall stop_timer
	tst time
	breq timer_zero
	subi time, 1
	ldi temp, 0xCD
	out PORTB, temp
	rcall enable
	mov temp, time
	subi temp, -NUMBER_OFFSET
	mov char_buffer, temp
	rcall write_char
	rcall start_timer
	sei
	ret
timer_zero:
	rjmp lose
