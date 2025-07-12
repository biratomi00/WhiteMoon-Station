/datum/station_trait/assistants_as_expeditioners
	name = "All assistants expeditioners now"
	report_message = "Мы решили записать абсолютно всех ассистентов в Экспедиционные Войска. Теперь у них есть доступ к ЕВА и к Гейту."
	trait_type = STATION_TRAIT_POSITIVE
	weight = 5
	cost = STATION_TRAIT_COST_LOW
	show_in_report = TRUE

/datum/station_trait/assistants_as_expeditioners/on_round_start()
	. = ..()

	var/datum/id_trim/job/assistant/assistant_trim = SSid_access.trim_singletons_by_path[/datum/id_trim/job/assistant]
	if(assistant_trim)
		assistant_trim.access |= list(
			ACCESS_GATEWAY,
			ACCESS_EVA,
			ACCESS_MAINT_TUNNELS,
			ACCESS_EXTERNAL_AIRLOCKS
		)
		assistant_trim.minimal_access |= list(
			ACCESS_GATEWAY,
			ACCESS_EVA,
			ACCESS_MAINT_TUNNELS,
			ACCESS_EXTERNAL_AIRLOCKS
		)
		assistant_trim.extra_access |= list(
			ACCESS_GATEWAY,
			ACCESS_EVA,
			ACCESS_MAINT_TUNNELS,
			ACCESS_EXTERNAL_AIRLOCKS
		)

	addtimer(CALLBACK(src, PROC_REF(send_expedition_announcement)), 10 MINUTES)

/datum/station_trait/assistants_as_expeditioners/proc/send_expedition_announcement()
	print_command_report(
		"ВНИМАНИЕ! Все ассистенты станции [station_name()] официально записаны в Экспедиционный Корпус Nanotrasen. \
		Вам выданы расширенные доступы к EVA и к Гейту. \
		Ваша новая миссия: поиск и исследование артефактов в космическом пространстве и через Гейт. \
		Используйте предоставленное оборудование ответственно и соблюдайте протоколы безопасности. \
		Удачи в ваших экспедициях!",
		"Экспедиционный Корпус Nanotrasen"
	)
	priority_announce(
		"ВНИМАНИЕ! Все ассистенты станции [station_name()] официально записаны в Экспедиционный Корпус Nanotrasen. \
		Вам выданы расширенные доступы к EVA и к Гейту. \
		Ваша новая миссия: поиск и исследование артефактов в космическом пространстве и через Гейт. \
		Используйте предоставленное оборудование ответственно и соблюдайте протоколы безопасности. \
		Удачи в ваших экспедициях!",
		"Экспедиционный Корпус Nanotrasen",
		'sound/announcer/announcement/announce_syndi.ogg'
	)
