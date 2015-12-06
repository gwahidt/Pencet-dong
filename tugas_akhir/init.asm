; This one is for title screen stuff, just before playing the game

; Displays main menu (game title + high score)
.org $50

titlescreen:
	rcall clear_display
	ldi ZH,high(2*title_message_top)
	ldi ZL,low(2*title_message_top) 
	rcall write_top_line
	ldi ZH,high(2*title_message_bottom)
	ldi ZL,low(2*title_message_bottom)
	rcall write_bottom_line
	mov temp, score1
	subi temp, -NUMBER_OFFSET
	mov char_buffer, temp
	rcall write_char
	mov temp, score0
	subi temp, -NUMBER_OFFSET
	mov char_buffer, temp
	rcall write_char
	rjmp wait


game_relay:
	rjmp game

gamelogic_relay:
	rjmp gamelogic

title_message_top:
	.db "  PENCET DONG!  ", 0xFF ; Two-space wide margin on each side
title_message_bottom:
	.db "   HISCORE ", 0xFF ; fill the next two character with score
