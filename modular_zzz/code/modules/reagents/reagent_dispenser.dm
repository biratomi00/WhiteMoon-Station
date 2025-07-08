/obj/structure/reagent_dispensers/beerkeg
	name = "Beer Keg"
	desc = "Кега с пивом. Кега выглядит совсем немного вздутой."

/obj/structure/reagent_dispensers/beerkeg/attack_animal(mob/living/simple_animal/user)
	if(prob(25) && isdog(user))
		explosion(src, light_impact_range = 3, flame_range = 5, flash_range = 10)
		playsound(src, 'modular_zzz/sounds/misc/kega.ogg', 100, 1)
		if(!QDELETED(src))
			qdel(src)
		return TRUE
	. = ..()

/obj/structure/reagent_dispensers/beerkeg/attack_hand(mob/living/carbon/human/user)
	. = ..()
	if(prob(25) && (ismammal(user) || iscanine(user)))
		explosion(src, light_impact_range = 3, flame_range = 5, flash_range = 10)
		playsound(src, 'modular_zzz/sounds/misc/kega.ogg', 100, 1)
		if(!QDELETED(src))
			qdel(src)
		return TRUE
