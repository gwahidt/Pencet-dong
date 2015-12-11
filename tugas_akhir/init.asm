; This one is for title screen stuff, just before playing the game

; Displays main menu (game title + high score)
.org $8C

titlescreen:
	ldi temp, 0x0
	out PORTC, temp
	rcall turn_off_display
	rcall clear_display
	ldi YH, high(SCORE0_ADDR)
	ldi YL, low(SCORE0_ADDR)
	ld temp, Y+
	mov highscore0, temp
	ld temp, Y
	mov highscore1, temp
	ldi gamestate, 0
	ldi ZH,high(2*title_message_top)
	ldi ZL,low(2*title_message_top) 
	rcall write_top_line
	ldi ZH,high(2*title_message_bottom)
	ldi ZL,low(2*title_message_bottom)
	rcall write_bottom_line
	mov temp, highscore1
	subi temp, -NUMBER_OFFSET
	mov char_buffer, temp
	rcall write_char
	mov temp, highscore0
	subi temp, -NUMBER_OFFSET
	mov char_buffer, temp
	rcall write_char
	rcall turn_on_display
	rcall reset_stats
	sei
	rjmp wait

reset_stats:
	ldi life,3
	ldi level0,0 ; Incremented in game
	ldi level1,0
	ldi score0,0
	ldi score1,0
	ldi temp, INITIAL_SPEED
	mov levelspeed, temp
	ret



game_relay:
	rjmp game

gamelogic_relay:
	rjmp gamelogic

title_message_top: .db "  PENCET DONG!  ", 0xFF ; Two-space wide margin on each side
title_message_bottom: .db "   HISCORE ", 0xFF ; fill the next two character with score
