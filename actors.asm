.SEGMENT "CODE"

ACTORS_INIT:
    LDA #.LOBYTE(Actors)    ; Store start of actor 
    STA ACTOR_PTR           ; In zero page
    LDA #.HIBYTE(Actors)
    STA ACTOR_PTR + 1
    LDX #$00
    JMP SET_ACTOR_PTR_NEXT
SET_ACTOR_PTR_FIRST:
    LDY #ACTOR_DATA::Index  ; Store the actors
    TXA                     ; index
    STA (ACTOR_PTR), Y
    LDA #.LOBYTE(Actors)    ; Store start of actor 
    LDY #ACTOR_DATA::NextActor
    STA (ACTOR_PTR), Y
    LDA #.HIBYTE(Actors)
    LDY #ACTOR_DATA::NextActor + 1
    STA (ACTOR_PTR), Y
    RTS
SET_ACTOR_PTR_NEXT:
    LDY #ACTOR_DATA::Index  ; Store the actors
    TXA                     ; index
    STA (ACTOR_PTR), Y
    CLC
    LDA ACTOR_PTR           ; Incrementing the ACTOR_PTR by
    ADC #.SIZEOF(Actor)     ; the size of the Actor object
    LDY #ACTOR_DATA::NextActor
    STA (ACTOR_PTR), Y
    PHA
    LDA ACTOR_PTR + 1
    ADC #$00
    LDY #ACTOR_DATA::NextActor + 1
    STA (ACTOR_PTR), Y
    STA ACTOR_PTR + 1
    PLA
    STA ACTOR_PTR
INTIALIZE_ACTORS_NEXT:
    INX
    CPX #ActorCount - 1
    BCC SET_ACTOR_PTR_NEXT
    BEQ SET_ACTOR_PTR_FIRST
INTIALIZE_ACTORS_EXIT:
    RTS

FIRST_ACTOR:
    PHA 
    LDA #.LOBYTE(Actors)    ; Store start of actor 
    STA ACTOR_PTR           ; In zero page
    LDA #.HIBYTE(Actors)
    STA ACTOR_PTR + 1
    JSR SET_META_ZP
    PLA
    RTS

LAST_ACTOR:
    PHA 
    LDA #.LOBYTE(LastActor)    ; Store start of actor 
    STA ACTOR_PTR           ; In zero page
    LDA #.HIBYTE(LastActor)
    STA ACTOR_PTR + 1
    JSR SET_META_ZP
    PLA
    RTS

NEXT_ACTOR:
    PHA
    LDY #ACTOR_DATA::NextActor
    LDA (ACTOR_PTR), Y
    PHA 
    LDY #ACTOR_DATA::NextActor + 1
    LDA (ACTOR_PTR), Y   
    STA ACTOR_PTR + 1
    PLA
    STA ACTOR_PTR
    JSR SET_META_ZP
    PLA
    RTS

PREV_ACTOR:
    LDY #ACTOR_DATA::Index
    LDA (ACTOR_PTR), Y
    BEQ PREV_ACTOR_EXIT         ; Are we already pointing at the first actor in the list?
    LDY #ACTOR_DATA::NextActor
    LDA (ACTOR_PTR), Y
    PHA 
    LDY #ACTOR_DATA::NextActor + 1
    LDA (ACTOR_PTR), Y   
    STA ACTOR_PTR + 1
    PLA
    STA ACTOR_PTR
    JSR SET_META_ZP
PREV_ACTOR_EXIT:
    RTS

;
; This routine will set the ZP pointer ACTOR_PTR
; to the start of the actor with the specified
; actor index in A
;
POINT_TO_ACTOR:
    JSR FIRST_ACTOR
POINT_TO_ACTOR_LOOP:
    LDY #ACTOR_DATA::Index
    CMP (ACTOR_PTR), Y
    BEQ POINT_TO_ACTOR_EXIT ; If we are wanting the first actor then exit
POINT_TO_ACTOR_NEXT:
    JSR NEXT_ACTOR
    JMP POINT_TO_ACTOR_LOOP
POINT_TO_ACTOR_EXIT:
    RTS

