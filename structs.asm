.SEGMENT "CODE"

.STRUCT Velocity
    Speed      .BYTE
    AccelConst .BYTE    
.ENDSTRUCT

.STRUCT Sprite
    Index      .BYTE
    Attributes .BYTE
    XOffset    .BYTE
    YOffset    .BYTE  ; Sprite offset relative to the actor's coordinates
.ENDSTRUCT

.STRUCT Movement
    Current    .BYTE
    Previous   .BYTE
.ENDSTRUCT 

.STRUCT Coordinates
    XPos       .WORD  
    YPos       .WORD 
.ENDSTRUCT

.STRUCT ViewPort
    Begin .TAG Coordinates
    End   .TAG Coordinates
.ENDSTRUCT

.STRUCT Actor
    Index               .BYTE ; The index of this actor
    MetaData            .WORD ; Pointer to this Actor's static meta data     
    WorldCoordinates    .TAG  Coordinates ; Actor's coordinates in the world
    Movement            .TAG  Movement ; Actor's movement actions
    Acceleration        .WORD ; Players current acceleration
    Attributes          .BYTE ; Player attributes (Active, Initialized, Health .ETC)
    NextActor           .WORD ; Pointer to the next actor
 .ENDSTRUCT

 .STRUCT Level
    NumScreens          .BYTE
    MetaMetaTileSet     .WORD
    MetaTileSet         .WORD
    Screens             .WORD
 .ENDSTRUCT

  .STRUCT Screen
    Index               .BYTE
    PrevScreen          .WORD
    NextScreen          .WORD
    MetaMetaTiles       .WORD
 .ENDSTRUCT

.STRUCT TileCoordinates
    Row                  .BYTE
    Col                  .BYTE
.ENDSTRUCT

.STRUCT TileData 
    TileIndex           .WORD 
    Coordinates         .TAG TileCoordinates
.ENDSTRUCT 

.STRUCT MetaTile
    Index                .BYTE
    TilesetIndex         .BYTE
    TileData             .TAG TileData
.ENDSTRUCT

.STRUCT Tile 
    Index               .BYTE
    Tile                .BYTE
    TileData            .TAG TileData
.ENDSTRUCT 

.STRUCT PPU
    BaseAddress         .WORD
    TileAddress         .WORD 
.ENDSTRUCT