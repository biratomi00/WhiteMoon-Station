/**
 * Данный антаг был вдоховлен игрою "Hatred" (2015).
 *
 * Антаг будет находиться в бета тесте неопределенное время в зависимости от того, смогу ли я "ловить моменты" появления антага в раунде и наблюдать за ним,
 * а также наличия конструктивного фидбека игроков.
 *
 * Краткое пояснение концепта антага и игромеханических решений:
 * 		Концепт: мажорный мидраунд антаг для медиум/хард динамика с целью моментального массового ПВП пиздореза. Почти как Lone Operative, но этот не должен
 * взрывать нюку и завершать раунд. Минимум манча и времени на разогрев. Только при существенном онлайне и с достаточным количеством живых офицеров СБ.
 * 		Хил от убийства других игроков: как и в оригинальной игре персонаж восстанавливает здоровье от кинематографичных убийств (glory kills) и это является
 * единственным способом востановить здоровье. Я полагаю и в сске оно будет выглядеть уместно и вполне сбалансированно. Игроку для восстановления
 * здоровья необходимо заставить живую цель не двигаться около 10 секунд и убить её выстрелом вплотную для восстановления здоровья. Тем самым мы снижаем
 * градус ахуевания антага и заставляем его делать передышики и играть аккуратнее, ведь он один, всегда уязвим и не может прятаться в космосе или вне станции,
 * как делает абсолютное большинство антагов.
 * 		Калаш с бесконечными патронами: в оригинальной игре это раундстарт каноничное оружие. По локации разбросана куча других оружий,
 * а также оружие щедро падает с бесконечных волн полицейских. Но в сске у нас ограниченное количество СБ, поэтому рано или поздно антаг пойдет манчить
 * себе оружие. Этот антаг создан для пиздореза, а не получасового манча оружейки, поэтому я хочу свести к минимуму любой существенный манч.
 * 		"Прикрученное намертво" снаряжение: всё минимально необходимое снаряжение намертво прикручено к персонажу. Оно хорошо сбалансированно
 * для ведения продолжительных пвп битв, но не является читами и накладывает массу ограничений, поэтому при возможности игрок скинул бы свое снаряжение и
 * взял бы что-то более мощное, убийственное или полезное, например МОДсьюты или хардсьюты ЕРТшников, но я ему не позволю, ибо как сказано в предыдущем
 * пункте: это антаг не для манча, а для моментального пиздореза.
 * 		Разгрузка с гранатами в обмен на сердца: это уже моя "отсебятина", такого в оригинальной игре нет. Очень спорная штука и она является первой
 * на очереди к нерфу, если антаг мне покажется излишне сильным. На этапе раннего бета тестирования будет отключена.
 *
 * Если будет востребованно, то я возможно сделаю:
 * 		- Антаг худ (квадратик над персонажем с иконкой роли)
 * 		- Спрайты для уникального шмота.
 * 		- Счетчик убийств и вывод его в итоги раунда (здесь мне нужна помощь, я не знаю, как считать сочные фраги).
 * 			- минимум убийств для получения гринтекста.
 * 			- порог убийств для самостоятельного вывода антага из раунда (если перебил пол станции).
 * 			- события после определенного кол-ва убийств.
 * 		- Разработка механа эффектного добивания ножом.
 * 		- Прибытие антага с шаттла карго.
 * 		- Больше QOL фич, если у меня или других игроков будут хорошие и выполнимые идеи.
 */

//////////////////////////////////////////////
//                                          //
//            	 ANTAG BASE		            //
//                                          //
//////////////////////////////////////////////

/datum/antagonist/hatred
	name = "\improper Mass Shooter"
	antagpanel_category = "Mass Shooter"
	// roundend_category = "mass shooter"
	pref_flag = ROLE_LONE_OPERATIVE
	antag_moodlet = /datum/mood_event/focused
	suicide_cry = "I REGRET NOTHING."
	show_to_ghosts = TRUE
	show_in_antagpanel = FALSE // only for ghosts
	antag_ticket_multiplier = 1
	var/list/allowed_z_levels = list()
	/**
	 * Level of available gear is determined by a number of alive security officers and blueshields.
	 * 0 = low guns: a pistol or double barrel shotgun. NOT IMPLEMENTED YET!
	 * 1 = default classic and serious guns: AK-12 or riot shotgun
	 * 2 = ROBUST gear: +15 armor or +cursed belt |||| +fast executions + +1 life on low gear
	 */
	var/gear_level = 1
	var/static/list/low_guns = list("Pistol", "Double-barreled shotgun") // NOT IMPLEMENTED YET!
	var/static/list/classic_guns = list("AK12","Riot Shotgun")
	// there won't be special level 2 guns, because I don't want antag to have cheat guns. Level 2 gear is always better stats/traits for level 1 gear.
	var/static/list/high_gear = list("Belt of Hatred", "More armor")
	var/chosen_gun = null
	var/chosen_high_gear = null

