*-----------------------------------------------------------
* Title      : Render Update
* Written by : Jonathan Conrad
* Date       : 10/2/2022
* Description: Draw Battlefield, LEDS, Player Tanks, Bullets
*-----------------------------------------------------------
DrawStartScreen:
    ; Draw Background
    move.l #GRASS_HEX_COLOR,d1
    move.l #PEN_COLOR_TRAP_CODE,d0
    trap #15
    move.l #FILL_COLOR_TRAP_CODE,d0
    trap #15

    move.w #0,d1
    move.w #0,d2
    move.w #OUTPUT_WIDTH,d3
    move.w #OUTPUT_HEIGHT,d4
    move.l #DRAW_RECT_TRAP_CODE,d0
    trap #15
    
    ;Draw start screen tank bmp image
    movem.l ALL_REGISTERS,-(sp)
    move.l #753,-(sp)
    move.l #416,-(sp)
    move.l #0,-(sp)
    move.l #0,-(sp)
    move.l #30,-(sp)
    move.l #100,-(sp)
    lea Start_Of_Start_Screen_Data,a1 
    jsr RunBitmapSubroutine
    movem.l (sp)+,ALL_REGISTERS
    rts
    
***********************Draw End Screen*************************    
    ; Draw End Screens
DrawBlueEndScreen:
    lea Start_Of_Blue_Screen_Data,a1 
    bra DrawEndScreen
DrawRedEndScreen:
    lea Start_Of_Red_Screen_Data,a1 
DrawEndScreen:
    movem.l ALL_REGISTERS,-(sp)
    move.l #END_SCREEN_WIDTH,-(sp)
    move.l #END_SCREEN_HEIGHT,-(sp)
    move.l #0,-(sp)
    move.l #0,-(sp)
    move.l #225,-(sp)
    move.l #225,-(sp)
    jsr RunBitmapSubroutine
    movem.l (sp)+,ALL_REGISTERS
    rts

***********************Draw Initial Battlefield****************    
RenderUpdate: 
    ; Redraw green background
    bsr DrawBattlefield
    
    ; Draw bitmap background and LEDs
    movem.l ALL_REGISTERS,-(sp)
    move.l #PARAMETER_WIDTH_OF_CHUNK,-(sp)
    move.l #PARAMETER_HEIGHT_OF_CHUNK,-(sp)
    move.l #PARAMETER_CHUNK_TOP_LEFT_X,-(sp)
    move.l #PARAMETER_CHUNK_TOP_LEFT_Y,-(sp)
    move.l #PARAMETER_DISPLAY_TOP_LEFT_X,-(sp)
    move.l #PARAMETER_DISPLAY_TOP_LEFT_Y,-(sp)
    lea Start_Of_Background_Data,a1 
    jsr RunBitmapSubroutine
    movem.l (sp)+,ALL_REGISTERS 
    
    jsr DrawLEDScores

***********************Swap Buffers****************************    
SwapBuffers:
    move.b  #REPAINT_SCREEN_TRAP_CODE,d0
    TRAP    #15         
    rts
    
***********************Draw Battlefield************************       
DrawBattlefield:   
    move.l #GRASS_HEX_COLOR,d1
    move.l #PEN_COLOR_TRAP_CODE,d0
    trap #15
    move.l #FILL_COLOR_TRAP_CODE,d0
    trap #15

    move.w #GRASS_LEFT_X,d1
    move.w #GRASS_UPPER_Y,d2
    move.w #GRASS_RIGHT_X,d3
    move.w #GRASS_LOWER_Y,d4
    move.l #DRAW_RECT_TRAP_CODE,d0
    trap #15
    
    move.l #WALL_HEX_COLOR,d1
    move.l #PEN_COLOR_TRAP_CODE,d0
    trap #15
    move.l #FILL_COLOR_TRAP_CODE,d0
    trap #15

    ; Draw left outer wall
    move.w #0,d1
    move.w #55,d2
    move.w #WALL_WIDTH,d3
    move.w #600,d4
    move.l #DRAW_RECT_TRAP_CODE,d0
    trap #15
    
    ; Draw right outer wall
    move.w #781,d1
    move.w #55,d2
    move.w #800,d3
    move.w #600,d4
    trap #15
    
    ; Draw upper outer wall
    move.w #20,d1
    move.w #55,d2
    move.w #780,d3
    move.w #92,d4 ; UPPERY + wall width
    trap #15
    
    ; Draw lower outer wall
    move.w #20,d1
    move.w #581,d2
    move.w #780,d3
    move.w #600,d4 ; UPPERY + wall width
    trap #15
     
