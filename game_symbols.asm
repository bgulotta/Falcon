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

.SEGMENT "CODE"
ActorCount = $10

Meta:
    ; Type, Attributes, Velocity, Tiles, Update Routine
PlayerMeta:
    .BYTE $00, $01, $01, $80, .LOBYTE(PlayerTiles), .HIBYTE(PlayerTiles), .LOBYTE(UPDATE_PLAYER), .HIBYTE(UPDATE_PLAYER) 
CameraMeta:
    .BYTE $01, $00, $01, $80, .LOBYTE(CameraTiles), .HIBYTE(CameraTiles), .LOBYTE(UPDATE_CAMERA), .HIBYTE(UPDATE_CAMERA)
    
Tiles:
    ; Num tiles, [YOffset, Tile Index, Attributes, XOffset] 
PlayerTiles:
    .BYTE $04, $00, $01, $01, $00, $00, $01, $40, $06, $06, $01, $80, $00, $06, $01, $C0, $06     
CameraTiles:
    .BYTE $01, $00, $01, $00, $00     
