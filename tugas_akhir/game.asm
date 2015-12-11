; This one is for game and gameplay-related stuff.

; Initialize and run the level
.org 0x105
game:
	; Increments level
	ldi gamestate, 1
	ldi temp, 0x9
	cp temp, level0
	brne level_carry
	inc level1
	ldi level0, -1
level_carry:
	inc level0
game_init:
	ldi temp,low(RAMEND)
	out SPL,temp
	ldi temp,high(RAMEND)
	out SPH,temp
	rcall level_intermission
	rcall game_setting
	rcall draw_hud
	rcall start_timer
	sei
game_loop:
	rcall generate_delay
	tst bounce_flag
	brne move_down
	rjmp move_up

move_up:
	ldi temp, 0b00000001
	cp temp, led_position
	breq flip_down
	lsr led_position
	out PORTC, led_position
	rjmp game_loop
flip_down:
	ldi temp,1
	mov bounce_flag, temp
	rjmp move_down

move_down:
	ldi temp, 0b10000000
	cp temp, led_position
	breq flip_up
	lsl led_position
	out PORTC, led_position
	rjmp game_loop
flip_up:
	ldi temp,0
	mov bounce_flag, temp
	rjmp move_up

; That one screen with level number and READY? message
level_intermission:
	rcall turn_off_display
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
	rcall turn_on_display
	ldi temp, 255
	mov delay1, temp
	mov delay2, temp
	rcall generate_delay
	rcall generate_delay
	rcall generate_delay
	ret

generate_delay:
	mov timing1, delay1
delay:
	dec timing2
	brne delay
	mov timing2, delay2
	dec timing1
	brne delay
	ret

draw_hud:
	rcall turn_off_display
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
	mov temp, time
	subi temp, -NUMBER_OFFSET
	mov char_buffer, temp
	rcall write_char
	rcall turn_on_display
	ret

display_lose_message:
	rcall turn_off_display
	rcall clear_display
	ldi ZH,high(2*lose_top)
	ldi ZL,low(2*lose_top) 
	rcall write_top_line
	ldi ZH,high(2*lose_bottom)
	ldi ZL,low(2*lose_bottom) 
	rcall write_bottom_line
	mov temp, life
	subi temp, -NUMBER_OFFSET
	mov char_buffer, temp
	rcall write_char
	rcall turn_on_display
	ldi temp, 255
	mov delay1, temp
	mov delay2, temp
	rcall generate_delay
	rcall generate_delay
	rcall generate_delay
	ret


game_setting:
	rcall reset_timer
	ldi temp, SPEED_FACTOR
	mov delay1, temp
	mov temp, levelspeed
	mov delay2, temp
	ldi time, INITIAL_TIME
	ldi led_position, 0b10000000
	out PORTC, led_position
	ldi temp, 0
	mov bounce_flag, temp
	ret

; Decides victory or defeat
gamelogic:
	cp led_position, win_position
	breq win
lose:
	rcall stop_timer
	tst life
	breq gameover_relay
	dec life
	rcall display_lose_message
	rjmp game_init
win:
	ldi temp, SPEED_SCALING
	sub levelspeed, temp
	add score0, time
	ldi temp, 0x0A
	cp score0, temp
	brmi score_carry
	inc score1
	sub score0, temp
score_carry:
	rjmp game
	

intermission_top_1: .db "    LEVEL ", 0xFF ; Top intermission message, part 1
intermission_top_2: .db "    ", 0xFF ; Top intermission message, part 2
intermission_bottom: .db "     READY?     ", 0xFF ; Bottom intermission message
hud_top_1: .db " LVL ", 0xFF ; Top HUD element, part 1
hud_top_2: .db " SCORE ", 0xFF ; Top HUD element, part 2
hud_bottom_1: .db " LIFE ", 0xFF ; Bottom HUD element, part 1
hud_bottom_2: .db " TIME ", 0xFF ; Bottom HUD element, part 2
lose_top: .db "    YOU LOSE    ", 0xFF; lose message top
lose_bottom: .db "     LIFE ", 0xFF ;lose message bottom

gameover_relay:
	rjmp gameover
