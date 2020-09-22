.SEGMENT "RODATA"
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
