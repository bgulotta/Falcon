
;--------------------------------------------------;
; This module will be responsible for keeping the  ;
; HUD updated based on game state.                 ;
;                                                  ;
;                                                  ;
;                                                  ;
;                                                  ;
;--------------------------------------------------;
HUD_INIT:
    LDA $7777
PLAYER1:
    LDA #$02
    JSR WR_BUF
    LDA #$20
    JSR WR_BUF
    LDA #$02
    JSR WR_BUF
    LDA PPUCTRLBUF
    AND #$FB
    JSR WR_BUF 
    LDY #$00
PLAYER1LOOP:
    LDA HUD_PLAYER1, Y
    BEQ PLAYER1_SCORE    
    TAX 
    DEX 
    TXA 
    JSR WR_BUF
    INY 
    JMP PLAYER1LOOP
PLAYER1_SCORE:
    INC NumCommands
    LDA #$07
    JSR WR_BUF
    LDA #$20
    JSR WR_BUF
    LDA #$22
    JSR WR_BUF
    LDA PPUCTRLBUF
    AND #$FB
    JSR WR_BUF 
    LDA #$2F
    LDY #$07
PLAYER1SCORELOOP:
    BEQ PLAYER2
    JSR WR_BUF
    DEY 
    JMP PLAYER1SCORELOOP
PLAYER2:
    INC NumCommands
    LDA #$02
    JSR WR_BUF
    LDA #$20
    JSR WR_BUF
    LDA #$17
    JSR WR_BUF
    LDA PPUCTRLBUF
    AND #$FB
    JSR WR_BUF 
    LDY #$00
PLAYER2LOOP:
    LDA HUD_PLAYER2, Y
    BEQ PLAYER2_SCORE    
    TAX 
    DEX 
    TXA 
    JSR WR_BUF
    INY 
    JMP PLAYER2LOOP
PLAYER2_SCORE:
    INC NumCommands
    LDA #$07
    JSR WR_BUF
    LDA #$20
    JSR WR_BUF
    LDA #$37
    JSR WR_BUF
    LDA PPUCTRLBUF
    AND #$FB
    JSR WR_BUF 
    LDA #$2F
    LDY #$07
PLAYER2SCORELOOP:
    BEQ INIT_HUD_EXIT
    JSR WR_BUF
    DEY 
    JMP PLAYER2SCORELOOP
INIT_HUD_EXIT:
    INC NumCommands
    RTS 