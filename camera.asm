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
    STA Temp
    LDA CamDestX + 1
    STA Temp + 1
    LDA CamDestY
    STA Temp2
    LDA CamDestY + 1
    STA Temp2 + 1
    RTS

RESTORE_CAMERA_DEST:
    LDA Temp
    STA CamDestX
    LDA Temp + 1
    STA CamDestX + 1
    LDA Temp2
    STA CamDestY
    LDA Temp2 + 1
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
   