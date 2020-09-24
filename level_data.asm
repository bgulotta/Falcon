.SEGMENT "RODATA"

; NumScreens  .BYTE       ; How many screens make up this level
; MetaTileSet .WORD       ; Pointer to the level's 16x16 metatile set
; Screens     .WORD       ; Pointer to the level's screens  
Levels: 
L1: 
    .BYTE $05, .LOBYTE(L1MetaTileSet), .HIBYTE(L1MetaTileSet), .LOBYTE(L1Screen1), .HIBYTE(L1Screen1)

; Index       .BYTE 
; PrevScreen  .WORD       ; Pointer to the previous screen
; NextScreen  .WORD       ; Pointer to the next screen
; MetaMetaTiles .WORD     ; Pointer to MetaMetaTiles for screen
LevelScreens:
L1Screen1:
    .BYTE $00, .LOBYTE(L1Screen5), .HIBYTE(L1Screen5), .LOBYTE(L1Screen2), .HIBYTE(L1Screen2), .LOBYTE(L1Screen1MetaMeta), .HIBYTE(L1Screen1MetaMeta)
L1Screen2:
    .BYTE $01, .LOBYTE(L1Screen1), .HIBYTE(L1Screen1), .LOBYTE(L1Screen3), .HIBYTE(L1Screen3), .LOBYTE(L1Screen2MetaMeta), .HIBYTE(L1Screen2MetaMeta) 
L1Screen3:
    .BYTE $02, .LOBYTE(L1Screen2), .HIBYTE(L1Screen2), .LOBYTE(L1Screen4), .HIBYTE(L1Screen4), .LOBYTE(L1Screen3MetaMeta), .HIBYTE(L1Screen3MetaMeta)
L1Screen4:
    .BYTE $03, .LOBYTE(L1Screen3), .HIBYTE(L1Screen3), .LOBYTE(L1Screen5), .HIBYTE(L1Screen5), .LOBYTE(L1Screen4MetaMeta), .HIBYTE(L1Screen4MetaMeta)
L1Screen5:
    .BYTE $04, .LOBYTE(L1Screen4), .HIBYTE(L1Screen4), .LOBYTE(L1Screen1), .HIBYTE(L1Screen1), .LOBYTE(L1Screen5MetaMeta), .HIBYTE(L1Screen5MetaMeta)

L1Screen1MetaMeta:
L1Screen2MetaMeta:
L1Screen3MetaMeta:
L1Screen4MetaMeta:
L1Screen5MetaMeta: ; 0-27; 28 - 55: (55 - X)
    .BYTE $00, $00, $00, $00, $00, $00, $00, $00
    .BYTE $00, $00, $00, $00, $00, $00, $00, $00
    .BYTE $00, $00, $00, $00, $00, $00, $00, $00
    .BYTE $00, $00, $00, $00

; Level 32 x 32 MetaMetaTileSet ; Left Top/Right Top/Left Bottom/Right Bottom
L1MetaMetaTileSet:
    .BYTE $00, $00, $00, $00
    .BYTE $00, $00, $00, $00

; Level 16x16 MetaTileSet ; Left Top/Right Top/Left Bottom/Right Bottom
L1MetaTileSet:
    .BYTE $00, $00, $00, $05 
    .BYTE $00, $00, $00, $00
