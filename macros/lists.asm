list_item: MACRO
.__item\1
if (_NARG > 1)
	db .__item\2 - .__item\1
endc
ENDM

current_list_item = 0

next_list_item: MACRO
next_list_item_index = current_list_item + 1
	list_item {d:current_list_item}, {d:next_list_item_index}
current_list_item = next_list_item_index
ENDM

end_list_items: MACRO
	list_item {d:current_list_item}
current_list_item = 0
ENDM
