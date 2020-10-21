.INCLUDE "HEADER.ASM"
.INCLUDE "ENUMS.ASM"
.INCLUDE "STRUCTS.ASM"
.INCLUDE "MACROS.ASM"
.INCLUDE "NES_SYMBOLS.ASM"
.INCLUDE "GAME_SYMBOLS.ASM"
.INCLUDE "UTILITIES.ASM"
.INCLUDE "BUFFERS.ASM"
.INCLUDE "IO.ASM"
.INCLUDE "PPU.ASM"
.INCLUDE "RESET.ASM"
.INCLUDE "INTERRUPTS.ASM"
.INCLUDE "LEVEL_DATA.ASM"
.INCLUDE "ACTOR_DATA.ASM"
.INCLUDE "LEVEL.ASM"
.INCLUDE "ACTORS.ASM"
.INCLUDE "PLAYER.ASM"
.INCLUDE "CAMERA.ASM"
.INCLUDE "VIEWPORT.ASM"

.SEGMENT "CODE"

MAIN:
    LDX #$FF        ; INITIALIZE BUFFER POINTERS
    STX CMD_RPTR
    STX CMD_WPTR

LOAD_PALETTES:      ; UPDATE BACKGROUND AND SPRITE PALETTE DATA
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

    LDA #(PPUCTRL::NMI_ENABLE | PPUCTRL::VRAM_INC) ; INITIAL PPUCTRL WRITE HAS TO ENABLE NMI INTERRUPTS; SUBSEQUENT WRITES TO PPUCTRL WILL BE BUFFERED AND TAKE PLACE IN NMI
    STA PPUCTRL 
    STA PPUCTRLBUF  ; TODO: FIGURE OUT WHY THIS IS NECESSARY
    
    LDA #(PPUMASK::SHOW_BG | PPUMASK::SHOW_SPR | PPUMASK::SHOW_BG_8 | PPUMASK::SHOW_SPR_8) ; SUBSEQUENT WRITES TO PPUMASK WILL BE BUFFERED AND TAKE PLACE IN NMI
    STA PPUMASK
    STA PPUMASKBUF

    CLI             ; RESPOND TO INTERRUPTS

    JSR SET_NMI_FLAGS

    LDA #$00
    JSR LEVEL_INIT
    JSR ACTORS_INIT

    ACTOR_INIT  $01, $00, $20, $00
    ACTOR_INIT  $00, $01, $00, $00
    
;---------------------------------------
; Main Game Loop
;---------------------------------------
GAME_LOOP:
    JSR SET_NMI_FLAGS
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
SET_NMI_FLAGS:
    LDA #BITS::BIT_7
    STA OAMFLAG
    STA PPUREGFLAG
    RTS
    
;---------------------------------------
.SEGMENT "RODATA"
PALETTE: 
    .BYTE $22, $16, $27, $18, $22, $1A, $30, $27, $22, $16, $30, $27, $22, $0F, $36, $17 ; SPRITES
    .BYTE $22, $29, $1A, $0F, $22, $36, $17, $0F, $22, $30, $21, $0F, $22, $27, $17, $0F ; BACKGROUND

MULT2:
    .BYTE $00, $02, $04, $06
MULT4:
    .BYTE $00, $04, $08, $0C, $10, $14, $18, $1C 
MULT16:
    .BYTE $00, $10, $20, $30, $40, $50, $60, $70, $80, $90, $A0, $B0, $C0, $D0, $E0, $F0 
MOD2:
    .BYTE $00, $01, $00, $01, $00, $01, $00, $01, $00, $01, $00, $01, $00, $01, $00
PPUBASELO:
    .BYTE $40, $00
PPUBASEHI:
    .BYTE $20, $24
DEFAULTHUD:
    .BYTE $00, 00, 00, 00, 00, 00, 00, 00, 00, 00, 00, 00, 00, 00, 00, 00, $00, 00, 00, 00, 00, 00, 00, 00, 00, 00, 00, 00, 00, 00, 00, 00
    .BYTE $00, 00, 00, 00, 00, 00, 00, 00, 00, 00, 00, 00, 00, 00, 00, 00, $00, 00, 00, 00, 00, 00, 00, 00, 00, 00, 00, 00, 00, 00, 00, 00

.SEGMENT "TILES"
.INCBIN "CHR.DAT"

.SEGMENT "VECTORS"
.ADDR NMI, RESET, IRQ