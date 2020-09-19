.SEGMENT "CODE"

.MACRO      ACTOR_INIT Type, Index, XCoord, YCoord
            LDA #Index
            JSR POINT_TO_ACTOR
            LDA #$00                     ; an actor slot. initially 
            LDY #ACTOR_DATA::Attributes ; We could be re-using
            STA (ACTOR_PTR), Y           ; zero out the attributes
            LDA #Type
            JSR POINT_TO_META
            LDY #ACTOR_DATA::MetaData
            LDA META_PTR
            STA (ACTOR_PTR), Y
            LDY #ACTOR_DATA::MetaData + 1
            LDA META_PTR + 1           
            STA (ACTOR_PTR), Y   
            LDY #ACTOR_DATA::XPos
            LDA #XCoord
            STA (ACTOR_PTR), Y   
            LDY #ACTOR_DATA::YPos
            LDA #YCoord
            STA (ACTOR_PTR), Y
            LDA #$00
            LDY #ACTOR_DATA::MovementPrev
            STA (ACTOR_PTR), Y
            LDY #ACTOR_DATA::Movement
            STA (ACTOR_PTR), Y
            LDY #ACTOR_DATA::Acceleration
            STA (ACTOR_PTR), Y
            LDY #ACTOR_DATA::Acceleration + 1
            STA (ACTOR_PTR), Y
            LDY #META_DATA::Attributes
            LDA (META_PTR), Y
            LDY #ACTOR_DATA::Attributes
            ORA #ACTOR_ATTRIBUTES::Active
            STA (ACTOR_PTR), Y
.ENDMACRO