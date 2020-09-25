.SEGMENT "CODE"

PPUADDRESS_TO_TILE_INDICES:

    JSR PPUADDRESS_TO_TILE_INDEX
    JSR TILE_INDEX_TO_META_TILE_INDEX
    JSR META_TILE_INDEX_TO_METAMETA_TILE_INDEX

    RTS

PPUADDRESS_TO_TILE_INDEX:

    LDA PPUAddress 
    STA TileIndex 
    LDA PPUAddress + 1
    AND #$0F
    STA TileIndex + 1

    JSR TILE_INDEX_TO_TILEXY

    RTS 

TILE_INDEX_TO_TILEXY:

    LDA TileIndex
    STA Temp  
    LDA TileIndex + 1
    STA Temp + 1
    
    JSR DIVIDE_BY_32
    LDA Temp 
    STA TileY
    LDA Temp + 1
    STA TileY + 1

    LDA TileIndex
    STA Temp  
    LDA TileIndex + 1
    STA Temp + 1

    JSR DIVIDE_BY_30
    LDA Temp 
    STA TileX
    LDA Temp + 1
    STA TileX + 1
    RTS

TILE_INDEX_TO_META_TILE_INDEX:

    LDA TileIndex 
    STA Temp
    LDA TileIndex + 1
    STA Temp + 1  
    JSR DIVIDE_BY_4
    
    LDA Temp 
    STA MetaTileIndex
    LDA Temp + 1
    STA MetaTileIndex + 1

    JSR META_TILE_INDEX_TO_TILEXY

    RTS

META_TILE_INDEX_TO_TILEXY:

    LDA MetaTileIndex
    STA Temp  
    LDA MetaTileIndex + 1
    STA Temp + 1
    
    JSR DIVIDE_BY_16
    LDA Temp 
    STA MetaTileY
    LDA Temp + 1
    STA MetaTileY + 1

    LDA MetaTileIndex
    STA Temp  
    LDA MetaTileIndex + 1
    STA Temp + 1

    JSR DIVIDE_BY_15
    LDA Temp 
    STA MetaTileX
    LDA Temp + 1
    STA MetaTileX + 1

    RTS

META_TILE_INDEX_TO_METAMETA_TILE_INDEX:

    LDA MetaTileIndex 
    STA Temp
    LDA MetaTileIndex + 1
    STA Temp + 1  
    JSR DIVIDE_BY_4
    
    LDA Temp 
    STA MetaMetaTileIndex
    LDA Temp + 1
    STA MetaMetaTileIndex + 1

    JSR METAMETA_TILE_INDEX_TO_TILEXY

    RTS

METAMETA_TILE_INDEX_TO_TILEXY:

    LDA MetaMetaTileIndex
    STA Temp  
    LDA MetaMetaTileIndex + 1
    STA Temp + 1
    
    JSR DIVIDE_BY_8
    LDA Temp 
    STA MetaMetaTileY
    LDA Temp + 1
    STA MetaMetaTileY + 1

    LDA MetaMetaTileIndex
    STA Temp  
    LDA MetaMetaTileIndex + 1
    STA Temp + 1

    JSR DIVIDE_BY_7
    LDA Temp 
    STA MetaMetaTileX
    LDA Temp + 1
    STA MetaMetaTileX + 1

    RTS

WORLD_COORDINATES_TO_TILE_INDICES:

    JSR WORLD_COORDINATES_TO_TILE_INDEX
    JSR TILE_INDEX_TO_META_TILE_INDEX
    JSR META_TILE_INDEX_TO_METAMETA_TILE_INDEX

    RTS

WORLD_COORDINATES_TO_TILE_INDEX:

    LDA TempX 
    STA Temp 
    LDA TempX + 1
    STA Temp + 1    
    JSR DIVIDE_BY_8

    LDA Temp
    STA Temp2 
    LDA Temp + 1
    STA Temp2 + 1

    LDA TempY 
    STA Temp 
    LDA TempY + 1
    STA Temp + 1    
    JSR DIVIDE_BY_8
    JSR MULTIPLY_BY_32 

    CLC             ; Temp + TileX = TileIndex
    LDA Temp 
    ADC Temp2 
    STA TileIndex
    LDA Temp + 1
    ADC Temp2 + 1
    STA TileIndex + 1

    JSR TILE_INDEX_TO_TILEXY

    RTS

