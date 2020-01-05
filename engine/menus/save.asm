SaveMenu:
	call LoadStandardMenuHeader
	farcall DisplaySaveInfoOnSave
	call SpeechTextbox
	call UpdateSprites
	farcall SaveMenu_CopyTilemapAtOnce
	ld hl, Text_WouldYouLikeToSaveTheGame
	call SaveTheGame_yesorno
	jr nz, .refused
	call AskOverwriteSaveFile
	jr c, .refused
	call PauseGameLogic
	call SavedTheGame
	call ResumeGameLogic
	call ExitMenu
	and a
	ret

.refused
	call ExitMenu
	call ret_d90
	farcall SaveMenu_CopyTilemapAtOnce
	scf
	ret

SaveAfterLinkTrade:
	call PauseGameLogic
	farcall StageRTCTimeForSave
	farcall BackupMysteryGift
	call SavePokemonData
	call SaveChecksum
	call SaveBackupPokemonData
	call SaveBackupChecksum
	farcall BackupPartyMonMail
	farcall SaveRTC
	call ResumeGameLogic
	ret

ChangeBoxSaveGame:
	push de
	ld hl, Text_SaveOnBoxSwitch
	call MenuTextbox
	call YesNoBox
	call ExitMenu
	jr c, .refused
	call AskOverwriteSaveFile
	jr c, .refused
	call PauseGameLogic
	call SaveBox
	pop de
	ld a, e
	ld [wCurBox], a
	call LoadBox
	call SavedTheGame
	call ResumeGameLogic
	and a
	ret
.refused
	pop de
	ret

Link_SaveGame:
	call AskOverwriteSaveFile
	jr c, .refused
	call PauseGameLogic
	call SavedTheGame
	call ResumeGameLogic
	and a

.refused
	ret

MoveMonWOMail_SaveGame:
	call PauseGameLogic
	push de
	call SaveBox
	pop de
	ld a, e
	ld [wCurBox], a
	call LoadBox
	call ResumeGameLogic
	ret

MoveMonWOMail_InsertMon_SaveGame:
	call PauseGameLogic
	push de
	call SaveBox
	pop de
	ld a, e
	ld [wCurBox], a
	ld a, TRUE
	ld [wSaveFileExists], a
	farcall StageRTCTimeForSave
	farcall BackupMysteryGift
	call ValidateSave
	call SaveOptions
	call SavePlayerData
	call SavePokemonData
	call SaveChecksum
	call ValidateBackupSave
	call SaveBackupOptions
	call SaveBackupPlayerData
	call SaveBackupPokemonData
	call SaveBackupChecksum
	farcall BackupPartyMonMail
	farcall BackupMobileEventIndex
	farcall SaveRTC
	call LoadBox
	call ResumeGameLogic
	ld de, SFX_SAVE
	jp PlaySFX

StartMoveMonWOMail_SaveGame:
	ld hl, Text_SaveOnMoveMonWOMail
	call MenuTextbox
	call YesNoBox
	call ExitMenu
	jr c, .refused
	call AskOverwriteSaveFile
	jr c, .refused
	call PauseGameLogic
	call SavedTheGame
	call ResumeGameLogic
	and a
	ret

.refused
	scf
	ret

PauseGameLogic:
	ld a, TRUE
	ld [wGameLogicPaused], a
	ret

ResumeGameLogic:
	xor a ; FALSE
	ld [wGameLogicPaused], a
	ret

AddHallOfFameEntry:
	ld a, BANK(sHallOfFame)
	call GetSRAMBank
	ld hl, sHallOfFame + HOF_LENGTH * (NUM_HOF_TEAMS - 1) - 1
	ld de, sHallOfFame + HOF_LENGTH * NUM_HOF_TEAMS - 1
	ld bc, HOF_LENGTH * (NUM_HOF_TEAMS - 1)
.loop
	ld a, [hld]
	ld [de], a
	dec de
	dec bc
	ld a, c
	or b
	jr nz, .loop
	ld hl, wHallOfFamePokemonList
	ld de, sHallOfFame
	ld bc, wHallOfFamePokemonListEnd - wHallOfFamePokemonList + 1
	call CopyBytes
	call CloseSRAM
	ret

AskOverwriteSaveFile:
	ld a, [wSaveFileExists]
	and a
	jr z, .erase
	call CompareLoadedAndSavedPlayerID
	ret z
	ld hl, Text_AnotherSaveFile
	call SaveTheGame_yesorno
	jr nz, .refused