/datum/antagonist/hatred/greet()
	SEND_SOUND(owner.current, sound(pick('modular_zzz/code/modules/antagonists/hatred/hatred_begin_1.ogg', \
										'modular_zzz/code/modules/antagonists/hatred/hatred_begin_2.ogg', \
										'modular_zzz/code/modules/antagonists/hatred/hatred_begin_3.ogg')))
	var/greet_text
	greet_text += "Ты - [span_red(span_bold("Безымянный Убийца"))]. Твое прошлое совершенно неважно, и даже если оно было, оно было незавидным.<br>"
	greet_text += "Ты испытываешь непреодолимую ненависть, отвращение и презрение ко всем окружающим.<br>"
	greet_text += "У тебя лишь две цели: <u>убивать</u> и <u>умереть славной смертью</u>.<br>"
	greet_text += "Твое проклятое снаряжение неразлучно с тобою и подстегивает тебя продолжать соврешать геноцид беззащитных гражданских.<br>"
	greet_text += "Твоё [span_red("Оружие Ненависти")] и неутолимая жажда убивать вознаграждают тебя, ибо завершающий выстрел в упор в голову (рот) исцеляет твои раны. Обычная медицина бессильна.<br>"
	greet_text += "[span_red("Cумка для патронов")] сама пополняет пустые магазины/картриджи/клипсы. Никогда не выбрасывай их!<br>"
	if(chosen_high_gear == "Belt of Hatred")
		greet_text += "[span_red("Пояс с гранатами")] пожирает сердца твоих жертв и вознаграждает тебя новой взрывоопасной аммуницией.<br>"
	greet_text += "[span_red(span_bold("Убивай и будь убит!"))] Ибо никто сегодня не защищен от твоей Ненависти.<br>"
	to_chat(owner.current, greet_text)
	owner.announce_objectives()

/datum/antagonist/hatred/on_gain()
	var/mob/living/carbon/human/H = owner.current
	if(!istype(H))
		return
	make_authentic_body()
	evaluate_security()
	forge_objectives()
	H.Immobilize(INFINITY, TRUE) // we don't want the player to walk around in temorary debug room during equipment selection.
	// H.Paralyze(INFINITY, TRUE)
	H.equipOutfit(/datum/outfit/hatred)
	H.SetImmobilized(0, TRUE)
	// H.SetParalyzed(0, TRUE)
	appear_on_station()
	. = ..()
	// TRAIT_NICE_SHOT TRAIT_DOUBLE_TAP TRAIT_ANALGESIA
	ADD_TRAIT(H, TRAIT_SLEEPIMMUNE, "hatred") // I challenge you to a glorious fight!
	ADD_TRAIT(H, TRAIT_VIRUS_RESISTANCE, "hatred")
	ADD_TRAIT(H, TRAIT_NONATURALHEAL, "hatred") // for heal_damage()
	ADD_TRAIT(H, TRAIT_FEARLESS, "hatred")
	ADD_TRAIT(H, TRAIT_STRONG_GRABBER, "hatred") // This way player will have less problems with his targets run/crawl away during glory kills
	ADD_TRAIT(H, TRAIT_QUICKER_CARRY, "hatred")
	ADD_TRAIT(H, TRAIT_NIGHT_VISION, "hatred")
	ADD_TRAIT(H, TRAIT_DRINKS_BLOOD, "hatred") // why not
	ADD_TRAIT(H, TRAIT_EVIL, "hatred")
	H.add_movespeed_mod_immunities("hatred", /datum/movespeed_modifier/damage_slowdown)
	// H.revive(ADMIN_HEAL_ALL)
	allowed_z_levels += SSmapping.levels_by_trait(ZTRAIT_CENTCOM)
	allowed_z_levels += SSmapping.levels_by_trait(ZTRAIT_RESERVED)
	allowed_z_levels += SSmapping.levels_by_trait(ZTRAIT_STATION)
	RegisterSignal(H, COMSIG_LIVING_LIFE, PROC_REF(check_hatred_off_station)) // almost like anchor implant, but doesn't hurt
	RegisterSignals(H, COMSIG_LIVING_ADJUST_STANDARD_DAMAGE_TYPES, PROC_REF(on_try_healing)) // for AdjustXXXLoss()
	addtimer(CALLBACK(src, PROC_REF(alarm_station)), 10 SECONDS, TIMER_DELETE_ME) // Give a player a moment to understand what's going on.

/datum/antagonist/hatred/proc/evaluate_security()
	var/security_alive = length(SSjob.get_living_sec())
	for(var/datum/mind/blu as anything in get_crewmember_minds())
		if(!(blu.assigned_role in list("Blueshield")))
			continue
		if(isnull(blu.current) || blu.current.stat == DEAD)
			continue
		security_alive++
	// if(GLOB.security_level == SEC_LEVEL_GREEN) // разбавляем эксту внутривенно (GC)
	// 	security_alive++
	switch(security_alive)
		// if(-INFINITY to 4)
		// 	gear_level = 0
		if(-INFINITY to 5) 	// 3(GC)-5
			gear_level = 1
		if(6 to INFINITY) 	// 6+
			gear_level = 2

