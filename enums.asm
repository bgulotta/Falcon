.SEGMENT "CODE"

; ENUMS
.SCOPE BITS
        BIT_0     = 1
        BIT_1     = 2
        BIT_2     = 4
        BIT_3     = 8
        BIT_4     = 16
        BIT_5     = 32
        BIT_6     = 64
        BIT_7     = 128
.ENDSCOPE

.SCOPE  PPUCTRL
        NT_BASE_0    = BITS::BIT_0 ;BASE NAMETABLE ADDRESS (0 = $2000; 1 = $2400; 2 = $2800; 3 = $2C00)
        NT_BASE_1    = BITS::BIT_1 
        VRAM_INC     = BITS::BIT_2 ; VRAM ADDRESS INCREMENT PER CPU READ/WRITE OF PPUDATA (0: ADD 1, GOING ACROSS; 1: ADD 32, GOING DOWN)
        PT_ADDR_SPR  = BITS::BIT_3 ; SPRITE PATTERN TABLE ADDRESS FOR 8X8 SPRITES (0: $0000; 1: $1000; IGNORED IN 8X16 MODE)
        PT_ADDR_BG   = BITS::BIT_4 ; BACKGROUND PATTERN TABLE ADDRESS (0: $0000; 1: $1000)
        SPRITE_SIZE  = BITS::BIT_5 ; SPRITE SIZE (0: 8X8 PIXELS; 1: 8X16 PIXELS)
        MASTER_SLAVE = BITS::BIT_6 ; PPU MASTER/SLAVE SELECT (0: READ BACKDROP FROM EXT PINS; 1: OUTPUT COLOR ON EXT PINS)
        NMI_ENABLE   = BITS::BIT_7 ; GENERATE AN NMI AT THE START OF THE VERTICAL BLANKING INTERVAL (0: OFF; 1: ON)
.ENDSCOPE

.SCOPE  PPUMASK
        GREYSCALE    = BITS::BIT_0 ; GREYSCALE (0: NORMAL COLOR, 1: PRODUCE A GREYSCALE DISPLAY)
        SHOW_BG_8    = BITS::BIT_1 ; SHOW BACKGROUND IN LEFTMOST 8 PIXELS OF SCREEN, 0: HIDE
        SHOW_SPR_8   = BITS::BIT_2 ; SHOW SPRITES IN LEFTMOST 8 PIXELS OF SCREEN, 0: HIDE
        SHOW_BG      = BITS::BIT_3 ; SHOW BACKGROUND
        SHOW_SPR     = BITS::BIT_4 ; SHOW SPRITES
        EM_RED       = BITS::BIT_5 ; EMPHASIZE RED
        EM_GREEN     = BITS::BIT_6 ; EMPHASIZE GREEN
        EM_BLUE      = BITS::BIT_7 ; EMPHASIZE BLUE
.ENDSCOPE

.SCOPE  PPUSTATUS
        SPRITE_OVF   = BITS::BIT_5 ; SPRITE OVERFLOW. THE INTENT WAS FOR THIS FLAG TO BE SET
                                   ; WHENEVER MORE THAN EIGHT SPRITES APPEAR ON A SCANLINE, BUT A
                                   ; HARDWARE BUG CAUSES THE ACTUAL BEHAVIOR TO BE MORE COMPLICATED
                                   ; AND GENERATE FALSE POSITIVES AS WELL AS FALSE NEGATIVES; SEE
                                   ; PPU SPRITE EVALUATION. THIS FLAG IS SET DURING SPRITE
                                   ; EVALUATION AND CLEARED AT DOT 1 (THE SECOND DOT) OF THE
                                   ; PRE-RENDER LINE.
        SPRITE_0_HIT = BITS::BIT_6 ; SPRITE 0 HIT.  SET WHEN A NONZERO PIXEL OF SPRITE 0 OVERLAPS A NONZERO BACKGROUND PIXEL; CLEARED AT DOT 1 OF THE PRE-RENDER LINE.  USED FOR RASTER TIMING.
        VBLANK_START = BITS::BIT_7 ; VERTICAL BLANK HAS STARTED (0: NOT IN VBLANK; 1: IN VBLANK). SET AT DOT 1 OF LINE 241 (THE LINE *AFTER* THE POST-RENDER LINE); CLEARED AFTER READING PPUSTATUS AND AT DOT 1 OF THE PRE-RENDER LINE.
.ENDSCOPE

.SCOPE JOYPAD
        ButtonA  = BITS::BIT_7
        ButtonB  = BITS::BIT_6
        Select   = BITS::BIT_5
        Start    = BITS::BIT_4
        Up       = BITS::BIT_3
        Down     = BITS::BIT_2
        Left     = BITS::BIT_1
        Right    = BITS::BIT_0
.ENDSCOPE 

.SCOPE ACTOR_TYPES
        Player   = 0
        Camera   = 1
.ENDSCOPE

.SCOPE ACTOR_DATA
        Index         = 0
        MetaData      = 1
        XPos          = 3
        YPos          = 5
        TileX         = 7    ; TODO: Use second byte here for something
        TileY         = 9    ; TODO: Use second byte here for something 
        Movement      = 11
        MovementPrev  = 12
        Acceleration  = 13
        Attributes    = 15
        NextActor     = 16
.ENDSCOPE

.SCOPE META_DATA
        Type          = 0
        Attributes    = 1 ; Default Attributes
        Speed         = 2
        AccelConst    = 3
        Sprites       = 4
        UpdateData    = 6
.ENDSCOPE

.SCOPE ACTOR_ATTRIBUTES
        Active = BITS::BIT_7       ; Is on screen?
        Initialized = BITS::BIT_6  ; Is initialized?
        Direction = BITS::BIT_0    ; Is Actor facing left or right? 0 left 1 right
.ENDSCOPE

;---------------------------------------
; Level enums
; 
;---------------------------------------
.SCOPE LEVEL_DATA
        NumScreens        = 0
        MetaMetaTileSet   = 1
        MetaTileSet       = 3
        Screens           = 5
.ENDSCOPE

.SCOPE SCREEN_DATA
        Index               = 0
        PrevScreen          = 1
        NextScreen          = 3
        MetaMetaTileIndex   = 5
.ENDSCOPE