.erase
	call ErasePreviousSave
	and a
	ret

.refused
	scf
	ret

SaveTheGame_yesorno:
	ld b, BANK(Text_WouldYouLikeToSaveTheGame)
	call MapTextbox
	call LoadMenuTextbox
	lb bc, 0, 7
	call PlaceYesNoBox
	ld a, [wMenuCursorY]
	dec a
	call CloseWindow
	push af
	call ret_d90
	pop af
	and a
	ret

CompareLoadedAndSavedPlayerID:
	ld a, BANK(sPlayerData)
	call GetSRAMBank
	ld hl, sPlayerData + (wPlayerID - wPlayerData)
	ld a, [hli]
	ld c, [hl]
	ld b, a
	call CloseSRAM
	ld a, [wPlayerID]
	cp b
	ret nz
	ld a, [wPlayerID + 1]
	cp c
	ret

SavedTheGame:
	ld hl, wOptions
	set NO_TEXT_SCROLL, [hl]
	push hl
	ld hl, .saving_text
	call PrintText
	pop hl
	res NO_TEXT_SCROLL, [hl]
	call SaveGameData
	; <PLAYER> saved the game!
	ld hl, Text_PlayerSavedTheGame
	call PrintText
	ld de, SFX_SAVE
	call WaitPlaySFX
	jp WaitSFX

.saving_text
	text "Saving…"
	done

SaveGameData:
	ld a, TRUE
	ld [wSaveFileExists], a
	farcall StageRTCTimeForSave
	farcall BackupMysteryGift
	call ValidateSave
	call SaveOptions
	call SavePlayerData
	call SavePokemonData
	call SaveBox
	call SaveChecksum
	call ValidateBackupSave
	call SaveBackupOptions
	call SaveBackupPlayerData
	call SaveBackupPokemonData
	call SaveBackupChecksum
	call UpdateStackTop
	farcall BackupPartyMonMail
	farcall BackupMobileEventIndex
	farcall SaveRTC
	ld a, BANK(sBattleTowerChallengeState)
	call GetSRAMBank
	ld a, [sBattleTowerChallengeState]
	cp BATTLETOWER_RECEIVED_REWARD
	jr nz, .ok
	xor a
	ld [sBattleTowerChallengeState], a
.ok
	call CloseSRAM
	ret

UpdateStackTop:
; sStackTop appears to be unused.
; It could have been used to debug stack overflow during saving.
	call FindStackTop
	ld a, BANK(sStackTop)
	call GetSRAMBank
	ld a, [sStackTop + 0]
	ld e, a
	ld a, [sStackTop + 1]
	ld d, a
	or e
	jr z, .update
	ld a, e
	sub l
	ld a, d
	sbc h
	jr c, .done

.update
	ld a, l
	ld [sStackTop + 0], a
	ld a, h
	ld [sStackTop + 1], a

.done
	call CloseSRAM
	ret

FindStackTop:
; Find the furthest point that sp has traversed to.
; This is distinct from the current value of sp.
	ld hl, wStack - $ff
.loop
	ld a, [hl]
	or a
	ret nz
	inc hl
	jr .loop

ErasePreviousSave:
	call EraseBoxes
	call EraseHallOfFame
	call EraseLinkBattleStats
	call EraseMysteryGift
	call SaveData
	call EraseBattleTowerStatus
	ld a, BANK(sStackTop)
	call GetSRAMBank
	xor a
	ld [sStackTop + 0], a
	ld [sStackTop + 1], a
	call CloseSRAM
	ld a, $1
	ld [wSavedAtLeastOnce], a
	ret

EraseLinkBattleStats:
	ld a, BANK(sLinkBattleStats)
	call GetSRAMBank
	ld hl, sLinkBattleStats
	ld bc, sLinkBattleStatsEnd - sLinkBattleStats
	xor a
	call ByteFill
	jp CloseSRAM

EraseMysteryGift:
	ld a, BANK(sBackupMysteryGiftItem)
	call GetSRAMBank
	ld hl, sBackupMysteryGiftItem
	ld bc, sBackupMysteryGiftItemEnd - sBackupMysteryGiftItem
	xor a
	call ByteFill
	jp CloseSRAM

