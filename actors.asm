.SEGMENT "CODE"
;
; This routine will set the ZP pointer OBJ_PTR
; to the start of the actor with the specified
; actor index in A
;
POINT_TO_ACTOR:
    TAY                     ; Transfer Actor Index to Y
    LDA #.LOBYTE(Actors)    ; Store start of actors 
    STA OBJ_PTR             ; In zero page
    LDA #.HIBYTE(Actors)
    STA OBJ_PTR + 1
    TYA                     ; Restore Actor Index to A
POINT_TO_ACTOR_LOOP:
    BEQ POINT_TO_ACTOR_EXIT ; Are we done iterating through the actors?
    CLC                     ; Otherwise loop through the actors one at a time
    LDA OBJ_PTR             ; Incrementing the OBJ_PTR by
    ADC #.SIZEOF(Actor)     ; the size of the Actor object
    STA OBJ_PTR             ; If carry is clear after add then no need to 
    BCC POINT_TO_ACTOR_NEXT ; increment the high byte of the address
    INC OBJ_PTR + 1         ; Otherwise increment high byte of addresss
POINT_TO_ACTOR_NEXT:
    DEY
    JMP POINT_TO_ACTOR_LOOP 
POINT_TO_ACTOR_EXIT:
    RTS

UPDATE_ACTOR_DATA:
    JSR RD_ACTOR_BUF   ; Data index in A
    TAY
    JSR RD_ACTOR_BUF   ; Num bytes in A
    TAX
UPDATE_ACTOR_DATA_LOOP:  
    TXA                ; Save X
    PHA                ; To the Stack
    JSR RD_ACTOR_BUF   ; Grab Data from Buffer
    STA (OBJ_PTR), Y   ; Update Actor
    PLA                ; Restore X
    TAX                ; From the Stack
    INY 
    DEX
    BNE UPDATE_ACTOR_DATA_LOOP
    RTS

UPDATE_POSITION:
    LDY #ACTOR_INDEX::Attributes
    LDA (OBJ_PTR), Y                ; If the actor is not active 
    BPL MOVE_OFFSCREEN              ; then make sure they are offscreen
    LDY #ACTOR_INDEX::Movement       ; otherwise we need to process
    LDA (OBJ_PTR), Y                ; any movement for the player 
CHECK_MOVE_RIGHT:
    LSR A
    BCC CHECK_MOVE_LEFT
    JSR MOVE_RIGHT
CHECK_MOVE_LEFT:
    LSR A
    BCC CHECK_MOVE_DOWN
    JSR MOVE_LEFT
CHECK_MOVE_DOWN:
    LSR A
    BCC CHECK_MOVE_UP
    JSR MOVE_DOWN
CHECK_MOVE_UP:
    LSR A
    BCC UPDATE_POSITION_EXIT
    JSR MOVE_UP
    JMP UPDATE_POSITION_EXIT
MOVE_OFFSCREEN:
    LDY #ACTOR_INDEX::YPos ; YPos LSB 
    LDA #$FF                    
    STA (OBJ_PTR), Y       ; Update YPos LSB
UPDATE_POSITION_EXIT:
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
    LDA (OBJ_PTR), Y    ; Load Actor's Acceleration
    LDY #ACTOR_INDEX::XPos           
    ADC (OBJ_PTR), Y    ; And add it to their XPos
    STA (OBJ_PTR), Y    ; and store the result.    
    BCC EXIT_MOVE_RIGHT ; If carry flag is clear then exit
    LDY #ACTOR_INDEX::XPos + 1                  
    LDA (OBJ_PTR), Y    ; If carry flag is set then 
    ADC #$00            ; add it to the XPos MSB
    STA (OBJ_PTR), Y    ; and store the result.
EXIT_MOVE_RIGHT:
    PLA
    RTS
;---------------------------------------------------------------

