*-----------------------------------------------------------
* Title      : Random Pickup
* Written by : Jonathan Conrad  
* Date       : 10/19/2022
* Description: Spawn a pickup item randomly at one of the pickup
* spawn locations. The pickup enlarges the next bullet the player
* shoots.
*-----------------------------------------------------------
; d1 = random number between 0-9
; d6 = random number between 0-256
; d7 = counter
; a0 = spawn table
; a1 = incremented spawn
; a2 = random pickup
; a3 = random pickup table
SpawnRandomPickup:
    movem.l ALL_REGISTERS,-(sp)
    lea SpawnTable,a0
    lea RandomPickupTable,a3
    move.l #0,d0
GetInActivePickup:
    addi.l #1,d0
    cmp.l MAX_PICKUPS,d0
    blt NotMaxNumberOfPickups
    movem.l (sp)+,ALL_REGISTERS
    rts
    
NotMaxNumberOfPickups:    
    move.l (a3)+,a2
    cmp.l #TRUE,PICKUP_ACTIVE(a2)
    beq GetInActivePickup    
    
    move.l #0,d0
    move.l #0,d6
    jsr getRandomByteIntoD6
    
    ; Get single digit from random number
    move.l #0,d1
    divu #10,d6
    move.w d6,d1
    cmp.l #10,d1
    blt SkipDivision
    move.l d1,d6
    divu #10,d6
    move.w d6,d1
SkipDivision:
    move.l (a0)+,a1
    cmp.w #7,d1
    blt CheckUpperRightSpawn
    jsr DrawPickup    
    movem.l (sp)+,ALL_REGISTERS
    rts

***********************Spawn Location Checks*******************    
    
CheckUpperRightSpawn:   
    move.l (a0)+,a1
    cmp.w #5,d1
    blt CheckLowerLeftSpawn
    jsr DrawPickup
    movem.l (sp)+,ALL_REGISTERS
    rts
    
CheckLowerLeftSpawn:
    move.l (a0)+,a1  
    cmp.w #3,d1
    ble CheckLowerRightSpawn
    jsr DrawPickup
    movem.l (sp)+,ALL_REGISTERS
    rts
    
CheckLowerRightSpawn:  
    move.l (a0)+,a1  
    cmp.w #2,d1
    blt IsMiddleSpawn
    jsr DrawPickup
    movem.l (sp)+,ALL_REGISTERS
    rts
    
IsMiddleSpawn:
    move.l (a0)+,a1  
    move.l #PICKUP_HEX_COLOR,d1   
    jsr DrawPickup  
    movem.l (sp)+,ALL_REGISTERS
    rts

***********************Get Random Number***********************    
    
SeedRandomNumber
    movem.l ALL_REGISTERS,-(sp)           
    move.l #0,d6
    move.b #GET_TIME_COMMAND,d0    
    move.l d1,RandomValue
    movem.l (sp)+,ALL_REGISTERS
    rts
        
GetRandomByteIntoD6:
    movem.l d0,-(sp)
    movem.l d1,-(sp)
    movem.l d2,-(sp)
    move.l RandomValue,d0
    moveq #$AF-$100,d1
    moveq #18,d2
Ninc0	
	add.l d0,d0
	bcc	Ninc1
	eor.b d1,d0
Ninc1
	dbf	d2,Ninc0
	move.l	d0,RandomValue
	clr.l	d6
	move.b	d0,d6
	
    movem.l (sp)+,d2
    movem.l (sp)+,d1
    movem.l (sp)+,d0
    rts
    
***************************************************************    
GET_TIME_COMMAND        EQU     8   
MAX_PICKUPS             EQU     4
PICKUP_ACTIVE           EQU     0
PICKUP_X                EQU     4
PICKUP_Y                EQU     8 
SPAWN_X                 EQU     0
SPAWN_Y                 EQU     4    
RandomValue             ds.l    1        
SpawnTable              dc.l UpperLeftSpawn,UpperRightSpawn
                        dc.l LowerLeftSpawn,LowerRightSpawn
                        dc.l MiddleSpawn
                        
***********************Spawn Location Table********************                            
UpperLeftSpawn:
    dc.l 167
    dc.l 197
UpperRightSpawn:
    dc.l 622
    dc.l 197
LowerLeftSpawn:
    dc.l 167
    dc.l 463
LowerRightSpawn:
    dc.l 622
    dc.l 463
MiddleSpawn:
    dc.l 389
    dc.l 332

***********************Pickup Tagble***************************        
RandomPickupTable dc.l RandomPickup1,RandomPickup2
                  dc.l RandomPickup3,RandomPickup4
RandomPickup1: 
    dc.l 0 ; 1 active or 0 inactive
    dc.l 389 ; default x
    dc.l 332 ; default y
RandomPickup2:
    dc.l 0 ; 1 active or 0 inactive
    dc.l 389 ; default x
    dc.l 332 ; default y   
RandomPickup3:
    dc.l 0 ; 1 active or 0 inactive
    dc.l 389 ; default x
    dc.l 332 ; default y   
RandomPickup4:
    dc.l 0 ; 1 active or 0 inactive
    dc.l 389 ; default x
    dc.l 332 ; default y  




*~Font name~Courier New~
*~Font size~10~
*~Tab type~1~
*~Tab size~4~