EraseHallOfFame:
	ld a, BANK(sHallOfFame)
	call GetSRAMBank
	ld hl, sHallOfFame
	ld bc, sHallOfFameEnd - sHallOfFame
	xor a
	call ByteFill
	jp CloseSRAM

Unreferenced_Function14d18:
; copy .Data to SRA4:a007
	ld a, 4 ; MBC30 bank used by JP Crystal; inaccessible by MBC3
	call GetSRAMBank
	ld hl, .Data
	ld de, $a007 ; address of MBC30 bank
	ld bc, .DataEnd - .Data
	call CopyBytes
	jp CloseSRAM

.Data:
	db $0d, $02, $00, $05, $00, $00
	db $22, $02, $01, $05, $00, $00
	db $03, $04, $05, $08, $03, $05
	db $0e, $06, $03, $02, $00, $00
	db $39, $07, $07, $04, $00, $05
	db $04, $07, $01, $05, $00, $00
	db $0f, $05, $14, $07, $05, $05
	db $11, $0c, $0c, $06, $06, $04
.DataEnd

EraseBattleTowerStatus:
	ld a, BANK(sBattleTowerChallengeState)
	call GetSRAMBank
	xor a
	ld [sBattleTowerChallengeState], a
	jp CloseSRAM

SaveData:
	call _SaveData
	ret

Unreferenced_Function14d6c:
	ld a, 4 ; MBC30 bank used by JP Crystal; inaccessible by MBC3
	call GetSRAMBank
	ld a, [$a60b] ; address of MBC30 bank
	ld b, $0
	and a
	jr z, .ok
	ld b, $2

.ok
	ld a, b
	ld [$a60b], a ; address of MBC30 bank
	call CloseSRAM
	ret

Unreferenced_Function14d83:
	ld a, 4 ; MBC30 bank used by JP Crystal; inaccessible by MBC3
	call GetSRAMBank
	xor a
	ld [$a60c], a ; address of MBC30 bank
	ld [$a60d], a ; address of MBC30 bank
	call CloseSRAM
	ret

Unreferenced_Function14d93:
	ld a, 7 ; MBC30 bank used by JP Crystal; inaccessible by MBC3
	call GetSRAMBank
	xor a
	ld [$a000], a ; address of MBC30 bank
	call CloseSRAM
	ret

HallOfFame_InitSaveIfNeeded:
	ld a, [wSavedAtLeastOnce]
	and a
	ret nz
	call ErasePreviousSave
	ret

ValidateSave:
	ld a, BANK(sCheckValue1) ; aka BANK(sCheckValue2)
	call GetSRAMBank
	ld a, SAVE_CHECK_VALUE_1
	ld [sCheckValue1], a
	ld a, SAVE_CHECK_VALUE_2
	ld [sCheckValue2], a
	jp CloseSRAM

SaveOptions:
	ld a, BANK(sOptions)
	call GetSRAMBank
	ld hl, wOptions
	ld de, sOptions
	ld bc, wOptionsEnd - wOptions
	call CopyBytes
	ld a, [wOptions]
	and $ff ^ (1 << NO_TEXT_SCROLL)
	ld [sOptions], a
	jp CloseSRAM

SavePlayerData:
	ld a, BANK(sPlayerData)
	call GetSRAMBank
	ld hl, wPlayerData
	ld de, sPlayerData
	ld bc, wPlayerDataEnd - wPlayerData
	call CopyBytes
	ld hl, wCurMapData
	ld de, sCurMapData
	ld bc, wCurMapDataEnd - wCurMapData
	call CopyBytes
	jp CloseSRAM

SavePokemonData:
	ld a, BANK(sPokemonData)
	call GetSRAMBank
	ld hl, wPokemonData
	ld de, sPokemonData
	ld bc, wPokemonDataEnd - wPokemonData
	call CopyBytes
	call CloseSRAM
	ret

SaveBox:
	call GetBoxAddress
	call SaveBoxAddress
	ret

SaveChecksum:
	ld hl, sGameData
	ld bc, sGameDataEnd - sGameData
	ld a, BANK(sGameData)
	call GetSRAMBank
	call Checksum
	ld a, e
	ld [sChecksum + 0], a
	ld a, d
	ld [sChecksum + 1], a
	call CloseSRAM
	ret