SET_META_ZP:
    LDY #ACTOR_DATA::MetaData
    LDA (ACTOR_PTR), Y
    STA META_PTR
    LDY #ACTOR_DATA::MetaData + 1
    LDA (ACTOR_PTR), Y
    STA META_PTR + 1
SET_META_ZP_EXIT:
    JSR SET_SPRITE_ZP
    RTS

SET_SPRITE_ZP:
    LDY #META_DATA::Sprites
    LDA (META_PTR), Y
    STA SPRITE_PTR
    LDY #META_DATA::Sprites + 1
    LDA (META_PTR), Y
    STA SPRITE_PTR + 1
SET_SPRITE_ZP_EXIT:
    RTS

POINT_TO_META:
    TAY                     ; Transfer Actor Type to Y
    LDA #.LOBYTE(Meta) ; Store start of actor's metadata 
    STA META_PTR      ; In zero page
    LDA #.HIBYTE(Meta)
    STA META_PTR + 1
    TYA                     ; Restore Actor Index to A
POINT_TO_META_LOOP:
    BEQ POINT_TO_META_EXIT ; Are we done iterating through the actors?
NEXT_META:
    CLC                     ; Otherwise loop through the actor's meta one at a time
    LDA META_PTR       ; Incrementing the ACTOR_META_PTR by
    ADC #$08                ; the size of the meta data
    STA META_PTR           ; If carry is clear after add then no need to 
    BCC POINT_TO_META_NEXT     ; increment the high byte of the address
    INC META_PTR + 1       ; Otherwise increment high byte of addresss
POINT_TO_META_NEXT:
    DEY
    JMP POINT_TO_META_LOOP 
POINT_TO_META_EXIT:
    RTS

UPDATE_ACTOR_DATA:
    JSR ACTOR_ACTIVE
    BEQ UPDATE_ACTOR_DATA_EXIT
    LDY #META_DATA::UpdateData
    LDA (META_PTR), Y
    STA JmpPtr
    LDY #META_DATA::UpdateData + 1
    LDA (META_PTR), Y
    STA JmpPtr + 1
    JSR JUMP_TO_FUNC
    JSR UPDATE_WORLD_COORDINATES
    ;JSR UPDATE_TILE_COORDINATES
UPDATE_ACTOR_DATA_EXIT:
    RTS

JUMP_TO_FUNC:
    JMP (JmpPtr)
    RTS

ACTOR_ACTIVE:
    LDA #$01
    LDA #ACTOR_TYPES::Camera 
    LDY #META_DATA::Type
    CMP (META_PTR), Y
    BEQ SET_ACTOR_ACTIVE
    JSR ACTOR_IN_VIEWPORT
    BNE SET_ACTOR_ACTIVE
    JMP SET_ACTOR_INACTIVE

ACTOR_IN_VIEWPORT:
    ; Check X
    SEC                                 ; Is the actor's xpos less than  
    LDA ViewPort + ViewPort::End        ; the end of the view port?
    LDY #ACTOR_DATA::XPos
    SBC (ACTOR_PTR), Y
    LDA ViewPort + ViewPort::End + 1    
    LDY #ACTOR_DATA::XPos + 1
    SBC (ACTOR_PTR), Y
    BCC SET_ACTOR_OUT_VIEWPORT
    SEC                                 ; Is the actor's xpos greater than  
    LDY #ACTOR_DATA::XPos               ; or equal the viewport beginning?
    LDA (ACTOR_PTR), Y
    SBC ViewPort + ViewPort::Begin      
    LDY #ACTOR_DATA::XPos + 1
    LDA (ACTOR_PTR), Y
    SBC ViewPort + ViewPort::Begin + 1  
    BCC SET_ACTOR_OUT_VIEWPORT
    ; Check Y
    SEC                                 ; Is the actor's ypos greater than  
    LDA ViewPort + ViewPort::End + 2    ; or equal to the end of the view port?
    LDY #ACTOR_DATA::YPos
    SBC (ACTOR_PTR), Y
    LDA ViewPort + ViewPort::End + 3    
    LDY #ACTOR_DATA::YPos + 1
    SBC (ACTOR_PTR), Y
    BCC SET_ACTOR_OUT_VIEWPORT
    SEC                                 ; Is the actor's ypos less than  
    LDY #ACTOR_DATA::YPos               ; the start of the view port?
    LDA (ACTOR_PTR), Y
    SBC ViewPort + ViewPort::Begin + 2    
    LDY #ACTOR_DATA::YPos + 1
    LDA (ACTOR_PTR), Y
    SBC ViewPort + ViewPort::Begin + 3  
    BCC SET_ACTOR_OUT_VIEWPORT
