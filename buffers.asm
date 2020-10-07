.SEGMENT "CODE"
;------------------------------------------------------------------------------------------------     
WR_BUF:  
    LDX  CMD_WPTR     ; Start with A containing the byte to put in the buffer.
    STA  CMDBUF,X   ; Get the pointer value and store the data where it says,
    INC  CMD_WPTR     ; then increment the pointer for the next write.
    RTS
;------------------------------------------------------------------------------------------------     
RD_BUF:  
    LDX  CMD_RPTR     ; Ends with A containing the byte just read from buffer.
    LDA  CMDBUF,X   ; Get the pointer value and read the data it points to.
    INC  CMD_RPTR     ; Then increment the pointer for the next read.
    RTS
;------------------------------------------------------------------------------------------------   
BUF_DIF: 
    LDA  CMD_WPTR     ; Find difference between number of bytes written
    SEC               ; and how many read.
    SBC  CMD_RPTR     ; Ends with A showing the number of bytes left to read.
    RTS
;------------------------------------------------------------------------------------------------     
RESET_TILE_BUF_PTRS:
    LDA #$00
    STA TILE_PTR_0
    LDA #$1C
    STA TILE_PTR_1
    LDA #$38
    STA TILE_PTR_2
    LDA #$54
    STA TILE_PTR_3
    RTS 

;--------------------------------------------------;
;  Tile value in A,                                  ;
;                                                  ;
;                                                  ;
;                                                  ;
;                                                  ;
;--------------------------------------------------;
WR_TILE_BUF: 
    LDY #$00
    LDA (TILEBUF_PTR), Y
    TAX
    LDA Tile + TILE::Tile
    STA TILEBUF, X   ; Get the pointer value and store the data where it says,
    INX
    TXA
    STA (TILEBUF_PTR), Y
    RTS