*-----------------------------------------------------------
* Title      : Physics Manager
* Written by : Jonathan Conrad  
* Date       : 10/9/2022
* Description: Collision Detection, Acceleration, Bullet Ricochet
*-----------------------------------------------------------
; Forward Checks
; d2 = movement direction
ForwardHorizontalCheck:
    ; Left Check
    move.l (a5),d3
    add.l d1,d3
    cmp.l #GRASS_LEFT_X,d3
    bne ForwardRightCheck
    move.l #COLLIDED,d2
    
ForwardRightCheck: 
    move.l (a5),d3
    add.l d1,d3
    cmp.l #(GRASS_RIGHT_X - MAX_PLAYER_WIDTH),d3
    bne PhysicsReturn
    move.l #COLLIDED,d2
    rts
  
ForwardVerticalCheck: 
    ; Up Check   
    move.l 4(a5),d3
    add.l d1,d3
    cmp.l #GRASS_UPPER_Y,d3
    bne ForwardDownCheck
    move.l #COLLIDED,d2
    
ForwardDownCheck:
    move.l 4(a5),d3
    add.l d1,d3
    cmp.l #(GRASS_LOWER_Y - MAX_PLAYER_HEIGHT),d3
    bne PhysicsReturn
    move.l #COLLIDED,d2
    rts

; Backward Checks
; d2 = movement direction
BackwardHorizontalCheck:
    ; Left Check
    move.l (a5),d3
    sub.l d1,d3
    cmp.l #GRASS_LEFT_X,d3
    bne BackwardRightCheck
    move.l #COLLIDED,d2
    
BackwardRightCheck:
    move.l (a5),d3
    sub.l d1,d3
    cmp.l #(GRASS_RIGHT_X - MAX_PLAYER_WIDTH),d3
    bne PhysicsReturn
    move.l #COLLIDED,d2
    rts
  
BackwardVerticalCheck: 
    ; Up Check   
    move.l 4(a5),d3
    sub.l d1,d3
    cmp.l #GRASS_UPPER_Y,d3
    bne BackwardDownCheck
    move.l #COLLIDED,d2
    
BackwardDownCheck:
    move.l 4(a5),d3
    sub.l d1,d3
    cmp.l #(GRASS_LOWER_Y - MAX_PLAYER_HEIGHT),d3
    bne PhysicsReturn
    move.l #COLLIDED,d2
    rts

; Player 1 Rotation
IncrementAngle:
    add.l #2,MovementAngle
    cmp.l #16,MovementAngle
    beq AngleRestartTo0
    rts
AngleRestartTo0:
    move.l #0,MovementAngle
    rts
DecrementAngle:
    sub.l #2,MovementAngle
    cmp.l #0,MovementAngle
    blt AngleRestartTo14
    rts
AngleRestartTo14
    move.l #14, MovementAngle
    rts

; Player 2 Rotation
P2IncrementAngle:
    add.l #2,P2MovementAngle
    cmp.l #16,P2MovementAngle
    beq P2AngleRestartTo0
    rts
P2AngleRestartTo0:
    move.l #0,P2MovementAngle
    rts
P2DecrementAngle:
    sub.l #2,P2MovementAngle
    cmp.l #0,P2MovementAngle
    blt P2AngleRestartTo14
    rts
P2AngleRestartTo14
    move.l #14,P2MovementAngle
    rts


; Player 1 Movement 
; d2 = Collision check return value
; a6 = Movement Table
Forward: 
    move.l MovementAngle,d0
    move.b (a6,d0),d1
    cmp.b #-1,d1
    bne XNotNegativeValueForward
    move.l #-1,d1 
XNotNegativeValueForward:
    move.l a3,a5
    jsr ForwardHorizontalCheck
    cmp.b #COLLIDED,d2
    beq SkipXForward
    add.l d1,PLAYER_X(a3) 
SkipXForward:
    move.l #0,d1
    move.b 1(a6,d0),d1
    cmp.b #-1,d1
    bne YNotNegativeValueForward
    move.l #-1,d1 
    
