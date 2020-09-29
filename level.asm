
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
    JSR META_META_TILE_INDEX_PTR_ZP
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
    JSR META_META_TILE_INDEX_PTR_ZP    
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
    JSR META_META_TILE_INDEX_PTR_ZP    
    RTS

RESET_PPUADDRESS:
    LDA #$00
    STA PPUAddress
    LDY #SCREEN_DATA::Index
    LDA (SCREEN_PTR), Y
    AND #$01
    BNE PPUADDRESS_NEXT_NAMETABLE 
    LDA #$20
    JMP RESET_PPUADDRESS_EXIT
PPUADDRESS_NEXT_NAMETABLE:
    LDA #$24
RESET_PPUADDRESS_EXIT:
    STA PPUAddress + 1
    RTS

META_META_TILE_INDEX_PTR_ZP:
    LDY #SCREEN_DATA::MetaMetaTileIndex
    LDA (SCREEN_PTR), Y
    STA META_META_TILE_INDEX_PTR
    LDY #SCREEN_DATA::MetaMetaTileIndex + 1
    LDA (SCREEN_PTR), Y
    STA META_META_TILE_INDEX_PTR + 1
META_META_TILE_INDEX_PTR_EXIT:
    RTS

FIRST_META_META_TILE:
    LDA #$00  ; 60 meta meta tiles make up a screen
    STA MetaMetaTileIndex ; MetaMetaTile Index
    JSR RESET_PPUADDRESS
    RTS 

NEXT_META_META_TILE:
    INC MetaMetaTileIndex
    JSR META_META_TILE_INDEX_TO_PPUADDRESS
    RTS

PREV_META_META_TILE:
    DEC MetaMetaTileIndex
    JSR META_META_TILE_INDEX_TO_PPUADDRESS
    RTS 

LAST_META_META_TILE:
    LDA #$3B  ; 60 meta meta tiles make up a screen
    STA MetaMetaTileIndex ; MetaMetaTile Index
    JSR META_META_TILE_INDEX_TO_PPUADDRESS
    RTS 

META_META_TILE_INDEX_TO_PPUADDRESS:
    JSR RESET_PPUADDRESS
    LDA MetaMetaTileIndex
    STA Temp 
    LDA #$00
    STA Temp + 1 
    JSR MULTIPLY_BY_16
    CLC 
    LDA PPUAddress
    ADC Temp 
    STA PPUAddress
    LDA PPUAddress + 1
    ADC Temp + 1
    STA PPUAddress + 1 
    RTS 

NEXT_PPUADDRESS:
    CLC
    LDA PPUAddress
    ADC #$01
    STA PPUAddress
    LDA PPUAddress + 1
    ADC #$00
    STA PPUAddress + 1
    RTS

SCREEN_TO_PPU: 
    JSR LAST_META_META_TILE
    LDA MetaMetaTileIndex 
METAMETA_TILE_LOOP:
    CMP #$1E
    BCC RENDER_META_META_TILE
SELECT_MIRRORED_TILE:
    SEC 
    LDA #$3B 
    SBC MetaMetaTileIndex
RENDER_META_META_TILE:
    JSR META_META_TILE_TO_PPU
    JSR PREV_META_META_TILE
    LDA MetaMetaTileIndex 
    BPL METAMETA_TILE_LOOP
    RTS

META_META_TILE_TO_PPU:
    TAY ; MetaMetaTileIndex
    LDA (META_META_TILE_INDEX_PTR), Y
    STA MetaMetaTileSetIndex
    TAY
    LDA #$00
    STA Temp4
META_META_TILE_LOOP:
    LDA (META_META_TILESET_PTR), Y
    TAY 
META_TILE_LOOP:
    LDA (META_TILESET_PTR), Y
    STA Tile    
    JSR TILE_TO_PPU
    JSR NEXT_PPUADDRESS
    INY 
    LDA Temp4
    CMP #$0F  ; Have we finished all 16 tiles?
    BCS META_META_TILE_TO_PPU_EXIT
    INC Temp4
    EOR Temp4 
    AND #$04  
    BEQ META_TILE_LOOP ; are we finished with this meta tile?
    INC MetaMetaTileSetIndex
    LDA MetaMetaTileSetIndex
    TAY 
    JMP META_META_TILE_LOOP
META_META_TILE_TO_PPU_EXIT:
    RTS

TILE_TO_PPU:
 
    LDA #$09
    CMP NumCommands
    BCC TILE_TO_PPU ; make sure we aren't overloading the NMI
    JSR BUF_DIF
    CMP #$7D        ; make sure we have enough bytes free in the buffer
    BCS TILE_TO_PPU

    LDA #$01
    JSR WR_BUF
    LDA PPUAddress + 1
    JSR WR_BUF
    LDA PPUAddress  
    JSR WR_BUF
    LDA Tile 
    JSR WR_BUF
    JSR CMD_SET
    RTS