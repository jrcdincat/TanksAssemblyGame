*-----------------------------------------------------------
* Title      : 7 Segment LED
* Written by : Jonathan Conrad  
* Date       : 9/28/2022
* Description: 7 Segment LED Subroutine
* Draws single number (0-9) onto screen at LED origin (x,y)
*-----------------------------------------------------------
; d1, parameter LED origin x
; d2, parameter LED origin y
; d3, parameter decimal number
; a1, bitmask number table address
DrawLEDSubroutine:
    ; Get bitmask from number table
    lea NumberTable,a1 
    move.b (a1,d3),d0 

LoopThroughLED: 
    lsr.b #1,d0     
    movem.l ALL_REGISTERS,-(sp)
    bcc.s SegmentB
    
    ; Segment A
    move.l d1,d3
    ; left x = Ox - half of length
    sub.l #Half_Segment_Pixel_Length,d1
    ; right x = 0X + half of length
    add.l #Half_Segment_Pixel_Length,d3
    ; upper y = Oy - length
    sub.l #Segment_Pixel_Length,d2
    ; lower y = uppery + width
    move.l d2,d4
    add.l #Segment_Pixel_Width,d4 
    ; parameter d6 = d1
    move.l d1,d6
    bsr.l Seg
    
SegmentB:    
    movem.l (sp)+,ALL_REGISTERS
    lsr.b #1,d0
    movem.l ALL_REGISTERS,-(sp)
    bcc.s SegmentC
    
    ;Segment B
    ; right x = 0x + half length
    move.l d1,d3
    add.l #Half_Segment_Pixel_Length,d3
    move.l d3,d1
    ; left x = rightx - width
    sub.l #Segment_Pixel_Width,d1
    ; lower y = y
    move.l d2,d4
    ; upper y = Oy - length
    sub.l #Segment_Pixel_Length,d2
    ; parameter d6 = d1
    move.l d1,d6
    bsr.l Seg
    
SegmentC:
    movem.l (sp)+,ALL_REGISTERS
    lsr.b #1,d0
    movem.l ALL_REGISTERS,-(sp)
    bcc.s SegmentD
    
    ;Segment C
    ;right x = 0x + half length
    move.l d1,d3
    add.l #Half_Segment_Pixel_Length,d3
    move.l d3,d1
    ;left x = rightx - width
    sub.l #Segment_Pixel_Width,d1
    ;upper y = y
    move.l d2,d4
    ;lower y = Oy + length
    add.l #Segment_Pixel_Length,d4
    ; parameter d6 = d1
    move.l d1,d6
    bsr.l Seg

SegmentD:
    movem.l (sp)+,ALL_REGISTERS
    lsr.b #1,d0
    movem.l ALL_REGISTERS,-(sp)
    bcc.s SegmentE
    
    ;Segment D 
    move.l d1,d3
    ; left x = Ox - half of length
    sub.l #Half_Segment_Pixel_Length,d1
    ; right x = 0X + half of length
    add.l #Half_Segment_Pixel_Length,d3
    ; lower y = 0y + length
    add.l #Segment_Pixel_Length,d2
    ; upper y = lower y - width
    move.l d2,d4
    sub.l #Segment_Pixel_Width,d4
    ; parameter d6 = d1
    move.l d1,d6
    bsr.l Seg
    
SegmentE:
    movem.l (sp)+,ALL_REGISTERS
    lsr.b #1,d0
    movem.l ALL_REGISTERS,-(sp)
    bcc.s SegmentF
    
    ;Segment E
    ;left x = 0x - half length
    sub.l #Half_Segment_Pixel_Length,d1
    move.l d1,d3
    ;right x = leftx + width
    add.l #Segment_Pixel_Width,d3
    ;upper y = y
    move.l d2,d4
    ;lower y = Oy + length
    add.l #Segment_Pixel_Length,d4
    ; parameter d6 = d1
    move.l d1,d6
    bsr.s Seg
    
SegmentF:
    movem.l (sp)+,ALL_REGISTERS
    lsr.b #1,d0
    movem.l ALL_REGISTERS,-(sp)
    bcc.s SegmentG
    
    ;Segment F
    ; left x = 0x - half length
    sub.l #Half_Segment_Pixel_Length,d1
    move.l d1,d3
    ; right x = leftx + width
    add.l #Segment_Pixel_Width,d3
    ; lower y = y
    move.l d2,d4
    ; upper y = Oy - length
    sub.l #Segment_Pixel_Length,d2    
    ; parameter d6 = d1
    move.l d1,d6
    bsr.s Seg
    
SegmentG:
    movem.l (sp)+,ALL_REGISTERS
    lsr.b #1,d0
    bcc.s Return
    
    ;Segment G
    move.l d1,d3
    ; left x = Ox - half of length
    sub.l #Half_Segment_Pixel_Length,d1
    ; right x = 0X + half of length
    add.l #Half_Segment_Pixel_Length,d3
    ; upper y = Oy - half of width
    move.l d2,d4
    sub.l #Half_Segment_Pixel_Width,d2
    ; lower y = y + half of width
    add.l #Half_Segment_Pixel_Width,d4 
    ; parameter d6 = d1
    move.l d1,d6
    bsr.s Seg

Return:    
   rts

; Draw Segment
Seg: 
    move.l CurrentLEDHexColor,d1
    move.l #PEN_COLOR_TRAP_CODE,d0
    trap #15
    move.l #FILL_COLOR_TRAP_CODE,d0
    trap #15
    
    move.l d6,d1
    move.l #DRAW_RECT_TRAP_CODE,d0
    trap #15

    rts
 
PEN_COLOR_TRAP_CODE             EQU 80   
FILL_COLOR_TRAP_CODE            EQU 81
DRAW_RECT_TRAP_CODE             EQU 87
Segment_Pixel_Length            EQU 12
Half_Segment_Pixel_Length       EQU 6
Segment_Pixel_Width             EQU 2
Half_Segment_Pixel_Width        EQU 1 
RED_HEX_COLOR                   EQU $5e59e2 
BLUE_HEX_COLOR                  EQU $e29a59
CurrentLEDHexColor              dc.l RED_HEX_COLOR

***********************Number Table****************************    
NumberTable: 
; Segment bits 0GFEDCBA
    dc.b %00111111 ;$3F - 0
    dc.b %00000110 ;$6  - 1
    dc.b %01011011 ;$5B - 2
    dc.b %01001111 ;$4F - 3
    dc.b %01100110 ;$66 - 4
    dc.b %01101101 ;$6D - 5
    dc.b %01111101 ;$7D - 6
    dc.b %00000111 ;$7  - 7
    dc.b %01111111 ;$7F - 8
    dc.b %01101111 ;$6F - 9





*~Font name~Courier New~
*~Font size~10~
*~Tab type~1~
*~Tab size~4~