YNotNegativeValueForward:
    jsr ForwardVerticalCheck
    cmp.b #COLLIDED,d2
    beq PhysicsReturn
    add.l d1,PLAYER_Y(a3)
    rts  

Backward: 
    move.l MovementAngle,d0
    move.b (a6,d0),d1
    cmp.b #-1,d1
    bne XNotNegativeValueBackward    
    move.l #-1,d1 
XNotNegativeValueBackward:
    move.l a3,a5
    jsr BackwardHorizontalCheck
    cmp.b #COLLIDED,d2
    beq SkipXBackward
    sub.l d1,PLAYER_X(a3)
SkipXBackward:
    move.l #0,d1 
    move.b 1(a6,d0),d1
    cmp.b #-1,d1
    bne YNotNegativeValueBackward   
    move.l #-1,d1
YNotNegativeValueBackward: 
    jsr BackwardVerticalCheck
    cmp.b #COLLIDED,d2
    beq PhysicsReturn
    sub.l d1,PLAYER_Y(a3)
    rts

; Player 2 Movement
; d2 = Collision check return value
; a6 = Movement Table
P2Forward:
    move.l P2MovementAngle,d0
    move.b (a6,d0),d1
    cmp.b #-1,d1
    bne P2XNotNegativeValueForward
    move.l #-1,d1 
P2XNotNegativeValueForward:
    move.l a4,a5
    jsr ForwardHorizontalCheck
    cmp.b #COLLIDED,d2
    beq P2SkipXForward
    add.l d1,PLAYER_X(a4) 
P2SkipXForward:
    move.l #0,d1
    move.b 1(a6,d0),d1
    cmp.b #-1,d1
    bne P2YNotNegativeValueForward
    move.l #-1,d1 
    
P2YNotNegativeValueForward:
    jsr ForwardVerticalCheck
    cmp.b #COLLIDED,d2
    beq PhysicsReturn
    add.l d1,PLAYER_Y(a4)
    rts  

P2Backward: 
    move.l P2MovementAngle,d0
    move.b (a6,d0),d1
    cmp.b #-1,d1
    bne P2XNotNegativeValueBackward    
    move.l #-1,d1 
P2XNotNegativeValueBackward:
    move.l a4,a5
    jsr BackwardHorizontalCheck
    cmp.b #COLLIDED,d2
    beq P2SkipXBackward
    sub.l d1,PLAYER_X(a4)
P2SkipXBackward:
    move.l #0,d1 
    move.b 1(a6,d0),d1
    cmp.b #-1,d1
    bne P2YNotNegativeValueBackward   
    move.l #-1,d1
P2YNotNegativeValueBackward: 
    jsr BackwardVerticalCheck
    cmp.b #COLLIDED,d2
    beq PhysicsReturn
    sub.l d1,PLAYER_Y(a4)
    rts

*********************Update Bullets****************************
; d0 = counter
; d1 = bullet velocity
; d2 = bullet angle
; d3 = bullet x or y position
; d4 = movement value -1,1,or 0
; d5 = player specifier
; a0 = player bullets table
; a1 = single bullet
; a2 = movement table
; a4 = player active bullets count
UpdateBullets:
    movem.l ALL_REGISTERS,-(sp)
    lea MovementTable,a2
    jsr Player1UpdateBullets
    jsr CheckForActiveBullet
    jsr Player2UpdateBullets
    jsr CheckForActiveBullet
    movem.l (sp)+,ALL_REGISTERS
    rts

; Loop through and update positions of all active bullets
CheckForActiveBullet: 
    move.l (a0)+,a1
    addi.l #1,d0
    cmp.l #1,BULLET_ACTIVE(a1)
    bne NoBulletToUpdate
    
    move.l BULLET_X_VELOCITY(a1),d1    
    move.l BULLET_X(a1),d3
    add.l d1,d3
    move.l d3,BULLET_X(a1) 
    move.l BULLET_Y(a1),d3
    move.l BULLET_Y_VELOCITY(a1),d1
    add.l d1,d3
    move.l d3,BULLET_Y(a1)
    jsr CheckBulletsForWallHit   

    cmp.l #Player2BulletsTable,d5
    bne SkipToPlayer1Bullet
    jsr CheckPlayer1HitByBullet
    bra NoBulletToUpdate
