/**
	Anything that's considered a "ship".
	This will have functionality for subsystems, weapons, etc.
*/
/datum/overmap/ship
	icon = 'nsv13/icons/overmap/nanotrasen/light_cruiser.dmi'
	icon_state = "cruiser-100"
	name = "Space SHIP"

/datum/overmap/ship/player
	name = "NSV Stupidity"
	faction = OVERMAP_FACTION_PLAYER
	collision_positions = list(new /matrix/vector(-8,46), new /matrix/vector(-17,33), new /matrix/vector(-25,2), new /matrix/vector(-14,-45), new /matrix/vector(9,-46), new /matrix/vector(22,4), new /matrix/vector(14,36))
	interior_type = /datum/component/overmap_interior

/datum/overmap/ship/syndicate
	name = "SSV Dumbass"
	faction = OVERMAP_FACTION_SYNDICATE
	icon = 'nsv13/icons/overmap/syndicate/syn_light_cruiser.dmi'
	icon_state = "cruiser"
	mass = MASS_MEDIUM
	collision_positions = list(new /matrix/vector(-3,45), new /matrix/vector(-17,29), new /matrix/vector(-22,-12), new /matrix/vector(-11,-45), new /matrix/vector(7,-47), new /matrix/vector(22,-12), new /matrix/vector(9,30))
