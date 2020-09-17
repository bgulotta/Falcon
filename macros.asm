.SEGMENT "CODE"

.MACRO      ACTOR_INIT Type, Index, XCoord, YCoord
            LDA #Index
            JSR POINT_TO_ACTOR
            LDY #ACTOR_INDEX::Attributes ; We could be re-using
            LDA #$00                     ; an actor slot. initially 
            STA (ACTOR_PTR), Y           ; zero out the attributes
            LDY #Type
            JSR POINT_TO_META
            LDY #ACTOR_INDEX::MetaData
            LDA META_PTR
            STA (ACTOR_PTR), Y
            LDY #ACTOR_INDEX::MetaData + 1
            LDA META_PTR + 1           
            STA (ACTOR_PTR), Y   
            LDY #ACTOR_INDEX::XPos
            LDA #XCoord
            STA (ACTOR_PTR), Y   
            LDY #ACTOR_INDEX::YPos
            LDA #YCoord
            STA (ACTOR_PTR), Y
            LDA #$00
            LDY #ACTOR_INDEX::MovementPrev
            STA (ACTOR_PTR), Y
            LDY #ACTOR_INDEX::Movement
            STA (ACTOR_PTR), Y
            LDY #ACTOR_INDEX::Acceleration
            STA (ACTOR_PTR), Y
            LDY #ACTOR_INDEX::Acceleration + 1
            STA (ACTOR_PTR), Y
            LDY #META_INDEX::Attributes
            LDA (META_PTR), Y
            LDY #ACTOR_INDEX::Attributes
            ORA #ACTOR_ATTRIBUTES::Active
            STA (ACTOR_PTR), Y
.ENDMACRO