;---------------------------------------
; Subroutine will take an X and Y 
; coordinates and convert it into 
; both a metameta tile index and 
; a metatile index for background 
; rendering, collision detection etc.
; Index = Columns * Y + X
;---------------------------------------
COORDINATES_TO_TILE_INDICES: ; TODO: Clean this code UP

    ; LDA #$03        ; Divide x coordinates by 8
    ; STA Loop
    ; JSR DIVIDE
    ; LDA Temp 
    ; STA TileX
    ; LDA Temp + 1
    ; STA TileX + 1
    ; LDA #$01        ; Divide x coordinates by 16
    ; STA Loop
    ; JSR DIVIDE
    ; LDA Temp 
    ; STA MetaTileX
    ; LDA Temp + 1
    ; STA MetaTileX + 1
    ; LDA #$01        ; Divide x coordinates by 32
    ; STA Loop
    ; JSR DIVIDE
    ; LDA Temp 
    ; STA MetaMetaTileX
    ; LDA Temp + 1 
    ; STA MetaMetaTileX + 1

    ; LDA TempY 
    ; STA Temp 
    ; LDA TempY + 1
    ; STA Temp + 1    
    ; LDA #$03        ; Divide y coordinates by 8
    ; STA Loop
    ; JSR DIVIDE
    ; LDA Temp 
    ; STA TileY
    ; LDA Temp + 1
    ; STA TileY + 1
    ; LDA #$01        ; Divide y coordinates by 16
    ; STA Loop
    ; JSR DIVIDE
    ; LDA Temp 
    ; STA MetaTileY
    ; LDA Temp + 1
    ; STA MetaTileY + 1
    ; LDA #$01        ; Divide y coordinates by 32
    ; STA Loop
    ; JSR DIVIDE
    ; LDA Temp 
    ; STA MetaMetaTileY
    ; LDA Temp + 1 
    ; STA MetaMetaTileY + 1

    ; ; Now that the global world coordinates are converted to tile coordinates
    ; ; we can calculated the tile indices 

    ; LDA TileY 
    ; STA Temp 
    ; LDA TileY + 1
    ; STA Temp + 1
    ; LDA #$05        ; Multiply y by 32
    ; STA Loop
    ; JSR MULTIPLY    
    
    ; CLC             ; Temp + TileX = TileIndex
    ; LDA Temp 
    ; ADC TileX 
    ; STA TileIndex
    ; LDA Temp + 1
    ; ADC TileX + 1
    ; STA TileIndex + 1

    ; LDA MetaTileY 
    ; STA Temp 
    ; LDA MetaTileY + 1
    ; STA Temp + 1
    ; LDA #$04        ; Multiply y by 16
    ; STA Loop
    ; JSR MULTIPLY    

    ; CLC             ; Temp + MetaTileX = MetaTileIndex
    ; LDA Temp 
    ; ADC MetaTileX 
    ; STA MetaTileIndex
    ; LDA Temp + 1
    ; ADC MetaTileX + 1
    ; STA MetaTileIndex + 1
    
    ; LDA MetaMetaTileY 
    ; STA Temp 
    ; LDA MetaMetaTileY + 1
    ; STA Temp + 1
    ; LDA #$03        ; Multiply y by 8
    ; STA Loop
    ; JSR MULTIPLY    

    ; CLC             ; Temp + MetaMetaTileX = MetaMetaTileIndex
    ; LDA Temp 
    ; ADC MetaMetaTileX 
    ; STA MetaMetaTileIndex
    ; LDA Temp + 1
    ; ADC MetaMetaTileX + 1
    ; STA MetaMetaTileIndex + 1

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

DIVIDE_BY_4:
    LDA #$02        ; Divide by 4
    STA Loop
    JSR DIVIDE
    RTS 

DIVIDE_BY_7:
    CLC         ; Divide by 7 = Add 8 / 8
    LDA Temp 
    ADC #$08
    STA Temp 
    LDA Temp + 1 
    ADC #$00 
    STA Temp + 1
    JSR DIVIDE_BY_8  
    RTS 

DIVIDE_BY_8:
    LDA #$03        ; Divide by 8
    STA Loop
    JSR DIVIDE
    RTS 

DIVIDE_BY_15:
    CLC         ; Divide by 15 = Add 16 / 16
    LDA Temp 
    ADC #$10
    STA Temp 
    LDA Temp + 1 
    ADC #$00 
    STA Temp + 1
    JSR DIVIDE_BY_16  
    RTS 

DIVIDE_BY_16:
    LDA #$04        ; Divide by 32
    STA Loop
    JSR DIVIDE
    RTS 

DIVIDE_BY_32:
    LDA #$05        ; Divide by 32
    STA Loop
    JSR DIVIDE
    RTS 

DIVIDE_BY_30:
    CLC         ; Divide by 32 = Add 64 / 32
    LDA Temp 
    ADC #$40
    STA Temp 
    LDA Temp + 1 
    ADC #$00 
    STA Temp + 1
    JSR DIVIDE_BY_32  
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

MULTIPLY_BY_32:
    LDA #$05        
    STA Loop
    JSR MULTIPLY    
    RTS 