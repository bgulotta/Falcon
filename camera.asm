.SEGMENT "CODE"

UPDATE_CAMERA:
;     LDY #ACTOR_DATA::YPos
;     LDA (ACTOR_PTR), Y
;     STA CamY
;     LDY #ACTOR_DATA::YPos + 1
;     LDA (ACTOR_PTR), Y
;     STA CamY + 1
;     SEC 
;     LDY #ACTOR_DATA::XPos
;     LDA (ACTOR_PTR), Y
;     STA CamX
;     SBC #$80
;     STA ScrollX
;     LDY #ACTOR_DATA::XPos + 1
;     STA CamX + 1
;     LDA (ACTOR_PTR), Y
;     SBC #$00
;     STA ScrollX + 1
;     BCS SET_PPUSCROLL
; SET_SCROLL_WORLD_START:
;     LDA #$00
;     STA ScrollX
;     STA ScrollX + 1
; SET_PPUSCROLL:
;     LDA CamX + 1
;     AND #$01
;     BEQ BIT0_OFF
; BIT0_ON:
;     ORA PPUCTRLBUF
;     JMP UPDATE_CAMERA_EXIT
; BIT0_OFF:
;     LDA PPUCTRLBUF
;     AND #$FE
; UPDATE_CAMERA_EXIT:
;     STA PPUCTRLBUF
;     JSR SCROLLFLAG_SET
    RTS

;---------------------------------------
; Converts the world coordinates of the 
; camera into Scroll coordinates for the 
; PPU. If the camera moved then scrolling 
; should take place.
;---------------------------------------