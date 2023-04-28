*-----------------------------------------------------------
* Title      : Tank Game Main    
* Written by : Jonathan Conrad
* Date       : 10/2/2022
* Description: Two Player Tank game where the bullets rebound off
* walls 3 times. Players can maneuver the battlefield by driving through
* the inner walls. The players can strategize ways to defend themselves
* and move on the offensive with the walls.
* Random pickups spawn around the battlefield based
* on the score of each player. When a player collects the pickup,
* the next shot fired will be a bullet that is 2x larger. First player
* to hit the other 10 times wins. 
* Player 1 Controls
*    W - Forward
*    S - Backward
*    A - Rotate Left
*    D - Rotate Right
*    Space - Fire
* Player 2 Controls
*    Up Arrow - Forward
*    Down Arrow - Backward
*    Left Arrow - Rotate Left
*    Right Arrow - Rotate Right
*
* ESC - Restart
*-----------------------------------------------------------
ALL_REGISTERS                   REG D0-D7/A0-A6
LED1_X_ORIGIN                   EQU $106
LED2_X_ORIGIN                   EQU $11A
LED3_X_ORIGIN                   EQU $1F0
LED4_X_ORIGIN                   EQU $204
LED_Y_ORIGIN                    EQU $1F
OUTPUT_WIDTH                    EQU 800
OUTPUT_HEIGHT                   EQU 600
SET_OUTPUT_RESOLUTION_TRAP_CODE EQU 33
DRAWING_MODE_TRAP_CODE          EQU	92
DOUBLE_BUFFERED_MODE	          EQU	17
TRUE                            EQU 1
FALSE                           EQU 0
PLAYER_X                        EQU 0
PLAYER_Y                        EQU 4
PLAYER_PREV_X                   EQU 8
PLAYER_PREV_Y                   EQU 12
FIXED_POINT_SHIFT               EQU 4
MAX_SCORE                       EQU 10
PLAYER1_LOCATION                ds.l 4
PLAYER2_LOCATION                ds.l 4
Player1Score                    ds.l 1
Player2Score                    ds.l 1
Player1PickupActivated          ds.b 1
Player2PickupActivated          ds.b 1
    
    ORG $200
    INCLUDE 'led_subroutine.x68'
    INCLUDE 'render_update.x68'
    INCLUDE 'bitmap_subroutine.x68'
    INCLUDE 'input_manager.x68'
    INCLUDE 'physics_manager.x68'
    INCLUDE 'random_pickup.x68'
    INCLUDE 'audio_manager.x68'

START ORG    $2100

    ; Set window resolution                     
    move.b #SET_OUTPUT_RESOLUTION_TRAP_CODE,d0
    move.l #OUTPUT_WIDTH,d1
    swap.w d1
    move.w #OUTPUT_HEIGHT,d1
    trap #15
    
      ;Set double buffer mode
    move.b	#DRAWING_MODE_TRAP_CODE,d0
    move.b	#DOUBLE_BUFFERED_MODE,d1
    trap	#15 
    
    jsr PlayMusic


ReturnToStartScreen:    
    jsr DrawStartScreen 
    jsr SwapBuffers      
        
StartScreen:
    jsr CheckEnterForMenu 
    cmp.l #FALSE,d0 
    beq StartScreen
    move.l #0,d0
    
; *******************Initialize********************** 
Initialize:   
    move.l #$01000000,a7
    jsr SeedRandomNumber
    lea RandomPickupTable,a3
    move.l #0,d0
    
ResetPickupsToInactive:
    move.b #0,Player1PickupActivated
    move.b #0,Player2PickupActivated
    move.l (a3)+,a4
    move.l #0,(a4)
    addi.l #1,d0
    cmp.l #MAX_PICKUPS,d0
    blt ResetPickupsToInactive
    
    move.l #0,d0    
    lea Player1BulletsTable,a3
ResetP1Bullets:
    move.l (a3)+,a4
    move.l #FALSE,BULLET_ACTIVE(a4)
    move.l #FALSE,BULLET_ENLARGED(a4)
    addi.l #1,d0
    cmp.l #MAX_PLAYER_BULLETS,d0   
    bne ResetP1Bullets

    move.l #0,d0
    lea Player2BulletsTable,a3 
ResetP2Bullets   
    move.l (a3)+,a4
    move.l #FALSE,BULLET_ACTIVE(a4)
    move.l #FALSE,BULLET_ENLARGED(a4)
    addi.l #1,d0
    cmp.l #MAX_PLAYER_BULLETS,d0   
    bne ResetP2Bullets

    move.l #0, Player1ActiveBullets
    move.l #0, Player2ActiveBullets
    
    ; Set location of players
    lea PLAYER1_LOCATION,a3
    move.l #50,PLAYER_X(a3)
    move.l #300,PLAYER_Y(a3)
    move.l #50,PLAYER_PREV_X(a3) 
    move.l #300,PLAYER_PREV_Y(a3)
    
    lea PLAYER2_LOCATION,a4
    move.l #730,PLAYER_X(a4)
    move.l #300,PLAYER_Y(a4)
    move.l #730,PLAYER_PREV_X(a4)
    move.l #300,PLAYER_PREV_Y(a4)
   
    lea MovementTable,a6
    move.l #0, MovementAngle
    move.l #0, PreviousMovementAngle
    move.l #8, P2MovementAngle
    move.l #8, P2PreviousMovementAngle
    
    move.l #0,Player1Score
    move.l #0,Player2Score
    
    jsr DrawPlayer1
    lea PLAYER2_LOCATION,a3
    jsr DrawPlayer2
    jsr RenderUpdate
     
GameLoop:  
    ; Update and Draw Objects
    lea PLAYER1_LOCATION,a3
    jsr DrawP1Bullets
    jsr DrawP2Bullets
    jsr UpdateBullets 
    jsr UpdatePlayerInput
    jsr DrawPlayer1
    lea PLAYER2_LOCATION,a3
    jsr DrawPlayer2
    jsr DrawInnerWalls
    jsr SwapBuffers
    
    ; Go to end screen if a player wins
    cmp.l #10,Player1Score
    bge Player1EndScreen  
    cmp.l #10,Player2Score
    bge Player2EndScreen
    bra GameLoop

Player1EndScreen:
    jsr DrawRedEndScreen
    jsr SwapBuffers
Player1EndScreenLoop:
    jsr CheckEnterForMenu 
    cmp.l #FALSE,d0 
    beq Player1EndScreenLoop
    bne ReturnToStartScreen

Player2EndScreen:
    jsr DrawBlueEndScreen
    jsr SwapBuffers
Player2EndScreenLoop:
    jsr CheckEnterForMenu 
    cmp.l #FALSE,d0 
    beq Player2EndScreenLoop
    bne ReturnToStartScreen
   
    STOP #$4000
    END    START       






















*~Font name~Courier New~
*~Font size~10~
*~Tab type~1~
*~Tab size~4~
