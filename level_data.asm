.SEGMENT "RODATA"

MetaMetaTileSetLo: 
    .BYTE .LOBYTE(L1MetaMetaTileSet)
MetaMetaTileSetHi: 
    .BYTE .HIBYTE(L1MetaMetaTileSet)
MetaTileSetLo: 
    .BYTE .LOBYTE(L1MetaTileSet)
MetaTileSetHi: 
    .BYTE .HIBYTE(L1MetaTileSet)

MetaMetaTilesetIndexLo: 
    .BYTE .LOBYTE(L1Screen1MetaMeta) 
    .BYTE .LOBYTE(L1Screen2MetaMeta) 
    .BYTE .LOBYTE(L1Screen3MetaMeta) 
    .BYTE .LOBYTE(L1Screen4MetaMeta) 
    .BYTE .LOBYTE(L1Screen5MetaMeta)
    .BYTE .LOBYTE(L1Screen6MetaMeta) 
    .BYTE .LOBYTE(L1Screen7MetaMeta) 
    .BYTE .LOBYTE(L1Screen8MetaMeta) 
    .BYTE .LOBYTE(L1Screen9MetaMeta) 
    .BYTE .LOBYTE(L1Screen10MetaMeta)
    .BYTE .LOBYTE(L1Screen11MetaMeta)
    .BYTE .LOBYTE(L1Screen12MetaMeta) 
    .BYTE .LOBYTE(L1Screen13MetaMeta) 
    .BYTE .LOBYTE(L1Screen14MetaMeta) 
    .BYTE .LOBYTE(L1Screen15MetaMeta)
MetaMetaTilesetIndexHi:
    .BYTE .HIBYTE(L1Screen1MetaMeta) 
    .BYTE .HIBYTE(L1Screen2MetaMeta) 
    .BYTE .HIBYTE(L1Screen3MetaMeta) 
    .BYTE .HIBYTE(L1Screen4MetaMeta) 
    .BYTE .HIBYTE(L1Screen5MetaMeta)
    .BYTE .HIBYTE(L1Screen6MetaMeta) 
    .BYTE .HIBYTE(L1Screen7MetaMeta) 
    .BYTE .HIBYTE(L1Screen8MetaMeta) 
    .BYTE .HIBYTE(L1Screen9MetaMeta) 
    .BYTE .HIBYTE(L1Screen10MetaMeta)
    .BYTE .HIBYTE(L1Screen11MetaMeta)
    .BYTE .HIBYTE(L1Screen12MetaMeta) 
    .BYTE .HIBYTE(L1Screen13MetaMeta) 
    .BYTE .HIBYTE(L1Screen14MetaMeta) 
    .BYTE .HIBYTE(L1Screen15MetaMeta)

L1Screen1MetaMeta:
    .BYTE $04, $04, $04, $04, $04, $04, $04, $04, $04, $04
    .BYTE $04, $04, $04, $04, $04, $04, $00, $00, $00, $00
    .BYTE $00, $00, $00, $00, $00, $00, $00, $00
L1Screen2MetaMeta:
    .BYTE $04, $04, $04, $04, $00, $00, $00, $00, $00, $00
    .BYTE $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
    .BYTE $00, $00, $00, $00, $00, $00, $00, $00
L1Screen3MetaMeta:
L1Screen4MetaMeta:
L1Screen5MetaMeta:
L1Screen6MetaMeta:
L1Screen7MetaMeta:
L1Screen8MetaMeta:
L1Screen9MetaMeta:
L1Screen10MetaMeta:
L1Screen11MetaMeta:
L1Screen12MetaMeta:
L1Screen13MetaMeta:
L1Screen14MetaMeta:
L1Screen15MetaMeta:
    .BYTE $04, $04, $04, $04, $00, $00, $00, $00, $00, $00
    .BYTE $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
    .BYTE $00, $00, $00, $00, $00, $00, $00, $00

; Level 32 x 32 MetaMetaTileSet ; Left Top/Right Top/Left Bottom/Right Bottom
L1MetaMetaTileSet:
    .BYTE $00, $00, $00, $00
    .BYTE $04, $04, $04, $04
    .BYTE $08, $00, $00, $08
    .BYTE $08, $00, $00, $08

; Level 16x16 MetaTileSet ; Left Top/Right Top/Left Bottom/Right Bottom
L1MetaTileSet:
    .BYTE $00, $00, $00, $00 
    .BYTE $05, $05, $05, $05
    .BYTE $00, $05, $05, $00
    .BYTE $08, $00, $00, $08