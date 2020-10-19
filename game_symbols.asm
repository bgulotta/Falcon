.IFNDEF _GAME_SYMBOLS_
.DEFINE _GAME_SYMBOLS_

.SEGMENT "ZEROPAGE"
ACTOR_PTR:             .RES 2
META_PTR:              .RES 2
SPRITE_PTR:            .RES 2
META_TILESET_PTR:      .RES 2 ; A pointer to the level's meta tilesets
META_META_TILESET_PTR: .RES 2 ; A pointer to the level's meta meta tilesets
META_META_TILES_PTR:   .RES 2 ; Points to the meta meta tiles for the currently selected screen
META_META_TILE_PTR:    .RES 2
META_TILE_PTR:         .RES 2
TILE_PTR:              .RES 2
TILEBUF_PTR:           .RES 2
.ENDIF

.SEGMENT "OAM"
OAM: .RES 256

.SEGMENT "RAM"
;----- Flags --------;
NMI_DONE:      .RES 1
PPUREGFLAG:    .RES 1
OAMFLAG:       .RES 1
DECODEDFLAG:   .RES 1
;--- Controller IO ---;
JOYPAD1:       .RES 1
JOYPAD2:       .RES 1
;--- Pointers ----;
CMD_RPTR:      .RES 1
CMD_WPTR:      .RES 1
TILE_PTR_0:    .RES 1
TILE_PTR_1:    .RES 1
TILE_PTR_2:    .RES 1
TILE_PTR_3:    .RES 1
JmpPtr:        .RES 2
;-- Sprite Vars --;
OamIndex:      .RES 1
NumTiles:      .RES 1
CamDestX:      .RES 2         ; Camera's X Destination
CamDestY:      .RES 2         ; Camera's Y Destination
;--- Work Vars ---;
Temp:          .RES 2
Temp2:         .RES 2
Temp3:         .RES 2
Temp4:         .RES 2
NumCommands:   .RES 1
NumIterations: .RES 1
;---- Buffers ----;
PPUMASKBUF:    .RES 1
PPUCTRLBUF:    .RES 1
CMDBUF:        .RES 256
TILEBUF:       .RES 112 

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
LastActor:
    .TAG Actor

.SEGMENT "LEVEL"
Level:  .BYTE $00 
Screen: .BYTE $00

PPU:
    .TAG PPU 
    
MetaMetaTile:
    .TAG MetaTile

MetaTile:
    .TAG MetaTile

Tile:
    .TAG Tile 