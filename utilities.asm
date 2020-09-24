.SEGMENT "CODE"

TILE_TO_PPU_ADDRESS:
    JSR TILE_TO_TILE_INDEX
    LDA #$00
    STA Temp 
    LDA #$20 
    STA Temp + 1
    LDA TileIndex 
    STA Temp2
    LDA TileIndex + 1
    STA Temp2 + 1
    JSR ADD
    LDA Temp3
    STA PPUAddress
    LDA Temp3
    STA PPUAddress + 1
    RTS

;-----------------------------------------------------------
; Subroutine will take a MetaMetaTileIndex,
; RowIndex (0-15), and ColumnIndex (0-15) 
; within the MetaMetaTile and convert that
; to a tileindex using the formula:
; TileIndex : 
;   (RowIndex * 32) + ColumnIndex + (MetaMetaTileIndex * 4) 
;-----------------------------------------------------------
TILE_TO_TILE_INDEX:
    LDA RowIndex 
    STA Temp
    LDA #$00
    STA Temp + 1
    LDA #$05
    STA Loop
    JSR MULTIPLY    ; RowIndex * 32
    LDA Temp 
    STA Temp2
    LDA Temp + 1 
    STA Temp2 + 1

    LDA MetaMetaTileIndex 
    STA Temp
    LDA #$00
    STA Temp + 1
    LDA #$02
    STA Loop
    JSR MULTIPLY    ; MetaMetaTileIndex * 4
    LDA Temp 
    STA Temp3
    LDA Temp + 1 
    STA Temp3 + 1

    CLC               ; Temp: (RowIndex * 32) + ColumnIndex + (MetaMetaTileIndex * 4)
    LDA Temp2
    ADC Temp3
    ADC ColumnIndex
    STA TileIndex 
    LDA Temp2 + 1
    ADC Temp3 + 1
    STA TileIndex + 1

    RTS

;---------------------------------------
; Subroutine will take an X and Y 
; coordinates and convert it into 
; both a metameta tile index and 
; a metatile index for background 
; rendering, collision detection etc.
; Index = Columns * Y + X
;---------------------------------------
COORDINATES_TO_INDICES:

    LDA TempX 
    STA Temp 
    LDA TempX + 1
    STA ScreenIndex
    LDA #$00
    STA Temp + 1    
    LDA #$03        ; Divide x coordinates by 8
    STA Loop
    JSR DIVIDE
    LDA Temp 
    STA TileX
    LDA Temp + 1
    STA TileX + 1
    LDA #$01        ; Divide x coordinates by 16
    STA Loop
    JSR DIVIDE
    LDA Temp 
    STA MetaTileX
    LDA Temp + 1
    STA MetaTileX + 1
    LDA #$01        ; Divide x coordinates by 32
    STA Loop
    JSR DIVIDE
    LDA Temp 
    STA MetaMetaTileX
    LDA Temp + 1 
    STA MetaMetaTileX + 1

    LDA TempY 
    STA Temp 
    LDA TempY + 1
    STA Temp + 1    
    LDA #$03        ; Divide y coordinates by 8
    STA Loop
    JSR DIVIDE
    LDA Temp 
    STA TileY
    LDA Temp + 1
    STA TileY + 1
    LDA #$01        ; Divide y coordinates by 16
    STA Loop
    JSR DIVIDE
    LDA Temp 
    STA MetaTileY
    LDA Temp + 1
    STA MetaTileY + 1
    LDA #$01        ; Divide y coordinates by 32
    STA Loop
    JSR DIVIDE
    LDA Temp 
    STA MetaMetaTileY
    LDA Temp + 1 
    STA MetaMetaTileY + 1

    ; Now that the global world coordinates are converted to tile coordinates
    ; we can calculated the tile indices 

    LDA TileY 
    STA Temp 
    LDA TileY + 1
    STA Temp + 1
    LDA #$05        ; Multiply y by 32
    STA Loop
    JSR MULTIPLY    
    
    CLC             ; Temp + TileX = TileIndex
    LDA Temp 
    ADC TileX 
    STA TileIndex
    LDA Temp + 1
    ADC TileX + 1
    STA TileIndex + 1

    LDA MetaTileY 
    STA Temp 
    LDA MetaTileY + 1
    STA Temp + 1
    LDA #$04        ; Multiply y by 16
    STA Loop
    JSR MULTIPLY    

    CLC             ; Temp + MetaTileX = MetaTileIndex
    LDA Temp 
    ADC MetaTileX 
    STA MetaTileIndex
    LDA Temp + 1
    ADC MetaTileX + 1
    STA MetaTileIndex + 1
    
    LDA MetaMetaTileY 
    STA Temp 
    LDA MetaMetaTileY + 1
    STA Temp + 1
    LDA #$03        ; Multiply y by 8
    STA Loop
    JSR MULTIPLY    

    CLC             ; Temp + MetaMetaTileX = MetaMetaTileIndex
    LDA Temp 
    ADC MetaMetaTileX 
    STA MetaMetaTileIndex
    LDA Temp + 1
    ADC MetaMetaTileX + 1
    STA MetaMetaTileIndex + 1

    RTS

;------------------------------
; This routine will divide a 16
; bit number by 2 x times where
; x = number of Loop
;------------------------------
DIVIDE:
DIVIDE_LOOP:
    LSR Temp + 1
    ROR Temp
    DEC Loop
    BNE DIVIDE_LOOP
    RTS

;------------------------------
; This routine will divide a 16
; bit number by 2 x times where
; x = number of Loop
;------------------------------
MULTIPLY:
MULTIPLY_LOOP:
    ASL Temp
    ROL Temp + 1
    DEC Loop
    BNE MULTIPLY_LOOP
    RTS

;------------------------------
; This will take to numbers stored
; in Temp, Temp2 and store the
; result in Temp3
;------------------------------
ADD:
    CLC 
    LDA Temp 
    ADC Temp2
    STA Temp3
    LDA Temp + 1
    ADC Temp2 + 1
    STA Temp3 + 1
    RTS

