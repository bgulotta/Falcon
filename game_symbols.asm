; TEST 
.IFNDEF _GAME_SYMBOLS_
.DEFINE _GAME_SYMBOLS_

.SEGMENT "ZEROPAGE"
JOYPAD1: .RES 1
JOYPAD2: .RES 1
RD_PTR:  .RES 1
WR_PTR:  .RES 1
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
CMDBUFFER:   .RES 256

.struct Player

.endstruct
