GetPartyParamLocation::
; Get the location of parameter a from wCurPartyMon in hl
	push bc
	ld hl, wPartyMons
	ld c, a
	ld b, 0
	add hl, bc
	ld a, [wCurPartyMon]
	call GetPartyLocation
	pop bc
	ret

GetPartyLocation::
; Add the length of a PartyMon struct to hl a times.
	ld bc, PARTYMON_STRUCT_LENGTH
	jp AddNTimes

FarSkipEvolutions::
; Calls SkipEvolutions from another bank. It can't be a farcall because it uses hl.
	ldh a, [hROMBank]
	push af
	ld a, BANK(SkipEvolutions)
	rst Bankswitch
	call SkipEvolutions
	pop af
	rst Bankswitch
	ret
