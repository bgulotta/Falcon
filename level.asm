
LEVEL_INIT:
    STA Level
    TAX 
    LDA MetaMetaTileSetLo, X 
    STA META_META_TILESET_PTR
    LDA MetaMetaTileSetHi, X 
    STA META_META_TILESET_PTR + 1
    LDA MetaTileSetLo, X 
    STA META_TILESET_PTR
    LDA MetaTileSetHi, X 
    STA META_TILESET_PTR + 1
    LDA #$00 
    STA Screen
    JSR CALCULATE_BASE_PPUADDRESS
    JSR SET_META_META_TILES_PTR
    JSR SCREEN_TO_PPU
    RTS

SET_SCREEN_PREV:
    DEC Screen
    JSR CALCULATE_BASE_PPUADDRESS
    JSR SET_META_META_TILES_PTR
    RTS 

SET_SCREEN_NEXT:
    INC Screen
    JSR CALCULATE_BASE_PPUADDRESS
    JSR SET_META_META_TILES_PTR
    RTS 

SET_META_META_TILES_PTR:    
    CLC
    LDA Level
    LDX Screen
    ADC MULT16, X 
    TAX
    LDA MetaMetaTilesetIndexLo, X
    STA META_META_TILES_PTR
    LDA MetaMetaTilesetIndexHi, X
    STA META_META_TILES_PTR + 1
META_META_TILES_PTR_EXIT:
    RTS

;--------------------------------------------------;
;                                                  ;
;                                                  ;
;                                                  ;
;                                                  ;
;                                                  ;
;--------------------------------------------------;
LAST_META_META_TILE_IN_COL:
    CLC 
    ADC #$30
    STA MetaMetaTile + MetaTile::Index 
    JSR SELECT_META_META_TILE
    RTS 

;--------------------------------------------------;
;                                                  ;
;                                                  ;
;                                                  ;
;                                                  ;
;                                                  ;
;--------------------------------------------------;
PREV_META_META_TILE_ROW_IN_COL:
    SEC 
    LDA MetaMetaTile + MetaTile::Index
    SBC #$08    
    BMI PREV_META_META_TILE_ROW_IN_COL_EXIT
    STA MetaMetaTile + MetaTile::Index
    JSR SELECT_META_META_TILE
PREV_META_META_TILE_ROW_IN_COL_EXIT:
    RTS 

;--------------------------------------------------;
;                                                  ;
;                                                  ;
;                                                  ;
;                                                  ;
;                                                  ;
;--------------------------------------------------;
SELECT_META_META_TILE:
    STA MetaMetaTile + MetaTile::Index   
    STA MetaMetaTile + MetaTile::TileData
SET_META_META_TILESET_INDEX:
    CMP #$1C
    BCC SET_META_META_TILESET_INDEX_EXIT
SELECT_MIRRORED_TILE:
    SEC 
    LDA #$37 
    SBC MetaMetaTile + MetaTile::Index
SET_META_META_TILESET_INDEX_EXIT:
    TAY ; MetaMetaTileIndex
    LDA (META_META_TILES_PTR), Y
    STA MetaMetaTile + MetaTile::TilesetIndex
    RTS 

;--------------------------------------------------;
;  This subroutine will select the first meta      ;
;  tile for the currently selected meta meta tile. ;
;                                                  ;
;                                                  ;
;                                                  ;
;--------------------------------------------------;
FIRST_META_TILE: 
    LDA #$00  ; 4 meta tiles make up a meta meta tile
    JSR SELECT_META_TILE
    RTS 

;--------------------------------------------------;
;                                                  ;
;                                                  ;
;                                                  ;
;                                                  ;
;                                                  ;
;--------------------------------------------------;
NEXT_META_TILE:
    INC MetaTile + MetaTile::Index
    LDA MetaTile + MetaTile::Index
    JSR SELECT_META_TILE
    RTS

;--------------------------------------------------;
;                                                  ;
;                                                  ;
;                                                  ;
;                                                  ;
;                                                  ;
;--------------------------------------------------;
PREV_META_TILE:
    DEC MetaTile + MetaTile::Index
    LDA MetaTile + MetaTile::Index
    BMI PREV_META_TILE_EXIT
    JSR SELECT_META_TILE
PREV_META_TILE_EXIT:
    RTS 

;--------------------------------------------------;
;                                                  ;
;                                                  ;
;                                                  ;
;                                                  ;
;                                                  ;
;--------------------------------------------------;
LAST_META_TILE:
    LDA #$03  ; 4 meta tiles make up a meta meta tile
    JSR SELECT_META_TILE
    RTS 

;--------------------------------------------------;
;                                                  ;
;                                                  ;
;                                                  ;
;                                                  ;
;                                                  ;
;--------------------------------------------------;
SELECT_META_TILE:
    STA MetaTile + MetaTile::Index
SET_META_TILESET_INDEX:
    CLC
    ADC MetaMetaTile + MetaTile::TilesetIndex
    TAY 
    LDA (META_META_TILESET_PTR), Y
    TAY 
    STA MetaTile + MetaTile::TilesetIndex
SELECT_META_TILE_EXIT:
    RTS 

;--------------------------------------------------;
;                                                  ;
;                                                  ;
;                                                  ;
;                                                  ;
;                                                  ;
;--------------------------------------------------;
FIRST_TILE:
    LDA #$00  ; 4 tiles make up a meta tile
    JSR SELECT_TILE
    RTS 

;--------------------------------------------------;
;                                                  ;
;                                                  ;
;                                                  ;
;                                                  ;
;                                                  ;
;--------------------------------------------------;
NEXT_TILE:
    INC Tile + Tile::Index
    LDA Tile + Tile::Index
    JSR SELECT_TILE
    RTS

