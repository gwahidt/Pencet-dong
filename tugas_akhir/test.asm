.include "m8515def.inc"
.def temp = r16
.org $00
rjmp res
.org $01
rjmp press
.org $02
rjmp press

res:
ldi temp,low(RAMEND)
out SPL,temp
ldi temp,high(RAMEND)
out SPH,temp

ldi r16, $ff
out DDRA, r16
out DDRD, r16
out PORTD, r16
ldi r17,0b00001010
out MCUCR,r17

ldi r17,0b11000000
out GICR,r17
sei


forever: rjmp forever

press:
	ldi temp, 0
	;pop temp
	reti
