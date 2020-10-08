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
WORLD_TO_TILE_COORDINATES:
; CALCULATE_TILE_X:
;     LDY #COORDINATES::XPos
;     LDA (COORDINATES_PTR), Y
;     STA Temp
;     LDY #COORDINATES::XPos + 1
;     LDA (COORDINATES_PTR), Y
;     STA Temp + 1
;     LDA #$03        ; Divide x coordinates by 8
;     STA NumIterations
;     JSR DIVIDE
;     LDY #COORDINATES::XPos + 1
;     LDA (COORDINATES_PTR), Y
;     BEQ STORE_TILE_X 
;     STA Temp3
; SUBTRACT_SCREEN_LOOP:    
;     JSR SUBTRACT_32
;     DEC Temp3 
;     BNE SUBTRACT_SCREEN_LOOP
; STORE_TILE_X:
;     LDA Temp 
;     LDY #COORDINATES::TileX
;     STA (COORDINATES_PTR), Y
;     LDA Temp + 1
;     LDY #COORDINATES::TileX + 1
;     STA (COORDINATES_PTR), Y
; CALCULATE_TILE_Y:
;     LDY #COORDINATES::YPos
;     LDA (COORDINATES_PTR), Y
;     STA Temp
;     LDY #COORDINATES::YPos + 1
;     LDA (COORDINATES_PTR), Y
;     STA Temp + 1
;     LDA #$03        ; Divide x coordinates by 8
;     STA NumIterations
;     JSR DIVIDE
; STORE_TILE_Y:
;     LDA Temp 
;     LDY #COORDINATES::TileY
;     STA (COORDINATES_PTR), Y
;     LDA Temp + 1
;     LDY #COORDINATES::TileY + 1
;     STA (COORDINATES_PTR), Y
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
TILE_TO_PPUADDRESS:
    CLC 
    LDA PPU + PPU::BaseAddress
    ADC Tile + TILE::TileIndex     
    STA PPU + PPU::TileAddress
    LDA PPU + PPU::BaseAddress + 1
    ADC Tile + TILE::TileIndex + 1
    STA PPU + PPU::TileAddress + 1
    RTS 

;--------------------------------------------------;
;                                                  ;
;                                                  ;
;                                                  ;
;                                                  ;
;                                                  ;
;--------------------------------------------------;
META_META_COLUMN_STARTADDRESS:
    JSR CALCULATE_BASE_PPUADDRESS
    LDA MetaMetaTile + MetaTile::Index
    STA Temp 
    LDA #$00
    STA Temp + 1 
    LDA #$02 
    STA NumIterations
    JSR MULTIPLY
    CLC 
    LDA PPU + PPU::BaseAddress
    ADC Temp      
    STA PPU + PPU::TileAddress
    LDA PPU + PPU::BaseAddress + 1
    ADC Temp + 1
    STA PPU + PPU::TileAddress + 1
    RTS 

META_META_COLUMN_NEXTADDRESS:
    CLC 
    LDA PPU + PPU::TileAddress
    ADC #$01
    STA PPU + PPU::TileAddress
    LDA PPU + PPU::TileAddress + 1
    ADC #$00
    STA PPU + PPU::TileAddress + 1
    RTS 

;--------------------------------------------------;
;                                                  ;
;                                                  ;
;                                                  ;
;                                                  ;
;                                                  ;
;--------------------------------------------------;
SCREEN_TO_PPU:
    LDA #$07    
RENDER_META_META_TILE_COL_LOOP:
    JSR DECODE_META_META_TILE_COL
    JSR TILEBUF_TO_PPU
    DEC MetaMetaTile + MetaTile::Index
    LDA MetaMetaTile + MetaTile::Index
    BPL RENDER_META_META_TILE_COL_LOOP
    RTS
    
;--------------------------------------------------;
;  Current screen column 0-7 to decode into        ;
;  TileBuf                                         ;
;                                                  ;
;                                                  ;
;                                                  ;
;--------------------------------------------------;
DECODE_META_META_TILE_COL:
    JSR LAST_META_META_TILE_IN_COL
    JSR RESET_TILE_BUF_PTRS
    LDA #$00
    STA DECODEDFLAG
 DECODE_META_META_TILE_LOOP:
    JSR DECODE_META_META_TILE  
    JSR PREV_META_META_TILE_ROW_IN_COL
    BPL DECODE_META_META_TILE_LOOP
DECODE_META_META_TILE_COL_EXIT:
    LDA #BITS::BIT_7
    STA DECODEDFLAG
    RTS

;--------------------------------------------------;
;                                                  ;
;                                                  ;
;                                                  ;
;                                                  ;
;                                                  ;
;--------------------------------------------------;
DECODE_META_META_TILE:
    JSR LAST_META_TILE