SkipToPlayer1Bullet:
    jsr CheckPlayer2HitByBullet
NoBulletToUpdate:
    cmp.l #MAX_PLAYER_BULLETS,d0
    bne CheckForActiveBullet
    rts
    
Player1UpdateBullets:
    lea Player1BulletsTable,a0
    lea Player1ActiveBullets,a4
    lea PLAYER1_LOCATION,a3
    jsr CheckPlayerPickup
    move.l a0,d5
    move.l #0,d0
    rts
    
Player2UpdateBullets:
    lea Player2BulletsTable,a0
    lea Player2ActiveBullets,a4
    lea PLAYER2_LOCATION,a3
    jsr CheckPlayerPickup
    move.l a0,d5
    move.l #0,d0
    rts

*****************************
; d0 = bullet counter
; d0 = wall x
; d1 = wall y
; d2 = wall x + wall width
; d3 = wall y + wall height
; d4 = bullet x (BoxCollisionCheck parameter)
; d5 = bullet y 
; d6 = bullet x + bullet width
; d7 = bullet y + bullet height
; a1 = (Parameter)bullet
; a5 = wall
; a6 = bullet wall collision table
CheckBulletsForWallHit:
    movem.l ALL_REGISTERS,-(sp)
    lea BulletWallCollisionTable,a6
    move.l #0,d0
CheckWallHit:
    addi.l #1,d0
    move.l d0,-(sp)
    move.l (a6)+,a5
    
    ; Wall Box Collider
    move.l (a5),d0
    move.l 4(a5),d1
    move.l 8(a5),d2
    move.l 12(a5),d3
    add.l d0,d2
    add.l d1,d3
    
    ; Bullet Box Collider
    move.l BULLET_X(a1),d4
    asr.l #FIXED_POINT_SHIFT,d4
    move.l BULLET_Y(a1),d5
    asr.l #FIXED_POINT_SHIFT,d5 
    move.l d4,d6
    move.l d5,d7
    add.l #BULLET_WIDTH,d6
    add.l #BULLET_HEIGHT,d7
    
    cmp.l #TRUE,BULLET_ENLARGED(a1)
    bne SkipEnlargeBulletCollider
    add.l #BULLET_WIDTH,d6
    add.l #BULLET_HEIGHT,d7
  
SkipEnlargeBulletCollider:
    
    jsr BoxCollisionCheck
    cmp.l #TRUE,d0
    beq WallHit
    move.l (sp)+,d0
    cmp.l #MAX_NUMBER_OF_WALLS,d0 
    bne CheckWallHit   
    movem.l (sp)+,ALL_REGISTERS
    rts 
    
******************Bullet Wall Hit******************************        
WallHit:
    ; Deactivate bullet after bouncing 3 times
    cmp.l #BOUNCE_NUM_TO_DEACTIVATE,BULLET_WALL_HIT_COUNT(a1)
    beq DeactivateBullet    
    cmp.l #FALSE,BULLET_Y_VELOCITY(a5)
    beq NegateYCheck
    move.l (a5),d0
    cmp.l d0,d4
    bgt NegateX
    cmp.l d4,d2 
    ble NegateYCheck            
NegateX:    
    move.l BULLET_X_VELOCITY(a1),d4
    add.l #ACCELERATE_PER_REBOUND,d4 
    muls #-1,d4
    cmp.l #0,d4
    bge SkipSubtractXAcceleration
    subi.l #ACCELERATE_PER_REBOUND,d4
    bra SkipAddXAcceleration
SkipSubtractXAcceleration:
    addi.l #ACCELERATE_PER_REBOUND,d4 
SkipAddXAcceleration:
    move.l d4,BULLET_X_VELOCITY(a1)
    bra SkipNegateY
NegateYCheck
    cmp.l d1,d7
    bgt NegateY
    cmp.l d5,d3
    ble SkipNegateY
