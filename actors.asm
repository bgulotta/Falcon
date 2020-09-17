.SEGMENT "CODE"


;
; This routine will set the ZP pointer ACTOR_PTR
; to the start of the actor with the specified
; actor index in A
;
POINT_TO_ACTOR:
    TAY                     ; Transfer Actor Index to Y
    LDA #.LOBYTE(Actors)    ; Store start of actor 
    STA ACTOR_PTR           ; In zero page
    LDA #.HIBYTE(Actors)
    STA ACTOR_PTR + 1
    TYA                     ; Restore Actor Index to A
POINT_TO_ACTOR_LOOP:
    BEQ POINT_TO_ACTOR_EXIT ; Are we done iterating through the actors?
NEXT_ACTOR:
    CLC                     ; Otherwise loop through the actors one at a time
    LDA ACTOR_PTR           ; Incrementing the ACTOR_PTR by
    ADC #.SIZEOF(Actor)     ; the size of the Actor object
    STA ACTOR_PTR           ; If carry is clear after add then no need to 
    BCC POINT_TO_ACTOR_NEXT     ; increment the high byte of the address
    INC ACTOR_PTR + 1       ; Otherwise increment high byte of addresss
POINT_TO_ACTOR_NEXT:
    DEY
    JMP POINT_TO_ACTOR_LOOP
POINT_TO_ACTOR_EXIT:
    JSR SET_META_ZP
    RTS

SET_META_ZP:
    LDY #ACTOR_INDEX::Attributes        ; If the actor has not been 
    LDA (ACTOR_PTR), Y                  ; initialized then we 
    BPL SET_META_ZP_EXIT
    LDY #ACTOR_INDEX::MetaData
    LDA (ACTOR_PTR), Y
    STA META_PTR
    LDY #ACTOR_INDEX::MetaData + 1
    LDA (ACTOR_PTR), Y
    STA META_PTR + 1
SET_META_ZP_EXIT:
    JSR SET_SPRITE_ZP
    RTS

SET_SPRITE_ZP:
    LDY #ACTOR_INDEX::Attributes        ; If the actor has not been 
    LDA (ACTOR_PTR), Y                  ; initialized then we 
    BPL SET_SPRITE_ZP_EXIT
    LDY #META_INDEX::Sprites
    LDA (META_PTR), Y
    STA SPRITE_PTR
    LDY #META_INDEX::Sprites + 1
    LDA (META_PTR), Y
    STA SPRITE_PTR + 1
SET_SPRITE_ZP_EXIT:
    RTS

POINT_TO_META:
    TAY                     ; Transfer Actor Type to Y
    LDA #.LOBYTE(ActorMeta) ; Store start of actor's metadata 
    STA META_PTR      ; In zero page
    LDA #.HIBYTE(ActorMeta)
    STA META_PTR + 1
    TYA                     ; Restore Actor Index to A
POINT_TO_META_LOOP:
    BEQ POINT_TO_META_EXIT ; Are we done iterating through the actors?
NEXT_META:
    CLC                     ; Otherwise loop through the actor's meta one at a time
    LDA META_PTR       ; Incrementing the ACTOR_META_PTR by
    ADC #$06                ; the size of the meta data
    STA META_PTR           ; If carry is clear after add then no need to 
    BCC POINT_TO_META_NEXT     ; increment the high byte of the address
    INC META_PTR + 1       ; Otherwise increment high byte of addresss
POINT_TO_META_NEXT:
    DEY
    JMP POINT_TO_META_LOOP 
POINT_TO_META_EXIT:
    RTS

UPDATE_ACTOR_DATA:
    CPX #$00
    BNE UPDATE_ACTOR_DATA_EXIT
    LDY #ACTOR_INDEX::Movement
    LDA JOYPAD1
    STA (ACTOR_PTR), Y    
UPDATE_ACTOR_DATA_EXIT:
    RTS


UPDATE_POSITION:
    LDY #ACTOR_INDEX::Movement       ; otherwise we need to process
    LDA (ACTOR_PTR), Y                ; any movement for the player 
    BEQ CHECK_ACTOR_DECELERATE
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
    LDY #ACTOR_INDEX::MovementPrev
    LDA (ACTOR_PTR), Y
    LDY #ACTOR_INDEX::Movement
    CMP (ACTOR_PTR), Y
    BEQ UPDATE_POSITION_EXIT
    JSR ACTOR_DECELERATE
    JMP UPDATE_POSITION_EXIT
