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

.STRUCT Position
    XPos        .WORD       
    YPos        .WORD  
.ENDSTRUCT

.STRUCT ViewPort
    Begin .TAG Position
    End   .TAG Position
.ENDSTRUCT

.STRUCT Actor
    Index               .BYTE ; The index of this actor
    MetaData            .WORD ; Pointer to this Actor's static meta data     
    Coordinates         .TAG  Position ; Actor's world coordinates
    Movement            .TAG  Movement ; Actor's movement actions
    Acceleration        .WORD ; Players current acceleration
    Attributes          .BYTE ; Player attributes (Active, Initialized, Health .ETC)
    NextActor           .WORD ; Pointer to the next actor
 .ENDSTRUCT

 .STRUCT Level
    NumScreens          .BYTE
    MetaTileSet         .WORD
    Screens             .WORD
 .ENDSTRUCT