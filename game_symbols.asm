.IFNDEF _GAME_SYMBOLS_
.DEFINE _GAME_SYMBOLS_

.SEGMENT "ZEROPAGE"
ACTOR_PTR:         .RES 2
META_PTR:          .RES 2
SPRITE_PTR:        .RES 2
LEVEL_PTR:         .RES 2
SCREEN_PTR:        .RES 2
META_TILE_PTR:     .RES 2
METAMETA_TILE_PTR: .RES 2
.ENDIF

.SEGMENT "OAM"
OAM: .RES 256

.SEGMENT "RAM"
;----- Flags --------;
NMI_DONE:    .RES 1
PPUMASKFLAG: .RES 1
PPUCTRLFLAG: .RES 1
OAMFLAG:     .RES 1
SCROLLFLAG:  .RES 1
;--- Controller IO ---;
JOYPAD1:     .RES 1
JOYPAD2:     .RES 1
JOYPAD3:     .RES 1
JOYPAD4:     .RES 1
;--- Pointers ----;
CMD_RPTR:    .RES 1
CMD_WPTR:    .RES 1
JmpPtr:      .RES 2
;-- Sprite Vars --;
OamIndex:    .RES 1
NumTiles:    .RES 1
;--- Work Vars ---;
Temp:        .RES 2
Temp2:       .RES 2
Temp3:       .RES 2
NumCommands: .RES 1
NumIterations: .RES 1
CamDestX:    .RES 2         ; Camera's X Destination
CamDestY:    .RES 2         ; Camera's Y Destination
PPUAddress:  .RES 2
;---- Buffers ----;
PPUMASKBUF:  .RES 1
PPUCTRLBUF:  .RES 1
CMDBUF:      .RES 128

.SEGMENT "VIEWPORT"
ViewPort: .TAG ViewPort

.SEGMENT "ACTORS"
Actors: 
Camera:
    .TAG Actor
    .TAG Actor
    .TAG Actor
    .TAG Actor
    .TAG Actor
    .TAG Actor
    .TAG Actor
    .TAG Actor
    .TAG Actor
    .TAG Actor
    .TAG Actor
    .TAG Actor
    .TAG Actor
    .TAG Actor
    .TAG Actor
LastActor:
    .TAG Actor