.INCLUDE "HEADER.ASM"
.INCLUDE "ENUMS.ASM"
.INCLUDE "STRUCTS.ASM"
.INCLUDE "MACROS.ASM"
.INCLUDE "NES_SYMBOLS.ASM"
.INCLUDE "GAME_SYMBOLS.ASM"
.INCLUDE "UTILITIES.ASM"
.INCLUDE "BUFFERS.ASM"
.INCLUDE "IO.ASM"
.INCLUDE "RESET.ASM"
.INCLUDE "INTERRUPTS.ASM"
.INCLUDE "LEVEL_DATA.ASM"
.INCLUDE "ACTOR_DATA.ASM"
.INCLUDE "LEVEL.ASM"
.INCLUDE "ACTORS.ASM"
.INCLUDE "PLAYER.ASM"
.INCLUDE "CAMERA.ASM"

.SEGMENT "CODE"

MAIN:
    LDX #$FF        ; INITIALIZE BUFFER POINTERS
    STX CMD_RPTR
    STX CMD_WPTR

LOAD_PALETTES:      ; UPDATE BACKGROUND AND SPRITE PALETTE DATA
    ;LDA #$20        ; NUMBER OF PALETTE DATA BYTES
    ;JSR WR_BUF 
    LDA #$3F        ; MSB PALETTE VRAM ADDRESS
    STA PPUADDR
    LDA #$00        ; LSB PALETTE VRAM ADDRESS
    STA PPUADDR
    LDX #$00  
LOOP_PALETTE_DATA:      
    LDA PALETTE, X  ; WITH THE PALETTE DATA STORED IN ROM
    STA PPUDATA
    INX
    CPX #$20
    BNE LOOP_PALETTE_DATA
    ;JSR CMD_SET
; LOAD_BACKGROUND:
;     ;LDA #$40
;     ;JSR WR_BUF
;     LDA #$20        ;
;     STA PPUADDR
;     LDA #$00        ; THE ADDRESS LATCH SHOULD ALREADY BE CLEARED 
;     STA PPUADDR
;     LDA #$04
;     LDY #$40
; LOOP_BACKGROUND_DATA:
;     STA PPUDATA
;     DEY
;     BNE LOOP_BACKGROUND_DATA
;     ;JSR CMD_SET
; LOAD_ATTRIBUTES:
;     ;LDA #$01
;     ;JSR WR_BUF
;     LDA #$23        ;
;     STA PPUADDR
;     LDA #$C0        ; THE ADDRESS LATCH SHOULD ALREADY BE CLEARED 
;     STA PPUADDR
;     LDA #(3 << 6) | (3 << 4) | (3 << 2) | (3 << 0)
;     STA PPUDATA 
;     ;JSR CMD_SET

    LDA #(PPUCTRL::NMI_ENABLE | PPUCTRL::PT_ADDR_BG) ; INITIAL PPUCTRL WRITE HAS TO ENABLE NMI INTERRUPTS; SUBSEQUENT WRITES TO PPUCTRL WILL BE BUFFERED AND TAKE PLACE IN NMI
    STA PPUCTRL 
    STA PPUCTRLBUF  ; TODO: FIGURE OUT WHY THIS IS NECESSARY
    
    LDA #(PPUMASK::SHOW_BG | PPUMASK::SHOW_SPR | PPUMASK::SHOW_BG_8 | PPUMASK::SHOW_SPR_8) ; SUBSEQUENT WRITES TO PPUMASK WILL BE BUFFERED AND TAKE PLACE IN NMI
    STA PPUMASK

    CLI             ; RESPOND TO INTERRUPTS

    LDA #$00
    JSR LEVEL_INIT
    JSR ACTORS_INIT

    ACTOR_INIT  $01, $00, $60, $20
    ACTOR_INIT  $00, $01, $20, $40
    
;---------------------------------------
; Main Game Loop
;---------------------------------------
GAME_LOOP:
    JSR NMI_WAIT
    JSR READ_JOYPADS
    JSR UPDATE_ACTORS
    JMP GAME_LOOP

;---------------------------------------
;
; This routine will loop through the actor
; buffer and perform updates on the actors
;
;---------------------------------------
UPDATE_ACTORS:  
    LDA #$00
    STA OamIndex
    JSR FIRST_ACTOR
UPDATE_ACTORS_LOOP:
    LDA #ACTOR_ATTRIBUTES::Initialized
    LDY #ACTOR_DATA::Attributes     ; If the actor is not initialized then  
    AND (ACTOR_PTR), Y              ; move on to the next actor slot
    BEQ UPDATE_ACTOR_NEXT 
    JSR UPDATE_ACTOR_DATA
    JSR ACTOR_TO_OAM
UPDATE_ACTOR_NEXT:
    JSR NEXT_ACTOR
    LDY #ACTOR_DATA::Index
    LDA (ACTOR_PTR), Y
    BNE UPDATE_ACTORS_LOOP
UPDATE_ACTORS_EXIT:
    JSR OAM_SET
    RTS

;---------------------------------------
; Subroutine will signal when NMI 
; is complete
;---------------------------------------
NMI_WAIT:
    LDA #BITS::BIT_7
    STA NMI_DONE
NMI_WAIT_LOOP:
    LDA NMI_DONE
    BMI NMI_WAIT_LOOP
    RTS

;---------------------------------------
; Subroutine sets a flag to let the NMI
; handler know that OAM Data needs to 
; be refreshed
;---------------------------------------
OAM_SET:
    LDA #BITS::BIT_7
    STA OAMFLAG
    RTS

;---------------------------------------
; Subroutine sets a flag to let the NMI
; handler know that PPUData needs to 
; be refreshed
;---------------------------------------
CMD_SET:
    INC NumCommands
    RTS

;---------------------------------------
; Subroutine sets a flag to let the NMI
; handler know that PPUMASK needs to 
; be refreshed
;---------------------------------------
PPUMASK_SET:
    LDA #BITS::BIT_7
    STA PPUMASKFLAG
    RTS

;---------------------------------------
; Subroutine sets a flag to let the NMI
; handler know that PPUCTRL needs to 
; be refreshed
;---------------------------------------
PPUCTRL_SET:
    LDA #BITS::BIT_7
    STA PPUCTRLFLAG
    RTS

;---------------------------------------
; Subroutine sets a flag to let the NMI
; handler know that PPUSCROLL needs to 
; be refreshed
;---------------------------------------
SCROLLFLAG_SET:
    LDA #BITS::BIT_7
    STA SCROLLFLAG
    RTS

.SEGMENT "RODATA"
PALETTE: 
    .BYTE $22, $29, $1A, $0F, $22, $36, $17, $0F, $22, $30, $21, $0F, $22, $27, $17, $0F ; BACKGROUND
    .BYTE $22, $16, $27, $18, $22, $1A, $30, $27, $22, $16, $30, $27, $22, $0F, $36, $17 ; SPRITES

.SEGMENT "TILES"
.INCBIN "SPRITE.CHR"
.INCBIN "BACKGROUND.CHR"

.SEGMENT "VECTORS"
.ADDR NMI, RESET, IRQ