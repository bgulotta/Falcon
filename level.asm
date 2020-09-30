
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
    JSR SET_SCREEN_NEXT
    JSR SCREEN_TO_PPU
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
    LDA #$3B  ; 60 meta meta tiles make up a screen
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
SET_META_META_TILESET_INDEX:
    CMP #$1E
    BCC SET_META_META_TILESET_INDEX_EXIT
SELECT_MIRRORED_TILE:
    SEC 
    LDA #$3B 
    SBC MetaMetaTile + MetaMetaTile::Index
SET_META_META_TILESET_INDEX_EXIT:
    TAY ; MetaMetaTileIndex
    LDA (META_META_TILES_PTR), Y
    STA MetaMetaTile + MetaMetaTile::MetaMetaTilesetIndex
    RTS 
    