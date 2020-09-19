.SEGMENT "CODE"

;---------------------------------------
; Routine checks to see if the player is 
; in the camera's window. If not it will
; move the camera/window so that it is. 
; Once the player stops moving the 
; camera/window should be centered on 
; the player. Camera boundary checking
; should take place here as well.
;---------------------------------------
UPDATE_CAMERA_POSITION: 
    LDY #META_DATA::Type
    LDA (META_PTR), Y                   ; Only player types affect the position of the camera
    BNE  UPDATE_CAMERA_POSITION_EXIT    
    LDY #ACTOR_DATA::XPos              ; Update Cam X LSB
    LDA (ACTOR_PTR), Y
    STA Cam
    LDY #ACTOR_DATA::XPos + 1          ; Update Cam X MSB
    LDA (ACTOR_PTR), Y
    STA Cam + 1
UPDATE_CAMERA_POSITION_EXIT:
    RTS

;---------------------------------------
; Converts the world coordinates of the 
; camera into Scroll coordinates for the 
; PPU. If the camera moved then scrolling 
; should take place.
;---------------------------------------
CAMERA_TO_SCROLL:
    LDA Cam 
    STA SCROLLX
    LDA Cam + 2
    STA SCROLLY
    LDA Cam + 1
    AND #$01
    BEQ BIT0_OFF
BIT0_ON:
    ORA PPUCTRLBUF
    JMP CAMERA_TO_SCROLL_EXIT
BIT0_OFF:
    LDA PPUCTRLBUF
    AND #$FE
CAMERA_TO_SCROLL_EXIT:
    STA PPUCTRLBUF
    JSR SCROLLFLAG_SET
    RTS