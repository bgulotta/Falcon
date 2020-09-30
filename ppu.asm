;--------------------------------------------------;
;                                                  ;
;   This file will be responsible for all PPU      ;
;   logic. PPUAddress Nametable and Attribute      ;
;   table encoding/decoding logic, writing         ;
;   to the PPU Buffer, etc.                        ;
;                                                  ;
;--------------------------------------------------;

;--------------------------------------------------;
;                                                  ;
;   This subtroutine will take a pointer to        ;
;   world coordinates and convert them             ;
;   to tile coordinates.                           ;
;                                                  ;
;--------------------------------------------------;
CALCULATE_TILE_COORDINATES:
CALCULATE_TILE_X:
    LDY #COORDINATES::XPos
    LDA (COORDINATES_PTR), Y
    STA Temp
    LDY #COORDINATES::XPos + 1
    LDA (COORDINATES_PTR), Y
    STA Temp + 1
    LDA #$03        ; Divide x coordinates by 8
    STA NumIterations
    JSR DIVIDE
    LDY #COORDINATES::XPos + 1
    LDA (COORDINATES_PTR), Y
    BEQ STORE_TILE_X 
    STA Temp3
SUBTRACT_SCREEN_LOOP:    
    JSR SUBTRACT_32
    DEC Temp3 
    BNE SUBTRACT_SCREEN_LOOP
STORE_TILE_X:
    LDA Temp 
    LDY #COORDINATES::TileX
    STA (COORDINATES_PTR), Y
    LDA Temp + 1
    LDY #COORDINATES::TileX + 1
    STA (COORDINATES_PTR), Y
CALCULATE_TILE_Y:
    LDY #COORDINATES::YPos
    LDA (COORDINATES_PTR), Y
    STA Temp
    LDY #COORDINATES::YPos + 1
    LDA (COORDINATES_PTR), Y
    STA Temp + 1
    LDA #$03        ; Divide x coordinates by 8
    STA NumIterations
    JSR DIVIDE
STORE_TILE_Y:
    LDA Temp 
    LDY #COORDINATES::TileY
    STA (COORDINATES_PTR), Y
    LDA Temp + 1
    LDY #COORDINATES::TileY + 1
    STA (COORDINATES_PTR), Y
    RTS


;--------------------------------------------------;
;                                                  ;
;                                                  ;
;                                                  ;
;                                                  ;
;                                                  ;
;--------------------------------------------------;
CALCULATE_BASE_PPUADDRESS:
    LDA #$00
    STA PPU + PPU::BaseAddress
    LDY #SCREEN_DATA::Index
    LDA (SCREEN_PTR), Y
    AND #$01
    BNE NEXT_NAMETABLE 
    LDA #$20
    JMP CALCULATE_BASE_PPUADDRESS_EXIT
NEXT_NAMETABLE:
    LDA #$24
CALCULATE_BASE_PPUADDRESS_EXIT:
    STA PPU + PPU::BaseAddress + 1
    RTS

;--------------------------------------------------;
;                                                  ;
;                                                  ;
;                                                  ;
;                                                  ;
;                                                  ;
;--------------------------------------------------;
META_META_TILE_TO_PPUADDRESS:
    LDA MetaMetaTile + MetaMetaTile::Index
    STA Temp 
    LDA #$00
    STA Temp + 1 
    JSR MULTIPLY_BY_16
    CLC 
    LDA PPU + PPU::BaseAddress
    ADC Temp 
    STA PPU + PPU::MetaMetaTileAddress
    LDA PPU + PPU::BaseAddress + 1
    ADC Temp + 1
    STA PPU + PPU::MetaMetaTileAddress + 1
    RTS 

;--------------------------------------------------;
;                                                  ;
;                                                  ;
;                                                  ;
;                                                  ;
;                                                  ;
;--------------------------------------------------;
SCREEN_TO_PPU: 
    JSR LAST_META_META_TILE
RENDER_META_META_TILE:
    JSR META_META_TILE_TO_PPU
    JSR PREV_META_META_TILE
    LDA MetaMetaTile + MetaMetaTile::Index 
    BPL RENDER_META_META_TILE
    RTS

;--------------------------------------------------;
;                                                  ;
;                                                  ;
;                                                  ;
;                                                  ;
;                                                  ;
;--------------------------------------------------;
META_META_TILE_TO_PPU:
    JSR META_META_TILE_TO_PPUADDRESS
;    LDA MetaMetaTile + MetaMetaTile::MetaMetaTilesetIndex
;     TAY
;     LDA #$00
;     STA Temp4
; META_META_TILE_LOOP:
;     LDA (META_META_TILESET_PTR), Y
;     TAY 
; META_TILE_LOOP:
;     LDA (META_TILESET_PTR), Y
;     ;STA Tile    
;     JSR TILE_TO_PPU
;     ;JSR NEXT_PPUADDRESS
;     INY 
;     LDA Temp4
;     CMP #$0F  ; Have we finished all 16 tiles?
;     BCS META_META_TILE_TO_PPU_EXIT
;     INC Temp4
;     EOR Temp4 
;     AND #$04  
;     BEQ META_TILE_LOOP ; are we finished with this meta tile?
;     INC MetaMetaTile + MetaMetaTile::MetaMetaTilesetIndex
;     LDA MetaMetaTile + MetaMetaTile::MetaMetaTilesetIndex
;     TAY 
;     JMP META_META_TILE_LOOP
META_META_TILE_TO_PPU_EXIT:
    RTS

;--------------------------------------------------;
;                                                  ;
;                                                  ;
;                                                  ;
;                                                  ;
;                                                  ;
;--------------------------------------------------;
TILE_TO_PPU:
 
    ; LDA #$09
    ; CMP NumCommands
    ; BCC TILE_TO_PPU ; make sure we aren't overloading the NMI
    ; JSR BUF_DIF
    ; CMP #$7D        ; make sure we have enough bytes free in the buffer
    ; BCS TILE_TO_PPU

    ; LDA #$01
    ; JSR WR_BUF
    ; LDA PPUAddress + 1
    ; JSR WR_BUF
    ; LDA PPUAddress  
    ; JSR WR_BUF
    ; LDA Tile 
    ; JSR WR_BUF
    ; JSR CMD_SET
    RTS