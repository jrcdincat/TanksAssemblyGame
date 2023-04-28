*-----------------------------------------------------------
* Title      : Input Manager
* Written by : Jonathan Conrad
* Date       : 10/4/2022
* Description: Handle keyboard input for players
*-----------------------------------------------------------
UpdatePlayerInput:

************** Player 1 Controls **************
    move.l #W_INPUT,d1
    move.b #GET_USER_INPUT_COMMAND,d0
    Trap #15
    andi.l #KEY_PRESSED,d1
    beq AKeyCheck
    movem.l ALL_REGISTERS,-(sp)
    beq AKeyCheck
    jsr Forward
    movem.l (sp)+,ALL_REGISTERS
    
AKeyCheck:
    move.l #A_INPUT,d1
    move.b #GET_USER_INPUT_COMMAND,d0
    Trap #15
    
    andi.l #KEY_PRESSED,d1 
    beq NoAInput
    move.b  HAVE_HAD_NO_A_INPUT,d0
    beq SKeyCheck
    move.b  #FALSE,HAVE_HAD_NO_A_INPUT
    jsr IncrementAngle
    bra SKeyCheck
NoAInput:
    move.b  #TRUE,HAVE_HAD_NO_A_INPUT 
    
SKeyCheck: 
    move.l #S_INPUT,d1
    move.b #GET_USER_INPUT_COMMAND,d0
    Trap #15
    
    andi.l #KEY_PRESSED,d1 
    beq DKeyCheck  
    movem.l ALL_REGISTERS,-(sp)
    beq DKeyCheck
    jsr Backward
    movem.l (sp)+,ALL_REGISTERS

DKeyCheck:
    move.l #D_INPUT,d1
    move.b #GET_USER_INPUT_COMMAND,d0
    Trap #15
    
    andi.l #KEY_PRESSED,d1 
    beq NoDInput
    move.b HAVE_HAD_NO_D_INPUT,d0
    beq SpaceKeyCheck  
    move.b #FALSE,HAVE_HAD_NO_D_INPUT
    jsr DecrementAngle
    bra SpaceKeyCheck
NoDInput:
    move.b  #TRUE,HAVE_HAD_NO_D_INPUT 
    
SpaceKeyCheck:
    move.l #SPACE_INPUT,d1
    move.b #GET_USER_INPUT_COMMAND,d0
    Trap #15
    
    andi.l #KEY_PRESSED,d1 
    beq NoSpaceInput
    move.b HAVE_HAD_NO_SPACE_INPUT,d0
    beq UpKeyCheck
    move.b #FALSE,HAVE_HAD_NO_SPACE_INPUT
    movem.l ALL_REGISTERS,-(sp)
    lea Player1ActiveBullets,a5
    lea PLAYER1_LOCATION,a3
    lea Player1BulletsTable,a0
    move.l MovementAngle,d4
    jsr CreateBullet
    movem.l (sp)+,ALL_REGISTERS
    bra UpKeyCheck
NoSpaceInput:
   move.b #TRUE,HAVE_HAD_NO_SPACE_INPUT
   
************** Player 2 Controls ************** 
UpKeyCheck:
    move.l #UP_INPUT,d1
    move.b #GET_USER_INPUT_COMMAND,d0
    Trap #15
    
    andi.l #KEY_PRESSED,d1 
    beq LeftKeyCheck
    movem.l ALL_REGISTERS,-(sp)
    beq LeftKeyCheck
    jsr P2Forward
    movem.l (sp)+,ALL_REGISTERS
    
LeftKeyCheck:
    move.l #LEFT_INPUT,d1
    move.b #GET_USER_INPUT_COMMAND,d0
    Trap #15
    
    andi.l #KEY_PRESSED,d1 
    beq NoLeftKeyInput 
    move.b  HAVE_HAD_NO_LEFT_INPUT,d0
    beq DownKeyCheck
    move.b  #FALSE,HAVE_HAD_NO_LEFT_INPUT
    jsr P2IncrementAngle
    bra DownKeyCheck
NoLeftKeyInput:
    move.b  #TRUE,HAVE_HAD_NO_LEFT_INPUT 

DownKeyCheck:
    move.l #DOWN_INPUT,d1
    move.b #GET_USER_INPUT_COMMAND,d0
    Trap #15
    
    andi.l #KEY_PRESSED,d1 
    beq RightKeyCheck
    movem.l ALL_REGISTERS,-(sp)
    beq RightKeyCheck
    jsr P2Backward
    movem.l (sp)+,ALL_REGISTERS
    