SET_ACTOR_IN_VIEWPORT:
    LDA #$01
    JMP ACTOR_IN_VIEWPORT_EXIT
SET_ACTOR_OUT_VIEWPORT:
    LDA #$00
ACTOR_IN_VIEWPORT_EXIT:
    RTS
 
SET_ACTOR_ACTIVE:
    LDA #ACTOR_ATTRIBUTES::Active
    LDY #ACTOR_DATA::Attributes
    ORA (ACTOR_PTR), Y
    STA (ACTOR_PTR), Y
    RTS

SET_ACTOR_INACTIVE:
    LDA #$7F
    LDY #ACTOR_DATA::Attributes
    AND (ACTOR_PTR), Y
    STA (ACTOR_PTR), Y
    RTS

; UPDATE_TILE_COORDINATES:

;     CLC 
;     LDA ACTOR_PTR
;     ADC #ACTOR_DATA::XPos
;     STA COORDINATES_PTR
;     LDA ACTOR_PTR + 1
;     ADC #$00
;     STA COORDINATES_PTR + 1
;     JSR WORLD_TO_TILE_COORDINATES
    
;     RTS

UPDATE_ACTOR_DIRECTION:
    AND #JOYPAD::Left | JOYPAD::Right  ; If we are not moving left or right just exit
    BNE UPDATE_DIRECTION
    JMP UPDATE_ACTOR_DIRECTION_EXIT
UPDATE_DIRECTION:
    LDY #ACTOR_DATA::Attributes
    AND #JOYPAD::Right                 ; Otherwise update the direction 
    BNE UPDATE_DIRECTION_RIGHT
UPDATE_DIRECTION_LEFT:
    LDA (ACTOR_PTR), Y
    AND #$FE       
    JMP UPDATE_DIRECTION_SET
UPDATE_DIRECTION_RIGHT:
    ORA (ACTOR_PTR), Y
UPDATE_DIRECTION_SET:
    STA (ACTOR_PTR), Y
UPDATE_ACTOR_DIRECTION_EXIT:
    RTS

UPDATE_WORLD_COORDINATES:
    LDY #ACTOR_DATA::Movement       ; otherwise we need to process
    LDA (ACTOR_PTR), Y                ; any movement for the player 
    BEQ CHECK_ACTOR_DECELERATE
    JSR SAVE_ACTOR_POSITION
CHECK_MOVE_RIGHT:
    LSR A
    BCC CHECK_MOVE_LEFT
    JSR MOVE_RIGHT
    JMP CHECK_ACTOR_DECELERATE
CHECK_MOVE_LEFT:
    LSR A
    BCC CHECK_MOVE_DOWN
    JSR MOVE_LEFT
    JMP CHECK_ACTOR_DECELERATE
CHECK_MOVE_DOWN:
    LSR A
    BCC CHECK_MOVE_UP
    JSR MOVE_DOWN
CHECK_MOVE_UP:
    LSR A
    BCC UPDATE_POSITION_EXIT
    JSR MOVE_UP
    JMP UPDATE_POSITION_EXIT
CHECK_ACTOR_DECELERATE:
    LDY #ACTOR_DATA::MovementPrev
    LDA (ACTOR_PTR), Y
    LDY #ACTOR_DATA::Movement
    CMP (ACTOR_PTR), Y
    BEQ UPDATE_POSITION_EXIT
    JSR ACTOR_DECELERATE
    JMP UPDATE_POSITION_EXIT
UPDATE_POSITION_EXIT:
    LDY #ACTOR_DATA::Movement
    LDA (ACTOR_PTR), Y
    LDY #ACTOR_DATA::MovementPrev
    STA (ACTOR_PTR), Y
    JSR ACTOR_IN_VIEWPORT
    BEQ RESTORE_ACTOR_POSITION
    RTS

