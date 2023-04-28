*-----------------------------------------------------------
* Title      : Audio Manager
* Written by : Jonathan Conrad  
* Date       : 10/20/22
* Description: Play Music and SFX
*-----------------------------------------------------------

PlayMusic:
    ; Load SFX Explosion
    lea Explosion,a1
    move.l #74,d0
    Trap #15
    move.b d1,ExplosionReferenceNum
    
    ; Load music
    move.l #0,d1
    lea Music,a1
    move.l #74,d0
    Trap #15
    
    ; Play Music on Loop
    move.l #1,d2
    move.l #77,d0
    Trap #15  
    rts
    

PlayExplosion:
     movem.l ALL_REGISTERS,-(sp)
     move.b ExplosionReferenceNum,d1
     move.l #0,d2
     move.l #77,d0
     Trap #15
     movem.l (sp)+,ALL_REGISTERS
     rts
    
Music dc.b 'audio\music.wav',0
Explosion dc.b 'audio\boom.wav',0
ExplosionReferenceNum ds.b 0
*~Font name~Courier New~
*~Font size~10~
*~Tab type~1~
*~Tab size~4~
