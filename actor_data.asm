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
    .BYTE $04, $00, $DA, $00, $00, $00, $DB, $00, $08, $08, $D5, $00, $00, $08, $D6, $00, $08     
CameraTiles:
    .BYTE $01, $00, $2D, $00, $00     