DrawInnerWalls:
    movem.l ALL_REGISTERS,-(sp)
    move.l #WALL_HEX_COLOR,d1
    move.l #PEN_COLOR_TRAP_CODE,d0
    trap #15
    move.l #FILL_COLOR_TRAP_CODE,d0
    trap #15
    move.l #DRAW_RECT_TRAP_CODE,d0
    trap #15
    
    ; Upper left wall
    move.w #130,d1
    move.w #UPPER_LOWER_WALL_LENGTH,d2
    move.w #(130 + INNER_WALL_WIDTH),d3
    move.w #(UPPER_LOWER_WALL_LENGTH + UPPER_LOWER_WALL_LENGTH),d4
    trap #15
    
    ; Lower left wall
    move.w #130,d1
    move.w #380,d2
    move.w #(130 + INNER_WALL_WIDTH),d3
    move.w #(380 + UPPER_LOWER_WALL_LENGTH),d4
    trap #15
    
    ; Upper right wall
    move.w #675,d1
    move.w #UPPER_LOWER_WALL_LENGTH,d2
    move.w #(675 + INNER_WALL_WIDTH),d3
    move.w #(UPPER_LOWER_WALL_LENGTH + UPPER_LOWER_WALL_LENGTH),d4
    trap #15
    
    ; Lower right wall
    move.w #675,d1
    move.w #380,d2
    move.w #(675 + INNER_WALL_WIDTH),d3
    move.w #(380 + UPPER_LOWER_WALL_LENGTH),d4
    trap #15
    
    ; Middle upper left wall
    move.w #205,d1
    move.w #190,d2
    move.w #(205 + 110),d3
    move.w #(190 + INNER_WALL_WIDTH),d4
    trap #15
    
    ; Middle lower left wall
    move.w #205,d1
    move.w #460,d2
    move.w #(205 + 110),d3
    move.w #(460 + INNER_WALL_WIDTH),d4
    trap #15
    
    ; Middle upper right wall
    move.w #468,d1
    move.w #190,d2
    move.w #(468 + 110),d3
    move.w #(190 + INNER_WALL_WIDTH),d4
    trap #15
    
    ; Middle lower right wall
    move.w #468,d1
    move.w #460,d2
    move.w #(468 + 110),d3
    move.w #(460 + INNER_WALL_WIDTH),d4
    trap #15
    
    ; Middle left wall
    move.w #250,d1
    move.w #280,d2
    move.w #(250 + INNER_WALL_WIDTH),d3
    move.w #(280 + 100),d4
    trap #15
    
    ; Middle right wall
    move.w #528,d1
    move.w #280,d2
    move.w #(528 + INNER_WALL_WIDTH),d3
    move.w #(280 + 100),d4
    trap #15
    
    movem.l (sp)+,ALL_REGISTERS
    rts
    
    
***********************Draw LED Scores*************************
DrawLEDScores:
    ; LED 1
    movem.l ALL_REGISTERS,-(sp)
    move.l #(2*Segment_Pixel_Length),-(sp)
    move.l #(3*Segment_Pixel_Length),-(sp)
    move.l #(LED1_X_ORIGIN - Half_Segment_Pixel_Length),-(sp)
    move.l #(LED_Y_ORIGIN - Segment_Pixel_Length),-(sp)
    move.l #(LED1_X_ORIGIN - Half_Segment_Pixel_Length),-(sp)
    move.l #(LED_Y_ORIGIN - Segment_Pixel_Length),-(sp)
    lea Start_Of_Background_Data,a1 
    jsr RunBitmapSubroutine
    movem.l (sp)+,ALL_REGISTERS
    
    movem.l ALL_REGISTERS,-(sp)
    move.l #0,d3
    cmp.l #MAX_SCORE,Player1Score
    blt SkipSetLED1To1
    move.l #1,d3
