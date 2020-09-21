.SEGMENT "CODE"

;---------------------------------------------
; This AI subroutine will start moving the   
; camera to it's destination 
;---------------------------------------------
UPDATE_CAMERA:
    LDY #ACTOR_DATA::XPos       ; Grab the camera's 
    LDA (ACTOR_PTR), Y          ; current x position
    CMP CamDestX                ; and see if it is 
    BNE MOVE_CAMERA
    LDY #ACTOR_DATA::XPos + 1   ; of it's intended dest
    LDA (ACTOR_PTR), Y          ; then move the camera
    CMP CamDestX + 1            ; left or right accordingly
    BNE MOVE_CAMERA
    JMP CAMERA_AT_DESTINATION
MOVE_CAMERA:
    SEC
    LDY #ACTOR_DATA::XPos       ; Grab the camera's 
    LDA (ACTOR_PTR), Y          ; current x position
    SBC CamDestX                ; and see if it is 
    LDY #ACTOR_DATA::XPos + 1   ; of it's intended dest
    LDA (ACTOR_PTR), Y          ; then move the camera
    SBC CamDestX + 1            ; left or right accordingly
    BCC MOVE_CAMERA_RIGHT
MOVE_CAMERA_LEFT:       
    LDA #JOYPAD::Left
    JMP UPDATE_CAMERA_EXIT
MOVE_CAMERA_RIGHT:
    LDA #JOYPAD::Right
    JMP UPDATE_CAMERA_EXIT
CAMERA_AT_DESTINATION:
    LDA #$00
UPDATE_CAMERA_EXIT:
    LDY #ACTOR_DATA::Movement    
    STA (ACTOR_PTR), Y
    JSR UPDATE_ACTOR_DIRECTION
    JSR UPDATE_VIEWPORT
    RTS

UPDATE_VIEWPORT:
    BEQ UPDATE_VIEWPORT_EXIT 
    JSR SET_VIEWPORT_BEGIN
    JSR SET_VIEWPORT_END
SET_SCROLL_MSB:
    LDY #ACTOR_DATA::XPos + 1
    LDA (ACTOR_PTR), Y
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
UPDATE_VIEWPORT_EXIT:
    RTS

SET_VIEWPORT_BEGIN:
    SEC 
    LDY #ACTOR_DATA::XPos
    LDA (ACTOR_PTR), Y
    SBC #$70
    STA ViewPort + ViewPort::Begin
    LDY #ACTOR_DATA::XPos + 1
    LDA (ACTOR_PTR), Y
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

;---------------------------------------------
; This subroutine will take a player's current
; movement and set the camera's destination
; to 8 pixel's in front of where the player is
; facing
;---------------------------------------------
UPDATE_CAMERA_DEST:
    JSR SAVE_CAMERA_DEST
    LDY #ACTOR_DATA::Attributes
    LDA (ACTOR_PTR), Y
    AND #ACTOR_ATTRIBUTES::Direction
    BEQ MOVE_CAMERA_DEST_LEFT
    JMP MOVE_CAMERA_DEST_RIGHT
    RTS

SAVE_CAMERA_DEST:
    LDA CamDestX
    STA TempX
    LDA CamDestX + 1
    STA TempX + 1
    LDA CamDestY
    STA TempY
    LDA CamDestY + 1
    STA TempY + 1
    RTS

RESTORE_CAMERA_DEST:
    LDA TempX
    STA CamDestX
    LDA TempX + 1
    STA CamDestX + 1
    LDA TempY
    STA CamDestY
    LDA TempY + 1
    STA CamDestY + 1
    RTS

MOVE_CAMERA_DEST_RIGHT:
    CLC
    LDY #ACTOR_DATA::XPos
    LDA (ACTOR_PTR), Y
    ADC #$08
    STA CamDestX
    LDY #ACTOR_DATA::XPos + 1
    LDA (ACTOR_PTR), Y
    ADC #$00
    STA CamDestX + 1
    BCS RESTORE_CAMERA_DEST     
    RTS

MOVE_CAMERA_DEST_LEFT:
    SEC
    LDY #ACTOR_DATA::XPos
    LDA (ACTOR_PTR), Y
    SBC #$08
    STA CamDestX
    LDY #ACTOR_DATA::XPos + 1
    LDA (ACTOR_PTR), Y
    SBC #$00
    STA CamDestX + 1
    BCC RESTORE_CAMERA_DEST     
    RTS
   