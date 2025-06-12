/datum/uplink_item/dangerous/nunchaku
	name = "Syndie Fitness Nunchuks"
	desc = "Heavyweight titanium nunchucks that can be used to knock out and harm your opponent quickly and easily.\
		In close combat, it allows you to block all melee attacks and throws, punishing the offender."
	item = /obj/item/melee/baton/nunchaku
	cost = 7
	purchasable_from = ~UPLINK_SPY //spy get their own tg version
	uplink_item_flags = SYNDIE_TRIPS_CONTRABAND

/datum/uplink_item/dangerous/thermal_pistols
	name = "Thermal Pistols with shoudler"
	desc = "A rather plain pair of shoulder holsters with a bit of insulated padding inside. \
	Meant to hold a twinned pair of thermal pistols, but can fit several kinds of energy handguns as well."
	item = /obj/item/storage/belt/holster/energy/thermal
	cost = 14
	purchasable_from = ~UPLINK_CLOWN_OPS