ValidateBackupSave:
	ld a, BANK(sBackupCheckValue1) ; aka BANK(sBackupCheckValue2)
	call GetSRAMBank
	ld a, SAVE_CHECK_VALUE_1
	ld [sBackupCheckValue1], a
	ld a, SAVE_CHECK_VALUE_2
	ld [sBackupCheckValue2], a
	call CloseSRAM
	ret

SaveBackupOptions:
	ld a, BANK(sBackupOptions)
	call GetSRAMBank
	ld hl, wOptions
	ld de, sBackupOptions
	ld bc, wOptionsEnd - wOptions
	call CopyBytes
	call CloseSRAM
	ret

SaveBackupPlayerData:
	ld a, BANK(sBackupPlayerData)
	call GetSRAMBank
	ld hl, wPlayerData
	ld de, sBackupPlayerData
	ld bc, wPlayerDataEnd - wPlayerData
	call CopyBytes
	ld hl, wCurMapData
	ld de, sBackupCurMapData
	ld bc, wCurMapDataEnd - wCurMapData
	call CopyBytes
	call CloseSRAM
	ret

SaveBackupPokemonData:
	ld a, BANK(sBackupPokemonData)
	call GetSRAMBank
	ld hl, wPokemonData
	ld de, sBackupPokemonData
	ld bc, wPokemonDataEnd - wPokemonData
	call CopyBytes
	call CloseSRAM
	ret

SaveBackupChecksum:
	ld hl, sBackupGameData
	ld bc, sBackupGameDataEnd - sBackupGameData
	ld a, BANK(sBackupGameData)
	call GetSRAMBank
	call Checksum
	ld a, e
	ld [sBackupChecksum + 0], a
	ld a, d
	ld [sBackupChecksum + 1], a
	call CloseSRAM
	ret

TryLoadSaveFile:
	call VerifyChecksum
	jr nz, .backup
	call LoadPlayerData
	call LoadPokemonData
	call LoadBox
	farcall RestorePartyMonMail
	farcall RestoreMobileEventIndex
	farcall RestoreMysteryGift
	call ValidateBackupSave
	call SaveBackupOptions
	call SaveBackupPlayerData
	call SaveBackupPokemonData
	call SaveBackupChecksum
	and a
	ret

.backup
	call VerifyBackupChecksum
	jr nz, .corrupt
	call LoadBackupPlayerData
	call LoadBackupPokemonData
	call LoadBox
	farcall RestorePartyMonMail
	farcall RestoreMobileEventIndex
	farcall RestoreMysteryGift
	call ValidateSave
	call SaveOptions
	call SavePlayerData
	call SavePokemonData
	call SaveChecksum
	and a
	ret

.corrupt
	ld a, [wOptions]
	push af
	set NO_TEXT_SCROLL, a
	ld [wOptions], a
	ld hl, Text_SaveFileCorrupted
	call PrintText
	pop af
	ld [wOptions], a
	scf
	ret

TryLoadSaveData:
	xor a ; FALSE
	ld [wSaveFileExists], a
	call CheckPrimarySaveFile
	ld a, [wSaveFileExists]
	and a
	jr z, .backup

	ld a, BANK(sPlayerData)
	call GetSRAMBank
	ld hl, sPlayerData + wStartDay - wPlayerData
	ld de, wStartDay
	ld bc, 8
	call CopyBytes
	ld hl, sPlayerData + wStatusFlags - wPlayerData
	ld de, wStatusFlags
	ld a, [hl]
	ld [de], a
	call CloseSRAM
	ret

.backup
	call CheckBackupSaveFile
	ld a, [wSaveFileExists]
	and a
	jr z, .corrupt

	ld a, BANK(sBackupPlayerData)
	call GetSRAMBank
	ld hl, sBackupPlayerData + wStartDay - wPlayerData
	ld de, wStartDay
	ld bc, 8
	call CopyBytes
	ld hl, sBackupPlayerData + wStatusFlags - wPlayerData
	ld de, wStatusFlags
	ld a, [hl]
	ld [de], a
	call CloseSRAM
	ret

.corrupt
	ld hl, DefaultOptions
	ld de, wOptions
	ld bc, wOptionsEnd - wOptions
	call CopyBytes
	call PanicResetClock
	ret

INCLUDE "data/default_options.asm"

