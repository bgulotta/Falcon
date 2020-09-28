
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
    ; Set Nametable and PPUAddress
    LDA #$00
    STA PPUAddress
    LDY #SCREEN_DATA::Index
    LDA (SCREEN_PTR), Y
    AND #$01
    BNE NEXT_NAMETABLE 
    LDA #$20
    JMP SET_SCREEN_ZP_EXIT
NEXT_NAMETABLE:
    LDA #$24
SET_SCREEN_ZP_EXIT:
    STA Nametable
    STA PPUAddress + 1
    CLC
    ADC #$03
    STA Nametable + 1
    JSR SET_MMT_INDEX_PTR_ZP
    RTS

SET_MMT_INDEX_PTR_ZP:
    LDY #SCREEN_DATA::MetaMetaTileIndex
    LDA (SCREEN_PTR), Y
    STA MMT_INDEX_PTR
    LDY #SCREEN_DATA::MetaMetaTileIndex + 1
    LDA (SCREEN_PTR), Y
    STA MMT_INDEX_PTR + 1
SET_MMT_INDEX_PTR_ZP_EXIT:
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
    TAY ; MetaMetaTile Index
    LDA (MMT_INDEX_PTR), Y
    TAY ; MetaMetaTileset Index
    LDA (META_META_TILESET_PTR), Y
    JSR 
    ; Calculate TileX, TileY, and PPUAddress
    ; of MetaMetaTileIndex = Temp6
    ; Loop 16 times writing each tile in 
    ; the meta meta tile to the PPU Buffer
    DEC Temp6
    BNE METAMETA_TILE_LOOP

    RTS

META_META_TILE_INDEX_TO_TILEXY:

    RTS 

TILEXY_TO_PPUADDRESS:

    RTS

; PPUADDRESS_TO_TILE:
;     LDA PPUAddress       
;     STA Temp            ; Get the Tile Number 
;     STA Temp2           ; From the PPUAddress
;     LDA PPUAddress + 1  
;     AND #$FC             
;     STA Temp + 1
;     STA Temp2 + 1
;     JSR DIVIDE_BY_32    ; Divide Tile Number by 32. 
;     LDA Temp            ; This division gives us TileY. 
;     STA Temp4           ; Store the result in Temp4
;     LDA Temp2           ; Restore Tile Number from Temp2
;     STA Temp            ; into Temp. Then subtract 32 * TileY 
;     LDA Temp2 + 1       ; times to calculate TileX
;     STA Temp + 1
;     LDA Temp4 
;     BEQ STORE_TILE_COL
;     STA Temp3       ; TileY to Temp3 for Calculating TileX
; SUBTRACT_TILE_ROW_LOOP:    
;     JSR SUBTRACT_32
;     DEC Temp3 
;     BNE SUBTRACT_TILE_ROW_LOOP ; TileX = Temp
; STORE_TILE_COL:
;     LDA Temp 
;     STA Temp4     
;     RTS


; TILE_TO_PPU:

;     LDA #$09
;     CMP NumCommands
;     BCC TILE_TO_PPU ; make sure we aren't overloading the NMI
;     JSR BUF_DIF
;     CMP #$7D        ; make sure we have enough bytes free in the buffer
;     BCS TILE_TO_PPU
    
;     ;PHA     ; A contains the tile 
;     ;JSR TILE_TO_PPU_ADDRESS 
;     LDA #$01
;     JSR WR_BUF
;     ;LDA #$0B
;     LDA PPUAddress + 1
;     JSR WR_BUF
;     ;LDA #$5A
;     LDA PPUAddress  
;     JSR WR_BUF
;     LDA #$05
;     ;PLA 
;     JSR WR_BUF
;     JSR CMD_SET
;     RTS

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