RightKeyCheck:    
    move.l #RIGHT_INPUT,d1
    move.b #GET_USER_INPUT_COMMAND,d0
    Trap #15
    
    andi.l #KEY_PRESSED,d1
    beq NoRightKeyInput
    move.b HAVE_HAD_NO_RIGHT_INPUT,d0 
    beq EnterKeyCheck  
    move.b #FALSE,HAVE_HAD_NO_RIGHT_INPUT
    jsr P2DecrementAngle
    bra EnterKeyCheck
NoRightKeyInput:
    move.b  #TRUE,HAVE_HAD_NO_RIGHT_INPUT 
    
EnterKeyCheck:
    move.l #ENTER_INPUT,d1
    move.b #GET_USER_INPUT_COMMAND,d0
    Trap #15
    
    andi.l #KEY_PRESSED,d1 
    beq NoEnterInput
    move.b HAVE_HAD_NO_ENTER_INPUT,d0
    beq EnterNotPressed
    move.b #FALSE,HAVE_HAD_NO_ENTER_INPUT
    movem.l ALL_REGISTERS,-(sp)
    lea Player2ActiveBullets,a5
    lea PLAYER2_LOCATION,a3
    lea Player2BulletsTable,a0
    move.l P2MovementAngle,d4
    jsr CreateBullet
    movem.l (sp)+,ALL_REGISTERS
    bra UpKeyCheck
NoEnterInput:
   move.b #TRUE,HAVE_HAD_NO_ENTER_INPUT
EnterNotPressed: 
    
    jsr CheckEscForRestart
    rts
    
**********************Other Controls***************************    
CheckEnterForMenu:
    move.l #ENTER_INPUT,d1
    move.b #GET_USER_INPUT_COMMAND,d0
    Trap #15
    
    move.l #FALSE,d0
    andi.l #KEY_PRESSED,d1 
    beq NoMenuEnterInput
    move.w HAVE_HAD_NO_MENU_ENTER_INPUT,d0
    beq MenuEnterNotPressed
    move.w #FALSE,HAVE_HAD_NO_MENU_ENTER_INPUT 
    move.l #TRUE,d0
    
NoMenuEnterInput:
    move.w #TRUE,HAVE_HAD_NO_MENU_ENTER_INPUT
MenuEnterNotPressed:
    rts
    
CheckEscForRestart:
    move.l #ESC_INPUT,d1
    move.b #GET_USER_INPUT_COMMAND,d0
    Trap #15
    
    move.l #FALSE,d0
    andi.l #KEY_PRESSED,d1 
    beq NoEscInput
    move.w HAVE_HAD_NO_ESC_INPUT,d0  
    beq EscNotPressed
    move.w #FALSE,HAVE_HAD_NO_ESC_INPUT
    jmp Initialize
    
NoEscInput:
    move.w #TRUE,HAVE_HAD_NO_ESC_INPUT
EscNotPressed:
    rts

***************************************************************    
GET_USER_INPUT_COMMAND          EQU 19
KEY_PRESSED                     EQU $FF
W_INPUT                         EQU 'W'
A_INPUT                         EQU 'A' 
S_INPUT                         EQU 'S' 
D_INPUT                         EQU 'D'
SPACE_INPUT                     EQU $20
UP_INPUT                        EQU $26
LEFT_INPUT                      EQU $25
DOWN_INPUT                      EQU $28
RIGHT_INPUT                     EQU $27
ENTER_INPUT                     EQU $D
ESC_INPUT                       EQU $1B
UP    dc.b $00000001
DOWN  dc.b $00000010
HAVE_HAD_NO_A_INPUT          ds.b 1
HAVE_HAD_NO_D_INPUT          ds.b 1
HAVE_HAD_NO_LEFT_INPUT       ds.b 1
HAVE_HAD_NO_RIGHT_INPUT      ds.b 1
HAVE_HAD_NO_SPACE_INPUT      ds.b 1
HAVE_HAD_NO_ENTER_INPUT      ds.b 1
HAVE_HAD_NO_MENU_ENTER_INPUT ds.w 1
HAVE_HAD_NO_ESC_INPUT        ds.w 1











*~Font name~Courier New~
*~Font size~10~
*~Tab type~1~
*~Tab size~4~