CheckPrimarySaveFile:
	ld a, BANK(sCheckValue1) ; aka BANK(sCheckValue2)
	call GetSRAMBank
	ld a, [sCheckValue1]
	cp SAVE_CHECK_VALUE_1
	jr nz, .nope
	ld a, [sCheckValue2]
	cp SAVE_CHECK_VALUE_2
	jr nz, .nope
	ld hl, sOptions
	ld de, wOptions
	ld bc, wOptionsEnd - wOptions
	call CopyBytes
	call CloseSRAM
	ld a, TRUE
	ld [wSaveFileExists], a

.nope
	call CloseSRAM
	ret

CheckBackupSaveFile:
	ld a, BANK(sBackupCheckValue1) ; aka BANK(sBackupCheckValue2)
	call GetSRAMBank
	ld a, [sBackupCheckValue1]
	cp SAVE_CHECK_VALUE_1
	jr nz, .nope
	ld a, [sBackupCheckValue2]
	cp SAVE_CHECK_VALUE_2
	jr nz, .nope
	ld hl, sBackupOptions
	ld de, wOptions
	ld bc, wOptionsEnd - wOptions
	call CopyBytes
	ld a, $2
	ld [wSaveFileExists], a

.nope
	call CloseSRAM
	ret

LoadPlayerData:
	ld a, BANK(sPlayerData)
	call GetSRAMBank
	ld hl, sPlayerData
	ld de, wPlayerData
	ld bc, wPlayerDataEnd - wPlayerData
	call CopyBytes
	ld hl, sCurMapData
	ld de, wCurMapData
	ld bc, wCurMapDataEnd - wCurMapData
	call CopyBytes
	call CloseSRAM
	ld a, BANK(sBattleTowerChallengeState)
	call GetSRAMBank
	ld a, [sBattleTowerChallengeState]
	cp BATTLETOWER_RECEIVED_REWARD
	jr nz, .not_4
	ld a, BATTLETOWER_WON_CHALLENGE
	ld [sBattleTowerChallengeState], a
.not_4
	call CloseSRAM
	ret

LoadPokemonData:
	ld a, BANK(sPokemonData)
	call GetSRAMBank
	ld hl, sPokemonData
	ld de, wPokemonData
	ld bc, wPokemonDataEnd - wPokemonData
	call CopyBytes
	call CloseSRAM
	ret

LoadBox:
	call GetBoxAddress
	call LoadBoxAddress
	ret

VerifyChecksum:
	ld hl, sGameData
	ld bc, sGameDataEnd - sGameData
	ld a, BANK(sGameData)
	call GetSRAMBank
	call Checksum
	ld a, [sChecksum + 0]
	cp e
	jr nz, .fail
	ld a, [sChecksum + 1]
	cp d
.fail
	push af
	call CloseSRAM
	pop af
	ret

LoadBackupPlayerData:
	ld a, BANK(sBackupPlayerData)
	call GetSRAMBank
	ld hl, sBackupPlayerData
	ld de, wPlayerData
	ld bc, wPlayerDataEnd - wPlayerData
	call CopyBytes
	ld hl, sBackupCurMapData
	ld de, wCurMapData
	ld bc, wCurMapDataEnd - wCurMapData
	call CopyBytes
	call CloseSRAM
	ret

LoadBackupPokemonData:
	ld a, BANK(sBackupPokemonData)
	call GetSRAMBank
	ld hl, sBackupPokemonData
	ld de, wPokemonData
	ld bc, wPokemonDataEnd - wPokemonData
	call CopyBytes
	call CloseSRAM
	ret

VerifyBackupChecksum:
	ld hl, sBackupGameData
	ld bc, sBackupGameDataEnd - sBackupGameData
	ld a, BANK(sBackupGameData)
	call GetSRAMBank
	call Checksum
	ld a, [sBackupChecksum + 0]
	cp e
	jr nz, .fail
	ld a, [sBackupChecksum + 1]
	cp d
.fail
	push af
	call CloseSRAM
	pop af
	ret

_SaveData:
	; This is called within two scenarios:
	;   a) ErasePreviousSave (the process of erasing the save from a previous game file)
	;   b) unused mobile functionality
	; It is not part of a regular save.

	ld a, BANK(sCrystalData)
	call GetSRAMBank
	ld hl, wCrystalData
	ld de, sCrystalData
	ld bc, wCrystalDataEnd - wCrystalData
	call CopyBytes

	; This block originally had some mobile functionality, but since we're still in
	; BANK(sCrystalData), it instead overwrites the sixteen wEventFlags starting at 1:a603 with
	; garbage from wd479. This isn't an issue, since ErasePreviousSave is followed by a regular
	; save that unwrites the garbage.

	ld hl, wd479
	ld a, [hli]
	ld [$a60e + 0], a
	ld a, [hli]
	ld [$a60e + 1], a

	jp CloseSRAM

