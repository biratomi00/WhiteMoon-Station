/datum/heretic_knowledge/limited_amount/starting/base_blade
	name = "The Cutting Edge"
	desc = "Opens up the Path of Blades to you. \
		Allows you to transmute a knife with one bar of silver or titanium to create a Sundered Blade. \
		You can create up to four at a time."
	gain_text = "Our great ancestors forged swords and practiced sparring on the eve of great battles."

/datum/heretic_knowledge/blade_grasp
	name = "Grasp of the Blade"
	desc = "Your Mansus Grasp will cause a short stun when used on someone lying down or facing away from you."
	gain_text = "The story of the footsoldier has been told since antiquity. It is one of blood and valor, \
		and is championed by sword, steel and silver."

/datum/heretic_knowledge/blade_grasp/proc/on_mansus_grasp(mob/living/source, mob/living/target)
	SIGNAL_HANDLER

	if(!check_behind(source, target))
		return

	// We're officially behind them, apply effects
	target.AdjustParalyzed(1.5 SECONDS)
	target.apply_damage(10, BRUTE, wound_bonus = CANT_WOUND)
	target.balloon_alert(source, "backstab!")
	playsound(target, 'sound/items/weapons/guillotine.ogg', 100, TRUE)

/datum/heretic_knowledge/blade_dance
	name = "Dance of the Brand"
	desc = "Being attacked while wielding a Heretic Blade in either hand will deliver a riposte \
		towards your attacker. This effect can only trigger once every 20 seconds."
	gain_text = "The footsoldier was known to be a fearsome duelist. \
		Their general quickly appointed them as their personal Champion."

/datum/heretic_knowledge/blade_dance/proc/counter_attack(mob/living/carbon/human/source, mob/living/target, obj/item/melee/sickly_blade/weapon, attack_text)
	playsound(get_turf(source), 'sound/items/weapons/parry.ogg', 100, TRUE)
	source.balloon_alert(source, "riposte used")
	source.visible_message(
		span_warning("[source] leans into [attack_text] and delivers a sudden riposte back at [target]!"),
		span_warning("You lean into [attack_text] and deliver a sudden riposte back at [target]!"),
		span_hear("You hear a clink, followed by a stab."),
	)
	weapon.melee_attack_chain(source, target)

/datum/heretic_knowledge/mark/blade_mark
	name = "Mark of the Blade"
	desc = "Your Mansus Grasp now applies the Mark of the Blade. While marked, \
		the victim will be unable to leave their current room until it expires or is triggered. \
		Triggering the mark will summon a knife that will orbit you for a short time. \
		The knife will block any attack directed towards you, but is consumed on use."
	gain_text = "His general wished to end the war, but the Champion knew there could be no life without death. \
		He would slay the coward himself, and anyone who tried to run."

/datum/heretic_knowledge/spell/realignment
	name = "Realignment"
	desc = "Grants you Realignment a spell that wil realign your body rapidly for a short period. \
		During this process, you will rapidly regenerate stamina and quickly recover from stuns, however, you will be unable to attack. \
		This spell can be cast in rapid succession, but doing so will increase the cooldown."
	gain_text = "In the flurry of death, he found peace within himself. Despite insurmountable odds, he forged on."

/datum/heretic_knowledge/spell/wolves_among_sheep
	name = "Wolves Among Sheep"
	desc = "Alters the fabric of reality, conjuring a magical arena unpassable to outsiders, \
		all participants are trapped and immune to any form of crowd control or enviromental hazards; \
		trapped participants are granted a Blade and are unable to leave or jaunt until they score a critical hit. \
		Critical hits partially restore the Heretic's health."
	gain_text = "Shadows crawl across the room, casting every chair, table \
		and console into the looming shape of another traitorous hand. \
		I have made an enemy of all, and peace will never be known to me \
		again. I have shattered bonds and severed all alliances. In this truth, \
		I know now the fragility of comradery. My enemies will be all, divided."