NegateY:
    move.l BULLET_Y_VELOCITY(a1),d5  
    muls #-1,d5
    cmp.l #0,d5
    bge SkipSubtractYAcceleration
    subi.l #ACCELERATE_PER_REBOUND,d5
    bra SkipAddYAcceleration
SkipSubtractYAcceleration:
    addi.l #ACCELERATE_PER_REBOUND,d5 
SkipAddYAcceleration:   
    move.l d5,BULLET_Y_VELOCITY(a1)   
SkipNegateY:
    ; Reset back to previous x,y
    move.l BULLET_PREV_X(a1),d0
    asl.l #FIXED_POINT_SHIFT,d0
    move.l d0,BULLET_X(a1)
    move.l BULLET_PREV_Y(a1),d0
    asl.l #FIXED_POINT_SHIFT,d0
    move.l d0,BULLET_Y(a1)
    
    move.l (sp)+,d0
    add.l #1,BULLET_WALL_HIT_COUNT(a1)
    movem.l (sp)+,ALL_REGISTERS
    rts

DeactivateBullet:
    move.l (sp)+,d0
    move.l #FALSE,BULLET_ACTIVE(a1)
    subi.l #1,(a4)
    jsr RedrawBulletGrassChunk
    move.l #FALSE,BULLET_ENLARGED(a1)
    movem.l (sp)+,ALL_REGISTERS
    rts
    
******************Check Player Pickup**************************        
; d0 = player x 
; d1 = player y 
; d2 = player x + player width
; d3 = player y + player height
; d4 = pickup x
; d5 = pickup y
; d6 = pickup x + pickup width
; d7 = pickup y + pickup height
; a0 = RandomPickupTable
; a1 = pickup 
; a3 = player
CheckPlayerPickup:
    movem.l ALL_REGISTERS,-(sp)
    lea RandomPickupTable,a0
    move.l #0,d1
    
CheckPickupLoop:    
    move.l (a0)+,a1
    addi.l #1,d1
    move.l d1,-(sp)
    
    cmp.l #TRUE,PICKUP_ACTIVE(a1)
    bne NoPickup
    
    move.l PLAYER_X(a3),d0 
    move.l PLAYER_Y(a3),d1
    move.l d0,d2
    move.l d1,d3
    add.l #MAX_PLAYER_WIDTH,d2 
    add.l #MAX_PLAYER_HEIGHT,d3
    
    move.l PICKUP_X(a1),d4
    move.l PICKUP_Y(a1),d5
    move.l d4,d6
    move.l d5,d7
    add.l #BULLET_WIDTH,d4
    add.l #BULLET_HEIGHT,d5
    jsr BoxCollisionCheck
    cmp.l #FALSE,d0
    beq NoPickup
    
    ; Set next bullet of player to enlarge
    lea PLAYER1_LOCATION,a4
    lea PLAYER2_LOCATION,a5
    cmp.l a3,a4
    bne Player2Pickup
    move.b #TRUE,Player1PickupActivated
Player2Pickup:    
    cmp.l a3,a5
    bne DeactivatePickup
    move.b #TRUE,Player2PickupActivated
DeactivatePickup:
    ; Deactivate pickup
    move.l #FALSE,PICKUP_ACTIVE(a1)
    
    ; Redraw grass over where pickup was
    jsr DrawPickupGrass
    
NoPickup:
    move.l (sp)+,d1
    cmp.l #MAX_PICKUPS,d1
    blt CheckPickupLoop 
   
    movem.l (sp)+,ALL_REGISTERS
    rts