SAVE_ACTOR_POSITION:
    PHA
    LDY #ACTOR_DATA::XPos
    LDA (ACTOR_PTR), Y
    STA Temp
    LDY #ACTOR_DATA::XPos + 1
    LDA (ACTOR_PTR), Y
    STA Temp + 1
    LDY #ACTOR_DATA::YPos
    LDA (ACTOR_PTR), Y
    STA Temp2
    LDY #ACTOR_DATA::YPos + 1
    LDA (ACTOR_PTR), Y
    STA Temp2 + 1
    PLA 
    RTS

RESTORE_ACTOR_POSITION:
    LDA Temp
    LDY #ACTOR_DATA::XPos
    STA (ACTOR_PTR), Y
    LDA Temp + 1
    LDY #ACTOR_DATA::XPos + 1
    STA (ACTOR_PTR), Y
    LDA Temp2
    LDY #ACTOR_DATA::YPos
    STA (ACTOR_PTR), Y
    LDA Temp2 + 1
    LDY #ACTOR_DATA::YPos + 1
    STA (ACTOR_PTR), Y
    RTS

;-----------------------------------------------
;   MOVES ACTOR TO THE RIGHT
;
;-----------------------------------------------
MOVE_RIGHT:
    PHA     
    JSR ACTOR_ACCELERATE
    CLC
    LDY #ACTOR_DATA::Acceleration + 1         
    LDA (ACTOR_PTR), Y    ; Load Actor's Acceleration
    LDY #ACTOR_DATA::XPos           
    ADC (ACTOR_PTR), Y    ; And add it to their XPos
    STA (ACTOR_PTR), Y    ; and store the result.    
    BCC EXIT_MOVE_RIGHT ; If carry flag is clear then exit
    LDY #ACTOR_DATA::XPos + 1                  
    LDA (ACTOR_PTR), Y    ; If carry flag is set then 
    ADC #$00            ; add it to the XPos MSB
    STA (ACTOR_PTR), Y    ; and store the result.
EXIT_MOVE_RIGHT:
    PLA
    RTS
;---------------------------------------------------------------

;---------------------------------------------------------------
; MOVES ACTOR TO THE LEFT
;---------------------------------------------------------------
MOVE_LEFT:
    PHA
    JSR ACTOR_ACCELERATE
    SEC
    LDY #ACTOR_DATA::XPos              
    LDA (ACTOR_PTR), Y                  ; Load the XPos   
    LDY #ACTOR_DATA::Acceleration + 1         
    SBC (ACTOR_PTR), Y                  ; Subtract Acceleration
    LDY #ACTOR_DATA::XPos              
    STA (ACTOR_PTR), Y                  ; Update XPos.
    LDY #ACTOR_DATA::XPos + 1
    LDA (ACTOR_PTR), Y                  ; If carry flag is clear then 
    SBC #$00                            ; subtract 1 from the XPos MSB
    STA (ACTOR_PTR), Y
EXIT_MOVE_LEFT:
    PLA
    RTS
;---------------------------------------------------------------

;---------------------------------------------------------------
; MOVES ACTOR UP
;---------------------------------------------------------------
MOVE_UP: 
    PHA
    SEC
    LDY #ACTOR_DATA::YPos            ; We need to load the current  
    LDA (ACTOR_PTR), Y    ; YPos and subtract the appropriate
    SBC #$01            ; amount taking into account de-acceleration (TODO)
    STA (ACTOR_PTR), Y    ; and store the result.
    BCS EXIT_MOVE_UP    ; If the carry flag is set then exit
    LDY #ACTOR_DATA::YPos + 1
    LDA (ACTOR_PTR), Y    ; If carry flag is clear then 
    SBC #$00            ; subtract 1 from the YPos MSB
    STA (ACTOR_PTR), Y    ; and store the result
EXIT_MOVE_UP:
    PLA
    RTS
;---------------------------------------------------------------

;---------------------------------------------------------------
; MOVES ACTOR DOWN
;---------------------------------------------------------------
MOVE_DOWN: ; TODO: DESCENDING SPEED
    PHA
    CLC
    LDY #ACTOR_DATA::YPos            ; We need to load the current
    LDA (ACTOR_PTR), Y    ; YPos and add the appropriate
    ADC #$01            ; amount taking into account acceleration (TODO)
    STA (ACTOR_PTR), Y    ; and store the result.
    BCC EXIT_MOVE_DOWN ; If carry flag is clear after then exit
    LDY #ACTOR_DATA::YPos + 1                  
    LDA (ACTOR_PTR), Y    ; If carry flag is set then 
    ADC #$00            ; add it to the XPos MSB
    STA (ACTOR_PTR), Y    ; and store the result.
