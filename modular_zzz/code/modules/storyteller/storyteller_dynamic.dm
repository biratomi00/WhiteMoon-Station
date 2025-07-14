/datum/storyteller/dynamic
	name = "Dynamic (Player Dependent Dynamic)"
	desc = "Тип Динамика будет выбран в зависимости от количества игроков (ПРОЖАВШИХ READY) и их предпочитаемого уровня Хаоса. Предпочитаемый уровень хаоса можно выбрать в настройках (GAME OPTIONS > Your Chaos Level)."
	votable = TRUE

/proc/pick_dynamic_storyteller_type_by_chaos(list/players)
	var/total_chaos = 0
	for(var/mob/player as anything in players)
		if(!player || !player.client || !player.client.prefs)
			continue
		var/chaos = player.client.prefs.read_preference(/datum/preference/numeric/preferred_chaos_level)
		if(isnum(chaos))
			total_chaos += chaos

	var/storyteller_type
	if(total_chaos >= CONFIG_GET(number/chaos_for_a_hard_storyteller))
		storyteller_type = /datum/storyteller/high
	else if(total_chaos >= CONFIG_GET(number/chaos_for_a_medium_storyteller))
		storyteller_type = /datum/storyteller/medium
	else
		storyteller_type = /datum/storyteller/low

	return storyteller_type