_LoadData:
	ld a, BANK(sCrystalData)
	call GetSRAMBank
	ld hl, sCrystalData
	ld de, wCrystalData
	ld bc, wCrystalDataEnd - wCrystalData
	call CopyBytes

	; This block originally had some mobile functionality to mirror _SaveData above, but instead it
	; (harmlessly) writes the aforementioned wEventFlags to the unused wd479.

	ld hl, wd479
	ld a, [$a60e + 0]
	ld [hli], a
	ld a, [$a60e + 1]
	ld [hli], a

	jp CloseSRAM

GetBoxAddress:
	ld a, [wCurBox]
	cp NUM_BOXES
	jr c, .ok
	xor a
	ld [wCurBox], a

.ok
	ld e, a
	ld d, 0
	ld hl, BoxAddresses
rept 5
	add hl, de
endr
	ld a, [hli]
	push af
	ld a, [hli]
	ld e, a
	ld a, [hli]
	ld d, a
	ld a, [hli]
	ld h, [hl]
	ld l, a
	pop af
	ret

SaveBoxAddress:
; Save box via wBoxPartialData.
; We do this in three steps because the size of wBoxPartialData is less than
; the size of sBox.
	push hl
; Load the first part of the active box.
	push af
	push de
	ld a, BANK(sBox)
	call GetSRAMBank
	ld hl, sBox
	ld de, wBoxPartialData
	ld bc, (wBoxPartialDataEnd - wBoxPartialData)
	call CopyBytes
	call CloseSRAM
	pop de
	pop af
; Save it to the target box.
	push af
	push de
	call GetSRAMBank
	ld hl, wBoxPartialData
	ld bc, (wBoxPartialDataEnd - wBoxPartialData)
	call CopyBytes
	call CloseSRAM

; Load the second part of the active box.
	ld a, BANK(sBox)
	call GetSRAMBank
	ld hl, sBox + (wBoxPartialDataEnd - wBoxPartialData)
	ld de, wBoxPartialData
	ld bc, (wBoxPartialDataEnd - wBoxPartialData)
	call CopyBytes
	call CloseSRAM
	pop de
	pop af

	ld hl, (wBoxPartialDataEnd - wBoxPartialData)
	add hl, de
	ld e, l
	ld d, h
; Save it to the next part of the target box.
	push af
	push de
	call GetSRAMBank
	ld hl, wBoxPartialData
	ld bc, (wBoxPartialDataEnd - wBoxPartialData)
	call CopyBytes
	call CloseSRAM

; Load the third and final part of the active box.
	ld a, BANK(sBox)
	call GetSRAMBank
	ld hl, sBox + (wBoxPartialDataEnd - wBoxPartialData) * 2
	ld de, wBoxPartialData
	ld bc, sBoxEnd - (sBox + (wBoxPartialDataEnd - wBoxPartialData) * 2) ; $8e
	call CopyBytes
	call CloseSRAM
	pop de
	pop af

	ld hl, (wBoxPartialDataEnd - wBoxPartialData)
	add hl, de
	ld e, l
	ld d, h
; Save it to the final part of the target box.
	call GetSRAMBank
	ld hl, wBoxPartialData
	ld bc, sBoxEnd - (sBox + (wBoxPartialDataEnd - wBoxPartialData) * 2) ; $8e
	call CopyBytes
	call CloseSRAM

	pop hl
	ret

LoadBoxAddress:
; Load box via wBoxPartialData.
; We do this in three steps because the size of wBoxPartialData is less than
; the size of sBox.
	push hl
	ld l, e
	ld h, d
; Load part 1
	push af
	push hl
	call GetSRAMBank
	ld de, wBoxPartialData
	ld bc, (wBoxPartialDataEnd - wBoxPartialData)
	call CopyBytes
	call CloseSRAM
	ld a, BANK(sBox)
	call GetSRAMBank
	ld hl, wBoxPartialData
	ld de, sBox
	ld bc, (wBoxPartialDataEnd - wBoxPartialData)
	call CopyBytes
	call CloseSRAM
	pop hl
	pop af

	ld de, (wBoxPartialDataEnd - wBoxPartialData)
	add hl, de