/datum/antagonist/hatred/proc/make_authentic_body()
	var/mob/living/carbon/human/H = owner.current
	H.real_name = "The Man without a name"
	H.set_species(/datum/species/human)
	H.set_gender(MALE, TRUE, forced = TRUE)
	H.physique = MALE
	H.dna.remove_all_mutations()
	H.skin_tone = "albino"
	H.set_hairstyle("Curtains", update = FALSE)
	H.set_haircolor(sanitize_hexcolor("#000000"), update = FALSE)
	H.set_facial_hairstyle("Shaved", update = FALSE)
	H.set_facial_haircolor(sanitize_hexcolor("#000000"), update = FALSE)
	H.set_blooper("growl2")
	H.blooper_speed = 8
	H.blooper_pitch = 0.6
	H.blooper_pitch_range = 0.3
	H.dna.update_ui_block(DNA_GENDER_BLOCK)
	H.dna.update_ui_block(DNA_SKIN_TONE_BLOCK)
	H.dna.update_ui_block(DNA_HAIRSTYLE_BLOCK)
	H.dna.update_ui_block(DNA_HAIR_COLOR_BLOCK)
	H.dna.update_ui_block(DNA_FACIAL_HAIRSTYLE_BLOCK)
	H.dna.update_ui_block(DNA_FACIAL_HAIR_COLOR_BLOCK)
	H.update_body(TRUE)
	H.update_hair()

/datum/antagonist/hatred/forge_objectives()
	var/datum/objective/O = new /datum/objective/genocide()
	O.owner = owner
	objectives += O
	O = new /datum/objective/martyr()
	O.owner = owner
	objectives += O

/datum/antagonist/hatred/proc/appear_on_station()
	var/list/possible_spawns = list()
	possible_spawns += get_safe_random_station_turf(typesof(/area/station/command/gateway))
	possible_spawns += get_safe_random_station_turf(typesof(/area/station/command/teleporter))
	// possible_spawns += get_safe_random_station_turf(typesof(/area/station/cargo)) // for debug at Runtime Station
	// for(var/turf/X in GLOB.generic_maintenance_landmarks) //Some xeno spawns are in some spots that will instantly kill human, like atmos
	// 	if(istype(X.loc, /area/maintenance))
	// 		possible_spawns += X
	// possible_spawns += GLOB.generic_maintenance_landmarks
	possible_spawns += find_maintenance_spawn(atmos_sensitive = TRUE)
	list_clear_nulls((possible_spawns))
	var/turf/chosen_spawn = length(possible_spawns) ? pick(possible_spawns) : find_safe_turf(extended_safety_checks = TRUE, dense_atoms = FALSE) // in case of some huge map problems
	owner.current.forceMove(chosen_spawn)
	do_sparks(4, TRUE, owner.current)

/datum/antagonist/hatred/proc/check_hatred_off_station()
	SIGNAL_HANDLER
	var/turf/my_location = get_turf(owner.current)
	if(!(my_location.z in allowed_z_levels))
		to_chat(owner.current, span_userdanger("Так просто они от меня не избавятся..."))
		appear_on_station()

/datum/antagonist/hatred/proc/on_try_healing(mob/current_mob, type, amount, forced)
	SIGNAL_HANDLER
	if(amount < 0 && !forced)
		return COMPONENT_IGNORE_CHANGE
	return NONE

/datum/antagonist/hatred/proc/alarm_station() // major antag is currently commencing genocide, so we must let everyone know.
	if(istype(src) && owner?.current)
		var/chosen_sound = pick('modular_zzz/code/modules/antagonists/hatred/hatred_spawned_1.ogg','modular_zzz/code/modules/antagonists/hatred/hatred_spawned_2.ogg')
		priority_announce("На ваш объект ворвался особо опасный вооруженный преступник с целью массового убийства гражданских лиц. \
							Нейтрализуйте угрозу любыми доступными средствами. \
							ЦК санкционирует всему персоналу станции против данной цели: использование летального вооружения, открытие огня без предупреждения и казнь на месте. \
							Особые приметы: мужчина в длинном черном кожаном пальто с длинными черными волосами и [chosen_gun].", \
							"ALERT: MASS SHOOTER!", chosen_sound, has_important_message = TRUE)

/datum/antagonist/hatred/on_removal()
	var/mob/living/L = owner.current
	UnregisterSignal(L, COMSIG_LIVING_LIFE)
	UnregisterSignal(L, COMSIG_LIVING_ADJUST_STANDARD_DAMAGE_TYPES)
	. = ..()
	if(istype(L))
		ADD_TRAIT(L, TRAIT_PREVENT_IMPLANT_AUTO_EXPLOSION, "hatred") // no boom on admin remove
		to_chat(L, span_userdanger("As Hatred leaves your mind, it consumes you completely..."))
		L.dust(force = TRUE) // from ghosts we come, to ghosts we leave.

/datum/objective/genocide
	name = "Genocide of civilians"
	explanation_text = "Убей столько народу, сколько успеешь за свою короткую оставшуюся жизнь. Не щади никого. Кровь слабых питает тебя."
	martyr_compatible = TRUE
	completed = TRUE // i have no idea how to count your personal kills.

