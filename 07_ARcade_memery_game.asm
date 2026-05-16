.model small
.stack 100h
.data
;Game messages with box drawing borders
msg1     db 13,10,'=====================================$'
msg_head db 13,10,'*       ARCADE MEMORY GAME          *$'
msg2     db 13,10,'Memorize the grid! (4 Seconds)$'
msg_r    db 13,10,'Row (0-3) or [H]int: $'
msg_c    db ' Col (0-3): $'
msg_match db 13,10,'[MATCH!]$'
msg_bonus db ' Bonus: +$'
msg_wrong db 13,10,'[WRONG! Streak Reset]$'
msg_win   db 13,10,'  *** CONGRATULATIONS! YOU WIN ***$'
msg_over  db 13,10,'  *** GAME OVER! BETTER LUCK NEXT TIME ***$'
msg_time  db 13,10,'  *** TIME OUT! SPEED UP NEXT TIME ***$'
msg_score db 13,10,'Score: $'
msg_high  db ' High Score: $'
msg_lives db ' Lives: $'
msg_streak db ' Streak: x$'
msg_t_lbl db ' Time: $'
msg_colon db ':$'

;Scoreboard box interface pieces
sb_top   db 13,10,'  +---------------------------------+$'
sb_mid1  db 13,10,'  |       FINAL SCOREBOARD          |$'
sb_mid2  db 13,10,'  +---------------------------------+$'
sb_sc_l  db 13,10,'  |  YOUR FINAL SCORE : $'
sb_hi_l  db 13,10,'  |  ALL-TIME HIGH    : $'
sb_p_l   db 13,10,'  |  PAIRS MATCHED    : $'
sb_bot   db 13,10,'  +---------------------------------+$'

;File handling variables
fname db 'HI.DAT', 0
fhandle dw ?

;Game grid values
grid db 'A','A','B','B','C','C','D','D','E','E','F','F','G','G','H','H'
hidden db 16 dup('*')  ;hidden board display

;User selection
row1 db ?
col1 db ?
row2 db ?
col2 db ?

;Calculated indexes
idx1 dw ?
idx2 dw ?

;Selected values
val1 db ?
val2 db ?

;Game variables
score dw 0
high_score dw 0
lives db 3
pairs db 0
streak dw 0
seed dw ?
start_time dw ?       ; Stores absolute start tick
timer_pos dw ?

;Print string macro
print macro m
    mov ah,09h
    lea dx,m
    int 21h
endm

.code
start:
    ;initiliaze data segment
    mov ax,@data
    mov ds,ax
    
    ;load saved high score
    call load_high_score

restart_game:
    ;reset game values
    mov score, 0
    mov lives, 3
    mov pairs, 0
    mov streak, 0
    
    ;reset hidden grid
    mov cx, 16
    lea si, hidden
reset_hidden:
    mov byte ptr [si], '*'
    inc si
    loop reset_hidden

    ;Generate random seed
    mov ah,00h
    int 1Ah
    mov seed,dx
    
    ;Shuffle board
    call shuffle
    
    ; Show full grid before game starts
    call refresh_screen
    print msg1
    print msg_head
    print msg1
    call show_grid
    print msg2
    call delay_4sec
    
    ; Set start timestamp securely
    mov ah,00h
    int 1Ah
    mov start_time, dx

;--MAIN GAME LOOP--
game_loop:
    ;clear screen
    call refresh_screen
    
    ;check game over
    cmp lives, 0
    jbe over_state
    
    ;check win condition
    cmp pairs, 8
    je win_state
    
    ;display game information
    print msg1
    print msg_head
    print msg1
    call newline
    
    print msg_score
    mov ax, score
    call print_num
    
    print msg_high
    mov ax, high_score
    call print_num
    
    print msg_lives
    mov al, lives
    xor ah, ah
    call print_num
    
    print msg_streak
    mov ax, streak
    call print_num
    
    ;save time cursor position
    print msg_t_lbl
    mov ah, 03h
    xor bh, bh
    int 10h
    mov timer_pos, dx
    
    ;show hidden box
    call show_hidden

;-FIRST INPUT--
p1:
    ;first card input
    print msg_r
    call get_live_input
    
    ;check for hint request
    cmp al, 'H'
    je do_hint
    
    mov row1, al
    print msg_c
    call get_live_input
    
    ; If hint requested at column prompt, loop back to first selection
    cmp al, 'H'
    je p1
    
    mov col1, al
    
    ;calculate first index
    call calc1
    mov si, idx1
    
    ;prevent selecting opened card
    cmp hidden[si], '*'
    jne p1
    
    ;store first value
    mov al, grid[si]
    mov val1, al