/datum/heretic_knowledge/blade_upgrade/blade
	name = "Empowered Blades"
	desc = "Attacking someone with a Sundered Blade in both hands \
		will now deliver a blow with both at once, dealing two attacks in rapid succession. \
		The second blow will be slightly weaker. \
		You are able to infuse your mansus grasp directly into your blades, and your blades are more effective against structures."
	gain_text = "I found him cleaved in twain, halves locked in a duel without end; \
		a flurry of blades, neither hitting their mark, for the Champion was indomitable."

/datum/heretic_knowledge/spell/furious_steel
	name = "Furious Steel"
	desc = "Grants you Furious Steel, a targeted spell. Using it will summon three \
		orbiting blades around you. These blades will protect you from all attacks, \
		but are consumed on use. Additionally, you can click to fire the blades \
		at a target, dealing damage and causing bleeding."
	gain_text = "Without thinking, I took the knife of a fallen soldier and threw with all my might. My aim was true! \
		The Torn Champion smiled at their first taste of agony, and with a nod, their blades became my own."

/datum/heretic_knowledge/ultimate/blade_final/on_finished_recipe(mob/living/user, list/selected_atoms, turf/loc)
	. = ..()
	ADD_TRAIT(user, TRAIT_NEVER_WOUNDED, type)
	RegisterSignal(user, COMSIG_HERETIC_BLADE_ATTACK, PROC_REF(on_eldritch_blade))
	user.apply_status_effect(/datum/status_effect/protective_blades/recharging, null, 8, 30, 0.25 SECONDS, /obj/effect/floating_blade, 1 MINUTES)
	user.add_stun_absorption(
		source = name,
		message = span_warning("%EFFECT_OWNER throws off the stun!"),
		self_message = span_warning("You throw off the stun!"),
		examine_message = span_hypnophrase("%EFFECT_OWNER_THEYRE standing stalwartly."),
		// flashbangs are like 5-10 seoncds,
		// a banana peel is ~5 seconds, depending on botany
		// body throws and tackles are less than 5 seconds,
		// stun baton / stamcrit detracts no time,
		// and worst case: beepsky / tasers are 10 seconds.
		max_seconds_of_stuns_blocked = 45 SECONDS,
		delete_after_passing_max = FALSE,
		recharge_time = 2 MINUTES,
	)
	var/datum/action/cooldown/spell/pointed/projectile/furious_steel/steel_spell = locate() in user.actions
	steel_spell?.cooldown_time /= 2

	var/mob/living/carbon/human/heretic = user
	heretic.physiology.knockdown_mod = 0.75 // Otherwise knockdowns would probably overpower the stun absorption effect.

/datum/heretic_knowledge/ultimate/blade_final
	name = "Maelstrom of Silver"
	desc = "Ритуал вознесения Пути Клинка. \
        Принеси 3 трупа без головы, либо с выпотрошенным черепом на руну трансмутации для завершения ритуала. \
        По завершению вы будете окружены бесчисленным количеством клинков, что будут, восстанавливается и следовать за вами. \
        Клинки будут защищать вас от всех напастей, что вы встретите, однако, они крайне хрупкие. \
        Также ваше заклинание Furious Steel будет иметь меньшую перезарядку. \
        При этом, вы становитесь мастером боевых искусств, получая полный иммунитет к ранам и способность игнорировать небольшие оглушения. \
        Также ваши Sundered Blades более смертоносны и способны вас восстановить во время атаки за часть нанесённых повреждений."
	gain_text = "Разорванный Чемпион освобождён! И я стану клинком, вновь единым, и с величайшими амбициями, \
        Я НЕ ПРЕВЗОЙДЁН! НАКРОЕТ ЖЕ НАС ШТОРМ ИЗ СЕРЕБРА И СТАЛИ! УЗРИТЕ ЖЕ МОЁ ПРОБУЖДЕНИЕ!"
	announcement_text = "%SPOOKY% Повелитель Клинков, ученик Разорванного Чемпиона, %NAME% вознёсся! Их сталь является той самой, что рассечёт реальность в серебряном водовороте! %SPOOKY%"
	announcement_sound = 'sound/music/antag/heretic/ascend_blade.ogg'
