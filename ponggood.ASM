Written and optiized by:  Vexis Morlock

started by following a build done by: Queso Fuego
https://www.youtube.com/watch?v=mYPzJlqQ3XI

Major changes:
shrank program size down a bit
added reset after game ends by hitting the "R" key
moved keyboard input to .delay section to reduce lag
changed the way hit detection works
changed score drawing routines
changed win condition routines to be smaller and more efficiant





format binary as 'img'
org 0x7c00
jmp setupGame                                ;skip running 'VAR'
;;======== CONS ========
        VIDMEM equ 0B800H                    ;video memory location for video mode
        ROWLEN equ 160                       ;row length of video mode
        plrX   equ 4                         ;player x set to 4
        cpuX   equ 154                       ;cpu x set to 2 from right - size of self
        key_W  equ 11h                       ;scancode for following keys
        key_S  equ 1Fh
        key_C  equ 2Eh
        key_R  equ 13h
        screenX equ 80                       ;screen size for left to right
        screenY equ 24                       ;screen size for up to down
        paddleY equ 5                        ;size of paddle
        plrBallStX equ 90                    ;start location of plyr side for x
        cpuBallStX equ 66                    ;start location of cpu side for x
        ballStY    equ 6                     ;start location of ball for y direction
        WINCOND    equ 3                     ;score to win
        diffScale  equ 3                     ;difficulty scale
;;======== VAR ========
        drawColor: db 0f0h                   ;black fg white bg 'blank space' default color palette
        plrY:      dw 10                     ;plr y location
        cpuY:      dw 10                     ;cpu y location
        ballX:     dw 66                     ;ball x location
        ballY:     dw 6                      ;ball y location
        ballVX:    db -2                     ;ball velocity for x direction
        ballVY:    db 1                      ;ball velocity for y direction
        plrScore:  db 0                      ;plr score
        cpuScore:  db 0                      ;cpu score
        cpuTimer:  db 0                      ;difficulty Timer
        cpuDiff:   db 1                      ;cpu difficulty adjust scale in cons to ajust scaling per score
        delayTimer dw 1                      ;delay tics
;;======== LOGIC ========
setupGame:                                   ;main setup
;; setUpVideoMode
	;;dont need this should already be in this mode to begin with
       ; mov ax,0003h                         ;SET VIDEO MODE BIOS INT AH00H; AL=03H TXT MODE 80X25 16C
       ; int 10h                              ;set video mode

;;setUpVideoMemory

        mov ax,VIDMEM                        ;load video memory location into AX register
        mov es,ax                            ;es:di,b800:0000  where video memory sits here


