_GetVarAction::
	ld a, c
	cp NUM_VARS
	jr c, .valid
	xor a
.valid
	ld c, a
	ld b, 0
	ld hl, .VarActionTable
	add hl, bc
	add hl, bc
	add hl, bc
	ld e, [hl]
	inc hl
	ld d, [hl]
	inc hl
	ld b, [hl]
	ld a, b
	and RETVAR_EXECUTE
	jr nz, .call
	ld a, b
	and RETVAR_ADDR_DE
	ret nz
	ld a, [de]
	jr .loadstringbuffer2

.call
	call _de_
	ret

.loadstringbuffer2
	ld de, wStringBuffer2
	ld [de], a
	ret

.VarActionTable:
; entries correspond to VAR_* constants
	; RETVAR_STRBUF2: copy [de] to wStringBuffer2
	; RETVAR_ADDR_DE: return address in de
	; RETVAR_EXECUTE: call function
	dwb wStringBuffer2,                 RETVAR_STRBUF2
	dwb wPartyCount,                    RETVAR_STRBUF2
	dwb .BattleResult,                  RETVAR_EXECUTE
	dwb wBattleType,                    RETVAR_ADDR_DE
	dwb wTimeOfDay,                     RETVAR_STRBUF2
	dwb .CountCaughtMons,               RETVAR_EXECUTE
	dwb .CountSeenMons,                 RETVAR_EXECUTE
	dwb .CountBadges,                   RETVAR_EXECUTE
	dwb wPlayerState,                   RETVAR_ADDR_DE
	dwb .PlayerFacing,                  RETVAR_EXECUTE
	dwb hHours,                         RETVAR_STRBUF2
	dwb .DayOfWeek,                     RETVAR_EXECUTE
	dwb wMapGroup,                      RETVAR_STRBUF2
	dwb wMapNumber,                     RETVAR_STRBUF2
	dwb .UnownCaught,                   RETVAR_EXECUTE
	dwb wEnvironment,                   RETVAR_STRBUF2
	dwb .BoxFreeSpace,                  RETVAR_EXECUTE
	dwb wBugContestMinsRemaining,       RETVAR_STRBUF2
	dwb wXCoord,                        RETVAR_STRBUF2
	dwb wYCoord,                        RETVAR_STRBUF2
	dwb wSpecialPhoneCallID,            RETVAR_STRBUF2
	dwb wNrOfBeatenBattleTowerTrainers, RETVAR_STRBUF2
	dwb wKurtApricornQuantity,          RETVAR_STRBUF2
	dwb wCurCaller,                     RETVAR_ADDR_DE
	dwb wBlueCardBalance,               RETVAR_ADDR_DE
	dwb wBuenasPassword,                RETVAR_ADDR_DE
	dwb wKenjiBreakTimer,               RETVAR_STRBUF2
	dwb .CountUncaughtMons,             RETVAR_EXECUTE

.CountCaughtMons:
; Caught mons. Saturate at 255.
	ld hl, wPokedexCaught
.count_caught_or_seen_mons
	ld bc, wEndPokedexCaught - wPokedexCaught
	call CountSetBits16
	ld a, b
.load_or_saturate
	add a, -1
	sbc a
	or c
	jp .loadstringbuffer2

.CountSeenMons:
; Seen mons. Saturate at 255.
	ld hl, wPokedexSeen
	jr .count_caught_or_seen_mons

.CountUncaughtMons:
; Mons left to catch. Saturate at 255.
	ld hl, wPokedexCaught
	ld bc, wEndPokedexCaught - wPokedexCaught
	call CountSetBits16
	ld a, LOW(NUM_POKEMON)
	sub c
	ld c, a
	ld a, HIGH(NUM_POKEMON)
	sbc b
	jr .load_or_saturate

.CountBadges:
; Number of owned badges.
	ld hl, wBadges
	ld b, 2
	call CountSetBits
	ld a, [wNumSetBits]
	jp .loadstringbuffer2

.PlayerFacing:
; The direction the player is facing.
	ld a, [wPlayerDirection]
	and $c
	rrca
	rrca
	jp .loadstringbuffer2

.DayOfWeek:
; The day of the week.
	call GetWeekday
	jp .loadstringbuffer2

.UnownCaught:
; Number of unique Unown caught.
	call .count
	ld a, b
	jp .loadstringbuffer2

.count
	ld hl, wUnownDex
	ld b, 0
.loop
	ld a, [hli]
	and a
	ret z
	inc b
	ld a, b
	cp NUM_UNOWN
	jr c, .loop
	ret

.BoxFreeSpace:
; Remaining slots in the current box.
	ld a, BANK(sBoxCount)
	call GetSRAMBank
	ld hl, sBoxCount
	ld a, MONS_PER_BOX
	sub [hl]
	ld b, a
	call CloseSRAM
	ld a, b
	jp .loadstringbuffer2

.BattleResult:
	ld a, [wBattleResult]
	and $ff ^ BATTLERESULT_BITMASK
	jp .loadstringbuffer2