******************Check Player 1 Hit By Bullet*****************        
; d0 = player1 x 
; d1 = player1 y 
; d2 = player1 x + player1 width
; d3 = player1 y + player1 height
; d4 = bullet x
; d5 = bullet y
; d6 = bullet x + bullet width
; d7 = bullet y + bullet height
; a1 = bullet
; a3 = Player1 Location
CheckPlayer1HitByBullet:
    movem.l ALL_REGISTERS,-(sp)
    
    ; Check if bullet box is within player box
    lea PLAYER1_LOCATION,a3
    move.l PLAYER_X(a3),d0 
    move.l PLAYER_Y(a3),d1
    move.l d0,d2
    move.l d1,d3
    add.l #MAX_PLAYER_WIDTH,d2 
    add.l #MAX_PLAYER_HEIGHT,d3
    
    move.l BULLET_X(a1),d4
    asr.l #FIXED_POINT_SHIFT,d4
    move.l BULLET_Y(a1),d5
    asr.l #FIXED_POINT_SHIFT,d5 
  
    move.l d4,d6
    move.l d5,d7
    add.l #BULLET_WIDTH,d6
    add.l #BULLET_HEIGHT,d7
    
    ;Enlarge if pickup is activated
    cmp.l #TRUE,BULLET_ENLARGED(a1)
    bne SkipEnlargeP2Bullet
    add.l #BULLET_WIDTH,d6
    add.l #BULLET_HEIGHT,d7
    
SkipEnlargeP2Bullet:
    ; Check for collision
    jsr BoxCollisionCheck
    cmp.l #0,d0
    beq Player1NotHit   

    ; Hit, Increment Player2 Score
    add.l #1,Player2Score
    jsr PlayExplosion
    jsr DrawLEDScores
    cmp.l #3,Player2Score
    bne SkipP2Pickup3
    jsr SpawnRandomPickup
SkipP2Pickup3:
    cmp.l #7,Player2Score
    bne SkipPickupP2Draw
    jsr SpawnRandomPickup

SkipPickupP2Draw:
    move.l #FALSE,BULLET_ACTIVE(a1)
    subi.l #1,(a4)
    jsr RedrawBulletGrassChunk
    
Player1NotHit:    
    movem.l (sp)+,ALL_REGISTERS
    rts
    
******************Check Player 2 Hit By Bullet*****************            
CheckPlayer2HitByBullet:
     movem.l ALL_REGISTERS,-(sp)
    
    ; Check if bullet box is within player box
    lea PLAYER2_LOCATION,a3
    move.l PLAYER_X(a3),d0 
    move.l PLAYER_Y(a3),d1
    move.l d0,d2
    move.l d1,d3
    add.l #MAX_PLAYER_WIDTH,d2 ; TODO: change to be specific?
    add.l #MAX_PLAYER_HEIGHT,d3
    
    move.l BULLET_X(a1),d4
    asr.l #FIXED_POINT_SHIFT,d4
    move.l BULLET_Y(a1),d5
    asr.l #FIXED_POINT_SHIFT,d5 
  
    move.l d4,d6
    move.l d5,d7
    add.l #BULLET_WIDTH,d6
    add.l #BULLET_HEIGHT,d7
    
    ; Enlarge if pickup is activated
    cmp.l #TRUE,BULLET_ENLARGED(a1)
    bne SkipEnlargeP1Bullet
    add.l #BULLET_WIDTH,d6
    add.l #BULLET_HEIGHT,d7
    
SkipEnlargeP1Bullet:
    ; Check for collision  
    jsr BoxCollisionCheck
    cmp.l #FALSE,d0
    beq Player2NotHit

    ; Hit, Increment Player2 Score
    jsr RedrawBulletGrassChunk
    add.l #1,Player1Score
    jsr PlayExplosion
    jsr DrawLEDScores
    cmp.l #3,Player1Score
    bne SkipP1Pickup3
    jsr SpawnRandomPickup
    
SkipP1Pickup3:
    cmp.l #7,Player1Score
    bne SkipPickupP1Draw
    jsr SpawnRandomPickup
    
SkipPickupP1Draw:
    subi.l #1,(a4)
    move.l #FALSE,BULLET_ACTIVE(a1)
    
Player2NotHit:    
    movem.l (sp)+,ALL_REGISTERS
    rts
    
