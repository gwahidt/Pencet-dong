; This one is for initialization stuff, just before playing the game

; Displays main menu (game title + high score)
.org $30

titlescreen:
	;display title screen

ldi temp, 0
rjmp main

.db "
