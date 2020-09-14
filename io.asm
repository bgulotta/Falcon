.SEGMENT "CODE"

READ_JOYPADS:
    LDA #$01               ; WE NEED TO TOGGLE STROBE BIT TO READ JOYPAD INPUT
    STA NESIOREG1          ; THIS ADDRESS CONTROLS THE READING OF BOTH CONTROLLERS 
    STA JOYPAD1            ; ONCE THIS BIT IS SHIFTED INTO C WE KNOW WE ARE DONE READING INPUT
    LSR A                  ; SHIFT BITS RIGHT; A(0) 
    STA NESIOREG1          ; STROBE BIT IS TOGGLED AND CONTROLLER INPUT CAN BE READ 1 BIT AT A TIME
LOOP:    
    LDA NESIOREG1          ; READ CONTROLLER 1 STATE 
    LSR A                  ; SHIFT BITS RIGHT; LSB(1|0) -> C;
    ROL JOYPAD1            ; SHIFT BITS LEFT; C -> BIT0 ; BIT7 -> C
    BCC LOOP               ; WHILE C(0)
    LDA JOYPAD1
    ;BEQ READ_JOYPADS_EXIT
UPDATE_P1_MOVEMENT:
    LDA #$00
    JSR WR_ACTOR_BUF            ; Write Actor Index
    LDA #ACTOR_INDEX::Movement  
    JSR WR_ACTOR_BUF            ; Write Data Index
    LDA #$01
    JSR WR_ACTOR_BUF            ; Write Packet Size
    LDA JOYPAD1
    JSR WR_ACTOR_BUF            ; Write Data
READ_JOYPADS_EXIT:
    RTS