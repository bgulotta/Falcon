.IFNDEF _GAME_SYMBOLS_
.DEFINE _GAME_SYMBOLS_

.SEGMENT "ZEROPAGE"
ACTOR_PTR:      .RES 2
META_PTR:       .RES 2
SPRITE_PTR:     .RES 2
.ENDIF

.SEGMENT "OAM"
OAM: .RES 256

.SEGMENT "RAM"
NMI_DONE:    .RES 1
PPUCMDFLAG:  .RES 1
PPUMASKFLAG: .RES 1
PPUCTRLFLAG: .RES 1
OAMFLAG:     .RES 1
SCROLLFLAG:  .RES 1
PPUMASKBUF:  .RES 1
PPUCTRLBUF:  .RES 1
SCROLLX:     .RES 1
SCROLLY:     .RES 1
CMD_RPTR:    .RES 1
CMD_WPTR:    .RES 1
CMDBUF:      .RES 256
JOYPAD1:     .RES 1
JOYPAD2:     .RES 1
JOYPAD3:     .RES 1
JOYPAD4:     .RES 1
Actor_XPos:  .RES 2
Actor_YPos:  .RES 2
NumTiles:    .RES 1
OamIndex:    .RES 1

Cam: 
    .TAG Camera
Actors: 
    .TAG Actor

.SEGMENT "CODE"
ACTOR_CNT: .BYTE $01

ActorMeta:
    ; Type, Attributes, Sprites, Velocity (Speed, Acceleration Const)
    .BYTE $01, $80, .LOBYTE(ActorTiles), .HIBYTE(ActorTiles), $01, $80 
ActorTiles:
    ; Num tiles, [YOffset, Tile Index, Attributes, XOffset] 
    .BYTE $04, $00, $01, $01, $00, $00, $01, $40, $08, $08, $01, $80, $00, $08, $01, $C0, $08     
