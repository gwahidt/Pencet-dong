; This one is for game and gameplay-related stuff.

; Initialize and run the level
.org $100
game:
	ldi gamestate, 2 ;temp
	ldi temp, 0x9
	cp temp, level0
	brne level_carry
	inc level1
	ldi level0, -1
level_carry:
	inc level0
	rcall level_intermission
	rcall draw_hud
	sei
	rjmp wait


; That one screen with level number and READY? message
level_intermission:
	rcall clear_display
	ldi ZH,high(2*intermission_top_1)
	ldi ZL,low(2*intermission_top_1) 
	rcall write_top_line
	mov temp, level1
	subi temp, -NUMBER_OFFSET
	mov char_buffer, temp
	rcall write_char
	mov temp, level0
	subi temp, -NUMBER_OFFSET
	mov char_buffer, temp
	rcall write_char
	ldi ZH,high(2*intermission_top_2)
	ldi ZL,low(2*intermission_top_2) 
	rcall write_line
	ldi ZH,high(2*intermission_bottom)
	ldi ZL,low(2*intermission_bottom)
	rcall write_bottom_line
	ldi timing2, 255
	rcall generate_delay
	ldi timing2, 255
	rcall generate_delay
	ldi timing2, 255
	rcall generate_delay
	ret

generate_delay:
	dec timing1
	brne generate_delay
	ldi timing1, 254
	dec timing2
	brne generate_delay
	ret

draw_hud:
	rcall clear_display
	; Draw top part
	ldi ZH,high(2*hud_top_1)
	ldi ZL,low(2*hud_top_1) 
	rcall write_top_line
	mov temp, level1
	subi temp, -NUMBER_OFFSET
	mov char_buffer, temp
	rcall write_char
	mov temp, level0
	subi temp, -NUMBER_OFFSET
	mov char_buffer, temp
	rcall write_char
	ldi ZH,high(2*hud_top_2)
	ldi ZL,low(2*hud_top_2) 
	rcall write_line
	mov temp, score1
	subi temp, -NUMBER_OFFSET
	mov char_buffer, temp
	rcall write_char
	mov temp, score0
	subi temp, -NUMBER_OFFSET
	mov char_buffer, temp
	rcall write_char
	;draw bottom part
	ldi ZH,high(2*hud_bottom_1)
	ldi ZL,low(2*hud_bottom_1) 
	rcall write_bottom_line
	mov temp, life
	subi temp, -NUMBER_OFFSET
	mov char_buffer, temp
	rcall write_char
	ldi ZH,high(2*hud_bottom_2)
	ldi ZL,low(2*hud_bottom_2) 
	rcall write_line
	ldi temp, INITIAL_TIME
	subi temp, -NUMBER_OFFSET
	mov char_buffer, temp
	rcall write_char
	ret


	

; Decides victory or defeat
gamelogic:

timer:

intermission_top_1: .db "    LEVEL ", 0xFF ; Top intermission message, part 1
intermission_top_2: .db "    ", 0xFF ; Top intermission message, part 2
intermission_bottom: .db "     READY?     ", 0xFF ; Bottom intermission message
hud_top_1: .db " LVL ", 0xFF ; Top HUD element, part 1
hud_top_2: .db " SCORE ", 0xFF ; Top HUD element, part 2
hud_bottom_1: .db " LIFE ", 0xFF ; Bottom HUD element, part 1
hud_bottom_2: .db " TIME ", 0xFF ; Bottom HUD element, part 2