;---------------------------------------------------------------
; MOVES ACTOR TO THE LEFT
;---------------------------------------------------------------
MOVE_LEFT:
    PHA
    SEC
    LDY #ACTOR_INDEX::XPos            ; We need to load the current  
    LDA (OBJ_PTR), Y    ; XPos and subtract the appropriate
    SBC #$01            ; amount taking into account de-acceleration (TODO)
    STA (OBJ_PTR), Y    ; and store the result.
    BCS EXIT_MOVE_LEFT  ; If the carry flag is set then exit
    LDY #ACTOR_INDEX::XPos + 1
    LDA (OBJ_PTR), Y    ; If carry flag is clear then 
    SBC #$00            ; subtract 1 from the XPos MSB
    STA (OBJ_PTR), Y    ; and store the result
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
    LDA (OBJ_PTR), Y    ; YPos and subtract the appropriate
    SBC #$01            ; amount taking into account de-acceleration (TODO)
    STA (OBJ_PTR), Y    ; and store the result.
    BCS EXIT_MOVE_UP    ; If the carry flag is set then exit
    LDY #ACTOR_INDEX::YPos + 1
    LDA (OBJ_PTR), Y    ; If carry flag is clear then 
    SBC #$00            ; subtract 1 from the YPos MSB
    STA (OBJ_PTR), Y    ; and store the result
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
    LDA (OBJ_PTR), Y    ; YPos and add the appropriate
    ADC #$01            ; amount taking into account acceleration (TODO)
    STA (OBJ_PTR), Y    ; and store the result.
    BCC EXIT_MOVE_DOWN ; If carry flag is clear after then exit
    LDY #ACTOR_INDEX::YPos + 1                  
    LDA (OBJ_PTR), Y    ; If carry flag is set then 
    ADC #$00            ; add it to the XPos MSB
    STA (OBJ_PTR), Y    ; and store the result.
EXIT_MOVE_DOWN:
    PLA
    RTS
;---------------------------------------------------------

ACTOR_ACCELERATE:
    LDY #ACTOR_INDEX::Velocity         ; full speed
    LDA (OBJ_PTR), Y                   ; are already accelerating at
    LDY #ACTOR_INDEX::Acceleration + 1 ; Check to see if we 
    CMP (OBJ_PTR), Y
    BCC EXIT_ACTOR_ACCELERATE
;RESET_ACCELERATION:
;    LDA #$00
;    STA (OBJ_PTR), Y
CONTINUE_ACCELERATION:
    CLC       
    LDY #ACTOR_INDEX::Const_Acc
    LDA (OBJ_PTR), Y    
    LDY #ACTOR_INDEX::Acceleration
    ADC (OBJ_PTR), Y                ; and add it to our fractional acceleration
    STA (OBJ_PTR), Y                ; saving the result
    BCC EXIT_ACTOR_ACCELERATE       ; if carry is clear exit 
    LDY #ACTOR_INDEX::Acceleration + 1   
    LDA (OBJ_PTR), Y    ; otherwise add the carry
    ADC #$00            ; to the whole acceleration variable
    STA (OBJ_PTR), Y    ; and store it 
EXIT_ACTOR_ACCELERATE:
    RTS

ACTORS_TO_SCREEN: 
    LDX NUM_ACTORS
ACTORS_TO_SCREEN_LOOP:
    DEX
    BMI ACTORS_TO_SCREEN_EXIT
    TXA
    JSR POINT_TO_ACTOR
    LDY #ACTOR_INDEX::YPos            ; TODO: Convert YPos to screen pos
    LDA (OBJ_PTR), Y
    STA OAM 
    LDA #%00000001      ; TODO: Tile index number
    STA OAM+1
    LDA #%00000001      ; TODO: Pattern table attributes
    STA OAM+2
    LDY #ACTOR_INDEX::XPos           ; TODO: Convert XPos to screen pos
    LDA (OBJ_PTR), Y
    STA OAM+3
    JMP ACTORS_TO_SCREEN_LOOP

ACTORS_TO_SCREEN_EXIT:
    JSR OAM_SET
    RTS