/obj/item/gun/handle_suicide(mob/living/carbon/human/user, mob/living/carbon/human/target, params, bypass_timer, time_to_kill = 12 SECONDS)
	if(!user.mind.has_antag_datum(/datum/antagonist/hatred))
		return ..()
	var/is_glory = TRUE
	if(target?.stat == DEAD || !target.client) // already dead bodies or npcs don't count
		is_glory = FALSE
	. = ..(user, target, params, bypass_timer, time_to_kill = 8 SECONDS)
	if(!. || user == target || !is_glory)
		return
	addtimer(CALLBACK(src, PROC_REF(check_glory_kill), user, target), 1 SECONDS, TIMER_DELETE_ME) // wait for boolet to do its job

/obj/item/gun/proc/check_glory_kill(mob/living/carbon/human/user, mob/living/carbon/human/target)
	if(QDELETED(target) || target?.stat == DEAD)
		user.fully_heal() // the only way of healing
		// user.do_adrenaline(150, TRUE, 0, 0, TRUE, list(/datum/reagent/medicine/inaprovaline = 10, /datum/reagent/medicine/synaptizine = 15, /datum/reagent/medicine/regen_jelly = 20, /datum/reagent/medicine/stimulants = 20), "<span class='boldnotice'>You feel a sudden surge of energy!</span>")
		user.visible_message("As blood splashes onto [src], it starts glowing menacingly and its wielder seemingly regaining their strength and vitality.")
		to_chat(user, span_notice("The blood of the weak gives you an inhuman relief and strength to continue the massacre."))
		var/obj/item/storage/belt/military/assault/hatred/B = user.get_item_by_slot(ITEM_SLOT_BELT)
		if(istype(B))
			to_chat(user, span_notice("[B.name] hungrily growls in anticipation of the coming sacrifice."))
			B.glory_points++

//////////////////////////////////////////////
//                                          //
//                	 GEAR		            //
//                                          //
//////////////////////////////////////////////

/// THE GUN OF HATRED ///

/obj/item/gun/ballistic/automatic/ar/ak12/hatred
	name = "\improper AK-12 rifle of Hatred"
	desc = "The scratches on this rifle say: \"The Genocide Machine\"."
	resistance_flags = FIRE_PROOF | ACID_PROOF
	burst_fire_selection = FALSE
	actions_types = list()
	burst_size = 1
	burst_delay = 2
	var/mob/living/carbon/human/original_wielder = null

/obj/item/gun/ballistic/automatic/ar/ak12/hatred/Initialize(mapload)
	. = ..()
	AddComponent(/datum/component/automatic_fire, 0.2 SECONDS)

/obj/item/gun/ballistic/automatic/ar/ak12/hatred/Destroy()
	if(!isnull(original_wielder))
		UnregisterSignal(original_wielder, COMSIG_LIVING_DEATH)
	. = ..()

/obj/item/gun/ballistic/automatic/ar/ak12/hatred/examine(mob/user)
	. = ..()
	if(HAS_TRAIT(src, TRAIT_NODROP))
		. += span_danger("You cannot make your fingers drop this weapon of Doom.")

/obj/item/gun/ballistic/automatic/ar/ak12/hatred/equipped(mob/living/user, slot)
	. = ..()
	if(isnull(original_wielder))
		original_wielder = user
		RegisterSignal(original_wielder, COMSIG_LIVING_DEATH, PROC_REF(on_wielder_death))
	if(original_wielder == user)
		ADD_TRAIT(src, TRAIT_NODROP, "hatred")

/obj/item/gun/ballistic/automatic/ar/ak12/hatred/proc/on_wielder_death()
	SIGNAL_HANDLER
	if(!QDELETED(src))
		var/obj/item/I = new /obj/item/gun/ballistic/automatic/ar/ak12(get_turf(src))
		I.name = "\improper AK-12 rifle of Faded Hatred"
		I.desc = "It looks less menacing than before. The blood stained scratches on this rifle say: \"The Genocide Machine\"."
		qdel(src)

/obj/item/gun/ballistic/automatic/ar/ak12/hatred/dropped(mob/user, silent)
	. = ..()
	if(!QDELETED(src))
		if(user == original_wielder) // lost arm
			REMOVE_TRAIT(src, TRAIT_NODROP, "hatred")

/// THE SHOTGUN OF HATRED ///

/obj/item/gun/ballistic/shotgun/riot/hatred
	name = "\improper Riot Shotgun of Hatred"
	desc = "The scratches on this shotgun say: \"The Bringer of Doom\"."
	accepted_magazine_type = /obj/item/ammo_box/magazine/internal/shot/extended // has lethal ammo from the start
	resistance_flags = FIRE_PROOF | ACID_PROOF
	box_reload_penalty = FALSE
	var/mob/living/carbon/human/original_wielder = null

/obj/item/gun/ballistic/shotgun/riot/hatred/Destroy()
	if(!isnull(original_wielder))
		UnregisterSignal(original_wielder, COMSIG_LIVING_DEATH)
	. = ..()

/obj/item/gun/ballistic/shotgun/riot/hatred/give_manufacturer_examine()
	return // no more "Nanotrasen Armories"