SkipSetLED1To1:    
    move.l #LED1_X_ORIGIN,d1
    move.l #LED_Y_ORIGIN,d2
    move.l #RED_HEX_COLOR,CurrentLEDHexColor  
    jsr DrawLEDSubroutine
    movem.l (sp)+,ALL_REGISTERS

    ; LED 2 
    movem.l ALL_REGISTERS,-(sp)
    move.l #(2*Segment_Pixel_Length),-(sp)
    move.l #(3*Segment_Pixel_Length),-(sp)
    move.l #(LED2_X_ORIGIN - Half_Segment_Pixel_Length),-(sp)
    move.l #(LED_Y_ORIGIN - Segment_Pixel_Length),-(sp)
    move.l #(LED2_X_ORIGIN - Half_Segment_Pixel_Length),-(sp)
    move.l #(LED_Y_ORIGIN - Segment_Pixel_Length),-(sp)
    lea Start_Of_Background_Data,a1 
    jsr RunBitmapSubroutine
    movem.l (sp)+,ALL_REGISTERS

    movem.l ALL_REGISTERS,-(sp)
    
    move.l Player1Score,d3
    
    cmp.l #MAX_SCORE,Player1Score
    blt SkipLED2Is0
    move.l #0,d3
SkipLED2Is0:   
    move.l #LED2_X_ORIGIN,d1
    move.l #LED_Y_ORIGIN,d2 
    jsr DrawLEDSubroutine
    movem.l (sp)+,ALL_REGISTERS
    
    ; LED 3
    movem.l ALL_REGISTERS,-(sp)
    move.l #(2*Segment_Pixel_Length),-(sp)
    move.l #(3*Segment_Pixel_Length),-(sp)
    move.l #(LED3_X_ORIGIN - Half_Segment_Pixel_Length),-(sp)
    move.l #(LED_Y_ORIGIN - Segment_Pixel_Length),-(sp)
    move.l #(LED3_X_ORIGIN - Half_Segment_Pixel_Length),-(sp)
    move.l #(LED_Y_ORIGIN - Segment_Pixel_Length),-(sp)
    lea Start_Of_Background_Data,a1 
    jsr RunBitmapSubroutine
    movem.l (sp)+,ALL_REGISTERS
    
    movem.l ALL_REGISTERS,-(sp) 
    move.l #0,d3
    cmp.l #MAX_SCORE,Player2Score
    blt SkipSetLED3To1
    move.l #1,d3
SkipSetLED3To1:    
    move.l #LED3_X_ORIGIN,d1
    move.l #LED_Y_ORIGIN,d2
    move.l #BLUE_HEX_COLOR,CurrentLEDHexColor 
    jsr DrawLEDSubroutine
    movem.l (sp)+,ALL_REGISTERS
    
    ; LED 4
    movem.l ALL_REGISTERS,-(sp)
    move.l #(2*Segment_Pixel_Length),-(sp)
    move.l #(3*Segment_Pixel_Length),-(sp)
    move.l #(LED4_X_ORIGIN - Half_Segment_Pixel_Length),-(sp)
    move.l #(LED_Y_ORIGIN - Segment_Pixel_Length),-(sp)
    move.l #(LED4_X_ORIGIN - Half_Segment_Pixel_Length),-(sp)
    move.l #(LED_Y_ORIGIN - Segment_Pixel_Length),-(sp)
    lea Start_Of_Background_Data,a1 
    jsr RunBitmapSubroutine
    movem.l (sp)+,ALL_REGISTERS


    movem.l ALL_REGISTERS,-(sp)
    move.l Player2Score,d3
    
    cmp.l #MAX_SCORE,Player2Score
    blt SkipLED4Is0
    move.l #0,d3
SkipLED4Is0:   
    move.l #LED4_X_ORIGIN,d1
    move.l #LED_Y_ORIGIN,d2 
    jsr DrawLEDSubroutine
    movem.l (sp)+,ALL_REGISTERS    
    rts
    
