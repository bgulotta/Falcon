
LEVEL_INIT:
    TAX
    LDA #.LOBYTE(Levels)    ; Store level 
    STA LEVEL_PTR           ; in zero page
    LDA #.HIBYTE(Levels)
    STA LEVEL_PTR + 1
LEVEL_INIT_LOOP:
    DEX
    BMI LEVEL_INIT_EXIT
    CLC
    LDA LEVEL_PTR           ; Incrementing the ACTOR_PTR by
    ADC #.SIZEOF(Level)     ; the size of the Actor object
    LDA LEVEL_PTR + 1
    ADC #$00
    JMP LEVEL_INIT_LOOP
LEVEL_INIT_EXIT:
    JSR SET_META_TILE_ZP
    JSR SET_SCREEN_ZP
    RTS

SET_META_TILE_ZP:
    LDY #LEVEL_DATA::MetaTileSet
    LDA (LEVEL_PTR), Y
    STA META_TILE_PTR
    LDY #LEVEL_DATA::MetaTileSet + 1
    LDA (LEVEL_PTR), Y
    STA META_TILE_PTR + 1
SET_META_TILE_ZP_EXIT:
    RTS

SET_SCREEN_ZP:
    LDY #LEVEL_DATA::Screens
    LDA (LEVEL_PTR), Y
    STA SCREEN_PTR
    LDY #LEVEL_DATA::Screens + 1
    LDA (LEVEL_PTR), Y
    STA SCREEN_PTR + 1
SET_SCREEN_ZP_EXIT:
    JSR SET_METAMETA_TILE_ZP
    RTS

SET_METAMETA_TILE_ZP:
    LDY #SCREEN_DATA::MetaMetaTiles
    LDA (SCREEN_PTR), Y
    STA METAMETA_TILE_PTR
    LDY #SCREEN_DATA::MetaMetaTiles + 1
    LDA (SCREEN_PTR), Y
    STA METAMETA_TILE_PTR + 1
SET_METAMETA_TILE_ZP_EXIT:
    RTS

SCREEN_TO_PPU:
    
    RTS

; POINT_TO_META:
;     TAY                     ; Transfer Actor Type to Y
;     LDA #.LOBYTE(Meta) ; Store start of actor's metadata 
;     STA META_PTR      ; In zero page
;     LDA #.HIBYTE(Meta)
;     STA META_PTR + 1
;     TYA                     ; Restore Actor Index to A
; POINT_TO_META_LOOP:
;     BEQ POINT_TO_META_EXIT ; Are we done iterating through the actors?
; NEXT_META:
;     CLC                     ; Otherwise loop through the actor's meta one at a time
;     LDA META_PTR       ; Incrementing the ACTOR_META_PTR by
;     ADC #$08                ; the size of the meta data
;     STA META_PTR           ; If carry is clear after add then no need to 
;     BCC POINT_TO_META_NEXT     ; increment the high byte of the address
;     INC META_PTR + 1       ; Otherwise increment high byte of addresss
; POINT_TO_META_NEXT:
;     DEY
;     JMP POINT_TO_META_LOOP 
; POINT_TO_META_EXIT:
;     RTS
