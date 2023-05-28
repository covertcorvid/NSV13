/**
	Anything that's considered a "ship".
	This will have functionality for subsystems, weapons, etc.
*/
/datum/overmap/ship
	icon = 'nsv13/icons/overmap/nanotrasen/light_cruiser.dmi'
	icon_state = "cruiser-100"
	name = "Space SHIP"
	armour_quadrants = list(
		//North East
		new /datum/armour_quadrant(400),
		//North West
		new /datum/armour_quadrant(400),
		//South West
		new /datum/armour_quadrant(400),
		//South East
		new /datum/armour_quadrant(400)
	)
	integrity = 400
	max_integrity = 400

/datum/overmap/ship/player
	name = "NSV Stupidity"
	faction = OVERMAP_FACTION_PLAYER
	interior_type = /datum/component/overmap_interior
	//collision_positions = list(new /matrix/vector(-8,46), new /matrix/vector(-17,33), new /matrix/vector(-25,2), new /matrix/vector(-14,-45), new /matrix/vector(9,-46), new /matrix/vector(22,4), new /matrix/vector(14,36))

/datum/overmap/ship/syndicate
	name = "SSV Dumbass"
	faction = OVERMAP_FACTION_SYNDICATE
	icon = 'nsv13/icons/overmap/syndicate/syn_light_cruiser.dmi'
	icon_state = "cruiser"
	mass = MASS_MEDIUM
	armour_quadrants = list(
		//North East
		new /datum/armour_quadrant(500),
		//North West
		new /datum/armour_quadrant(500),
		//South West
		new /datum/armour_quadrant(500),
		//South East
		new /datum/armour_quadrant(500)
	)
	//collision_positions = list(new /matrix/vector(-3,45), new /matrix/vector(-17,29), new /matrix/vector(-22,-12), new /matrix/vector(-11,-45), new /matrix/vector(7,-47), new /matrix/vector(22,-12), new /matrix/vector(9,30))

/datum/overmap/ship/syndicate/frigate
	name = "SSV Peon"
	faction = OVERMAP_FACTION_SYNDICATE
	icon = 'nsv13/icons/overmap/new/syndicate/frigate.dmi'
	icon_state = "mako"
	mass = MASS_SMALL

/datum/overmap/ship/syndicate/cruiser
	name = "SSV Dunning-Kreuger"
	faction = OVERMAP_FACTION_SYNDICATE
	icon = 'nsv13/icons/overmap/syndicate/syn_patrol_cruiser.dmi'
	icon_state = "patrol_cruiser-100"
	mass = MASS_LARGE
	integrity = 1000
	max_integrity = 1000
	armour_quadrants = list(
		//North East
		new /datum/armour_quadrant(1250),
		//North West
		new /datum/armour_quadrant(1250),
		//South West
		new /datum/armour_quadrant(1250),
		//South East
		new /datum/armour_quadrant(1250)
	)

/datum/overmap/ship/syndicate/destroyer
	name = "SSV Dunning-Kreuger"
	faction = OVERMAP_FACTION_SYNDICATE
	icon = 'nsv13/icons/overmap/syndicate/gunboat.dmi'
	icon_state = "gunboat-100"
	mass = MASS_MEDIUM
	integrity = 500
	max_integrity = 500
	armour_quadrants = list(
		//North East
		new /datum/armour_quadrant(500),
		//North West
		new /datum/armour_quadrant(500),
		//South West
		new /datum/armour_quadrant(500),
		//South East
		new /datum/armour_quadrant(500)
	)
