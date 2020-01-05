_Multiply::
; hMultiplier is one byte.
	ld a, 8
	ld b, a

	xor a
	ldh [hMultiplicand - 1], a
	ldh [hMathBuffer + 1], a
	ldh [hMathBuffer + 2], a
	ldh [hMathBuffer + 3], a
	ldh [hMathBuffer + 4], a

.loop
	ldh a, [hMultiplier]
	srl a
	ldh [hMultiplier], a
	jr nc, .next

	ldh a, [hMathBuffer + 4]
	ld c, a
	ldh a, [hMultiplicand + 2]
	add c
	ldh [hMathBuffer + 4], a

	ldh a, [hMathBuffer + 3]
	ld c, a
	ldh a, [hMultiplicand + 1]
	adc c
	ldh [hMathBuffer + 3], a

	ldh a, [hMathBuffer + 2]
	ld c, a
	ldh a, [hMultiplicand]
	adc c
	ldh [hMathBuffer + 2], a

	ldh a, [hMathBuffer + 1]
	ld c, a
	ldh a, [hMultiplicand - 1]
	adc c
	ldh [hMathBuffer + 1], a

.next
	dec b
	jr z, .done

; hMultiplicand <<= 1

	ldh a, [hMultiplicand + 2]
	add a
	ldh [hMultiplicand + 2], a

	ldh a, [hMultiplicand + 1]
	rla
	ldh [hMultiplicand + 1], a

	ldh a, [hMultiplicand]
	rla
	ldh [hMultiplicand], a

	ldh a, [hMultiplicand - 1]
	rla
	ldh [hMultiplicand - 1], a

	jr .loop

.done
	ldh a, [hMathBuffer + 4]
	ldh [hProduct + 3], a

	ldh a, [hMathBuffer + 3]
	ldh [hProduct + 2], a

	ldh a, [hMathBuffer + 2]
	ldh [hProduct + 1], a

	ldh a, [hMathBuffer + 1]
	ldh [hProduct], a

	ret

_Divide::
	xor a
	ldh [hMathBuffer], a
	ldh [hMathBuffer + 1], a
	ldh [hMathBuffer + 2], a
	ldh [hMathBuffer + 3], a
	ldh [hMathBuffer + 4], a

	ld a, 9
	ld e, a

.loop
	ldh a, [hMathBuffer]
	ld c, a
	ldh a, [hDividend + 1]
	sub c
	ld d, a

	ldh a, [hDivisor]
	ld c, a
	ldh a, [hDividend]
	sbc c
	jr c, .next

	ldh [hDividend], a

	ld a, d
	ldh [hDividend + 1], a

	ldh a, [hMathBuffer + 4]
	inc a
	ldh [hMathBuffer + 4], a

	jr .loop

.next
	ld a, b
	cp 1
	jr z, .done

	ldh a, [hMathBuffer + 4]
	add a
	ldh [hMathBuffer + 4], a

	ldh a, [hMathBuffer + 3]
	rla
	ldh [hMathBuffer + 3], a

	ldh a, [hMathBuffer + 2]
	rla
	ldh [hMathBuffer + 2], a

	ldh a, [hMathBuffer + 1]
	rla
	ldh [hMathBuffer + 1], a

	dec e
	jr nz, .next2

	ld e, 8
	ldh a, [hMathBuffer]
	ldh [hDivisor], a
	xor a
	ldh [hMathBuffer], a

	ldh a, [hDividend + 1]
	ldh [hDividend], a

	ldh a, [hDividend + 2]
	ldh [hDividend + 1], a

	ldh a, [hDividend + 3]
	ldh [hDividend + 2], a

.next2
	ld a, e
	cp 1
	jr nz, .okay
	dec b

.okay
	ldh a, [hDivisor]
	srl a
	ldh [hDivisor], a

	ldh a, [hMathBuffer]
	rra
	ldh [hMathBuffer], a

	jr .loop

.done
	ldh a, [hDividend + 1]
	ldh [hRemainder], a

	ldh a, [hMathBuffer + 4]
	ldh [hQuotient + 3], a

	ldh a, [hMathBuffer + 3]
	ldh [hQuotient + 2], a

	ldh a, [hMathBuffer + 2]
	ldh [hQuotient + 1], a

	ldh a, [hMathBuffer + 1]
	ldh [hQuotient], a

	ret
