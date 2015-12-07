; This one is for displaying game over messages.

; Displays game over message and score. Also check for highscore
.org 0x200
gameover:
	ldi gamestate, 2
	rcall turn_off_display
	rcall clear_display
	; Draw top part
	ldi ZH,high(2*gameover_message)
	ldi ZL,low(2*gameover_message)
	rcall write_top_line
	; Draw bottom part
	cp highscore1, score1
	brmi display_new_highscore
	brne display_score
	cp highscore0, score0
	brmi display_new_highscore

display_score:
	ldi ZH,high(2*score_message)
	ldi ZL,low(2*score_message)
	rcall write_bottom_line
	mov temp, score1
	subi temp, -NUMBER_OFFSET
	mov char_buffer, temp
	rcall write_char
	mov temp, score0
	subi temp, -NUMBER_OFFSET
	mov char_buffer, temp
	rcall write_char
	rcall turn_on_display
	rjmp wait_gameover

display_new_highscore:
	mov highscore0, score0
	mov highscore1, score1
	ldi ZH,high(2*highscore_message)
	ldi ZL,low(2*highscore_message)
	rcall write_bottom_line
	rcall turn_on_display
	rjmp wait_gameover

wait_gameover:
	sei
forever:
	rjmp forever
gameover_message: .db "    GAMEOVER    ", 0xFF
score_message: .db "    SCORE ", 0xFF
highscore_message: .db "  NEW HISCORE!  ", 0xFF