***********************Draw Bullets****************************
; d0 = bullet counter
; a0 = playertotalbullets table
; a1 = single bullet
DrawP1Bullets:
    lea Player1BulletsTable,a0
    move.l #PLAYER1_HEX_COLOR,d1
    jsr DrawBullets
    rts
DrawP2Bullets:
    lea Player2BulletsTable,a0
    move.l #PLAYER2_HEX_COLOR,d1
DrawBullets:
    movem.l ALL_REGISTERS,-(sp)
    move.l #0,d0    
DrawAllActiveBullets:    
    move.l (a0)+,a1
    addi.l #1,d0
    cmp.l #TRUE,BULLET_ACTIVE(a1)
    bne SkipBulletDraw
    movem.l ALL_REGISTERS,-(sp)
    jsr DrawBullet
    movem.l (sp)+,ALL_REGISTERS
SkipBulletDraw: 
    cmp.l #MAX_PLAYER_BULLETS,d0   
    bne DrawAllActiveBullets
    movem.l (sp)+,ALL_REGISTERS
    rts
    
; a1 = single bullet
DrawBullet:
    movem.l ALL_REGISTERS,-(sp)
    jsr RedrawBulletGrassChunk
    movem.l (sp)+,ALL_REGISTERS

    move.l #PEN_COLOR_TRAP_CODE,d0
    trap #15
    move.l #FILL_COLOR_TRAP_CODE,d0
    trap #15
        
    move.l BULLET_X(a1),d1
    asr.l #FIXED_POINT_SHIFT,d1
    move.l BULLET_Y(a1),d2
    asr.l #FIXED_POINT_SHIFT,d2
    
    move.l d1,BULLET_PREV_X(a1)
    move.l d2,BULLET_PREV_Y(a1)
    
    move.l d1,d3
    move.l d2,d4
    add.l #BULLET_WIDTH,d3
    add.l #BULLET_HEIGHT,d4   
    
    cmp.l #1,BULLET_ENLARGED(a1)
    bne SkipEnlargeDrawBullet
    add.l #BULLET_WIDTH,d3
    add.l #BULLET_HEIGHT,d4
  
SkipEnlargeDrawBullet: 
    move.l #DRAW_RECT_TRAP_CODE,d0
    trap #15
    rts
    
; d1 = (parameter) hex color or spawn x location
; d2 = spawn y location
; d3 = pickup x + width
; d4 = pickup y + height
; a1 = spawn location
; a2 = pickup
DrawPickup:
    move.l #PICKUP_HEX_COLOR,d1
    move.l #PEN_COLOR_TRAP_CODE,d0
    trap #15
    move.l #FILL_COLOR_TRAP_CODE,d0
    trap #15
    
    move.l #TRUE,PICKUP_ACTIVE(a2)
    move.l SPAWN_X(a1),d1
    move.l d1,PICKUP_X(a2)
    move.l SPAWN_Y(a1),d2
    move.l d2,PICKUP_Y(a2)
    move.l #BULLET_WIDTH,d3
    add.l d1,d3
    move.l #BULLET_HEIGHT,d4
    add.l d2,d4   
     
    move.l #DRAW_RECT_TRAP_CODE,d0
    trap #15
    rts   
  
DrawPickupGrass:
    move.l #GRASS_HEX_COLOR,d1
    move.l #PEN_COLOR_TRAP_CODE,d0
    trap #15
    move.l #FILL_COLOR_TRAP_CODE,d0
    trap #15
    
    move.l PICKUP_X(a1),d1
    move.l PICKUP_Y(a1),d2  
    move.l #BULLET_WIDTH,d3
    add.l d1,d3
    move.l #BULLET_HEIGHT,d4
    add.l d2,d4   
     
    move.l #DRAW_RECT_TRAP_CODE,d0
    trap #15
    rts   

***********************Draw Players****************************    
    ; d0 = rts address
    ; d6 = 4 * MovementAngle
    ; d7 = temp
    ; a1 = player dimensions
    ; a5 = RedTankDrawTable