UPDATE_POSITION_EXIT:
    LDY #ACTOR_INDEX::Movement
    LDA (ACTOR_PTR), Y
    LDY #ACTOR_INDEX::MovementPrev
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
    LDY #ACTOR_INDEX::Acceleration + 1         
    LDA (ACTOR_PTR), Y    ; Load Actor's Acceleration
    LDY #ACTOR_INDEX::XPos           
    ADC (ACTOR_PTR), Y    ; And add it to their XPos
    STA (ACTOR_PTR), Y    ; and store the result.    
    BCC EXIT_MOVE_RIGHT ; If carry flag is clear then exit
    LDY #ACTOR_INDEX::XPos + 1                  
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
    LDY #ACTOR_INDEX::XPos            ; We need to load the current  
    LDA (ACTOR_PTR), Y    ; Load Actor's Acceleration
    LDY #ACTOR_INDEX::Acceleration + 1         
    SBC (ACTOR_PTR), Y    ; XPos and subtract the appropriate
    LDY #ACTOR_INDEX::XPos            ; We need to load the current  
    STA (ACTOR_PTR), Y    ; and store the result.
    BCS EXIT_MOVE_LEFT  ; If the carry flag is set then exit
    LDY #ACTOR_INDEX::XPos + 1
    LDA (ACTOR_PTR), Y    ; If carry flag is clear then 
    SBC #$00            ; subtract 1 from the XPos MSB
    STA (ACTOR_PTR), Y    ; and store the result
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
    LDY #ACTOR_INDEX::YPos            ; We need to load the current  
    LDA (ACTOR_PTR), Y    ; YPos and subtract the appropriate
    SBC #$01            ; amount taking into account de-acceleration (TODO)
    STA (ACTOR_PTR), Y    ; and store the result.
    BCS EXIT_MOVE_UP    ; If the carry flag is set then exit
    LDY #ACTOR_INDEX::YPos + 1
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
    LDY #ACTOR_INDEX::YPos            ; We need to load the current
    LDA (ACTOR_PTR), Y    ; YPos and add the appropriate
    ADC #$01            ; amount taking into account acceleration (TODO)
    STA (ACTOR_PTR), Y    ; and store the result.
    BCC EXIT_MOVE_DOWN ; If carry flag is clear after then exit
    LDY #ACTOR_INDEX::YPos + 1                  
    LDA (ACTOR_PTR), Y    ; If carry flag is set then 
    ADC #$00            ; add it to the XPos MSB
    STA (ACTOR_PTR), Y    ; and store the result.
EXIT_MOVE_DOWN:
    PLA
    RTS
;---------------------------------------------------------

ACTOR_DECELERATE:
    LDA #$00
    LDY #ACTOR_INDEX::Acceleration   
    STA (ACTOR_PTR), Y
    LDY #ACTOR_INDEX::Acceleration + 1     
    STA (ACTOR_PTR), Y
    RTS

ACTOR_ACCELERATE:
    LDY #META_INDEX::Speed         ; full speed
    LDA (META_PTR), Y        ; are already accelerating at
    LDY #ACTOR_INDEX::Acceleration + 1 ; Check to see if we 
    CMP (ACTOR_PTR), Y
    BCC EXIT_ACTOR_ACCELERATE
CONTINUE_ACCELERATION:
    CLC       
    LDY #META_INDEX::AccelConst
    LDA (META_PTR), Y    
    LDY #ACTOR_INDEX::Acceleration
    ADC (ACTOR_PTR), Y                ; and add it to our fractional acceleration
    STA (ACTOR_PTR), Y                ; saving the result
    BCC EXIT_ACTOR_ACCELERATE       ; if carry is clear exit 
    LDY #ACTOR_INDEX::Acceleration + 1   
    LDA (ACTOR_PTR), Y    ; otherwise add the carry
    ADC #$00            ; to the whole acceleration variable
    STA (ACTOR_PTR), Y    ; and store it 
EXIT_ACTOR_ACCELERATE:
    RTS

ACTOR_TO_OAM:
    LDY #ACTOR_INDEX::Attributes    ; If the actor is not active 
    LDA (ACTOR_PTR), Y              ; initialized then check the
    BPL ACTOR_TO_OAM_EXIT           ; next actor
    LDY #ACTOR_INDEX::XPos          ; Save the actors 
    LDA (ACTOR_PTR), Y              ; current position
    STA Actor_XPos                  ; for incrementing
    LDY #ACTOR_INDEX::YPos          ; the tile position
    LDA (ACTOR_PTR), Y              ; below.
    STA Actor_YPos
    LDY #$00
    LDA (SPRITE_PTR), Y ; Get the # of Tiles that make up this actor
    STA NumTiles        ; and store the number
    LDX OamIndex 
TILE_LOOP:
    INY   
    ; TODO: SUBTRACT CAMERA POSITION
    CLC             
    LDA (SPRITE_PTR), Y ; Y Offset
    ADC Actor_YPos
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
    ; TODO: SUBTRACT CAMERA POSITION
    CLC             
    LDA (SPRITE_PTR), Y ; X Offset
    ADC Actor_XPos
    STA OAM, X
    INX
    STX OamIndex
    DEC NumTiles 
    BNE TILE_LOOP
ACTOR_TO_OAM_EXIT:
    RTS