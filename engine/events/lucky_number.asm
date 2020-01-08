CheckForLuckyNumberWinners:
	xor a
	ld [wScriptVar], a
	ld [wTempByteValue], a
	ld a, [wPartyCount]
	and a
	ret z
	ld d, a
	ld hl, wPartyMon1ID
	ld bc, wPartySpecies
.PartyLoop:
	ld a, [bc]
	inc bc
	cp EGG
	call nz, .CompareLuckyNumberToMonID
	push bc
	ld bc, PARTYMON_STRUCT_LENGTH
	add hl, bc
	pop bc
	dec d
	jr nz, .PartyLoop
	ld a, BANK(sBox)
	call GetSRAMBank
	ld a, [sBoxCount]
	and a
	jr z, .SkipOpenBox
	ld d, a
	ld hl, sBoxMon1ID
	ld bc, sBoxSpecies
.OpenBoxLoop:
	ld a, [bc]
	inc bc
	cp EGG
	jr z, .SkipOpenBoxMon
	call .CompareLuckyNumberToMonID
	jr nc, .SkipOpenBoxMon
	ld a, TRUE
	ld [wTempByteValue], a

.SkipOpenBoxMon:
	push bc
	ld bc, BOXMON_STRUCT_LENGTH
	add hl, bc
	pop bc
	dec d
	jr nz, .OpenBoxLoop

.SkipOpenBox:
	call CloseSRAM
	ld c, $0
.BoxesLoop:
	ld a, [wCurBox]
	and $f
	cp c
	jr z, .SkipBox
	ld hl, .BoxBankAddresses
	ld b, 0
	add hl, bc
	add hl, bc
	add hl, bc
	ld a, [hli]
	call GetSRAMBank
	ld a, [hli]
	ld h, [hl]
	ld l, a ; hl now contains the address of the loaded box in SRAM
	ld a, [hl]
	and a
	jr z, .SkipBox ; no mons in this box
	ld [wTempLoopCounter], a
	ld de, sBoxMon1ID - sBox
	add hl, de
	ld d, 0
	ld e, c
	push bc
	ld b, h
	ld c, l
	inc bc
.BoxNLoop:
	ld a, [bc]
	inc bc
	cp EGG
	jr z, .SkipBoxMon

	call .CompareLuckyNumberToMonID ; sets wScriptVar and wCurPartySpecies appropriately
	jr nc, .SkipBoxMon
	ld a, e
	add a, 2
	ld [wTempByteValue], a
	ld a, d
	ld [wCurPartySpecies], a

.SkipBoxMon:
	push bc
	ld bc, BOXMON_STRUCT_LENGTH
	add hl, bc
	pop bc
	inc d
	ld a, [wTempLoopCounter]
	cp d
	jr nz, .BoxNLoop
	pop bc

.SkipBox:
	inc c
	ld a, c
	cp NUM_BOXES
	jr c, .BoxesLoop

	call CloseSRAM
	ld a, [wScriptVar]
	and a
	ret z ; found nothing
	farcall StubbedTrainerRankings_LuckyNumberShow
	ld a, [wTempByteValue]
	ld hl, .FoundPartymonText
	and a
	jr z, .print
	dec a
	jr z, .print_box
	ld e, a
	ld d, 0
	ld hl, .BoxSpeciesBankAddresses - 3 ;box number is one-based here
	add hl, de
	add hl, de
	add hl, de
	ld a, [hli]
	call GetSRAMBank
	ld a, [hli]
	ld h, [hl]
	ld l, a
	ld a, [wCurPartySpecies]
	ld e, a
	add hl, de
	add hl, de
	ld a, [hli]
	ld h, [hl]
	ld l, a
	call CloseSRAM
	call GetPokemonIDFromIndex
	ld [wCurPartySpecies], a
.print_box
	ld hl, .FoundBoxmonText
.print
	ld a, [wCurPartySpecies]
	ld [wNamedObjectIndexBuffer], a
	call GetPokemonName
	jp PrintText

.CompareLuckyNumberToMonID:
	push bc
	push de
	push hl
	ld d, h
	ld e, l
	ld hl, wBuffer1
	lb bc, PRINTNUM_LEADINGZEROS | 2, 5
	call PrintNum
	ld hl, wLuckyNumberDigitsBuffer
	ld de, wLuckyIDNumber
	lb bc, PRINTNUM_LEADINGZEROS | 2, 5
	call PrintNum
	ld b, 5
	ld c, 0
	ld hl, wLuckyNumberDigitsBuffer + 4
	ld de, wBuffer1 + 4
.loop
	ld a, [de]
	cp [hl]
	jr nz, .done
	dec de
	dec hl
	inc c
	dec b
	jr nz, .loop

.done
	pop hl
	push hl
	ld de, -6
	add hl, de
	ld a, [hl]
	pop hl
	pop de
	push af
	ld a, c
	ld b, 1
	cp 5
	jr z, .okay
	ld b, 2
	cp 3
	jr nc, .okay
	ld b, 3
	cp 2
	jr nz, .nomatch

.okay
	inc b
	ld a, [wScriptVar]
	and a
	jr z, .bettermatch
	cp b
	jr c, .nomatch

.bettermatch
	dec b
	ld a, b
	ld [wScriptVar], a
	pop bc
	ld a, b
	ld [wCurPartySpecies], a
	pop bc
	scf
	ret

.nomatch
	pop bc
	pop bc
	and a
	ret

.BoxBankAddresses:
	dba sBox1
	dba sBox2
	dba sBox3
	dba sBox4
	dba sBox5
	dba sBox6
	dba sBox7
	dba sBox8
	dba sBox9
	dba sBox10
	dba sBox11
	dba sBox12
	dba sBox13
	dba sBox14

.BoxSpeciesBankAddresses:
	dba sBox1PokemonIndexes
	dba sBox2PokemonIndexes
	dba sBox3PokemonIndexes
	dba sBox4PokemonIndexes
	dba sBox5PokemonIndexes
	dba sBox6PokemonIndexes
	dba sBox7PokemonIndexes
	dba sBox8PokemonIndexes
	dba sBox9PokemonIndexes
	dba sBox10PokemonIndexes
	dba sBox11PokemonIndexes
	dba sBox12PokemonIndexes
	dba sBox13PokemonIndexes
	dba sBox14PokemonIndexes

.FoundPartymonText:
	; Congratulations! We have a match with the ID number of @  in your party.
	text_far UnknownText_0x1c1261
	text_end

.FoundBoxmonText:
	; Congratulations! We have a match with the ID number of @  in your PC BOX.
	text_far UnknownText_0x1c12ae
	text_end

PrintTodaysLuckyNumber:
	ld hl, wStringBuffer3
	ld de, wLuckyIDNumber
	lb bc, PRINTNUM_LEADINGZEROS | 2, 5
	call PrintNum
	ld a, "@"
	ld [wStringBuffer3 + 5], a
	ret
