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

; NEXT_COL_ADDRESS:
;     CLC 
;     INC PPU + PPU::TileAddress
;     BCC NEXT_COL_ADDRESS_EXIT
;     INC PPU + PPU::TileAddress + 1
; NEXT_COL_ADDRESS_EXIT:
;     RTS 
HUD_TO_PPU:

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
    JSR LEVELBUF_TO_PPU
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
    LDY Tile + Tile::Index 
    LDX MOD2, Y
    STX Temp3 + 1
    CLC 
    LDA Temp3
    ADC Temp3 + 1
    TAX     
    LDY TILEBUF_INX, X
    LDA Tile + Tile::Tile     
    STA TILEBUF, Y 
    INC TILEBUF_INX, X
    JSR PREV_TILE
    BPL DECODE_TILE_LOOP
    RTS 

HUDBUF_TO_PPU:
    RTS 

;--------------------------------------------------;
;                                                  ;
; Tile Buffer 0-3 to send to the PPU               ;
;                                                  ;
;                                                  ;
;                                                  ;
;--------------------------------------------------;
 LEVELBUF_TO_PPU:
    LDA DECODEDFLAG
    ORA #BITS::BIT_6
    STA DECODEDFLAG
    JSR META_META_COLUMN_STARTADDRESS
    LDY #$00 
LEVELBUF_TO_PPU_NEXT_CMD:
    JSR BUF_DIF
    CMP #$E2 
    BCS LEVELBUF_TO_PPU_NEXT_CMD
    LDA #$1D
    JSR WR_BUF
    LDA PPU + PPU::TileAddress + 1
    JSR WR_BUF
    LDA PPU + PPU::TileAddress
    JSR WR_BUF
    LDA PPUCTRLBUF
    ORA #PPUCTRL::VRAM_INC
    JSR WR_BUF 
LEVELBUF_TO_PPU_LOOP:
    LDA TILEBUF, Y
    JSR WR_BUF
    INY 
    CPY #$1D
    BEQ SEND_LEVELBUF_TO_PPU
    CPY #$3A
    BEQ SEND_LEVELBUF_TO_PPU
    CPY #$57
    BEQ SEND_LEVELBUF_TO_PPU
    CPY #$74 
    BCS LEVELBUF_TO_PPU_EXIT
    JMP LEVELBUF_TO_PPU_LOOP    
SEND_LEVELBUF_TO_PPU:
    INC NumCommands
    INC PPU + PPU::TileAddress
    JMP LEVELBUF_TO_PPU_NEXT_CMD
LEVELBUF_TO_PPU_EXIT:
    INC NumCommands
    RTS 