DrawPlayer1:
    move.l (sp)+,d0
    movem.l ALL_REGISTERS,-(sp)
    
    ; Draw correct chunk for current tank rotation
    lea RedTankDrawTable,a5
    move.l PreviousMovementAngle,d6
    lsl.l #2,d6
    movem.l ALL_REGISTERS,-(sp)
    
    ; Parameter player width and height
    move.l 4(a5,d6),a1
    move.l (a1),-(sp)
    move.l 4(a1),-(sp)
 
    jsr RedrawGrassChunk
    movem.l (sp)+,ALL_REGISTERS
    move.l MovementAngle,d6
    lsl.l #2,d6
    move.l #0,d7
    
    ; Parameter player width and height
    move.l 4(a5,d6),a1
    move.l (a1),-(sp)
    move.l 4(a1),-(sp)
    
    ; Parameter top left x
    move.w (a5,d6),d7
    move.l d7,-(sp)
    
    ; Parameter top left y
    move.w 2(a5,d6),d7
    move.l d7,-(sp)
    
    ; Parameter display top left x and y
    move.l PLAYER_X(a3),-(sp) 
    move.l PLAYER_Y(a3),-(sp) 
    
    lea Start_Of_Player1_Data,a1 
    jsr RunBitmapSubroutine
    movem.l (sp)+,ALL_REGISTERS
    
    ; Set current (x,y) as previous (x,y)
    move.l PLAYER_X(a3),PLAYER_PREV_X(a3)
    move.l PLAYER_Y(a3),PLAYER_PREV_Y(a3)
    
    move.l MovementAngle,PreviousMovementAngle
    move.l d0,-(sp)
    rts
    
DrawPlayer2:
    move.l (sp)+,d0
    movem.l ALL_REGISTERS,-(sp)
    
    ; Draw correct chunk for current tank rotation
    lea BlueTankDrawTable,a5
    move.l P2PreviousMovementAngle,d6
    lsl.l #2,d6
    movem.l ALL_REGISTERS,-(sp)
    
    ; Parameter player width and height
    move.l 4(a5,d6),a1
    move.l (a1),-(sp)
    move.l 4(a1),-(sp) 
    jsr RedrawGrassChunk
    movem.l (sp)+,ALL_REGISTERS
  
    move.l P2MovementAngle,d6
    lsl.l #2,d6
    move.l #0,d7
    
    ; Parameter player width and height
    move.l 4(a5,d6),a1
    move.l (a1),-(sp)
    move.l 4(a1),-(sp)
    
    ; Parameter top left x
    move.w (a5,d6),d7
    move.l d7,-(sp)
    
    ; Parameter top left y
    move.w 2(a5,d6),d7
    move.l d7,-(sp)
    
    ; Parameter display top left x and y
    move.l PLAYER_X(a3),-(sp) 
    move.l PLAYER_Y(a3),-(sp) 
    
    lea Start_Of_Player1_Data,a1 
    jsr RunBitmapSubroutine
    movem.l (sp)+,ALL_REGISTERS
    
    ; Set current (x,y) as previous (x,y)
    move.l PLAYER_X(a3),PLAYER_PREV_X(a3)
    move.l PLAYER_Y(a3),PLAYER_PREV_Y(a3)
    
    move.l P2MovementAngle,P2PreviousMovementAngle
    move.l d0,-(sp)
    rts

***********************Draw Grass******************************
; d0 = temp
; d1 = left x
; d2 = upper y
; d3 = right x
; d4 = lower y
; d5 = chunk width
; d6 = chunk height
; a3 = player location
RedrawGrassChunk: 
    move.l #GRASS_HEX_COLOR,d1
    move.l #PEN_COLOR_TRAP_CODE,d0
    trap #15
    move.l #FILL_COLOR_TRAP_CODE,d0
    trap #15
    
    move.l PLAYER_PREV_Y(a3),d2
    move.l PLAYER_PREV_X(a3),d1
    move.l (sp)+,d0
    move.l (sp)+,d6
    move.l (sp)+,d5
    move.l d0,-(sp)
    move.l d1,d3
    move.l d2,d4
    add.l d5,d3
    add.l d6,d4
   
    move.l #DRAW_RECT_TRAP_CODE,d0
    trap #15    
    rts

