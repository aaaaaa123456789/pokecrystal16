___current_indirect_size = 0

; usage:
; Table:
;   indirect_table <entry size>, <start index> (0-1)
;   indirect_entries <max index>, <optional far label>
;   (repeat as many times as necessary)
;   indirect_table_end

indirect_table: MACRO
	; arguments: entry size, initial index (0 or 1)
	if ((\2) * (\2)) != (\2)
		; guarantees that the index is something numeric, and it's only true if the index is 0 or 1
		fail "indirect table error: invalid initial index (must be 0 or 1)"
	endc
	if ___current_indirect_size
		fail "indirect table error: there's already an active indirect table"
	endc
	if (\1) < 1
		fail "indirect table error: the entry size must be positive"
	endc
	if (\1) > $7FFF
		; the limit could be set much lower, but this will do as a sanity check
		fail "indirect table error: entry size is set to an invalid value"
	endc
___current_indirect_index = \2
___current_indirect_size = \1
	dw (\1) | ((\2) << 15)
ENDM

indirect_entries: MACRO
	; arguments: next max index, far label (omit for zero/no data), far bank (if different from label)
	if ___current_indirect_size == 0
		fail "indirect table error: there's no active indirect table"
	endc
	if (\1) < ___current_indirect_index
		fail "indirect table error: attempted to move backwards"
	endc
___current_indirect_count = (\1) + 1 - ___current_indirect_index
___current_indirect_index = (\1) + 1
___current_indirect_iteration_limit = ___current_indirect_count / $FF
___current_indirect_count = ___current_indirect_count % $FF
	if ___current_indirect_iteration_limit
___current_indirect_iteration = 0
		rept ___current_indirect_iteration_limit
			db $FF
			if _NARG == 1
				db 0, 0, 0
			else
				if _NARG == 2
					db BANK(\2)
				else
					db \3
				endc
				dw (\2) + $FF * ___current_indirect_size * ___current_indirect_iteration
			endc
___current_indirect_iteration = ___current_indirect_iteration + 1
		endr
	endc
	if ___current_indirect_count
		db ___current_indirect_count
		if _NARG == 1
			db 0, 0, 0
		else
			if _NARG == 2
				db BANK(\2)
			else
				db \3
			endc
			dw (\2) + $FF * ___current_indirect_size * ___current_indirect_iteration_limit
		endc
	endc
ENDM

indirect_table_end: MACRO
	; no arguments
	if ___current_indirect_size == 0
		fail "indirect table error: there's no active indirect table"
	endc
	db 0
___current_indirect_size = 0
ENDM