DECODE_META_TILE_LOOP:
    JSR DECODE_META_TILE
    JSR PREV_META_TILE
    LDA MetaTile + MetaTile::Index 
    BPL DECODE_META_TILE_LOOP
    RTS 

;--------------------------------------------------;
;                                                  ;
;                                                  ;
;                                                  ;
;                                                  ;
;                                                  ;
;--------------------------------------------------;
DECODE_META_TILE:
    JSR LAST_TILE
    JSR META_TILE_MOD2
DECODE_TILE_LOOP:
    JSR TILE_MOD2
    JSR SET_TILE_BUF_PTR
    JSR WR_TILE_BUF
    JSR PREV_TILE
    LDA Tile + Tile::Index 
    BPL DECODE_TILE_LOOP
    RTS 

;--------------------------------------------------;
;                                                  ;
;                                                  ;
;                                                  ;
;                                                  ;
;                                                  ;
;--------------------------------------------------;
META_TILE_MOD2:
    LDA MetaTile + MetaTile::Index
    STA Temp 
    LDA #$02 
    STA Temp + 1 
    JSR MOD
    STA Temp            
    LDA #$01
    STA NumIterations   
    JSR MULTIPLY   
    LDA Temp
    STA Temp3 
    RTS 

;--------------------------------------------------;
;                                                  ;
;                                                  ;
;                                                  ;
;                                                  ;
;                                                  ;
;--------------------------------------------------;
TILE_MOD2:
    LDA Tile + Tile::Index
    STA Temp 
    LDA #$02 
    STA Temp + 1 
    JSR MOD
    STA Temp3 + 1
    RTS 

;--------------------------------------------------;
;                                                  ;
;                                                  ;
;                                                  ;
;                                                  ;
;                                                  ;
;--------------------------------------------------;
SET_TILE_BUF_PTR:
    CLC 
    LDA Temp3
    ADC Temp3 + 1
    CMP #$03
    BCS SET_TILE_PTR_FOURTH_BUCKET
    CMP #$02
    BCS SET_TILE_PTR_THIRD_BUCKET
    CMP #$01
    BCS SET_TILE_PTR_SECOND_BUCKET
SET_TILE_PTR_FIRST_BUCKET:
    LDA #.LOBYTE(TILE_PTR_0)
    STA TILEBUF_PTR
    LDA #.HIBYTE(TILE_PTR_0)
    STA TILEBUF_PTR + 1
    RTS 
SET_TILE_PTR_SECOND_BUCKET:
    LDA #.LOBYTE(TILE_PTR_1)
    STA TILEBUF_PTR
    LDA #.HIBYTE(TILE_PTR_1)
    STA TILEBUF_PTR + 1
    RTS 
SET_TILE_PTR_THIRD_BUCKET:
    LDA #.LOBYTE(TILE_PTR_2)
    STA TILEBUF_PTR
    LDA #.HIBYTE(TILE_PTR_2)
    STA TILEBUF_PTR + 1
    RTS 
SET_TILE_PTR_FOURTH_BUCKET:
    LDA #.LOBYTE(TILE_PTR_3)
    STA TILEBUF_PTR
    LDA #.HIBYTE(TILE_PTR_3)
    STA TILEBUF_PTR + 1
    RTS 


;--------------------------------------------------;
;                                                  ;
; Tile Buffer 0-3 to send to the PPU               ;
;                                                  ;
;                                                  ;
;                                                  ;
;--------------------------------------------------;
TILEBUF_TO_PPU:
    LDA DECODEDFLAG
    ORA #BITS::BIT_6
    STA DECODEDFLAG
    JSR META_META_COLUMN_STARTADDRESS
    LDY #$00 
TILEBUFF_TO_PPU_NEXT_CMD:
    JSR BUF_DIF
    CMP #$E0 
    BCS TILEBUFF_TO_PPU_NEXT_CMD
    LDA #$1C
    JSR WR_BUF
    LDA PPU + PPU::TileAddress + 1
    JSR WR_BUF
    LDA PPU + PPU::TileAddress
    JSR WR_BUF
TILEBUF_TO_PPU_LOOP:
    LDA TILEBUF, Y
    JSR WR_BUF
    INY 
    CPY #$1C
    BEQ SEND_TILE_BUF_TO_PPU
    CPY #$38
    BEQ SEND_TILE_BUF_TO_PPU
    CPY #$54
    BEQ SEND_TILE_BUF_TO_PPU
    CPY #$70 
    BCS TILEBUF_TO_PPU_EXIT
    JMP TILEBUF_TO_PPU_LOOP    
SEND_TILE_BUF_TO_PPU:
    INC NumCommands
    JSR META_META_COLUMN_NEXTADDRESS
    JMP TILEBUFF_TO_PPU_NEXT_CMD
TILEBUF_TO_PPU_EXIT:
    INC NumCommands
    RTS 
