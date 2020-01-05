NamesPointers::
; entries correspond to GetName constants (see constants/text_constants.asm); MON_NAME is not handled by this table
	dba MoveNames           ; MOVE_NAME
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

	ld a, [wNamedObjectTypeBuffer]
	dec a
	jr nz, .not_mon_name

	ld a, [wCurSpecies]
	ld [wNamedObjectIndexBuffer], a
	call GetPokemonName
	jr .done

.not_mon_name
	dec a
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
	call CopyBytes

.done
	pop de
	pop bc
	pop hl
	pop af
	rst Bankswitch
	ret

GetNthString::
; Return the address of the
; ath string starting from hl.

	and a
	ret z

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
	dec a
	ld d, 0
	ld e, a
	ld h, 0
	ld l, a
	add hl, hl ; hl = hl * 4
	add hl, hl ; hl = hl * 4
	add hl, de ; hl = (hl*4) + de
	add hl, hl ; hl = (5*hl) + (5*hl)
	ld de, PokemonNames
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

	ld a, MOVE_NAME
	ld [wNamedObjectTypeBuffer], a

	ld a, [wNamedObjectIndexBuffer] ; move id
	ld [wCurSpecies], a

	call GetName
	ld de, wStringBuffer1

	pop hl
	ret