;--------------------------------------------------;
;                                                  ;
;                                                  ;
;                                                  ;
;                                                  ;
;                                                  ;
;--------------------------------------------------;
PREV_TILE:
    DEC Tile + Tile::Index
    LDA Tile + Tile::Index
    BMI PREV_TILE_EXIT
    JSR SELECT_TILE
PREV_TILE_EXIT:
    RTS 

;--------------------------------------------------;
;                                                  ;
;                                                  ;
;                                                  ;
;                                                  ;
;                                                  ;
;--------------------------------------------------;
LAST_TILE:
    LDA #$03  ; 4 tiles make up a meta tile
    JSR SELECT_TILE
    RTS 

;--------------------------------------------------;
;                                                  ;
;                                                  ;
;                                                  ;
;                                                  ;
;                                                  ;
;--------------------------------------------------;
SELECT_TILE:
    STA Tile + Tile::Index
    CLC
    ADC MetaTile + MetaTile::TilesetIndex
    TAY 
    LDA (META_TILESET_PTR), Y
    STA Tile + Tile::Tile
    RTS 

;--------------------------------------------------;
;    This subroutine will set the TileIndex        ;
;    and TileCoordinates for the selected tile or  ;
;    meta tile                                     ;
;--------------------------------------------------;
;SET_TILE_DATA:
;     STA Temp2 
;     PHA 
;     JSR SET_TILE_INDEX
;     PLA
;     STA Temp2
;     JSR SET_TILE_COORDINATES
; SET_TILE_DATA_EXIT:
;    RTS
    
;--------------------------------------------------;
;                                                  ;
;  This subroutine will take a tile MetaMetaTile,  ;
;  MetaTile, or Tile with a given TileIndex and    ;
;  calculate the tile's row and col index.         ;
;  Inputs: NumCols = Temp2, TILE_PTR               ; 
;                                                  ;
;  Formulas:                                       ;
;   Y=Row=TileIndex/NumCols                        ;
;   X=Col=TileIndex - NumCols*Y                    ;
;--------------------------------------------------;
; SET_TILE_COORDINATES:
; CALCULATE_TILE_ROW:
;     LDY #TILE::TileIndex
;     LDA (TILE_PTR), Y
;     STA Temp
;     LDY #TILE::TileIndex + 1
;     LDA (TILE_PTR), Y
;     STA Temp + 1
;     LDA Temp2 
;     LSR A 
;     PHA 
;     STA NumIterations
;     JSR DIVIDE
;     LDA Temp
;     LDY #TILE::Row
;     STA (TILE_PTR), Y
; CALCULATE_TILE_COL:
;     STA Temp
;     LDA #$00
;     STA Temp + 1
;     PLA 
;     STA NumIterations 
;     JSR MULTIPLY 
;     SEC 
;     LDY #TILE::TileIndex
;     LDA (TILE_PTR), Y
;     SBC Temp
;     LDY #TILE::Column
;     STA (TILE_PTR), Y
;     RTS 

;--------------------------------------------------;
;                                                  ;
;  This subroutine will take a tile MetaMetaTile   ;
;  or MetaTile and calculate the tile index        ;
;  of the first tile contained within the tile.    ; 
;  Inputs: NumCols = Temp2, PARENT_TILE_PTR        ; 
;          CHILD_TILE_PTR                          ;
;  Formulas:                                       ;
;   Child::TileIndex =                             ;
;     2*(NumCols*Parent::Row + Parent::Column)     ;
;                                                  ;
;--------------------------------------------------;
; SET_TILE_INDEX:
; SET_TILE_INDEX_FIRST_TILE:
;     LDY #TILE::Row
;     LDA (PARENT_TILE_PTR), Y
;     STA Temp 
;     LDA #$00
;     STA Temp + 1
;     LDA Temp2 
;     PHA 
;     LSR A 
;     STA NumIterations 
;     JSR MULTIPLY        ; Temp = NumCols*Parent::Row
;     PLA 
;     STA Temp2
;     CLC
;     LDA Temp 
;     LDY #TILE::Column
;     ADC (PARENT_TILE_PTR), Y
;     STA Temp 
;     LDA Temp + 1
;     ADC #$00
;     STA Temp + 1        ; Temp = NumCols*Parent::Row + Parent::Column 
;     LDA #$01
;     STA NumIterations 
;     JSR MULTIPLY
;     LDY #TILE::Index
;     LDA (TILE_PTR), Y
;     BEQ SET_TILE_INDEX_EXIT
;     CMP #$03
;     BCS SET_TILE_INDEX_BOTTOM_RIGHT
;     CMP #$02
;     BCS SET_TILE_INDEX_BOTTOM_LEFT
; SET_TILE_INDEX_TOP_RIGHT:
;     CLC 
;     LDA Temp 
;     ADC #$01
;     STA Temp 
;     LDA Temp + 1 
;     ADC #$00 
;     STA Temp + 1
;     JMP SET_TILE_INDEX_EXIT
; SET_TILE_INDEX_BOTTOM_RIGHT:
;     CLC 
;     LDA Temp2 
;     ADC Temp
;     ADC #$01 
;     STA Temp 
;     LDA #$00 
;     ADC Temp + 1 
;     STA Temp + 1
;     JMP SET_TILE_INDEX_EXIT
; SET_TILE_INDEX_BOTTOM_LEFT:
;     CLC 
;     LDA Temp2 
;     ADC Temp 
;     STA Temp 
;     LDA #$00 
;     ADC Temp + 1 
;     STA Temp + 1
; SET_TILE_INDEX_EXIT:
;     LDA Temp 
;     LDY #TILE::TileIndex
;     STA (TILE_PTR), Y
;     LDA Temp + 1
;     LDY #TILE::TileIndex + 1
;     STA (TILE_PTR), Y
;     RTS 
    