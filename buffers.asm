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