/obj/item/gun/ballistic/shotgun/riot/hatred/examine(mob/user)
	. = ..()
	. += span_notice("[span_bold("Ctrl-Shift-Click")] to quickly empty [src].")
	if(HAS_TRAIT(src, TRAIT_NODROP))
		. += span_danger("You cannot make your fingers drop this weapon of Doom.")

/obj/item/gun/ballistic/shotgun/riot/hatred/click_ctrl_shift(mob/user)
	// default rack_delay = 5
	rack()
	stoplag(4)
	while(chambered)
		rack()
		stoplag(4)

/obj/item/gun/ballistic/shotgun/riot/hatred/equipped(mob/living/user, slot)
	. = ..()
	if(isnull(original_wielder))
		original_wielder = user
		RegisterSignal(original_wielder, COMSIG_LIVING_DEATH, PROC_REF(on_wielder_death))
	if(original_wielder == user)
		ADD_TRAIT(src, TRAIT_NODROP, "hatred")

/obj/item/gun/ballistic/shotgun/riot/hatred/proc/on_wielder_death()
	SIGNAL_HANDLER
	if(!QDELETED(src))
		var/obj/item/I = new /obj/item/gun/ballistic/shotgun/riot(get_turf(src))
		I.name = "\improper Riot Shotgun of Faded Hatred"
		I.desc = "It looks less menacing than before. The blood stained scratches on this shotgun say: \"The Bringer of Doom\"."
		qdel(src)

/obj/item/gun/ballistic/shotgun/riot/hatred/dropped(mob/user, silent)
	. = ..()
	if(!QDELETED(src))
		if(user == original_wielder) // lost arm
			REMOVE_TRAIT(src, TRAIT_NODROP, "hatred")

/// THE POUCH OF HATRED ///

/obj/item/storage/pouch/ammo/hatred
	name = "\improper Ammo pouch of Hatred"
	desc = "The cursed pouch with infinite bullets encourage you to relentlessly continue your atrocities against humanity. What a miracle and delight for your Genocide Machines."
	unique_reskin = null
	// uses_advanced_reskins = FALSE

/obj/item/storage/pouch/ammo/hatred/Initialize(mapload)
	. = ..()
	atom_storage.max_specific_storage = WEIGHT_CLASS_NORMAL
	atom_storage.numerical_stacking = FALSE
	atom_storage.attack_hand_interact = TRUE

/obj/item/storage/pouch/ammo/hatred/post_reskin(mob/our_mob)
	return // its reskin changes properties of its inner contrainer. no comments.

/obj/item/storage/pouch/ammo/hatred/examine(mob/user)
	. = ..()
	. += "If you place an empty magazine/clip into this phenomenal pouch next time you check it will be filled with bullets."
	. += span_notice("Click [span_bold("RMB")] to open.")
	. += span_notice("Once you lose this item it will turn into dust.")

/obj/item/storage/pouch/ammo/hatred/Entered(atom/movable/AM, atom/oldLoc)
	. = ..()
	var/M = AM.type
	qdel(AM)
	new M(src)
	atom_storage.refresh_views()
	update_appearance()

/obj/item/storage/pouch/ammo/hatred/equipped(mob/user, slot, initial)
	. = ..()
	ADD_TRAIT(src, TRAIT_NODROP, "hatred")

/obj/item/storage/pouch/ammo/hatred/dropped(mob/user, silent)
	. = ..()
	if(!QDELETED(src))
		visible_message("[src] рассыпается в прах на ваших глазах...")
		qdel(src)

/// THE BELT OF HATRED ///

/obj/item/storage/belt/military/assault/hatred
	name = "\improper Belt of Hatred"
	desc = "The cursed belt eagerly devours hearts of your victims and supplies you with new deadly explosives."
	resistance_flags = FIRE_PROOF | ACID_PROOF
	var/glory_points = 0

/obj/item/storage/belt/military/assault/hatred/Initialize(mapload)
	. = ..()
	atom_storage.max_slots = 3

/obj/item/storage/belt/military/assault/hatred/examine(mob/user)
	. = ..()
	. += "If you place a heart into this phenomenal belt next time you check there will be no heart but a deadly explosive."
	. += span_notice("[src] is ready to accept [span_bold("[glory_points]")] hearts. Get more Glory Kills to make it accept more.")
	. += span_notice("Once you lose this item it will turn into dust.")

/obj/item/storage/belt/military/assault/hatred/Entered(atom/movable/AM, atom/oldLoc)
	. = ..()
	if(istype(AM, /obj/item/organ/heart) && glory_points)
		glory_points--
		qdel(AM)
		if(prob(50))
			new /obj/item/grenade/syndieminibomb/concussion(src)
		else
			new /obj/item/grenade/frag(src)
		atom_storage.refresh_views()
		update_appearance()

/obj/item/storage/belt/military/assault/hatred/equipped(mob/user, slot, initial)
	. = ..()
	ADD_TRAIT(src, TRAIT_NODROP, "hatred")

/obj/item/storage/belt/military/assault/hatred/dropped(mob/user, silent)
	. = ..()
	if(!QDELETED(src))
		visible_message("[src] рассыпается в прах на ваших глазах...")
		qdel(src)

/// THE OVERCOAT OF HATRED ///

