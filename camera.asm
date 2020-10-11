.SEGMENT "CODE"

;---------------------------------------------
; This AI subroutine will start moving the   
; camera to it's destination 
;---------------------------------------------
UPDATE_CAMERA:
    LDY #ACTOR_DATA::XPos       ; Grab the camera's 
    LDA (ACTOR_PTR), Y          ; current x position
    STA Temp4
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
    JSR UPDATE_WORLD_COORDINATES
    JSR UPDATE_VIEWPORT
    JSR DECODE_LEVEL_DATA
    JSR RENDER_LEVEL_DATA
    RTS

;--------------------------------------------------;
;                                                  ;
;                                                  ;
;                                                  ;
;                                                  ;
;                                                  ;
;--------------------------------------------------;
DECODE_LEVEL_DATA:
    LDY #ACTOR_DATA::XPos       ; Grab the camera's 
    EOR (ACTOR_PTR), Y          ; current x position
    AND #$20
    BEQ DECODE_LEVEL_DATA_EXIT
UPDATE_LEVEL_DATA:
    LDY #ACTOR_DATA::Attributes       ; Grab the camera's 
    LDA (ACTOR_PTR), Y          ; current x position
    AND #JOYPAD::Right
    BEQ DECODE_LEVEL_DATA_LEFT
DECODE_LEVEL_DATA_RIGHT:
    LDA #.LOBYTE(ViewPort + ViewPort::End)
    STA COORDINATES_PTR
    LDA #.HIBYTE(ViewPort + ViewPort::End)
    STA COORDINATES_PTR + 1
    JSR DECODE_LEVEL_DATA_NEXT
    RTS
DECODE_LEVEL_DATA_LEFT:
    LDA #.LOBYTE(ViewPort + ViewPort::Begin)
    STA COORDINATES_PTR
    LDA #.HIBYTE(ViewPort + ViewPort::Begin)
    STA COORDINATES_PTR + 1
    JSR DECODE_LEVEL_DATA_NEXT
DECODE_LEVEL_DATA_EXIT: 
    RTS 

DECODE_LEVEL_DATA_NEXT:
    LDY #COORDINATES::XPos
    LDA (COORDINATES_PTR), Y
    STA Temp
    LDA #$00
    STA Temp + 1
    LDA #$10            ; Divide X LSB by 32 to get MetaMetaTile column to render
    STA NumIterations
    JSR DIVIDE
    LDA Temp 
    CMP MetaMetaTile + MetaTile::Index
    BEQ DECODE_LEVEL_DATA_NEXT_EXIT
DECODE_LEVEL_SELECT_SCREEN:
    LDY #COORDINATES::XPos + 1
    LDA (COORDINATES_PTR), Y
    LDY #SCREEN_DATA::Index 
    CMP (SCREEN_PTR), Y 
    BCC DECODE_LEVEL_PREV_SCREEN
    BEQ DECODE_META_META_TILE_COLUMN
DECODE_LEVEL_NEXT_SCREEN:
    JSR SET_SCREEN_NEXT
    JMP DECODE_META_META_TILE_COLUMN
DECODE_LEVEL_PREV_SCREEN:
    JSR SET_SCREEN_PREV
DECODE_META_META_TILE_COLUMN:
    LDA Temp
    JSR DECODE_META_META_TILE_COL
DECODE_LEVEL_DATA_NEXT_EXIT:
    RTS

RENDER_LEVEL_DATA:
    BIT DECODEDFLAG 
    BPL RENDER_LEVEL_DATA_EXIT ; Has a tile been decoded?
    BVS RENDER_LEVEL_DATA_EXIT ; Has a tile already been rendered?
    JSR TILEBUF_TO_PPU
RENDER_LEVEL_DATA_EXIT:
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
   