EXIT_MOVE_DOWN:
    PLA
    RTS
;---------------------------------------------------------

ACTOR_DECELERATE:
    LDA #$00
    LDY #ACTOR_DATA::Acceleration   
    STA (ACTOR_PTR), Y
    LDY #ACTOR_DATA::Acceleration + 1     
    STA (ACTOR_PTR), Y
    RTS

ACTOR_ACCELERATE:
    LDY #META_DATA::Speed         ; full speed
    LDA (META_PTR), Y        ; are already accelerating at
    LDY #ACTOR_DATA::Acceleration + 1 ; Check to see if we 
    CMP (ACTOR_PTR), Y
    BCC EXIT_ACTOR_ACCELERATE
CONTINUE_ACCELERATION:
    CLC       
    LDY #META_DATA::AccelConst
    LDA (META_PTR), Y    
    LDY #ACTOR_DATA::Acceleration
    ADC (ACTOR_PTR), Y                ; and add it to our fractional acceleration
    STA (ACTOR_PTR), Y                ; saving the result
    BCC EXIT_ACTOR_ACCELERATE       ; if carry is clear exit 
    LDY #ACTOR_DATA::Acceleration + 1   
    LDA (ACTOR_PTR), Y    ; otherwise add the carry
    ADC #$00            ; to the whole acceleration variable
    STA (ACTOR_PTR), Y    ; and store it 
EXIT_ACTOR_ACCELERATE:
    RTS

ACTOR_TO_SCREEN_COORD: 
    SEC
    LDY #ACTOR_DATA::XPos                   ; Subtract the actor's
    LDA (ACTOR_PTR), Y                      ; XPos with start of the viewport
    SBC ViewPort + ViewPort::Begin          ; the end of the view port?
    STA Temp                     ; ScreenX
    LDY #ACTOR_DATA::XPos + 1               ; Subtract the actor's
    LDA (ACTOR_PTR), Y                      ; XPos with start of the viewport
    SBC ViewPort + ViewPort::Begin + 1      ; the end of the view port?
    STA Temp + 1                     ; ScreenX

    LDY #ACTOR_DATA::YPos                   ; Subtract the actor's
    LDA (ACTOR_PTR), Y                      ; XPos with start of the viewport
    SBC ViewPort + ViewPort::Begin + 2          ; the end of the view port?
    STA Temp2                     ; ScreenX
    LDY #ACTOR_DATA::YPos + 1               ; Subtract the actor's
    LDA (ACTOR_PTR), Y                      ; XPos with start of the viewport
    SBC ViewPort + ViewPort::Begin + 3      ; the end of the view port?
    STA Temp2 + 1                     ; ScreenX

    RTS

ACTOR_TO_OAM:
    LDY #ACTOR_DATA::Attributes     ; If the actor is not active on screen 
    LDA (ACTOR_PTR), Y              ; then don't attempt to render them
    BPL ACTOR_TO_OAM_EXIT
    JSR ACTOR_TO_SCREEN_COORD
    LDY #$00
    LDA (SPRITE_PTR), Y ; Get the # of Tiles that make up this actor
    STA NumTiles        ; and store the number
    LDX OamIndex 
TILE_LOOP:
    INY   
    SEC 
    CLC             
    LDA (SPRITE_PTR), Y ; Y Offset
    ADC Temp2
    STA OAM, X
    INX
    INY 
    LDA (SPRITE_PTR), Y ; Tile Index
    STA OAM, X
    INX 
    INY 
    LDA (SPRITE_PTR), Y ; Tile Attributes
    STA OAM, X
    INX
    INY 
    CLC             
    LDA (SPRITE_PTR), Y ; X Offset
    ADC Temp
    STA OAM, X
    INX
    STX OamIndex
    DEC NumTiles 
    BNE TILE_LOOP
ACTOR_TO_OAM_EXIT:
    RTS