/obj/item/clothing/suit/jacket/leather_trenchcoat/hatred
	name = "leather overcoat of Hatred"
	desc = "The shabby leather overcoat with decent armor paddings. Once it has been splashed with blood you can't take it off anymore."
	armor_type = /datum/armor/hatred
	// clueless armor stats. A bit worse than red ert hardsuit and other types of hardsuits. decent versatile armor.
	// armor = list(MELEE = 50, BULLET = 50, LASER = 50, ENERGY = 50, BOMB = 50, BIO = 30, RAD = 10, FIRE = 75, ACID = 75, WOUND = 50)

// clueless armor stats. A bit worse than red ert hardsuit and other types of hardsuits. decent versatile armor.
/datum/armor/hatred
	melee = 50
	bullet = 50
	laser = 50
	energy = 50
	bomb = 50
	bio = 30
	fire = 75
	acid = 75
	wound = WOUND_ARMOR_STANDARD

// level 2 gear upgrade. +15
/datum/armor/hatred_more
	melee = 65
	bullet = 65
	laser = 65
	energy = 65
	bomb = 65
	bio = 45
	fire = 90
	acid = 90
	wound = WOUND_ARMOR_HIGH

/obj/item/clothing/suit/jacket/leather_trenchcoat/hatred/equipped(mob/user, slot)
	. = ..()
	if(slot == ITEM_SLOT_OCLOTHING)
		ADD_TRAIT(src, TRAIT_NODROP, "hatred")

/obj/item/clothing/suit/jacket/leather_trenchcoat/hatred/dropped(mob/user)
	. = ..()
	if(!QDELETED(src))
		REMOVE_TRAIT(src, TRAIT_NODROP, "hatred")

/obj/item/clothing/head/invisihat/hatred
	name = "Veil of Hatred"
	desc = "Once you felt <b><i>that</i></b> urge to commit relentless genocide of civilians, you clearly understood you were cursed... blessed... and... protected by invisible spirit of Hatred."
	armor_type = /datum/armor/hatred

/obj/item/clothing/head/invisihat/hatred/equipped(mob/user, slot)
	. = ..()
	ADD_TRAIT(src, TRAIT_NODROP, "hatred")

/obj/item/clothing/head/invisihat/hatred/dropped(mob/user)
	. = ..()
	if(!QDELETED(src))
		visible_message("[src] рассыпается в прах на ваших глазах...")
		qdel(src)

/// OUTFIT ///
/// defult gear. will be changed during pre_equip().
/datum/outfit/hatred
	name = "Hatred"
	head = /obj/item/clothing/head/invisihat/hatred // /obj/item/clothing/glasses/hud/ar/aviator/health // black gas mask // black turtleneck /obj/item/clothing/glasses/hud/health/sunglasses
	glasses = /obj/item/clothing/glasses/hud/health/sunglasses // to help player identify when a target is in crit so player can safely execute him
	uniform = /obj/item/clothing/under/syndicate/tacticool/black
	suit = /obj/item/clothing/suit/jacket/leather_trenchcoat/hatred
	gloves = /obj/item/clothing/gloves/tackler/combat/insulated
	shoes = /obj/item/clothing/shoes/jackboots/knee
	id = /obj/item/card/id/away/old
	l_pocket = /obj/item/storage/pouch/ammo/hatred
	r_pocket = /obj/item/flashlight/seclite
	belt = /obj/item/storage/belt/military/assault
	// back = /obj/item/storage/backpack/duffelbag/syndie/nri/captain
	back = /obj/item/storage/backpack/satchel/fireproof
	backpack_contents = list(/obj/item/storage/box/survival/engineer = 1,
		/obj/item/knife/combat = 1,
		/obj/item/sensor_device = 1,
		/obj/item/crowbar = 1
		)
	// r_hand = /obj/item/gun/ballistic/automatic/ar/ak12/hatred
	// implants = list(/obj/item/implant/explosive, /obj/item/implant/anchor) // post_equip() doesn't work for implants since implanting occurs afrer post_equip()

/datum/outfit/hatred/pre_equip(mob/living/carbon/human/H, visualsOnly, client/preference_source)
	var/datum/antagonist/hatred/Ha = H.mind?.has_antag_datum(/datum/antagonist/hatred)
	if(!Ha)
		return
	// Ha.gear_level = tgui_input_list(H, "ЭТО ОКОШКО ДЛЯ ОБМАНА ПОДСЧЕТА ОФИЦЕРОВ В РАУНДЕ И НУЖНО ТОЛЬКО ДЛЯ ДЕБАГА, В ИГРЕ ЕГО НЕ БУДЕТ", "gear level?", list(1, 2), 1)
	var/available_sets = Ha.classic_guns
	SEND_SOUND(H, 'sound/announcer/notice/notice2.ogg')
	Ha.chosen_gun = tgui_input_list(H, "Выбери стартовое оружие и сделай это БЫСТРО!", "Выбери оружие геноцида", available_sets, available_sets[1], 10 SECONDS)
	switch(Ha.chosen_gun)
		if(null)
			Ha.chosen_gun = "AK12"
			r_hand = /obj/item/gun/ballistic/automatic/ar/ak12/hatred
		if("AK12")
			r_hand = /obj/item/gun/ballistic/automatic/ar/ak12/hatred
		if("Riot Shotgun")
			r_hand = /obj/item/gun/ballistic/shotgun/riot/hatred
	if(Ha.gear_level == 2)
		Ha.chosen_high_gear = tgui_input_list(H, "Выбери дополнительную экипировку и сделай это БЫСТРО!", "Выбери оружие геноцида", Ha.high_gear, Ha.high_gear[1], 10 SECONDS)
		switch(Ha.chosen_high_gear)
			if(null)
				Ha.chosen_high_gear = "Belt of Hatred"
				belt = /obj/item/storage/belt/military/assault/hatred
			if("Belt of Hatred")
				belt = /obj/item/storage/belt/military/assault/hatred

