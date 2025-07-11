/mob/get_status_tab_items()
	.=..()
	if(SSticker.current_state < GAME_STATE_PLAYING)
		return

	if(client?.holder)
		. += "Storyteller: [SSgamemode.storyteller.name]"
	else
		. += "Storyteller: [SSgamemode.storyteller.name]"
