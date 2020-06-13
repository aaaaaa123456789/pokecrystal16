_GiveOddEgg:
	; Figure out which egg to give.

	; Compare a random word to
	; probabilities out of 0xffff.
	call Random
	ld hl, OddEggProbabilities
	ld c, 0
	ld b, c
.loop
	ld a, [hli]
	ld e, a
	ld a, [hli]
	ld d, a

	; Break on $ffff.
	ld a, d
	cp HIGH($ffff)
	jr nz, .not_done
	ld a, e
	cp LOW($ffff)
	jr z, .done
.not_done

	; Break when [hRandom] <= de.
	ldh a, [hRandom + 1]
	cp d
	jr c, .done
	jr z, .ok
	jr .next
.ok
	ldh a, [hRandom + 0]
	cp e
	jr c, .done
	jr z, .done
.next
	inc bc
	jr .loop
.done

	push bc
	ld hl, OddEggs
	ld a, NICKNAMED_MON_STRUCT_LENGTH
	call AddNTimes

	; Writes to wOddEgg, wOddEggName, and wOddEggOTName,
	; even though OddEggs does not have data for wOddEggOTName
	ld de, wOddEgg
	ld bc, NICKNAMED_MON_STRUCT_LENGTH + NAME_LENGTH
	call CopyBytes
	
	; Loads the actual species and overwrites the zero in wOddEggSpecies
	pop hl
	add hl, hl
	push hl
	ld bc, OddEggSpecies
	add hl, bc
	ld a, [hli]
	ld h, [hl]
	ld l, a
	call GetPokemonIDFromIndex
	ld [wOddEggSpecies], a

	; And likewise with moves
	pop hl
	add hl, hl
	add hl, hl
	ld bc, OddEggMoves
	add hl, bc
	ld c, NUM_MOVES
	ld de, wOddEggMoves
.move_loop
	ld a, [hli]
	push hl
	ld h, [hl]
	ld l, a
	call GetMoveIDFromIndex
	pop hl
	inc hl
	ld [de], a
	inc de
	dec c
	jr nz, .move_loop

	ld a, EGG_TICKET
	ld [wCurItem], a
	ld a, 1
	ld [wItemQuantityChangeBuffer], a
	ld a, -1
	ld [wCurItemQuantity], a
	ld hl, wNumItems
	call TossItem

	; load species in wcd2a
	ld a, EGG
	ld [wMobileMonSpeciesBuffer], a

	; load pointer to (wMobileMonSpeciesBuffer - 1) in wMobileMonSpeciesPointerBuffer
	ld a, LOW(wMobileMonSpeciesBuffer - 1)
	ld [wMobileMonSpeciesPointerBuffer], a
	ld a, HIGH(wMobileMonSpeciesBuffer - 1)
	ld [wMobileMonSpeciesPointerBuffer + 1], a
	; load pointer to wOddEgg in wMobileMonStructurePointerBuffer
	ld a, LOW(wOddEgg)
	ld [wMobileMonStructurePointerBuffer], a
	ld a, HIGH(wOddEgg)
	ld [wMobileMonStructurePointerBuffer + 1], a

	; load Odd Egg Name in wTempOddEggNickname
	ld hl, .Odd
	ld de, wTempOddEggNickname
	ld bc, MON_NAME_LENGTH
	call CopyBytes

	; load pointer to wTempOddEggNickname in wMobileMonOTNamePointerBuffer
	ld a, LOW(wTempOddEggNickname)
	ld [wMobileMonOTNamePointerBuffer], a
	ld a, HIGH(wTempOddEggNickname)
	ld [wMobileMonOTNamePointerBuffer + 1], a
	; load pointer to wOddEggName in wMobileMonNicknamePointerBuffer
	ld a, LOW(wOddEggName)
	ld [wMobileMonNicknamePointerBuffer], a
	ld a, HIGH(wOddEggName)
	ld [wMobileMonNicknamePointerBuffer + 1], a
	farcall AddMobileMonToParty
	ret

.Odd:
	db "ODD@@@@@@@@@"

INCLUDE "data/events/odd_eggs.asm"
