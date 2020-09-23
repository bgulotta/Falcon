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
TempX:       .RES 2
TempY:       .RES 2
NMI_DONE:    .RES 1
PPUCMDFLAG:  .RES 1
PPUMASKFLAG: .RES 1
PPUCTRLFLAG: .RES 1
OAMFLAG:     .RES 1
SCROLLFLAG:  .RES 1
PPUMASKBUF:  .RES 1
PPUCTRLBUF:  .RES 1
JOYPAD1:     .RES 1
JOYPAD2:     .RES 1
JOYPAD3:     .RES 1
JOYPAD4:     .RES 1
ScreenX:     .RES 2
ScreenY:     .RES 2
NumTiles:    .RES 1
OamIndex:    .RES 1
CMD_RPTR:    .RES 1
CMD_WPTR:    .RES 1
JmpPtr:      .RES 2
CamDestX:    .RES 2         ; Camera's X Destination
CamDestY:    .RES 2         ; Camera's Y Destination
Temp:        .RES 2  
Iterations:  .RES 1
MetaMetaTileX: .RES 2
MetaMetaTileY: .RES 2
MetaMetaTileIndex: .RES 2
MetaTileX:     .RES 2
MetaTileY:     .RES 2
MetaTileIndex: .RES 2
TileX:         .RES 2
TileY:         .RES 2
TileIndex:     .RES 2
CMDBUF:       .RES 128

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