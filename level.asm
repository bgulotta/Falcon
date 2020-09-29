
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
    JSR SET_SCREEN_ZP
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

SET_SCREEN_ZP:
    LDY #LEVEL_DATA::Screens
    LDA (LEVEL_PTR), Y
    STA SCREEN_PTR
    LDY #LEVEL_DATA::Screens + 1
    LDA (LEVEL_PTR), Y
    STA SCREEN_PTR + 1
SET_SCREEN_ZP_EXIT:
    JSR META_META_TILE_INDEX_PTR_ZP
    JSR RESET_PPUADDRESS
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

SCREEN_TO_PPU: 
    LDA #$3B  ; 60 meta meta tiles make up a screen
    STA Temp6 ; MetaMetaTile Index
METAMETA_TILE_LOOP:
    LDA Temp6 
    CMP #$1E
    BCC SELECT_METAMETA_TILE
SELECT_MIRRORED_TILE:
    SEC 
    LDA Temp6 
    SBC #$1E
SELECT_METAMETA_TILE:
    JSR META_META_TILE_TO_PPU
    DEC Temp6
    BNE METAMETA_TILE_LOOP
    RTS

META_META_TILE_TO_PPU:
    PHA
    JSR META_META_TILE_INDEX_TO_PPUADDRESS
    PLA 
    TAY ; MetaMetaTile Index
    LDA (META_META_TILE_INDEX_PTR), Y
    STA Temp5 
    TAY ; MetaMetaTileSet Pointer
META_META_TILE_LOOP:
    LDA (META_META_TILESET_PTR), Y
    STA Temp4
    TAY ; MetaTileSet Pointer
META_TILE_LOOP:
    LDA (META_TILESET_PTR), Y
    ;JSR TILE_TO_PPU
    INY 
    TYA 
    EOR Temp4 
    AND #$04 
    BEQ META_TILE_LOOP
    ; PLA  
    ; TAY 
    ; INY 
    ; TYA 
    ; EOR Temp5 
    ; AND #$04
    ; BEQ META_META_TILE_LOOP
    RTS

META_META_TILE_INDEX_TO_PPUADDRESS:
    JSR RESET_PPUADDRESS
    LDA Temp6
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

TILE_TO_PPU:

    PHA     ; A contains the tile 
 
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
    PLA 
    JSR WR_BUF
    JSR CMD_SET
    RTS