*************************Box Collision Check*******************
; d0 = object1 x 
; d1 = object1 y 
; d2 = object1 x + object1 width
; d3 = object1 y + object1 height
; d4 = object2 x
; d5 = object2 y
; d6 = object2 x + bullet width
; d7 = object2 y + bullet height
; d0 = return collision true(1) or false (0) 
BoxCollisionCheck:
    ; Check for collision
    cmp.l d0,d6
    blt NoObjectCollision
    cmp.l d2,d4
    bgt NoObjectCollision
    cmp.l d1,d7
    blt NoObjectCollision
    cmp.l d3,d5
    bgt NoObjectCollision
    move.l #TRUE,d0
    rts
    
NoObjectCollision:
    move.l #FALSE,d0
    rts   
    
*************************Create Bullet*************************
; d0 = bullet counter
; d1 = player angle
; d2 = bullet x velocity
; d3 = movement value -1,1, or 0
; d4 = (parameter)movement angle
; d5 = bullet y velocity
; a0 = (parameter) player total bullets table
; a1 = single bullet
; a2 = bullet start offset location table
; a3 = (parameter) player location
; a4 = movement table
; a5 = (parameter) Player#ActiveBullets
; a6 = Player1ActiveBullets
CreateBullet:
    cmp.l #MAX_PLAYER_BULLETS,(a5)
    beq PhysicsReturn
    ; Get available bullet 
    move.l #0,d0
    lea Player1ActiveBullets,a6
CheckForInactiveBullet:
    move.l (a0)+,a1
    cmp.l #TRUE,BULLET_ACTIVE(a1)
    bne SetBulletActive
    addi.l #1,d0
    cmp.l #MAX_PLAYER_BULLETS,d0
    bne CheckForInactiveBullet
    
SetBulletActive: 
    move.l #TRUE,BULLET_ACTIVE(a1)
    cmp.b #TRUE,Player1PickupActivated
    bne SkipPlayer1PickupActivation
    cmp.l a5,a6
    bne SkipPlayer1PickupActivation
    move.l #TRUE,BULLET_ENLARGED(a1)
    move.b #FALSE,Player1PickupActivated 
 
SkipPlayer1PickupActivation:
    cmp.b #TRUE,Player2PickupActivated
    bne SkipPlayer2PickupActivation
    cmp.l a5,a6
    beq SkipPlayer2PickupActivation
    move.l #TRUE,BULLET_ENLARGED(a1)
    move.b #FALSE,Player2PickupActivated

SkipPlayer2PickupActivation:
    addi.l #1,(a5)
    lea BulletStartLocationoffsetTable,a2 
    move.l d4,d1
    lsl.l #2,d1 

    ; Set bullet start location
    move.l PLAYER_X(a3),d0
    add.l BULLET_START_LOC_X_OFFSET(a2,d1),d0
    lsl.l #FIXED_POINT_SHIFT,d0
    move.l d0,BULLET_X(a1)
    move.l d0,BULLET_PREV_X(a1)
    move.l PLAYER_Y(a3),d0
    add.l BULLET_START_LOC_Y_OFFSET(a2,d1),d0
    lsl.l #FIXED_POINT_SHIFT,d0
    move.l d0,BULLET_Y(a1) 
    move.l d0,BULLET_PREV_Y(a1)
   
    ; Set bullet velocity and angle
    lea MovementTable,a4
    move.l #INITIAL_BULLET_VELOCITY,d2   
    move.l #0,d3
    move.b (a4,d4),d3
    cmp.b #-1,d3
    bne NotNegative
    move.w #-1,d3
    
NotNegative:
    muls d3,d2
    
SkipXMultiply:
    move.l d2,BULLET_X_VELOCITY(a1)
    move.l #INITIAL_BULLET_VELOCITY,d5
    move.l #0,d3
    move.b 1(a4,d4),d3
    cmp.b #-1,d3
    bne YNotNegative
    move.w #-1,d3
    
YNotNegative:
    muls d3,d5
SkipYMultiply:    
    move.l d5,BULLET_Y_VELOCITY(a1)
    move.l #0,BULLET_WALL_HIT_COUNT(a1)
    rts

PhysicsReturn:
    rts


***************************************************************        
    
