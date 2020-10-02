
LEVEL_INIT:
    TAX
    LDA #.LOBYTE(Levels)    ; Store level 
    STA LEVEL_PTR           ; in zero page
    LDA #.HIBYTE(Levels)
    STA LEVEL_PTR + 1
LEVEL_INIT_LOOP:
    DEX
    BMI LEVEL_INIT_EXIT
    CLC
    LDA LEVEL_PTR           ; Incrementing the ACTOR_PTR by
    ADC #.SIZEOF(Level)     ; the size of the Actor object
    LDA LEVEL_PTR + 1
    ADC #$00
    JMP LEVEL_INIT_LOOP
LEVEL_INIT_EXIT:
    JSR SET_TILESET_ZP
    JSR SET_SCREEN_FIRST
    JSR SCREEN_TO_PPU
    ;JSR SET_SCREEN_NEXT
    ;JSR SCREEN_TO_PPU
    RTS

SET_TILESET_ZP:
    LDY #LEVEL_DATA::MetaTileSet
    LDA (LEVEL_PTR), Y
    STA META_TILESET_PTR
    LDY #LEVEL_DATA::MetaTileSet + 1
    LDA (LEVEL_PTR), Y
    STA META_TILESET_PTR + 1
    LDY #LEVEL_DATA::MetaMetaTileSet
    LDA (LEVEL_PTR), Y
    STA META_META_TILESET_PTR
    LDY #LEVEL_DATA::MetaMetaTileSet + 1
    LDA (LEVEL_PTR), Y
    STA META_META_TILESET_PTR + 1
SET_TILESET_ZP_EXIT:
    RTS

SET_SCREEN_FIRST:
    LDY #LEVEL_DATA::Screens
    LDA (LEVEL_PTR), Y
    STA SCREEN_PTR
    LDY #LEVEL_DATA::Screens + 1
    LDA (LEVEL_PTR), Y
    STA SCREEN_PTR + 1
SET_SCREEN_FIRST_EXIT:
    JSR CALCULATE_BASE_PPUADDRESS
    JSR SET_META_META_TILES_PTR
    RTS

SET_SCREEN_NEXT:
    LDY #SCREEN_DATA::NextScreen
    LDA (SCREEN_PTR), Y
    PHA
    LDY #SCREEN_DATA::NextScreen + 1
    LDA (SCREEN_PTR), Y
    STA SCREEN_PTR + 1
    PLA 
    STA SCREEN_PTR
SET_SCREEN_NEXT_EXIT:
    JSR CALCULATE_BASE_PPUADDRESS
    JSR SET_META_META_TILES_PTR    
    RTS

SET_SCREEN_PREV:
    LDY #SCREEN_DATA::PrevScreen
    LDA (SCREEN_PTR), Y
    PHA
    LDY #SCREEN_DATA::PrevScreen + 1
    LDA (SCREEN_PTR), Y
    STA SCREEN_PTR + 1
    PLA 
    STA SCREEN_PTR
SET_SCREEN_PREV_EXIT:
    JSR CALCULATE_BASE_PPUADDRESS
    JSR SET_META_META_TILES_PTR    
    RTS

SET_META_META_TILES_PTR:
    LDY #SCREEN_DATA::MetaMetaTiles
    LDA (SCREEN_PTR), Y
    STA META_META_TILES_PTR
    LDY #SCREEN_DATA::MetaMetaTiles + 1
    LDA (SCREEN_PTR), Y
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
FIRST_META_META_TILE:
    LDA #$00  ; 60 meta meta tiles make up a screen
    JSR SELECT_META_META_TILE
    RTS 

;--------------------------------------------------;
;                                                  ;
;                                                  ;
;                                                  ;
;                                                  ;
;                                                  ;
;--------------------------------------------------;
NEXT_META_META_TILE:
    INC MetaMetaTile + MetaMetaTile::Index
    LDA MetaMetaTile + MetaMetaTile::Index
    JSR SELECT_META_META_TILE
    RTS

;--------------------------------------------------;
;                                                  ;
;                                                  ;
;                                                  ;
;                                                  ;
;                                                  ;
;--------------------------------------------------;
PREV_META_META_TILE:
    DEC MetaMetaTile + MetaMetaTile::Index
    LDA MetaMetaTile + MetaMetaTile::Index
    JSR SELECT_META_META_TILE
    RTS 

;--------------------------------------------------;
;                                                  ;
;                                                  ;
;                                                  ;
;                                                  ;
;                                                  ;
;--------------------------------------------------;
LAST_META_META_TILE:
    LDA #$37  ; 56 meta meta tiles make up a screen (2 rows of tiles will be dedicated to a score/hud area)
    JSR SELECT_META_META_TILE
    RTS 

;--------------------------------------------------;
;                                                  ;
;                                                  ;
;                                                  ;
;                                                  ;
;                                                  ;
;--------------------------------------------------;
SELECT_META_META_TILE:
    STA MetaMetaTile + MetaMetaTile::Index   
    STA MetaMetaTile + MetaMetaTile::TileData