;SECOND INPUT
p2:
    ;second card input
    print msg_r
    call get_live_input
    cmp al, 'H'
    je do_hint
    
    mov row2, al
    print msg_c
    call get_live_input
    
    ; If hint requested at column prompt, loop back to second selection
    cmp al, 'H'
    je p2
    
    mov col2, al
    
    ;calculate second index
    call calc2
    mov si, idx2
    
    ;prevent selecting same card
    cmp si, idx1
    je p2
    
    ;prevent selecting opened card
    cmp hidden[si], '*'
    jne p2
    
    ;store second value
    mov al, grid[si]
    mov val2, al
    
    ;compare both values
    mov al, val1
    cmp al, val2
    je is_match

;-----WRONG MATCH-----
    ;wrong match case
    print msg_wrong
    call beep_low
    dec lives
    
    ; Fix negative score rollovers by checking floor limits
    cmp score, 5
    jb zero_score
    sub score, 5
    jmp reset_streak_flow
zero_score:
    mov score, 0
reset_streak_flow:
    mov streak, 0
    call check_high_score
    call delay_1sec
    jmp game_loop

;----MATCH FOUND----
is_match:
    print msg_match
    ;play match sound
    call beep_high
    
    ;increase streak
    inc streak
    
    ;bonus score calculation
    mov bx, 0           ;initialize
    cmp streak, 2       ; Bonus only after streak >= 2
    jl skip_bonus_calc
    
    ;bonus = streak x 5
    mov ax, streak
    mov cx, 5
    mul cx
    mov bx, ax

skip_bonus_calc:
    ;add normal scores
    add score, 10
    add score, bx       ; add bonus score
    
    ;show bonus if exists
    cmp bx, 0
    je no_bonus_msg
    print msg_bonus
    mov ax, bx
    call print_num

no_bonus_msg:
    ;check high score
    call check_high_score
    
    ;reveal matched cards
    call reveal
    
    ;increase matched pairs
    inc pairs
    call delay_1sec
    jmp game_loop

;----HINT SYSTEM---
do_hint:
    ;Prevent hint if only 1 life left
    cmp lives, 1
    jbe game_loop
    
    ;deduct one life
    dec lives
    
    ;show complete board briefly
    call refresh_screen
    print msg1
    print msg_head
    print msg1
    call show_grid
    call delay_1sec
    jmp game_loop

;-----HINT SCORE CHECK----
check_high_score proc
    mov ax, score
    cmp ax, high_score
    jle no_new_high
    mov high_score, ax   ;high score update
    call save_high_score
no_new_high:
    ret
check_high_score endp

;---LOAD HIGH SCORE---
load_high_score proc
    mov ah, 3Dh         ;open file
    mov al, 0
    lea dx, fname
    int 21h
    
    ;If file exists
    jnc file_found
    
    mov ah, 3Ch         ;create file if not exists
    mov cx, 0
    lea dx, fname
    int 21h
    jc load_exit
    
    mov bx, ax
    mov ah, 40h
    mov cx, 2
    lea dx, high_score
    int 21h
    jmp close_file
    
file_found:
    mov fhandle, ax
    mov ah, 3Fh         ;read high score from file
    mov bx, fhandle
    mov cx, 2
    lea dx, high_score
    int 21h

close_file:
    mov ah, 3Eh         ;close file
    mov bx, fhandle
    int 21h
load_exit:
    ret
load_high_score endp

;---SAVE HIGH SCORE----
save_high_score proc
    mov ah, 3Ch         ;open/create file
    mov cx, 0
    lea dx, fname
    int 21h
    mov fhandle, ax
    
    ;write high score
    mov ah, 40h
    mov bx, fhandle
    mov cx, 2
    lea dx, high_score
    int 21h
    
    ;close file
    mov ah, 3Eh
    mov bx, fhandle
    int 21h
    ret
save_high_score endp

;---INPUT HANDLING----
get_live_input proc
wait_key:
    ;get user current cursor position
    mov ah, 03h
    xor bh, bh
    int 10h
    push dx             ;save cursor position
    
    ;move cursor to timer position
    mov ah, 02h
    xor bh, bh
    mov dx, timer_pos
    int 10h
    
    ;display live timer
    call print_timer_only
    
    ;restore old potiton of cursor
    pop dx
    mov ah, 02h
    xor bh, bh
    int 10h
    
    ; Get current ticks
    mov ah, 00h
    int 1Ah
    
    ; Calculate elapsed ticks cleanly (handles rollover)
    sub dx, start_time
    
    ; Check if 3 minutes (3276 ticks) have elapsed
    cmp dx, 3276
    jae t_up_jmp
    
    ;check if key pressed
    mov ah, 01h
    int 16h
    jz wait_key
    
    ;read keyboard input
    mov ah, 00h
    int 16h
    push ax
    
    ;check for hint key
    cmp al, 'h'
    je is_h
    cmp al, 'H'
    je is_h
    
    ;validate input range 0-3
    cmp al, '0'
    jb bad_key
    cmp al, '3'
    ja bad_key
    
    ;echo entered digit
    mov dl, al
    mov ah, 02h
    int 21h
    
    ;convert ASCII to number
    pop ax
    xor ah, ah
    sub al, '0'
    ret