COLLIDED EQU $FF
MovementAngle ds.l 1
PreviousMovementAngle ds.l 1
P2MovementAngle ds.l 1
P2PreviousMovementAngle ds.l 1
MovementTable:
Angle
    dc.b 1
    dc.b 0
Angle45
    dc.b 1
    dc.b -1
Angle90
    dc.b 0
    dc.b -1
Angle135
    dc.b -1
    dc.b -1
Angle180
    dc.b -1
    dc.b 0
Angle225
    dc.b -1
    dc.b 1
Angle270
    dc.b 0
    dc.b 1
Angle315
    dc.b 1
    dc.b 1
      
INITIAL_BULLET_VELOCITY         EQU 120
ACCELERATE_PER_REBOUND          EQU 50
WALL_WIDTH                      EQU 19
INNER_WALL_WIDTH                EQU 8
UPPER_LOWER_WALL_LENGTH         EQU 140
MAX_NUMBER_OF_WALLS             EQU 14
BOUNCE_NUM_TO_DEACTIVATE        EQU 3

BulletWallCollisionTable 
    dc.l OuterUpperWall,OuterLowerWall,OuterLeftWall,OuterRightWall
    dc.l UpperLeftWall,LowerLeftWall,UpperRightWall,LowerRightWall
    dc.l MiddleUpperLeftWall,MiddleLowerLeftWall,MiddleUpperRightWall,MiddleLowerRightWall
    dc.l MiddleLeftWall,MiddleRightWall
    
*******************Bullet Wall Collision Table*****************        
OuterUpperWall: 
    dc.l 20 ; x
    dc.l 73 ; y
    dc.l 800 ; w
    dc.l WALL_WIDTH ; h
    dc.l 0 ; 0 horizontal, 1 vertical
OuterLeftWall:
    dc.l 0
    dc.l 73
    dc.l WALL_WIDTH
    dc.l 600
    dc.l 1
OuterLowerWall:
    dc.l 20
    dc.l 581
    dc.l 800
    dc.l WALL_WIDTH
    dc.l 0
OuterRightWall:
    dc.l 781
    dc.l 73
    dc.l WALL_WIDTH
    dc.l 600
    dc.l 1
UpperLeftWall:
    dc.l 130
    dc.l UPPER_LOWER_WALL_LENGTH
    dc.l INNER_WALL_WIDTH
    dc.l UPPER_LOWER_WALL_LENGTH
    dc.l 1
LowerLeftWall:
    dc.l 130
    dc.l 380    
    dc.l INNER_WALL_WIDTH
    dc.l UPPER_LOWER_WALL_LENGTH
    dc.l 1
UpperRightWall:
    dc.l 675
    dc.l UPPER_LOWER_WALL_LENGTH
    dc.l INNER_WALL_WIDTH
    dc.l UPPER_LOWER_WALL_LENGTH
    dc.l 1
LowerRightWall:
    dc.l 675
    dc.l 380
    dc.l INNER_WALL_WIDTH
    dc.l UPPER_LOWER_WALL_LENGTH
    dc.l 1
MiddleUpperLeftWall: 
    dc.l 205
    dc.l 190
    dc.l 110
    dc.l INNER_WALL_WIDTH
    dc.l 0
MiddleLowerLeftWall:
    dc.l 205
    dc.l 460
    dc.l 110
    dc.l INNER_WALL_WIDTH    
    dc.l 0
MiddleUpperRightWall:
    dc.l 468
    dc.l 190
    dc.l 110
    dc.l INNER_WALL_WIDTH
    dc.l 0
MiddleLowerRightWall:
    dc.l 468
    dc.l 460
    dc.l 110
    dc.l INNER_WALL_WIDTH
    dc.l 0
MiddleLeftWall
    dc.l 250
    dc.l 280
    dc.l INNER_WALL_WIDTH
    dc.l 100
    dc.l 1
MiddleRightWall
    dc.l 528
    dc.l 280
    dc.l INNER_WALL_WIDTH
    dc.l 100
    dc.l 1
    








*~Font name~Courier New~
*~Font size~10~
*~Tab type~1~
*~Tab size~4~
