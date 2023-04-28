*-----------------------------------------------------------
* Title      : Bitmap Subroutine
* Written by : Jonathan Conrad
* Date       : 9/16/22
* Description: Start subroutine in bitmap_main.x68
* Subroutine parses through a 24 bit or 32 bit bitmap and displays
* a chunk of the bitmap at a coordinate in the bitmap
* at a coordinate on the output window.
* The bitmap should not have a color palette.
* 24 bit bitmaps store color values in 3 bytes in the order 
* of BBGGRR and require padding to maintain 4 byte alignment.
* 32 bit bitmpas store color values in 4 bytes in BBGGRRWW
* Bitmaps are in little endian and require conversion to big endian. 
*-----------------------------------------------------------
; d0 = temp data register   
; d1 = number of bytes per pixel  
; d4 = padding
; d5 = rows
; d6 = bitmap width 
; d7 = bitmap height       
; a0 = temp adress register
; a1 = Start_Of_Data             
; a2 = address location of pixel arrray
RunBitmapSubroutine:
    move.l (sp)+,d0
    move.l (sp)+,DisplayTopLeftY
    move.l (sp)+,DisplayTopLeftX
    move.l (sp)+,ChunkTopLeftY 
    move.l (sp)+,ChunkTopLeftX 
    move.l (sp)+,ChunkHeight 
    move.l (sp)+,ChunkWidth
    move.l d0,-(sp)
    
    ; Check that chunk width + display x does not exceed window output width
    move.l ChunkWidth,d0
    add.l DisplayTopLeftX,d0
    cmp.l #OUTPUT_WIDTH,d0
    bgt PrintExceedDisplaySizeTextError
    
    ; Check that chunk height + display y does not exceed window output height
    move.l ChunkHeight,d0
    add.l DisplayTopLeftY,d0
    cmp.l #OUTPUT_HEIGHT,d0
    bgt PrintExceedDisplaySizeTextError

    ; Check for negative parameter values
    move.l #0,d0
    cmp.l ChunkWidth,d0
    bgt PrintNegativeParameterError
    
    cmp.l ChunkHeight,d0
    bgt PrintNegativeParameterError
    
    cmp.l ChunkTopLeftX,d0
    bgt PrintNegativeParameterError
    
    cmp.l ChunkTopLeftY ,d0
    bgt PrintNegativeParameterError
    
    cmp.l DisplayTopLeftX,d0
    bgt PrintNegativeParameterError
    
    cmp.l DisplayTopLeftY,d0
    bgt PrintNegativeParameterError
    
    ; Check if parameter width or height are 0
    cmp.l ChunkWidth,d0
    beq Done
    cmp.l ChunkWidth,d0
    beq Done
    
    ;lea Start_Of_Data,a1**************Remove?
    
    ; Check that the id field is BM for bmp
    cmp.w #EXPECTED_BMP_ID,(a1) 
    bne PrintFileTypeErrorText
    move.l PIXEL_ARRAY_OFFSET_OFFSET_LOC(a1),d0 
    bsr.l ConvertToBigEndian

    ; Set address location of pixel array in based on d0 offset
    move.l a1,a2
    add.l d0,a2
    
    ; Check that bitmap has no color palette
    move.l NUM_OF_PALETTE_COLORS_OFFSET(a1),d0
    cmp.l #0,d0
    bne PrintColorPaletteError
    
    ; Check that the number of bits per pixel are correct
    move.w NUM_OF_BITS_PER_PIXEL_OFFSET(a1),d2
    cmp.w #BMP_32_BITS,d2
    beq Skip24BitCheck
    cmp.w #BMP_24_BITS,d2
    bne PrintNumberOfBitsPerPixelError
    
Skip24BitCheck:
    ; Set bitmap width in d6
    move.l BITMAP_WIDTH_OFFSET_LOCATION(a1),d0
    bsr.l ConvertToBigEndian
    move.l d0,d6
    
    ; Check that chunk width + chunk x does not exceed bitmap width in d6
    move.l ChunkWidth,d0
    add.l ChunkTopLeftX,d0 
    cmp.l d0,d6
    blt PrintChunkExceedsBitmapSizeText
    
    ; Calculate Required Padding
    move.l d6,d4
    divu #ALIGNMENT_4_BYTES,d4
    move.w #0,d4
    swap.w d4
    
    ; Set correct number of bytes per pixel in d1
    move.l #NUMBER_OF_BYTES_PER_PIXEL_24,d1
    cmp.w #BMP_24_BITS,d2
    beq Skip32BitNumberOfBytesPerPixel
    move.l #NUMBER_OF_BYTES_PER_PIXEL_32,d1
    
Skip32BitNumberOfBytesPerPixel:
    ; Calculate and set width chunk padding in d4
    move.l d6,d0
    sub.l ChunkWidth,d0
    mulu.w d1,d0 ; 24
    add.l d0,d4
    
    ; Set bitmap height in d7
    move.l BITMAP_HEIGHT_OFFSET_LOCATION(a1),d0
    bsr.l ConvertToBigEndian
    move.l d0,d7
    
    ; Check that chunk height + chunk y does not exceed bitmap height in d7
    move.l ChunkHeight,d0
    add.l ChunkTopLeftY,d0
    cmp.l d0,d7
    blt PrintChunkExceedsBitmapSizeText
    
    ; Calculate and set start location in a2
    move.l d7,d0
    sub.l ChunkHeight,d0 ; d0 become # of rows to skip
    move.l d0,d5
    sub.l ChunkTopLeftY,d5
    move.l ChunkWidth,d0

    mulu.w d1,d0    
    add.l d4,d0
    mulu.w d5,d0 ; d5 rows * d0 result 
    add.l d0,a2
    move.l ChunkTopLeftX,d0
    mulu.w d1,d0 
    add.l d0,a2
    move.l ChunkWidth,d6
    move.l ChunkHeight,d7
    sub.l #1,d7
 
    move.l d2,d5
    move.l #0,d3
    
    ;d0 = temp
    ;d1 = pixel color or x location of pixel
    ;d2 = y location of pixel
    ;d3 = width of chunk counter (x)
    ;d4 = padding
    ;d6 = width of chunk
    ;d7 = height of chunk counter (y)
    ;a2 = current byte address for pixel color data
