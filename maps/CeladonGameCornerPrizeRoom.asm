CELADONGAMECORNERPRIZEROOM_TM32_COINS EQU 1500
CELADONGAMECORNERPRIZEROOM_TM29_COINS EQU 3500
CELADONGAMECORNERPRIZEROOM_TM15_COINS EQU 7500
CELADONGAMECORNERPRIZEROOM_PIKACHU_COINS  EQU 2222
CELADONGAMECORNERPRIZEROOM_PORYGON_COINS  EQU 5555
CELADONGAMECORNERPRIZEROOM_LARVITAR_COINS EQU 8888

	object_const_def ; object_event constants
	const CELADONGAMECORNERPRIZEROOM_GENTLEMAN
	const CELADONGAMECORNERPRIZEROOM_PHARMACIST

CeladonGameCornerPrizeRoom_MapScripts:
	db 0 ; scene scripts

	db 0 ; callbacks

CeladonGameCornerPrizeRoomGentlemanScript:
	jumptextfaceplayer CeladonGameCornerPrizeRoomGentlemanText

CeladonGameCornerPrizeRoomPharmacistScript:
	jumptextfaceplayer CeladonGameCornerPrizeRoomPharmacistText

CeladonGameCornerPrizeRoomTMVendor:
	faceplayer
	opentext
	writetext CeladonPrizeRoom_PrizeVendorIntroText
	waitbutton
	checkitem COIN_CASE
	iffalse CeladonPrizeRoom_NoCoinCase
	writetext CeladonPrizeRoom_AskWhichPrizeText
CeladonPrizeRoom_tmcounterloop:
	special DisplayCoinCaseBalance
	loadmenu CeladonPrizeRoom_TMMenuHeader
	verticalmenu
	closewindow
	ifequal 1, .DoubleTeam
	ifequal 2, .Psychic
	ifequal 3, .HyperBeam
	sjump CeladonPrizeRoom_CancelPurchaseScript

.DoubleTeam:
	checkcoins CELADONGAMECORNERPRIZEROOM_TM32_COINS
	ifequal HAVE_LESS, CeladonPrizeRoom_notenoughcoins
	getitemname STRING_BUFFER_3, TM_DOUBLE_TEAM
	scall CeladonPrizeRoom_askbuy
	iffalse CeladonPrizeRoom_CancelPurchaseScript
	giveitem TM_DOUBLE_TEAM
	iffalse CeladonPrizeRoom_notenoughroom
	takecoins CELADONGAMECORNERPRIZEROOM_TM32_COINS
	sjump CeladonPrizeRoom_purchased

.Psychic:
	checkcoins CELADONGAMECORNERPRIZEROOM_TM29_COINS
	ifequal HAVE_LESS, CeladonPrizeRoom_notenoughcoins
	getitemname STRING_BUFFER_3, TM_PSYCHIC_M
	scall CeladonPrizeRoom_askbuy
	iffalse CeladonPrizeRoom_CancelPurchaseScript
	giveitem TM_PSYCHIC_M
	iffalse CeladonPrizeRoom_notenoughroom
	takecoins CELADONGAMECORNERPRIZEROOM_TM29_COINS
	sjump CeladonPrizeRoom_purchased

.HyperBeam:
	checkcoins CELADONGAMECORNERPRIZEROOM_TM15_COINS
	ifequal HAVE_LESS, CeladonPrizeRoom_notenoughcoins
	getitemname STRING_BUFFER_3, TM_HYPER_BEAM
	scall CeladonPrizeRoom_askbuy
	iffalse CeladonPrizeRoom_CancelPurchaseScript
	giveitem TM_HYPER_BEAM
	iffalse CeladonPrizeRoom_notenoughroom
	takecoins CELADONGAMECORNERPRIZEROOM_TM15_COINS
	sjump CeladonPrizeRoom_purchased

CeladonPrizeRoom_askbuy:
	writetext CeladonPrizeRoom_ConfirmPurchaseText
	yesorno
	end

CeladonPrizeRoom_purchased:
	waitsfx
	playsound SFX_TRANSACTION
	writetext CeladonPrizeRoom_HereYouGoText
	waitbutton
	sjump CeladonPrizeRoom_tmcounterloop

CeladonPrizeRoom_notenoughcoins:
	writetext CeladonPrizeRoom_NotEnoughCoinsText
	waitbutton
	closetext
	end

CeladonPrizeRoom_notenoughroom:
	writetext CeladonPrizeRoom_NotEnoughRoomText
	waitbutton
	closetext
	end

CeladonPrizeRoom_CancelPurchaseScript:
	writetext CeladonPrizeRoom_ComeAgainText
	waitbutton
	closetext
	end

CeladonPrizeRoom_NoCoinCase:
	writetext CeladonPrizeRoom_NoCoinCaseText
	waitbutton
	closetext
	end

CeladonPrizeRoom_TMMenuHeader:
	db MENU_BACKUP_TILES ; flags
	menu_coords 0, 2, 15, TEXTBOX_Y - 1
	dw .MenuData
	db 1 ; default option

.MenuData:
	db STATICMENU_CURSOR ; flags
	db 4 ; items
	db "TM32    1500@"
	db "TM29    3500@"
	db "TM15    7500@"
	db "CANCEL@"

CeladonGameCornerPrizeRoomPokemonVendor:
	faceplayer
	opentext
	writetext CeladonPrizeRoom_PrizeVendorIntroText
	waitbutton
	checkitem COIN_CASE
	iffalse CeladonPrizeRoom_NoCoinCase
.loop
	writetext CeladonPrizeRoom_AskWhichPrizeText
	special DisplayCoinCaseBalance
	loadmenu .MenuHeader
	verticalmenu
	closewindow
	ifequal 1, .Pikachu
	ifequal 2, .Porygon
	ifequal 3, .Larvitar
	sjump CeladonPrizeRoom_CancelPurchaseScript

