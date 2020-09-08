.SEGMENT "CODE"

READJOY:
    LDA #$01     ; WE NEED TO TOGGLE STROBE BIT TO READ JOYPAD INPUT
    STA NESIOREG1  ; THIS ADDRESS CONTROLS THE READING OF BOTH CONTROLLERS 
    STA JOYPAD1  ; ONCE THIS BIT IS SHIFTED INTO C WE KNOW WE ARE DONE READING INPUT
    LSR A        ; SHIFT BITS RIGHT; A(0) 
    STA NESIOREG1  ; STROBE BIT IS TOGGLED AND CONTROLLER INPUT CAN BE READ 1 BIT AT A TIME
LOOP:    
    LDA NESIOREG1  ; READ CONTROLLER 1 STATE 
    LSR A        ; SHIFT BITS RIGHT; LSB(1|0) -> C;
    ROL JOYPAD1  ; SHIFT BITS LEFT; C -> BIT0 ; BIT7 -> C
    BCC LOOP    ; WHILE C(0)
    RTS
;------------------------------------------------------------------------------------------------     
WR_BUF:  
    LDX  WR_PTR     ; Start with A containing the byte to put in the buffer.
    STA  CMDBUFFER,X   ; Get the pointer value and store the data where it says,
    INC  WR_PTR     ; then increment the pointer for the next write.
    RTS
;------------------------------------------------------------------------------------------------     
RD_BUF:  
    LDX  RD_PTR     ; Ends with A containing the byte just read from buffer.
    LDA  CMDBUFFER,X   ; Get the pointer value and read the data it points to.
    INC  RD_PTR     ; Then increment the pointer for the next read.
    RTS
;------------------------------------------------------------------------------------------------     