; a1 bullet address
; d1 previous x
; d2 previous y
; d3 right x
; d4 lower y
RedrawBulletGrassChunk:
    move.l #GRASS_HEX_COLOR,d1
    move.l #PEN_COLOR_TRAP_CODE,d0
    trap #15
    move.l #FILL_COLOR_TRAP_CODE,d0
    trap #15
    
    move.l BULLET_PREV_X(a1),d1
    move.l BULLET_PREV_Y(a1),d2
    move.l d1,d3
    move.l d2,d4
    add.l #BULLET_WIDTH,d3
    add.l #BULLET_HEIGHT,d4    
   
    cmp.l #TRUE,BULLET_ENLARGED(a1)
    bne SkipEnlargeGrassChunkDraw 
    add.l #BULLET_WIDTH,d3
    add.l #BULLET_HEIGHT,d4 
 
SkipEnlargeGrassChunkDraw:
    move.l #DRAW_RECT_TRAP_CODE,d0
    trap #15    
    rts
    
*************************Equates*******************************
GRASS_HEX_COLOR                 EQU $1E7A47   
GRASS_LEFT_X                    EQU 21
GRASS_RIGHT_X                   EQU 779
GRASS_UPPER_Y                   EQU 94
GRASS_LOWER_Y                   EQU 579
WALL_HEX_COLOR                  EQU $2B4F85
PLAYER1_HEX_COLOR               EQU $00007E
PLAYER2_HEX_COLOR               EQU $804A00
PICKUP_HEX_COLOR                EQU $0000ffff
PEN_COLOR_TRAP_CODE             EQU 80   
FILL_COLOR_TRAP_CODE            EQU 81
DRAW_RECT_TRAP_CODE             EQU 87
REPAINT_SCREEN_TRAP_CODE	    EQU	94
PARAMETER_WIDTH_OF_CHUNK        EQU 800 
PARAMETER_HEIGHT_OF_CHUNK       EQU 72
PARAMETER_CHUNK_TOP_LEFT_X      EQU 0
PARAMETER_CHUNK_TOP_LEFT_Y      EQU 0
PARAMETER_DISPLAY_TOP_LEFT_X    EQU 0
PARAMETER_DISPLAY_TOP_LEFT_Y    EQU 0
MAX_PLAYER_HEIGHT               EQU 40
MAX_PLAYER_WIDTH                EQU 39
BULLET_WIDTH                    EQU 8
BULLET_HEIGHT                   EQU 8

************************* Tank Draw Tables ********************
RedTankDrawTable:
RedTankAngle0
    dc.w 0 ; x
    dc.w 6 ; y
    dc.l TankChunkDimensions1
RedTankAngle45
    dc.w 38
    dc.w 0
    dc.l TankChunkDimensions2
RedTankAngle90
    dc.w 85
    dc.w 4
    dc.l TankChunkDimensions3
RedTankAngle135
    dc.w 120
    dc.w 0
    dc.l TankChunkDimensions2
RedTankAngle180
    dc.w 0
    dc.w 48
    dc.l TankChunkDimensions1
RedTankAngle225
    dc.w 38
    dc.w 41
    dc.l TankChunkDimensions2
RedTankAngle270
    dc.w 85
    dc.w 44
    dc.l TankChunkDimensions3
RedTankAngle315
    dc.w 120
    dc.w 41
    dc.l TankChunkDimensions2
      
BlueTankDrawTable:
BlueTankAngle180
    dc.w 0
    dc.w 88        
    dc.l TankChunkDimensions1
BlueTankAngle225
    dc.w 38
    dc.w 82
    dc.l TankChunkDimensions2
BlueTankAngle270
    dc.w 85
    dc.w 86
    dc.l TankChunkDimensions3
BlueTankAngle315
    dc.w 120
    dc.w 82
    dc.l TankChunkDimensions2
BlueTankAngle0 
    dc.w 0
    dc.w 129
    dc.l TankChunkDimensions1    
BlueTankAngle45
    dc.w 38
    dc.w 123
    dc.l TankChunkDimensions2
BlueTankAngle90
    dc.w 85
    dc.w 126
    dc.l TankChunkDimensions3
BlueTankAngle135
    dc.w 120
    dc.w 123
    dc.l TankChunkDimensions2