is_h:
    pop ax
    xor ah, ah
    mov al, 'H'
    ret

bad_key:
    ;ignore invalid key
    pop ax
    jmp wait_key

t_up_jmp:
    jmp time_up_state
get_live_input endp

;---TIMER DISPLAY---
print_timer_only proc
    push ax             ;save registers
    push bx
    push cx
    push dx
    
    ;read current timer tick
    mov ah, 00h
    int 1Ah
    
    ;Calculate elapsed ticks safely
    sub dx, start_time
    
    ;Invert calculation to find remaining ticks
    mov ax, 3276
    sub ax, dx
    jg t_ok             ; Fixed typo here (changed jgs to jg)
    xor ax, ax
t_ok:
    ;convert ticks to sec
    xor dx, dx
    mov bx, 18
    div bx
    
    xor dx, dx
    ;convert sec to minutes:sec
    mov bx, 60
    div bx
    push dx             ;save second
    
    ;print minutes
    add al, '0'
    mov dl, al
    mov ah, 02h
    int 21h
    
    ;print colon
    mov dl, ':'
    mov ah, 02h
    int 21h
    
    pop ax              ;restore sec
    mov bl, 10          ;divide sec digits
    div bl
    
    ;print tens digit
    push ax
    mov dl, al
    add dl, '0'
    mov ah, 02h
    int 21h
    
    ;restore registers
    pop ax
    mov dl, ah
    add dl, '0'
    mov ah, 02h
    int 21h
    
    pop dx
    pop cx
    pop bx
    pop ax
    ret
print_timer_only endp

;--CLEAR SCREEN----
refresh_screen proc
    ;scroll entire screen up and apply Blue Background (1) + Yellow Text (E) = 1Eh
    mov ax, 0600h
    mov bh, 1Fh
    mov cx, 0000h
    mov dx, 184Fh
    int 10h
    
    ;move cursor to top left
    mov ah, 02h
    mov bh, 0
    mov dx, 0
    int 10h
    ret
refresh_screen endp

;----HIGH BEEP SOUND---
beep_high proc
    mov ah, 02h         ;simple speaker beep
    mov dl, 07h
    int 21h
    ret
beep_high endp

;----LOW BEEP SOUND---
beep_low proc
    mov al, 182         ;configure speaker
    out 43h, al
    ;set frequency
    mov ax, 4000
    out 42h, al
    mov al, ah
    out 42h, al
    ;enable speaker
    in al, 61h
    or al, 03h
    out 61h, al
    ;delay sound
    call delay_1sec
    ;disable speaker
    in al, 61h
    and al, 0FCh
    out 61h, al
    ret
beep_low endp

;---FRIST INDEX CALCULATION----
calc1 proc
    ;row x 4+ col
    mov al, row1
    xor ah, ah
    mov bl, 4
    mul bl
    add al, col1
    mov idx1, ax        ;store index
    ret
calc1 endp

;----SECOND INDEX CALCULATION----
calc2 proc
    ;row x 4+ col
    mov al, row2
    xor ah, ah
    mov bl, 4
    mul bl
    add al, col2
    mov idx2, ax        ;store index
    ret
calc2 endp

;----REVEAL MACTHED CARDS---
reveal proc
    ;reveal frist card
    mov si, idx1
    mov al, val1
    mov hidden[si], al
    
    ;reveals econd card
    mov si, idx2
    mov al, val2
    mov hidden[si], al
    ret
reveal endp

;----4 SECOND DELAY ---
delay_4sec proc
    mov ah, 00h         ;read current ticks
    int 1Ah
    mov bx, dx
    add bx, 73          ;add 4 sec ticks
w4:
    ;wait until time completed
    int 1Ah
    cmp dx, bx
    jb w4
    ret
delay_4sec endp

;----1 SEC DELAY ----
delay_1sec proc
    mov ah, 00h         ;read current ticks
    int 1Ah
    mov bx, dx
    add bx, 18          ;add 1 sec ticks
w1:
    int 1Ah             ;wait loop
    cmp dx, bx
    jb w1
    ret
