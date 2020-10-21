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
    STA TILEBUF_INX
    LDA #$1D
    STA TILEBUF_INX + 1
    LDA #$3A
    STA TILEBUF_INX + 2
    LDA #$57
    STA TILEBUF_INX + 3
    RTS 