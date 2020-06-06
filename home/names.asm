NamesPointers::
; entries correspond to GetName constants (see constants/text_constants.asm); MON_NAME and MOVE_NAME are not handled by this table
	dba ItemNames           ; ITEM_NAME
	dbw 0, wPartyMonOT      ; PARTY_OT_NAME
	dbw 0, wOTPartyMonOT    ; ENEMY_OT_NAME
	dba TrainerClassNames   ; TRAINER_NAME

GetName::
; Return name wCurSpecies from name list wNamedObjectTypeBuffer in wStringBuffer1.

	ldh a, [hROMBank]
	push af
	push hl
	push bc
	push de

	ld a, [wCurSpecies]
	ld [wNamedObjectIndexBuffer], a

	ld a, [wNamedObjectTypeBuffer]
	dec a ; MON_NAME
	ld hl, GetPokemonName
	jr z, .go
	dec a ; MOVE_NAME
	ld hl, GetMoveName
	jr z, .go
	dec a
	ld hl, .generic_function
.go
	call _hl_

	pop de
	pop bc
	pop hl
	pop af
	rst Bankswitch
	ret

.generic_function
	ld l, a
	add a, a
	add a, l
	add a, LOW(NamesPointers)
	ld l, a
	ld a, HIGH(NamesPointers)
	adc 0
	ld h, a
	ld a, [hli]
	rst Bankswitch
	ld a, [hli]
	ld h, [hl]
	ld l, a

	ld a, [wCurSpecies]
	dec a
	call GetNthString

	ld de, wStringBuffer1
	ld bc, ITEM_NAME_LENGTH
	jp CopyBytes

GetNthString16::
; Like GetNthString, but with a 16-bit index in bc
	inc b
	jr .handle_loop

.loop
	xor a
	call GetNthString.loop ; will act as a = $100
.handle_loop
	dec b
	jr nz, .loop
	ld a, c
	; fallthrough

GetNthString::
; Return the address of the
; ath string starting from hl.

	and a
	ret z

.loop
	push bc
	ld b, a
	ld c, "@"
.readChar
	ld a, [hli]
	cp c
	jr nz, .readChar
	dec b
	jr nz, .readChar
	pop bc
	ret

GetBasePokemonName::
; Discards gender (Nidoran).

	push hl
	call GetPokemonName

	ld hl, wStringBuffer1
.loop
	ld a, [hl]
	cp "@"
	jr z, .quit
	cp "♂"
	jr z, .end
	cp "♀"
	jr z, .end
	inc hl
	jr .loop
.end
	ld [hl], "@"
.quit
	pop hl
	ret

GetPokemonName::
; Get Pokemon name for wNamedObjectIndexBuffer.

	ldh a, [hROMBank]
	push af
	push hl
	ld a, BANK(PokemonNames)
	rst Bankswitch

; Each name is ten characters
	ld a, [wNamedObjectIndexBuffer]
	call GetPokemonIndexFromID
	ld e, l
	ld d, h
	add hl, hl ; hl = hl * 4
	add hl, hl ; hl = hl * 4
	add hl, de ; hl = (hl*4) + de
	add hl, hl ; hl = (5*hl) + (5*hl)
	ld de, PokemonNames - 10
	add hl, de

; Terminator
	ld de, wStringBuffer1
	push de
	ld bc, MON_NAME_LENGTH - 1
	call CopyBytes
	ld hl, wStringBuffer1 + MON_NAME_LENGTH - 1
	ld [hl], "@"
	pop de

	pop hl
	pop af
	rst Bankswitch
	ret

GetItemName::
; Get item name for wNamedObjectIndexBuffer.

	push hl
	push bc
	ld a, [wNamedObjectIndexBuffer]

	cp TM01
	jr nc, .TM

	ld [wCurSpecies], a
	ld a, ITEM_NAME
	ld [wNamedObjectTypeBuffer], a
	call GetName
	jr .Copied
.TM:
	call GetTMHMName
.Copied:
	ld de, wStringBuffer1
	pop bc
	pop hl
	ret

GetTMHMName::
; Get TM/HM name for item wNamedObjectIndexBuffer.

	push hl
	push de
	push bc
	ld a, [wNamedObjectIndexBuffer]
	push af

; TM/HM prefix
	cp HM01
	push af
	jr c, .TM

	ld hl, .HMText
	ld bc, .HMTextEnd - .HMText
	jr .asm_34a1

.TM:
	ld hl, .TMText
	ld bc, .TMTextEnd - .TMText

.asm_34a1
	ld de, wStringBuffer1
	call CopyBytes

; TM/HM number
	push de
	ld a, [wNamedObjectIndexBuffer]
	ld c, a
	callfar GetTMHMNumber
	pop de

; HM numbers start from 51, not 1
	pop af
	ld a, c
	jr c, .asm_34b9
	sub NUM_TMS
.asm_34b9

; Divide and mod by 10 to get the top and bottom digits respectively
	ld b, "0"
.mod10
	sub 10
	jr c, .asm_34c2
	inc b
	jr .mod10
.asm_34c2
	add 10

	push af
	ld a, b
	ld [de], a
	inc de
	pop af

	ld b, "0"
	add b
	ld [de], a

; End the string
	inc de
	ld a, "@"
	ld [de], a

	pop af
	ld [wNamedObjectIndexBuffer], a
	pop bc
	pop de
	pop hl
	ret

.TMText:
	db "TM"
.TMTextEnd:
	db "@"

.HMText:
	db "HM"
.HMTextEnd:
	db "@"

INCLUDE "home/hm_moves.asm"

GetMoveName::
	push hl
	push bc
	ldh a, [hROMBank]
	push af
	ld a, BANK(MoveNames)
	rst Bankswitch
	ld a, [wNamedObjectIndexBuffer]
	call GetMoveIndexFromID
	dec hl
	ld b, h
	ld c, l
	ld hl, MoveNames
	call GetNthString16
	ld de, wStringBuffer1
	push de
	ld bc, MOVE_NAME_LENGTH
	call CopyBytes
	pop de
	pop af
	rst Bankswitch
	pop bc
	pop hl
	ret
