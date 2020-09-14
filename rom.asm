.INCLUDE "HEADER.ASM"
.INCLUDE "ENUMS.ASM"
.INCLUDE "STRUCTS.ASM"
.INCLUDE "MACROS.ASM"
.INCLUDE "NES_SYMBOLS.ASM"
.INCLUDE "GAME_SYMBOLS.ASM"
.INCLUDE "BUFFERS.ASM"
.INCLUDE "IO.ASM"
.INCLUDE "RESET.ASM"
.INCLUDE "INTERRUPTS.ASM"
.INCLUDE "ACTORS.ASM"
.INCLUDE "CAMERA.ASM"

.SEGMENT "CODE"

MAIN:
    LDX #$FF        ; INITIALIZE BUFFER POINTERS
    STX CMD_RPTR
    STX CMD_WPTR
    STX ACTOR_RPTR
    STX ACTOR_WPTR

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
LOAD_BACKGROUND:
    ;LDA #$40
    ;JSR WR_BUF
    LDA #$20        ;
    STA PPUADDR
    LDA #$00        ; THE ADDRESS LATCH SHOULD ALREADY BE CLEARED 
    STA PPUADDR
    LDA #$04
    LDY #$40
LOOP_BACKGROUND_DATA:
    STA PPUDATA
    DEY
    BNE LOOP_BACKGROUND_DATA
    ;JSR CMD_SET
LOAD_ATTRIBUTES:
    ;LDA #$01
    ;JSR WR_BUF
    LDA #$23        ;
    STA PPUADDR
    LDA #$C0        ; THE ADDRESS LATCH SHOULD ALREADY BE CLEARED 
    STA PPUADDR
    LDA #(3 << 6) | (3 << 4) | (3 << 2) | (3 << 0)
    STA PPUDATA
    ;JSR CMD_SET

    LDA #(PPUCTRL::NMI_ENABLE | PPUCTRL::PT_ADDR_BG) ; INITIAL PPUCTRL WRITE HAS TO ENABLE NMI INTERRUPTS; SUBSEQUENT WRITES TO PPUCTRL WILL BE BUFFERED AND TAKE PLACE IN NMI
    STA PPUCTRL
    STA PPUCTRLBUF

    LDA #(PPUMASK::SHOW_BG | PPUMASK::SHOW_SPR | PPUMASK::SHOW_BG_8 | PPUMASK::SHOW_SPR_8) ; SUBSEQUENT WRITES TO PPUMASK WILL BE BUFFERED AND TAKE PLACE IN NMI
    STA PPUMASK

    CLI             ; RESPOND TO INTERRUPTS

    ;
    ;    Type                .BYTE               ; Type of object
    ;    Attributes          .BYTE               ; (7: Active)
    ;    Movement            .BYTE               ; Movement to process for actor this frame
    ;    XPos                .TAG Position       ; Actors horizontal position in level coordinates
    ;    YPos                .TAG Position       ; TODO: FIND USE FOR UNUSED HIGH BYTE
    ;    Velocity            .BYTE               ; How fast does this object move in a given direction? 
    ;    Const_Acc           .BYTE               ; What rate does velocity change for this actor?
    ;    Acceleration        .WORD  
    ;

    LDA #$00
    JSR WR_ACTOR_BUF                ; Write Actor Index          
    JSR WR_ACTOR_BUF                ; Write Data Index
    LDA #.SIZEOF(Actor)
    JSR WR_ACTOR_BUF                ; Write Packet Size
    LDA #ACTOR_TYPES::PLAYER        
    JSR WR_ACTOR_BUF                ; Actor Type
    LDA #ACTOR_ATTRIBUTES::Active
    JSR WR_ACTOR_BUF                ; Actor Active
    LDA #$00
    JSR WR_ACTOR_BUF                ; Movement
    JSR WR_ACTOR_BUF                ; XPos LSB
    JSR WR_ACTOR_BUF                ; XPos MSB 
    LDA #$36
    JSR WR_ACTOR_BUF                ; YPos LSB
    LDA #$00
    JSR WR_ACTOR_BUF                ; YPos MSB 
    LDA #$02
    JSR WR_ACTOR_BUF                ; Velocity
    LDA #$30                        ; Const_Acc
    JSR WR_ACTOR_BUF
    LDA #$00                        ; Acceleration
    JSR WR_ACTOR_BUF
    JSR WR_ACTOR_BUF

;---------------------------------------
; Main Game Loop
;---------------------------------------
GAME_LOOP:
    JSR NMI_WAIT
    JSR ACTORS_TO_SCREEN
    ;JSR CAMERA_TO_SCREEN
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
    JSR ACTOR_BUF_DIF
    BEQ UPDATE_ACTORS_EXIT 
    JSR RD_ACTOR_BUF        ; Actor Index
    JSR POINT_TO_ACTOR      ; Actor to OBJ_PTR
    JSR UPDATE_ACTOR_DATA
    JSR UPDATE_POSITION
    JMP UPDATE_ACTORS
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
    LDA #BITS::BIT_7
    STA PPUCMDFLAG
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