TankChunkDimensions1:
    dc.l 33 ; w
    dc.l 27 ; h
TankChunkDimensions2:
    dc.l 39
    dc.l 40
TankChunkDimensions3:
    dc.l 27
    dc.l 33    


***************************** Bullets ************************
MAX_PLAYER_BULLETS          EQU 9
BULLET_ACTIVE               EQU 0
BULLET_X                    EQU 4
BULLET_Y                    EQU 8
BULLET_X_VELOCITY           EQU 12
BULLET_Y_VELOCITY           EQU 16
BULLET_WALL_HIT_COUNT       EQU 20
BULLET_PREV_X               EQU 24
BULLET_PREV_Y               EQU 28
BULLET_ENLARGED             EQU 32
BULLET_START_LOC_X_OFFSET   EQU 0
BULLET_START_LOC_Y_OFFSET   EQU 4
Player1BulletsTable         dc.l P1Bullet1,P1Bullet2,P1Bullet3,P1Bullet4,P1Bullet5,P1Bullet6,P1Bullet7,P1Bullet8,P1Bullet9
Player2BulletsTable         dc.l P2Bullet1,P2Bullet2,P2Bullet3,P2Bullet4,P2Bullet5,P2Bullet6,P2Bullet7,P2Bullet8,P2Bullet9
Player1ActiveBullets        dc.l 0
Player2ActiveBullets        dc.l 0


************************Player1 Bullets***********************
; Bullet Active
; x, y, 
; x-velocity,y-velocity, 
; wall hit count, 
; previous X, previous Y
; enlarged
P1Bullet1:
    dc.l 0    
    ds.l 7
    dc.l 0   
P1Bullet2:
    dc.l 0    
    ds.l 7
    dc.l 0   
P1Bullet3:
    dc.l 0    
    ds.l 7
    dc.l 0   
P1Bullet4:
    dc.l 0    
    ds.l 7  
    dc.l 0  
P1Bullet5:
    dc.l 0    
    ds.l 7
    dc.l 0
P1Bullet6:
    dc.l 0    
    ds.l 7
    dc.l 0    
P1Bullet7:    
    dc.l 0    
    ds.l 7
    dc.l 0
P1Bullet8:
    dc.l 0    
    ds.l 7
    dc.l 0 
P1Bullet9:
    dc.l 0    
    ds.l 7
    dc.l 0

**********************Player2 Bullets ************************
; Bullet Active
; x, y, 
; x-velocity,y-velocity, 
; wall hit count, 
; previous X, previous Y
; enlarged
P2Bullet1:
    dc.l 0    
    ds.l 7
    dc.l 0
P2Bullet2:
    dc.l 0    
    ds.l 7
    dc.l 0
P2Bullet3:
    dc.l 0    
    ds.l 7
    dc.l 0
P2Bullet4:
    dc.l 0    
    ds.l 7
    dc.l 0 
P2Bullet5:
    dc.l 0    
    ds.l 7
    dc.l 0
P2Bullet6:
    dc.l 0    
    ds.l 7
    dc.l 0  
P2Bullet7:    
    dc.l 0    
    ds.l 7
    dc.l 0
P2Bullet8:
    dc.l 0    
    ds.l 7
    dc.l 0   
P2Bullet9:
    dc.l 0    
    ds.l 7
    dc.l 0
    
***************Bullet Start Location Offsets******************
BulletStartLocationOffsetTable:
    ; 0 degrees
    dc.l 34 ; left x offset from player x
    dc.l 8  ; top left y offset from player y
    ; 45 degrees
    dc.l 34
    dc.l -1 
    ; 90 degrees
    dc.l 9
    dc.l -8  
    ; 135 degrees
    dc.l 0
    dc.l 0   
    ; 180 degrees
    dc.l -8
    dc.l 10  
    ; 225 degrees
    dc.l 0
    dc.l 33  
    ; 270 degrees
    dc.l 9
    dc.l 34  
    ; 315 degrees
    dc.l 33
    dc.l 33
    

   
    











*~Font name~Courier New~
*~Font size~10~
*~Tab type~1~
*~Tab size~4~