.Pikachu:
	checkcoins CELADONGAMECORNERPRIZEROOM_PIKACHU_COINS
	ifequal HAVE_LESS, CeladonPrizeRoom_notenoughcoins
	readvar VAR_PARTYCOUNT
	ifequal PARTY_LENGTH, CeladonPrizeRoom_notenoughroom
	getmonname STRING_BUFFER_3, PIKACHU
	scall CeladonPrizeRoom_askbuy
	iffalse CeladonPrizeRoom_CancelPurchaseScript
	waitsfx
	playsound SFX_TRANSACTION
	writetext CeladonPrizeRoom_HereYouGoText
	waitbutton
	loadmonindex 1, PIKACHU
	special GameCornerPrizeMonCheckDex
	givepoke PIKACHU, 25
	takecoins CELADONGAMECORNERPRIZEROOM_PIKACHU_COINS
	sjump .loop

.Porygon:
	checkcoins CELADONGAMECORNERPRIZEROOM_PORYGON_COINS
	ifequal HAVE_LESS, CeladonPrizeRoom_notenoughcoins
	readvar VAR_PARTYCOUNT
	ifequal PARTY_LENGTH, CeladonPrizeRoom_notenoughroom
	getmonname STRING_BUFFER_3, PORYGON
	scall CeladonPrizeRoom_askbuy
	iffalse CeladonPrizeRoom_CancelPurchaseScript
	waitsfx
	playsound SFX_TRANSACTION
	writetext CeladonPrizeRoom_HereYouGoText
	waitbutton
	loadmonindex 2, PORYGON
	special GameCornerPrizeMonCheckDex
	givepoke PORYGON, 15
	takecoins CELADONGAMECORNERPRIZEROOM_PORYGON_COINS
	sjump .loop

.Larvitar:
	checkcoins CELADONGAMECORNERPRIZEROOM_LARVITAR_COINS
	ifequal HAVE_LESS, CeladonPrizeRoom_notenoughcoins
	readvar VAR_PARTYCOUNT
	ifequal PARTY_LENGTH, CeladonPrizeRoom_notenoughroom
	getmonname STRING_BUFFER_3, LARVITAR
	scall CeladonPrizeRoom_askbuy
	iffalse CeladonPrizeRoom_CancelPurchaseScript
	waitsfx
	playsound SFX_TRANSACTION
	writetext CeladonPrizeRoom_HereYouGoText
	waitbutton
	loadmonindex 3, LARVITAR
	special GameCornerPrizeMonCheckDex
	givepoke LARVITAR, 40
	takecoins CELADONGAMECORNERPRIZEROOM_LARVITAR_COINS
	sjump .loop

.MenuHeader:
	db MENU_BACKUP_TILES ; flags
	menu_coords 0, 2, 17, TEXTBOX_Y - 1
	dw .MenuData
	db 1 ; default option

.MenuData:
	db STATICMENU_CURSOR ; flags
	db 4 ; items
	db "PIKACHU    2222@"
	db "PORYGON    5555@"
	db "LARVITAR   8888@"
	db "CANCEL@"

CeladonGameCornerPrizeRoomGentlemanText:
	text "I wanted PORYGON,"
	line "but I was short by"
	cont "100 coins…"
	done

CeladonGameCornerPrizeRoomPharmacistText:
	text "Whew…"

	para "I've got to stay"
	line "calm and cool…"

	para "I can't lose my"
	line "cool, or I'll lose"
	cont "all my money…"
	done

CeladonPrizeRoom_PrizeVendorIntroText:
	text "Welcome!"

	para "We exchange your"
	line "coins for fabulous"
	cont "prizes!"
	done

CeladonPrizeRoom_AskWhichPrizeText:
	text "Which prize would"
	line "you like?"
	done

CeladonPrizeRoom_ConfirmPurchaseText:
	text "OK, so you wanted"
	line "a @"
	text_ram wStringBuffer3
	text "?"
	done

CeladonPrizeRoom_HereYouGoText:
	text "Here you go!"
	done

CeladonPrizeRoom_NotEnoughCoinsText:
	text "You don't have"
	line "enough coins."
	done

CeladonPrizeRoom_NotEnoughRoomText:
	text "You have no room"
	line "for it."
	done

CeladonPrizeRoom_ComeAgainText:
	text "Oh. Please come"
	line "back with coins!"
	done

CeladonPrizeRoom_NoCoinCaseText:
	text "Oh? You don't have"
	line "a COIN CASE."
	done

CeladonGameCornerPrizeRoom_MapEvents:
	db 0, 0 ; filler

	db 2 ; warp events
	warp_event  2,  5, CELADON_CITY, 7
	warp_event  3,  5, CELADON_CITY, 7

	db 0 ; coord events

	db 2 ; bg events
	bg_event  2,  1, BGEVENT_READ, CeladonGameCornerPrizeRoomTMVendor
	bg_event  4,  1, BGEVENT_READ, CeladonGameCornerPrizeRoomPokemonVendor

	db 2 ; object events
	object_event  0,  2, SPRITE_GENTLEMAN, SPRITEMOVEDATA_STANDING_DOWN, 0, 0, -1, -1, PAL_NPC_RED, OBJECTTYPE_SCRIPT, 0, CeladonGameCornerPrizeRoomGentlemanScript, -1
	object_event  4,  4, SPRITE_PHARMACIST, SPRITEMOVEDATA_WALK_UP_DOWN, 0, 1, -1, -1, PAL_NPC_GREEN, OBJECTTYPE_SCRIPT, 0, CeladonGameCornerPrizeRoomPharmacistScript, -1
