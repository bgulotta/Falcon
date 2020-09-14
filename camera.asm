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
MOVE_CAMERA: ; TODO: Loop all active players
    ;SEC 
    ;LDA #$20 ; 32 pixel window
    ;SBC P1+Player::
    RTS

;---------------------------------------
; Converts the world coordinates of the 
; camera into Scroll coordinates for the 
; PPU. If the camera moved then scrolling 
; should take place.
;---------------------------------------
CAMERA_TO_SCREEN:

    RTS