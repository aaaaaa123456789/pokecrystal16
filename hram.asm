SECTION "HRAM", HRAM

hTransferVirtualOAM:: ds 10 ; ff80

hROMBankBackup:: db ; ff8a
hBuffer:: db ; ff8b
hSRAMBank:: db ; ff8c

hRTCDayHi::   db ; ff8d
hRTCDayLo::   db ; ff8e
hRTCHours::   db ; ff8f
hRTCMinutes:: db ; ff90
hRTCSeconds:: db ; ff91

	ds 2

hHours:: db ; ff94
	ds 1
hMinutes:: db ; ff96
	ds 1
hSeconds:: db ; ff98
	ds 1

	ds 1

hVBlankCounter:: db ; ff9b

	ds 1

hROMBank:: db ; ff9d
hVBlank:: db ; ff9e
hMapEntryMethod:: db ; ff9f
hMenuReturn:: db ; ffa0

	ds 1

hJoypadReleased:: db ; ffa2
hJoypadPressed::  db ; ffa3
hJoypadDown::     db ; ffa4
hJoypadSum::      db ; ffa5
hJoyReleased::    db ; ffa6
hJoyPressed::     db ; ffa7
hJoyDown::        db ; ffa8
hJoyLast::        db ; ffa9

hInMenu:: db ; ffaa

	ds 1

hPrinter:: db ; ffac
hGraphicStartTile:: db ; ffad
hMoveMon:: db ; ffae

UNION ; ffaf
hMapObjectIndexBuffer:: db ; ffaf
hObjectStructIndexBuffer:: db ; ffb0
NEXTU ; ffaf
hConnectionStripLength:: db ; ffaf
hConnectedMapWidth:: db ; ffb0
ENDU ; ffb1

hEnemyMonSpeed:: dw ; ffb1

UNION ; ffb3
; math-related values

UNION ; ffb3
; inputs to Multiply
	ds 1
hMultiplicand:: ds 3 ; ffb4
hMultiplier::   db   ; ffb7
NEXTU ; ffb3
; result of Multiply
hProduct::      ds 4 ; ffb3
NEXTU ; ffb3
; inputs to Divide
hDividend::     ds 4 ; ffb3
hDivisor::      db   ; ffb7
NEXTU ; ffb3
; results of Divide
hQuotient::     ds 4 ; ffb3
hRemainder::    db   ; ffb7
ENDU ; ffb8

hMathBuffer:: ds 5 ; ffb8

NEXTU ; ffb3
; PrintNum scratch space
hPrintNumBuffer:: ds 10 ; ffb3

NEXTU ; ffb3
; miscellaneous
    ds 9
hMGStatusFlags:: db ; ffbc
ENDU ; ffbd

hUsedSpriteIndex:: db ; ffbd
hUsedSpriteTile::  db ; ffbe
hFFBF::            db ; ffbf
hFFC0::            db ; ffc0
hFFC1::            db ; ffc1
hFFC2::            db ; ffc2

UNION ; ffc3
hMoneyTemp:: ds 3 ; ffc3
NEXTU ; ffc3
hMGJoypadPressed::  db ; ffc3
hMGJoypadReleased:: db ; ffc4
ENDU ; ffc6

hLCDCPointer::     db ; ffc6
hLYOverrideStart:: db ; ffc7
hLYOverrideEnd::   db ; ffc8

hMobileReceive::             db ; ffc9
hSerialReceivedNewData::     db ; ffca
hSerialConnectionStatus::    db ; ffcb
hSerialIgnoringInitialData:: db ; ffcc
hSerialSend::                db ; ffcd
hSerialReceive::             db ; ffce

hSCX::           db ; ffcf
hSCY::           db ; ffd0
hWX::            db ; ffd1
hWY::            db ; ffd2
hTilesPerCycle:: db ; ffd3
hBGMapMode::     db ; ffd4
hBGMapThird::    db ; ffd5
hBGMapAddress::  dw ; ffd6

hOAMUpdate:: db ; ffd8

hSPBuffer::  dw ; ffd9

hBGMapUpdate::    db ; ffdb
hBGMapTileCount:: db ; ffdc

hTemp:: db ; ffdd

hMapAnims::      db ; ffde
hTileAnimFrame:: db ; ffdf

hLastTalked:: db ; ffe0

hRandom::
hRandomAdd:: db ; ffe1
hRandomSub:: db ; ffe2

hSecondsBackup:: db ; ffe3

hBattleTurn:: ; ffe4
; Which trainer's turn is it? 0: player, 1: opponent trainer
	db

hCGBPalUpdate:: db ; ffe5
hCGB::          db ; ffe6
hSGB::          db ; ffe7

hDMATransfer:: db ; ffe8
hMobile:: db ; ffe9
hSystemBooted:: db ; ffea
hClockResetTrigger:: db ; ffeb
