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
;                                                  ;
;                                                  ;
;                                                  ;
;                                                  ;
;--------------------------------------------------;
CALCULATE_BASE_PPUADDRESS:
    TAX
    LDA PPUBASELO, X
    STA PPU + PPU::BaseAddress
    LDY Screen
    LDX MOD2, Y
    LDA PPUBASEHI, X
    STA PPU + PPU::BaseAddress + 1
    RTS

;--------------------------------------------------;
;                                                  ;
;                                                  ;
;                                                  ;
;                                                  ;
;                                                  ;
;--------------------------------------------------;
META_META_COLUMN_STARTADDRESS:
    CLC
    LDA PPU + PPU::BaseAddress
    LDX MetaMetaTile + MetaTile::Index
    ADC MULT4, X      
    STA PPU + PPU::TileAddress
    LDA PPU + PPU::BaseAddress + 1
    STA PPU + PPU::TileAddress + 1
    RTS 

NEXT_TILE_ADDRESS:
    CLC 
    INC PPU + PPU::TileAddress
    BCC NEXT_TILE_ADDRESS_EXIT
    INC PPU + PPU::TileAddress + 1
NEXT_TILE_ADDRESS_EXIT:
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
    ORA MetaMetaTile + MetaTile::Index
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
    LDY MetaTile + MetaTile::Index
    LDX MOD2, Y 
    LDY MULT2, X 
    STY Temp3
DECODE_TILE_LOOP:
    LDA Tile + Tile::Index 
    TAY
    LDX MOD2, Y
    STX Temp3 + 1 
    JSR SET_TILE_BUF_PTR
    JSR WR_TILE_BUF
    JSR PREV_TILE
    BPL DECODE_TILE_LOOP
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
    JSR NEXT_TILE_ADDRESS
    JMP TILEBUFF_TO_PPU_NEXT_CMD
TILEBUF_TO_PPU_EXIT:
    INC NumCommands
    RTS 