; Load part 2
	push af
	push hl
	call GetSRAMBank
	ld de, wBoxPartialData
	ld bc, (wBoxPartialDataEnd - wBoxPartialData)
	call CopyBytes
	call CloseSRAM
	ld a, BANK(sBox)
	call GetSRAMBank
	ld hl, wBoxPartialData
	ld de, sBox + (wBoxPartialDataEnd - wBoxPartialData)
	ld bc, (wBoxPartialDataEnd - wBoxPartialData)
	call CopyBytes
	call CloseSRAM
	pop hl
	pop af
; Load part 3
	ld de, (wBoxPartialDataEnd - wBoxPartialData)
	add hl, de
	call GetSRAMBank
	ld de, wBoxPartialData
	ld bc, sBoxEnd - (sBox + (wBoxPartialDataEnd - wBoxPartialData) * 2) ; $8e
	call CopyBytes
	call CloseSRAM
	ld a, BANK(sBox)
	call GetSRAMBank
	ld hl, wBoxPartialData
	ld de, sBox + (wBoxPartialDataEnd - wBoxPartialData) * 2
	ld bc, sBoxEnd - (sBox + (wBoxPartialDataEnd - wBoxPartialData) * 2) ; $8e
	call CopyBytes
	call CloseSRAM

	pop hl
	ret

EraseBoxes:
	ld hl, BoxAddresses
	ld c, NUM_BOXES
.next
	push bc
	ld a, [hli]
	call GetSRAMBank
	ld a, [hli]
	ld e, a
	ld a, [hli]
	ld d, a
	xor a
	ld [de], a
	inc de
	ld a, -1
	ld [de], a
	inc de
	ld bc, sBoxEnd - (sBox + 2)
.clear
	xor a
	ld [de], a
	inc de
	dec bc
	ld a, b
	or c
	jr nz, .clear
	ld a, [hli]
	ld e, a
	ld a, [hli]
	ld d, a
	ld a, -1
	ld [de], a
	inc de
	xor a
	ld [de], a
	call CloseSRAM
	pop bc
	dec c
	jr nz, .next
	ret

BoxAddresses:
; dbww bank, address, address
	dbww BANK(sBox1),  sBox1,  sBox1End
	dbww BANK(sBox2),  sBox2,  sBox2End
	dbww BANK(sBox3),  sBox3,  sBox3End
	dbww BANK(sBox4),  sBox4,  sBox4End
	dbww BANK(sBox5),  sBox5,  sBox5End
	dbww BANK(sBox6),  sBox6,  sBox6End
	dbww BANK(sBox7),  sBox7,  sBox7End
	dbww BANK(sBox8),  sBox8,  sBox8End
	dbww BANK(sBox9),  sBox9,  sBox9End
	dbww BANK(sBox10), sBox10, sBox10End
	dbww BANK(sBox11), sBox11, sBox11End
	dbww BANK(sBox12), sBox12, sBox12End
	dbww BANK(sBox13), sBox13, sBox13End
	dbww BANK(sBox14), sBox14, sBox14End

Checksum:
	ld de, 0
.loop
	ld a, [hli]
	add e
	ld e, a
	ld a, 0
	adc d
	ld d, a
	dec bc
	ld a, b
	or c
	jr nz, .loop
	ret

Text_WouldYouLikeToSaveTheGame:
	; Would you like to save the game?
	text_far UnknownText_0x1c454b
	text_end

Text_PlayerSavedTheGame:
	; saved the game.
	text_far UnknownText_0x1c4590
	text_end

Text_AnotherSaveFile:
	; There is another save file. Is it OK to overwrite?
	text_far UnknownText_0x1c45d9
	text_end

Text_SaveFileCorrupted:
	; The save file is corrupted!
	text_far UnknownText_0x1c460d
	text_end

Text_SaveOnBoxSwitch:
	; When you change a #MON BOX, data will be saved. OK?
	text_far UnknownText_0x1c462a
	text_end

Text_SaveOnMoveMonWOMail:
	; Each time you move a #MON, data will be saved. OK?
	text_far UnknownText_0x1c465f
	text_end