SET_META_META_TILESET_INDEX:
    CMP #$1C
    BCC SET_META_META_TILESET_INDEX_EXIT
SELECT_MIRRORED_TILE:
    SEC 
    LDA #$37 
    SBC MetaMetaTile + MetaMetaTile::Index
SET_META_META_TILESET_INDEX_EXIT:
    TAY ; MetaMetaTileIndex
    LDA (META_META_TILES_PTR), Y
    STA MetaMetaTile + MetaMetaTile::MetaMetaTilesetIndex
SET_META_META_TILE_DATA:
    LDA #$08
    STA Temp2 
    LDA .LOBYTE(MetaMetaTile + MetaMetaTile::TileData)
    STA TILE_PTR
    LDA .HIBYTE(MetaMetaTile + MetaMetaTile::TileData)
    STA TILE_PTR + 1
    JSR SET_TILE_COORDINATES
    RTS 

;--------------------------------------------------;
;    This subroutine will set the TileIndex        ;
;    and TileCoordinates for the selected tile or  ;
;    meta tile                                     ;
;--------------------------------------------------;
SET_TILE_DATA:
    STA Temp2 
    PHA 
    JSR SET_TILE_INDEX
    PLA
    STA Temp2
    JSR SET_TILE_COORDINATES
SET_TILE_DATA_EXIT:
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
    JSR SELECT_META_TILE
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
    ADC MetaMetaTile + MetaMetaTile::MetaMetaTilesetIndex
    TAY 
    LDA (META_META_TILESET_PTR), Y
    TAY 
    STA MetaTile + MetaTile::MetaTilesetIndex
SELECT_META_TILE_EXIT:
    LDA .LOBYTE(MetaMetaTile + MetaMetaTile::TileData)
    STA PARENT_TILE_PTR
    LDA .HIBYTE(MetaMetaTile + MetaMetaTile::TileData)
    STA PARENT_TILE_PTR + 1
    LDA .LOBYTE(MetaTile + MetaTile::TileData)
    STA TILE_PTR
    STA CHILD_TILE_PTR
    LDA .HIBYTE(MetaTile + MetaTile::TileData)
    STA TILE_PTR + 1
    STA CHILD_TILE_PTR + 1
    LDA #$10
    JSR SET_TILE_DATA
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
    JSR SELECT_TILE
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
    ADC MetaTile + MetaTile::MetaTilesetIndex
    TAY 
    LDA (META_TILESET_PTR), Y
    STA Tile + Tile::Tile
    RTS 

;--------------------------------------------------;
;                                                  ;
;  This subroutine will take a tile MetaMetaTile,  ;
;  MetaTile, or Tile with a given index and        ;
;  calculate the tile's row and col index.         ;
;  Inputs: NumCols = Temp2, TILE_PTR               ; 
;                                                  ;
;  Formulas:                                       ;
;   Y=Row=TileIndex/NumCols                        ;
;   X=Col=TileIndex - NumCols*Y                    ;
;--------------------------------------------------;
SET_TILE_COORDINATES:
CALCULATE_TILE_ROW:
    LDY #TILE_DATA::TileIndex
    STA (TILE_PTR), Y
    STA Temp
    LDY #TILE_DATA::TileIndex + 1
    STA (TILE_PTR), Y
    STA Temp + 1
    LDA Temp2 
    LSR A 
    PHA 
    STA NumIterations
    JSR DIVIDE
    LDA Temp
    LDY #TILE_DATA::Row
    STA (TILE_PTR), Y
CALCULATE_TILE_COL:
    STA Temp
    LDA #$00
    STA Temp + 1
    PLA 
    STA NumIterations 
    JSR MULTIPLY 
    SEC 
    LDY #TILE_DATA::TileIndex
    STA (TILE_PTR), Y
    SBC Temp
    LDY #TILE_DATA::Column
    STA (TILE_PTR), Y
    RTS 

;--------------------------------------------------;
;                                                  ;
;  This subroutine will take a tile MetaMetaTile   ;
;  or MetaTile and calculate the tile index        ;
;  of the first tile contained within the tile.    ; 
;  Inputs: NumCols = Temp2, PARENT_TILE_PTR        ; 
;          CHILD_TILE_PTR                          ;
;  Formulas:                                       ;
;   TileIndex = NumCols*(Column + Row)             ;
;                                                  ;
;--------------------------------------------------;
SET_TILE_INDEX:
    CLC 
    LDY #TILE_DATA::Column
    LDA (PARENT_TILE_PTR), Y
    LDY #TILE_DATA::Row
    ADC (PARENT_TILE_PTR), Y
    STA Temp 
    LDA #$00
    STA Temp + 1
    LDA Temp2 
    LSR A 
    STA NumIterations 
    JSR MULTIPLY
    LDY #TILE_DATA::TileIndex
    LDA (CHILD_TILE_PTR), Y
    RTS 