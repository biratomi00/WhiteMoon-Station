/datum/controller/subsystem/vote/proc/check_combo()
	var/list/roundtypes = list()
	var/much_to_check = ROUNDTYPE_MAX_COMBO
	log_world("SSpersistence.saved_modes contents:")
	for (var/mode in SSpersistence.saved_modes)
		log_world("- [mode]: [SSpersistence.saved_modes[mode]]")

	for (var/mode in SSpersistence.saved_modes)
		if(!istext(mode))
			continue
		if(!much_to_check)
			break
		much_to_check--
		if(!(mode in roundtypes))
			roundtypes[mode] = 0
		roundtypes[mode]++
		if(roundtypes[mode] >= ROUNDTYPE_MAX_COMBO)
			return mode
	return FALSE