/datum/outfit/hatred/post_equip(mob/living/carbon/human/H, visualsOnly, client/preference_source)
	var/obj/item/implant/explosive/E = new
	E.implant(H)
	var/obj/item/clothing/under/syndicate/tacticool/black/I = H.get_item_by_slot(ITEM_SLOT_ICLOTHING)
	I.has_sensor = NO_SENSORS
	I.resistance_flags = FIRE_PROOF | ACID_PROOF
	I.unique_reskin = null
	ADD_TRAIT(I, TRAIT_NODROP, "hatred")

	var/obj/item/card/id/advanced/A = H.get_item_by_slot(ITEM_SLOT_ID)
	A.name = "Mangled ID Card"
	A.desc = "Deep cuts and scratches made its inscriptions and pics unreadable."
	A.access = list(/*REGION_ACCESS_GENERAL, */ACCESS_MAINT_TUNNELS)

	var/obj/item/storage/belt/B = H.get_item_by_slot(ITEM_SLOT_BELT)
	new /obj/item/grenade/syndieminibomb/concussion(B)
	new /obj/item/grenade/frag(B)
	new /obj/item/grenade/frag(B)

	var/obj/item/storage/pouch/ammo/hatred/P = H.get_item_by_slot(ITEM_SLOT_LPOCKET)
	var/datum/antagonist/hatred/Ha = H.mind?.has_antag_datum(/datum/antagonist/hatred)
	if(!Ha)
		return
	switch(Ha.chosen_gun)
		if("AK12")
			P.atom_storage.set_holdable(list(/obj/item/ammo_box/magazine/ak12), list(), list(/obj/item/ammo_box/magazine/ak12))
			new /obj/item/ammo_box/magazine/ak12(P)
			new /obj/item/ammo_box/magazine/ak12(P)
		if("Riot Shotgun")
			P.atom_storage.set_holdable(list(/obj/item/ammo_box/advanced/s12gauge), list(), list(/obj/item/ammo_box/advanced/s12gauge))
			P.atom_storage.max_slots = 4
			new /obj/item/ammo_box/advanced/s12gauge/buckshot(P)
			new /obj/item/ammo_box/advanced/s12gauge(P)
			new /obj/item/ammo_box/advanced/s12gauge/incendiary(P)
			new /obj/item/ammo_box/advanced/s12gauge/flechette(P)

	switch(Ha.chosen_high_gear)
		if("More armor")
			// initial = 	list(MELEE = 50, BULLET = 50, LASER = 50, ENERGY = 50, BOMB = 50, BIO = 30, RAD = 10, FIRE = 75, ACID = 75, WOUND = 50)
			// 				list(MELEE = 65, BULLET = 65, LASER = 65, ENERGY = 65, BOMB = 65, BIO = 45, RAD = 25, FIRE = 90, ACID = 90, WOUND = 65)
			var/obj/item/clothing/C = H.get_item_by_slot(ITEM_SLOT_OCLOTHING)
			C.set_armor(/datum/armor/hatred_more)
			C = H.get_item_by_slot(ITEM_SLOT_HEAD)
			C.set_armor(/datum/armor/hatred_more)

//////////////////////////////////////////////
//                                          //
//        	 	DYNAMIC THINGS		        //
//                                          //
//////////////////////////////////////////////

/datum/dynamic_ruleset/midround/from_ghosts/hatred
	name = "Mass Shooter"
	config_tag = "Mass Shooter"
	candidate_role = "The Man of Genocide"
	// preview_antag_datum = /datum/antagonist/nukeop
	midround_type = HEAVY_MIDROUND
	pref_flag = ROLE_LONE_OPERATIVE
	ruleset_flags = RULESET_INVADER
	weight = list(
		DYNAMIC_TIER_LOW = 0,
		DYNAMIC_TIER_LOWMEDIUM = 0,
		DYNAMIC_TIER_MEDIUMHIGH = 9,
		DYNAMIC_TIER_HIGH = 9, // будет 7 или 8, так как этот антаг имеет высокие требования к количеству живых офицеров и в нагруженные динамики это требование будет невыполено. на время бета теста выставлено 9.
	)
	min_pop = 30
	max_antag_cap = 1
	repeatable = FALSE // one man is enough to shake this station.
	signup_atom_appearance = /obj/item/gun/ballistic/automatic/ar/ak12
	var/saved_mind = null
	var/mob/living/carbon/human/hatred_body = null

