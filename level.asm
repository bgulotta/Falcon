
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
    JSR SET_META_TILE_ZP
    JSR SET_SCREEN_ZP
    JSR SCREEN_TO_PPU
    RTS

SET_META_TILE_ZP:
    LDY #LEVEL_DATA::MetaTileSet
    LDA (LEVEL_PTR), Y
    STA META_TILE_PTR
    LDY #LEVEL_DATA::MetaTileSet + 1
    LDA (LEVEL_PTR), Y
    STA META_TILE_PTR + 1
SET_META_TILE_ZP_EXIT:
    RTS

SET_SCREEN_ZP:
    LDY #LEVEL_DATA::Screens
    LDA (LEVEL_PTR), Y
    STA SCREEN_PTR
    LDY #LEVEL_DATA::Screens + 1
    LDA (LEVEL_PTR), Y
    STA SCREEN_PTR + 1
SET_SCREEN_ZP_EXIT:
    JSR SET_METAMETA_TILE_ZP
    RTS

SET_METAMETA_TILE_ZP:
    LDY #SCREEN_DATA::MetaMetaTiles
    LDA (SCREEN_PTR), Y
    STA METAMETA_TILE_PTR
    LDY #SCREEN_DATA::MetaMetaTiles + 1
    LDA (SCREEN_PTR), Y
    STA METAMETA_TILE_PTR + 1
SET_METAMETA_TILE_ZP_EXIT:
    RTS

; Loop through all the metameta tiles rendering them to the ppu
SCREEN_TO_PPU:
    LDA #$38
    STA MetaMetaTileIndex                 
METAMETA_TILE_LOOP:
    LDA MetaMetaTileIndex                 
    JSR METAMETA_TILE_TO_PPU
    DEC MetaMetaTileIndex
    BPL METAMETA_TILE_LOOP 
    RTS

; This subroutine will take a metameta tile index
; in A and render it to the screen
METAMETA_TILE_TO_PPU:
    CMP #$1C ; Are we pulling back a mirrored metameta tile (Indexes 28-56)?
    BCC METAMETA_TILESET_INDEX
TRANSLATE_METAMETA_TILESET_INDEX:
    SEC 
    SBC #$1D
    BCS METAMETA_TILESET_INDEX
    LDA #$00
METAMETA_TILESET_INDEX:
    STA MetaMetaTileSetIndex
    LDA #$03 
    STA RowIndex
METAMETA_TILESET_LOOP:
    LDY MetaMetaTileSetIndex        ; move on to the next metameta tileset index
    LDA (METAMETA_TILE_PTR), Y      ; A is our meta tileset index 
    JSR META_TILE_TO_PPU            
    INC MetaMetaTileSetIndex
    DEC RowIndex                        ; have we finished 4 iterations?
    BPL METAMETA_TILESET_LOOP
METAMETA_TILE_TO_PPU_EXIT:
    RTS

META_TILE_TO_PPU:
    TAY                             ; A is our meta tileset index 
    LDA #$03
    STA ColumnIndex   
META_TILESET_LOOP:
    LDA (META_TILE_PTR), Y  
    JSR TILE_TO_PPU
    INY 
    DEC ColumnIndex
    BPL META_TILESET_LOOP
    RTS

TILE_TO_PPU:
    PHA     ; A contains the tile 
    JSR TILE_TO_PPU_ADDRESS 
    LDA #$01
    JSR WR_BUF
    LDA #$0B
    ;LDA PPUAddress + 1
    JSR WR_BUF
    LDA #$5A
    ;LDA PPUAddress 
    JSR WR_BUF
    LDA #$05
    ;PLA 
    JSR WR_BUF
    
    JSR CMD_SET
    RTS



; POINT_TO_META:
;     TAY                     ; Transfer Actor Type to Y
;     LDA #.LOBYTE(Meta) ; Store start of actor's metadata 
;     STA META_PTR      ; In zero page
;     LDA #.HIBYTE(Meta)
;     STA META_PTR + 1
;     TYA                     ; Restore Actor Index to A
; POINT_TO_META_LOOP:
;     BEQ POINT_TO_META_EXIT ; Are we done iterating through the actors?
; NEXT_META:
;     CLC                     ; Otherwise loop through the actor's meta one at a time
;     LDA META_PTR       ; Incrementing the ACTOR_META_PTR by
;     ADC #$08                ; the size of the meta data
;     STA META_PTR           ; If carry is clear after add then no need to 
;     BCC POINT_TO_META_NEXT     ; increment the high byte of the address
;     INC META_PTR + 1       ; Otherwise increment high byte of addresss
; POINT_TO_META_NEXT:
;     DEY
;     JMP POINT_TO_META_LOOP 
; POINT_TO_META_EXIT:
;     RTS