delay_1sec endp

;---NUMBER PRINT---
print_num proc
    push ax             ;save registers
    push bx
    push cx
    push dx
    
    ;check negative number
    test ax, ax
    jns positive
    mov dl, '-'         ;print minus sign
    mov ah, 02h
    int 21h
    neg ax
positive:
    mov bx, 10
    xor cx, cx
p_l1:
    xor dx, dx
    div bx
    push dx             ;save remainder
    inc cx              ;continue till quotient =0
    test ax, ax
    jnz p_l1
p_l2:
    ;print digits
    pop dx
    add dl, '0'
    mov ah, 02h
    int 21h
    loop p_l2
    
    pop dx              ;restore registers
    pop cx
    pop bx
    pop ax
    ret
print_num endp

;---SHUFFLE BOARD----
shuffle proc
    mov cx, 15          ;loop through array
sh_l:
    call rand           ;generate random number
    xor dx, dx
    mov bx, cx
    inc bx
    div bx              ;random index
    mov si, dx
    mov di, cx
    ;swap values
    mov al, grid[si]
    mov bl, grid[di]
    mov grid[si], bl
    mov grid[di], al
    loop sh_l
    ret
shuffle endp

;---RANDOM NUMBER---
rand proc
    mov ax, seed        ; Linear congruential generator
    mov bx, 25173
    mul bx
    add ax, 13849
    mov seed, ax        ;store new seed
    ret
rand endp

;---SHOW COMPLETE GRID----
show_grid proc
    call newline
    ;start from first grid element
    mov si, 0
    mov cx, 16          ;total 16 elements
    mov bl, 0           ;column counter
sg:
    ;print current grid character
    mov dl, grid[si]
    mov ah, 02h
    int 21h
    ;space after character
    mov dl, ' '
    int 21h
    ;mov to next element
    inc si
    ;inc col count
    inc bl
    ;check if 4 col printed
    cmp bl, 4
    jne skg
    call newline        ;mov to next row
    mov bl, 0           ;reset column counter
skg:
    loop sg             ;repeat loop
    ret
show_grid endp

;---SHOW HIDDEN GRID-----
show_hidden proc
    call newline
    ;start from first hidden element
    mov si, 0           ;total 16 elements
    mov cx, 16
    mov bl, 0           ;col counter
;print hidden charcter
sh:
    mov dl, hidden[si]
    mov ah, 02h
    int 21h
    ;space
    mov dl, ' '
    int 21h
    ;mov to next position
    inc si
    inc bl              ;inc col counter
    ;check if 4 row completed
    cmp bl, 4
    jne skh
    call newline
    mov bl, 0           ;continue loop
skh:
    loop sh
    ret
show_hidden endp

;---NEWLINE---
newline proc
    mov dl, 13
    mov ah, 02h
    int 21h
    mov dl, 10
    int 21h
    ret
newline endp

;---TIME UP STATE----
time_up_state:
    call refresh_screen
    print msg_time
    jmp ask_restart     ;go restart section

;---WIN STATE----
win_state:
    call refresh_screen
    print msg_win
    ; --- 3 WIN BEEPS ---
    call beep_high
    call delay_1sec
    call beep_high
    call delay_1sec
    call beep_high
    jmp ask_restart     ;go restart

;---GAME OVER STATE---
over_state:
    call refresh_screen
    print msg_over

;--RESTART SECTION WITH FIXED CURSOR ALIGNED RIGHT WALLS----
ask_restart:
    call newline
    print sb_top
    print sb_mid1
    print sb_mid2
    
    ; Row 1: Current Score
    print sb_sc_l
    mov ax, score
    call print_num
    call draw_right_wall
    
    ; Row 2: High Score
    print sb_hi_l
    mov ax, high_score
    call print_num
    call draw_right_wall
    
    ; Row 3: Pairs Found
    print sb_p_l
    mov al, pairs
    xor ah, ah
    call print_num
    call draw_right_wall
    
    ; Fixed Line 833 macro error here by using explicit service expansion
    mov ah, 09h
    lea dx, sb_bot
    int 21h
    call newline
    
    call delay_4sec     ;wait before restarting
    jmp restart_game    ;restart

; Helper routine to force the right border window pipe to column 36
draw_right_wall proc
    push ax
    push bx
    push dx
    ; Get present line location
    mov ah, 03h
    xor bh, bh
    int 10h
    ; Override column back to precise index 36 (24h)
    mov dl, 36
    mov ah, 02h
    int 10h
    ; Draw wall piece
    mov dl, '|'
    mov ah, 02h
    int 21h
    pop dx
    pop bx
    pop ax
    ret
draw_right_wall endp

end start
\