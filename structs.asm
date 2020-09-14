.SEGMENT "CODE"

.STRUCT Position
    Position   .WORD
.ENDSTRUCT

.STRUCT Camera
    XPos   .TAG Position ; The camera's position in level coordinates
.ENDSTRUCT

.STRUCT Actor
    Type                .BYTE               ; Type of object
    Attributes          .BYTE               ; (7: Active)
    Movement            .BYTE               ; Movement to process for actor this frame
    XPos                .TAG Position       ; Actors horizontal position in level coordinates
    YPos                .TAG Position       ; TODO: FIND USE FOR UNUSED HIGH BYTE
    Velocity            .BYTE               ; How fast does this object move in a given direction? 
    Const_Acc           .BYTE               ; What rate does velocity change for this actor?
    Acceleration        .WORD               ; How fast is the actor currently accelerating? (LSB: Fraction, MSB: Whole)   
    
 .ENDSTRUCT