;; game Loop
gameLoop:
    ;;clearToBlack
        xor ax,ax                            ;clear AX
        xor di,di                            ;mov ax,0
        mov cx,80*25                         ;rep times to do
        rep stosw                            ;mov di,0
                                             ;mov [es:di],ax    ;inc di
   ;;drawMiddleLine
        mov ah,[drawColor]                   ;set draw color for center line
        mov di,78                            ;draw in middle screen 1/2(80(2) -1) every char is 2 bytes(char and color)
        mov cx,13                            ;draw 1/2 the time (doted line)  loop

        .drawMiddleLoop:
                stosw                        ;inc di  -2 on next line
                add di,2*ROWLEN-2            ; =360  draw half time (80 char in line * 2 char and color *2 every other row)
                loop .drawMiddleLoop         ;draw next dot

   ;;drawPlayerPaddle
        imul di, [plrY],ROWLEN               ;plr y pos is y *number of rows *length of row ;nuber of charater before first row
        add di, plrX                         ;add player X offset
        mov cl, paddleY                      ;size of player paddle
        .drawPlayerLoop:
                stosw                        ;also inc di set next line to -2
                add di,ROWLEN-2              ;=160  draw full time (80 char in line * 2 char and color)
                loop .drawPlayerLoop         ;draw rest of paddle

   ;;drawCpuPaddle
        imul di, [cpuY],ROWLEN               ;plr y pos is y *number of rows *length of row ;nuber of charater before first row
        add di, cpuX                         ;add player X offset
        mov cl, paddleY                      ;size of player paddle
        .drawCpuLoop:
                stosw                        ;also inc di set next line to -2
                add di,ROWLEN-2              ;=160  draw full time (80 char in line * 2 char and color)
                loop .drawCpuLoop            ;draw rest of paddle

   ;;drawBall
   moveBall:

   ;; moveBalltoPOS
        mov bl, [ballVX]                     ;move current ball's X velocity to BL
        add [ballX], bl                      ;calculate next ball X location and store back into BL
        mov bl, [ballVY]                     ;move current ball's Y velocity to BL
        add [ballY], bl                      ;calculate next ball Y location and store back into BL


   ;;cpuInput                               	 ;cpu AI and ball movement
        moveCpu:
                mov bl, [cpuDiff]            ;move current difficulty setting into BL
                cmp [cpuTimer], bl           ;compare difficulty to timer
                jl  incCpuTimer              ;if BL is smaller inc timer
                mov byte [cpuTimer],0        ;clear cputimer
                jmp drawBall                 ;skip moving cpu

        incCpuTimer:
                   inc byte[cpuTimer]        ;inc timer and move cpu paddle

                mov bx, [cpuY]               ;move cpu y location to BX
                cmp bx, [ballY]              ;compare to ball y location
                jl  moveCpuDown              ;if ball is lower jump to lowering paddle
                dec word [cpuY]              ;move paddle up
                jge  drawBall                ;if paddle is not at top of screen skip rest
                inc word [cpuY]              ;if paddle is at top of screen push back
                jmp drawBall                 ;move on


                moveCpuDown:
                      add bx, paddleY        ;check bottom of cpu paddle
                      cmp bx, [ballY]        ;compare bottom of paddle to ball Y pos
                      cmp bx,screenY         ;compare paddle bottom to screen bottom
                      jg drawBall            ;if not below bottom of screen skip next
                      inc word [cpuY]        ;push paddle back up

        drawBall:
                imul di, [ballY],ROWLEN      ;plr y pos is y *number of rows *length of row ;nuber of charater before first row
                add di, [ballX]              ;add player X offset
                mov word [es:di],2020h       ;make ball green and space char blank is laggy





   ;;collisionCheck
        checkHitTop:
                mov cx,[ballY]
                jcxz reverseBallY            ;check if ball is at 0 Y and jump if true
                cmp cx,24                    ;did ball hit bottom
                jne checkHitPlr              ;skip if not


        reverseBallY:
                neg byte [ballVY]           ;flip ball y velocity

        checkHitPlr:
                cmp word [ballX],plrX       ;is ball and plr in same row
                jne checkHitCpu             ;next
                mov bx, [plrY]              ;get player y
                cmp bx, [ballY]             ;check ball y vs paddle y or lower
                jg  checkHitCpu             ;next if no
                add bx, paddleY             ;check ball y vs paddle y[bottom] above
                cmp bx, [ballY]
                jl  checkHitCpu             ;next if no
                jmp reverseBallX            ;next

        checkHitCpu:
                cmp word [ballX],cpuX       ;compare ball X location to cpu X
                jne checkHitLeft            ;if != move on
                mov bx, [cpuY]              ;move cpu y into bx
                cmp bx, [ballY]             ;compare ball Y location to cpu Y
                jg  checkHitLeft            ;if != move on
                add bx, paddleY             ;move to bottom of paddle
                cmp bx, [ballY]             ;compare ball y location to cpu y bottom
                jl  checkHitLeft            ;if != move on else flip ball X velocity


        reverseBallX:
                neg byte [ballVX]           ;flip X velocity

        checkHitLeft:
                cmp word [ballX], 0         ;compare ball X left screen limit
                jg  checkHitRight           ;if != move on
                inc byte [cpuScore]         ;give cpu 1 point
                mov bx, plrBallStX          ;give resetBall somewhere to start
                jmp resetBall

        checkHitRight:
                cmp word [ballX], ROWLEN
                jl  endCol
                inc byte [plrScore]
                mov bx, cpuBallStX

        resetBall:
        ;;randomize x start location
                cbw                         ;0 out ah if al<128  smaller bytes
                int 1Ah                     ;clock tics since midnight to cx:dx [sudo random number generator]
                mov ax,dx                   ;move random number into ax
                xor dx,dx                   ;clear dx
                mov cx,10                   ;set highest number for output n-1
                div cx                      ;dx\cz to get remander 0-9 save to dx
                shl dx,1                    ;2^dx
                add bx,dx                   ;add to start location taken from either checkHitLeft or checkHitRight
                mov word [ballX], bx        ;set ball start location for this round
                mov word [ballY], ballStY   ;set ball start location for this round

                cmp byte [cpuScore], WINCOND ;did cpu win
                je  plrLos                   ;if true goto plrLos
                cmp byte [plrScore], WINCOND ;did plr win
                je  plrWon                   ;if true goto plrWin

                mov cl, [plrScore]
                jcxz endCol                  ;is plrScore 0 if so jump to endCol
                imul cx,[plrScore],diffScale ;else increase difficulty
                mov [cpuDiff], cl




        endCol:
       ;; draw Score
                mov di, ROWLEN+66           ;location of plr score
                mov bh, 0eh                 ;Score color yellow
                mov bl, [plrScore]          ;move actual score into BL
                add bl, 30h                 ;make score ascii number
                mov [es:di], bx             ;Draw score


                add di,24                   ;move to location of CPU score
                mov bl, [cpuScore]          ;move cpu score into bl
                add bl, 30h                 ;make ascii
                mov [es:di], bx             ;draw

   ;;gameDelay
                mov bx,[046ch]              ;[046ch] = nember of timer tics since boot
                inc bx                      ;slow down game
                ;inc bx

        delay:
		;;playerInput
				mov ah,1                    ;bios get keyboard status 16 AH 01h
				int 16h                     ;Bios keyboard interupt
				jz  delay2                  ;if no input move on

				cbw                         ;0 out ah if al<128  smaller bytes
				int 16h                     ;bios get keystroke into ah scan code al is key

				cmp ah, key_W               ;compare scan codes
				je wPressed
				cmp ah, key_S
				je sPressed
				cmp ah, key_C
				je cPressed
				cmp ah, key_R
				je rPressed

				jmp delay2					;if not a known key move on
													
        wPressed:
                dec word [plrY]             ;move player up
                jge delay2                  ;if plr is not at top of screen move on
                inc word [plrY]             ;else push plr back into screen
                jmp delay2                  ;move on

        sPressed:
                cmp word [plrY],screenY-paddleY ;compare bottom of plr paddle to bottom of screen
                jg delay2                   ;stop plr from moving off bottom of screen
                inc word [plrY]             ;move player down
                jmp delay2                  ;move on

        rPressed:
                int 19h                     ;reset game

        cPressed:
                add byte [drawColor],10h    ;change palette


        delay2:

                cmp [046ch],bx              ;wait tell match
                jl delay


                jmp gameLoop                ;cont playing game

;;winCondition



        plrWon:
                mov dword [es:0000], 0F490F57h    ;print 'W''I'
                mov dword [es:0004], 0F210F4Eh    ;print 'N'!'
                jmp killMe                        ;move on


        plrLos:
                mov dword [es:0000], 0F4F0F4Ch    ;print 'L''O'
                mov dword [es:0004], 0F450F53h    ;print 'S''E'



;;======== /LOGIC ========
    killMe:                                 ;end game

int 16h

        mov ah,1                            ;bios get keyboard status 16 AH 01h
        int 16h                             ;Bios keyboard interupt
        jz  killMe                          ;if no input move on
        cbw                                 ;0 out ah if al<128  smaller bytes
        int 16h                             ;bios get keystroke into ah scan code al is key
        cmp ah, key_R
        jne killMe
        int 19h                             ;reset game
       ; cli ; clear interrupt flag
       ; hlt ; halt execution

;;BOOTSECTOR PADDING
times 510-($-$$) db 0                      ;FILL REST WITH 0
dw 0xAA55                                  ;MAGIC BOOTSECTOR NUMBER