/datum/dynamic_ruleset/midround/from_ghosts/hatred/can_be_selected()
	. = ..()
	if(!.)
		return
	. = FALSE
	if(SSsecurity_level.get_current_level_as_number() == SEC_LEVEL_GREEN) // разбавляем эксту внутривенно
		if(length(SSjob.get_living_sec()) < 3)
			return
	else if(length(SSjob.get_living_sec()) < 4) // я желаю достойного сопротивления.
		return
	return TRUE

/datum/dynamic_ruleset/midround/from_ghosts/hatred/create_ruleset_body()
	return // this shit forces player main character appearance

/datum/dynamic_ruleset/midround/from_ghosts/hatred/assign_role(datum/mind/candidate)
	// var/turf/entry_spawn_loc
	// /area/awaymission/errorroom
	var/mob/living/carbon/human/body = new (GET_ERROR_ROOM) // what a fine empty room. why don't we borrow it for a couple of seconds during preparation.
	candidate.transfer_to(body, force_key_move = TRUE)
	body.dna.remove_all_mutations()
	body.dna.update_dna_identity()
	candidate.add_antag_datum(/datum/antagonist/hatred)
	// message_admins("[ADMIN_LOOKUPFLW(body)] has been made into a Mass Shooter by the midround ruleset.")
	// log_game("DYNAMIC: [key_name(body)] was spawned as a Mass Shooter by the midround ruleset.")

//////////////////////////////////////////////
//                                          //
//        ROUND EVENT CONTROL THINGS		//
//                                          //
//////////////////////////////////////////////

/datum/round_event_control/hatred
	name = "Spawn Mass Shooter"
	typepath = /datum/round_event/ghost_role/hatred
	track = EVENT_TRACK_GHOSTSET
	tags = list(TAG_COMBAT, TAG_MEDIUM) // more strict additional checks will be done during can_spawn_event().
	// этот антаг имеет жесткие требования живых игроков и живых офицеров в раунде, а еще бета тест. поэтому х2 к шансу попытки запустить антага.
	// когда все устаканится, то можно опустить до 15, но крайне желательно не ставить меньше 10, так как этот антаг имеет высокие требования к количеству живых офицеров и в нагруженные динамики это требование будет невыполено.
	weight = 20
	max_occurrences = 1
	min_players = 20 // для малфа нужно 20. и для демона резни. пусть будет так. меньше не надо - некого убивать.
	category = EVENT_CATEGORY_ENTITIES // bloodshed. genocide. quite simple desires.
	description = "The Man without a name is about to commit ruthless genocide of crewmembers."

/datum/round_event/ghost_role/hatred
	minimum_required = 1
	role_name = "Mass Shooter"
	announce_chance = 0
	fakeable = FALSE

/datum/round_event_control/hatred/can_spawn_event(players_amt, allow_magic)
	. = ..()
	if(!.)
		return
	. = FALSE
	if(!(SSgamemode.storyteller.storyteller_type in list(STORYTELLER_TYPE_INTENSE, STORYTELLER_TYPE_ALWAYS_AVAILABLE))) // only for medium/high dynamics
		return
	if(!SSdynamic.antag_events_enabled)
		return
	if(EMERGENCY_PAST_POINT_OF_NO_RETURN)
		return
	if(SSsecurity_level.get_current_level_as_number() == SEC_LEVEL_GREEN) // разбавляем эксту внутривенно
		if(length(SSjob.get_living_sec()) < 3)
			return
	else if(length(SSjob.get_living_sec()) < 4) // я желаю достойного сопротивления.
		return
	return TRUE

/datum/round_event/ghost_role/hatred/spawn_role()
	var/mob/chosen_one = SSpolling.poll_ghost_candidates(check_jobban = ROLE_LONE_OPERATIVE, role = ROLE_LONE_OPERATIVE, alert_pic = /obj/item/gun/ballistic/automatic/ar/ak12, role_name_text = "The Man of Genocide", amount_to_pick = 1)
	if(isnull(chosen_one))
		return NOT_ENOUGH_PLAYERS
	var/turf/entry_spawn_loc = GET_ERROR_ROOM // what a fine empty room. why don't we borrow it for a couple of seconds during preparation.
	if(isnull(entry_spawn_loc) || isnull(find_safe_turf(extended_safety_checks = TRUE, dense_atoms = FALSE))) // we'll send him on station right away so we think ahead.
		return MAP_ERROR
	var/mob/living/carbon/human/body = new (entry_spawn_loc)
	// body.PossessByPlayer(chosen_one.key)
	var/datum/mind/Mind = new /datum/mind(chosen_one.key)
	Mind.active = TRUE
	Mind.transfer_to(body)
	Mind.add_antag_datum(/datum/antagonist/hatred)
	// playsound(dragon, 'sound/effects/magic/ethereal_exit.ogg', 50, TRUE, -1)
	message_admins("[ADMIN_LOOKUPFLW(body)] has been made into a Mass Shooter by an event.")
	body.log_message("was spawned as a Mass Shooter by an event.", LOG_GAME)
	spawned_mobs += body
	return SUCCESSFUL_SPAWN
