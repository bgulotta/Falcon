.SEGMENT "CODE"

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
    STA Temp + 1    
    LDA #$03        ; Divide x coordinates by 8
    STA Iterations
    JSR DIVIDE
    LDA Temp 
    STA TileX
    LDA Temp + 1
    STA TileX + 1
    LDA #$01        ; Divide x coordinates by 16
    STA Iterations
    JSR DIVIDE
    LDA Temp 
    STA MetaTileX
    LDA Temp + 1
    STA MetaTileX + 1
    LDA #$01        ; Divide x coordinates by 32
    STA Iterations
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
    STA Iterations
    JSR DIVIDE
    LDA Temp 
    STA TileY
    LDA Temp + 1
    STA TileY + 1
    LDA #$01        ; Divide y coordinates by 16
    STA Iterations
    JSR DIVIDE
    LDA Temp 
    STA MetaTileY
    LDA Temp + 1
    STA MetaTileY + 1
    LDA #$01        ; Divide y coordinates by 32
    STA Iterations
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
    STA Iterations
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
    STA Iterations
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
    STA Iterations
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
; x = number of iterations
;------------------------------
DIVIDE:
DIVIDE_LOOP:
    LSR Temp + 1
    ROR Temp
    DEC Iterations
    BNE DIVIDE_LOOP
    RTS

;------------------------------
; This routine will divide a 16
; bit number by 2 x times where
; x = number of iterations
;------------------------------
MULTIPLY:
MULTIPLY_LOOP:
    ASL Temp
    ROL Temp + 1
    DEC Iterations
    BNE MULTIPLY_LOOP
    RTS