OuterLoop: 
InnerLoop:
    move.l #0,d1

    ;Set d1 pixel color
    move.b (a2)+,d1
    lsl.l #NUMBER_OF_BITS_IN_BYTE,d1
    move.b (a2)+,d1
    lsl.l #NUMBER_OF_BITS_IN_BYTE,d1
    move.b (a2)+,d1
    
    ;Skip background color
    cmp.l #BMP_32_BITS,d5
    bne SkipAddByte
    add.l #1,a2
    cmp.l #$003A7B47,d1
    beq SkipDraw

SkipAddByte:
    move.l #PEN_COLOR_TRAP_CODE,d0
    trap #15
    
    ;Draw pixel at location (d1,d2)
    move.l d3,d1  
    move.l d7,d2
    add.l DisplayTopLeftX,d1
    add.l DisplayTopLeftY,d2
    move.l #DRAW_PIXEL_TRAP_CODE,d0
    trap #15
    
SkipDraw:
    add.l #1,d3
    cmp.l d3,d6
    bgt InnerLoop
    add.l d4,a2 
    move.l #0,d3
    dbra d7,OuterLoop
    
Done rts
    
PrintExceedDisplaySizeTextError:
    lea ExceedDisplaySizeText,a1
    bra PrintError

PrintNegativeParameterError:
    lea NegativeParameterErrorText,a1
    bra PrintError

PrintFileTypeErrorText: 
    lea FileTypeErrorText,a1
    bra PrintError

PrintChunkExceedsBitmapSizeText:
    lea ChunkExceedsBitmapSizeText,a1
    bra PrintError

PrintColorPaletteError:
    lea ColorPaletteErrorText,a1
    bra PrintError

PrintNumberOfBitsPerPixelError:
    lea IncorrectNumberOfBitsPerPixel,a1
    
PrintError:
    move.l #DISPLAY_STRING_TRAP_CODE,d0
    trap #15
    bra Done
    
ConvertToBigEndian:
    ror.w #NUMBER_OF_BITS_IN_BYTE,d0
    swap.w d0
    ror.w #NUMBER_OF_BITS_IN_BYTE,d0
    rts

Start_Of_Background_Data INCBIN "images\corner_rainbow.bmp"
End_Of_Background_Data
Start_Of_Player1_Data INCBIN "images\Tank_Sprites.bmp"
End_Of_Player1_Data
Start_Of_Start_Screen_Data INCBIN "images\StartScreen.bmp"
End_Of_Start_Screen_Data
Start_Of_Blue_Screen_Data INCBIN "images\BlueEndScreen.bmp"
End_Of_Blue_Screen_Data
Start_Of_Red_Screen_Data INCBIN "images\RedEndScreen.bmp"
End_Of_Red_Screen_Data
END_SCREEN_WIDTH                EQU 350
END_SCREEN_HEIGHT               EQU 200
OUTPUT_WIDTH                    EQU 800
OUTPUT_HEIGHT                   EQU 600
SET_OUTPUT_RESOLUTION_TRAP_CODE EQU 33
EXPECTED_BMP_ID                 EQU $424D
BITMAP_WIDTH_OFFSET_LOCATION    EQU $12
BITMAP_HEIGHT_OFFSET_LOCATION   EQU $16
NUM_OF_BITS_PER_PIXEL_OFFSET    EQU $1C
BMP_24_BITS                     EQU $1800
BMP_32_BITS                     EQU $2000
PIXEL_ARRAY_OFFSET_OFFSET_LOC   EQU $A
NUM_OF_PALEtTE_COLORS_OFFSET    EQU $2E
NUMBER_OF_BYTES_PER_PIXEL_24    EQU 3
NUMBER_OF_BYTES_PER_PIXEL_32    EQU 4
PEN_COLOR_TRAP_CODE             EQU 80   
DRAW_PIXEL_TRAP_CODE            EQU 82
NUMBER_OF_BITS_IN_BYTE          EQU 8
DISPLAY_STRING_TRAP_CODE        EQU 13
ALIGNMENT_4_BYTES               EQU 4

ChunkExceedsBitmapSizeText dc.b '> Error: Parameter chunk size and chunk coordinates exceed the bounds of the bitmap',0
ExceedDisplaySizeText dc.b '> Error: Parameter chunk size and display coordinates exceed display resolution.',0
FileTypeErrorText dc.b '> Error: Not a bitmap file.',0
IncorrectNumberOfBitsPerPixel dc.b '> Error: Bitmap must be 24 bits per pixel.',0
NegativeParameterErrorText dc.b '> Error: Parameter cannot be negative.',0
ColorPaletteErrorText dc.b '> Error: Subroutine does not support color palette bitmaps',0
ChunkWidth ds.l 1
ChunkHeight ds.l 1
ChunkTopLeftX ds.l 1
ChunkTopLeftY ds.l 1
DisplayTopLeftX ds.l 1
DisplayTopLeftY ds.l 1



























*~Font name~Courier New~
*~Font size~10~
*~Tab type~1~
*~Tab size~4~
