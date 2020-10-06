UPDATE_VIEWPORT:
    BEQ UPDATE_VIEWPORT_EXIT   ; If the camera isn't moving then the viewport is where it needs to be
    JSR SET_VIEWPORT_BEGIN
    JSR SET_VIEWPORT_END
    JSR UPDATE_SCROLL
UPDATE_VIEWPORT_EXIT:
    RTS

UPDATE_SCROLL:
    LDA ViewPort + ViewPort::Begin + 1
    AND #$01  
    BEQ BIT0_OFF
BIT0_ON:
    ORA PPUCTRLBUF
    JMP UPDATE_SCROLL_EXIT
BIT0_OFF:
    LDA PPUCTRLBUF
    AND #$FE
UPDATE_SCROLL_EXIT:
    STA PPUCTRLBUF
    JSR SCROLLFLAG_SET    
    RTS

SET_VIEWPORT_BEGIN:
    SEC 
    LDA Camera + ACTOR_DATA::XPos
    SBC #$70
    STA ViewPort + ViewPort::Begin
    LDA Camera + ACTOR_DATA::XPos + 1
    SBC #$00
    STA ViewPort + ViewPort::Begin + 1
    BCS SET_VIEWPORT_BEGIN_EXIT
SET_VIEWPORT_START:
    LDA #$00
    STA ViewPort + ViewPort::Begin
    STA ViewPort + ViewPort::Begin + 1
SET_VIEWPORT_BEGIN_EXIT:
    LDA #$00
    STA ViewPort + ViewPort::Begin + 2
    STA ViewPort + ViewPort::Begin + 3
    RTS

SET_VIEWPORT_END:
    CLC 
    LDA ViewPort + ViewPort::Begin
    ADC #$FF
    STA ViewPort + ViewPort::End 
    LDA ViewPort + ViewPort::Begin + 1
    ADC #$00
    STA ViewPort + ViewPort::End + 1
    BCC SET_VIEWPORT_END_EXIT
 SET_VIEWPORT_FINISH:
    LDA #$FF
    STA ViewPort + ViewPort::End
    STA ViewPort + ViewPort::End + 1
SET_VIEWPORT_END_EXIT:
    LDA #$F0
    STA ViewPort + ViewPort::End + 2
    RTS
