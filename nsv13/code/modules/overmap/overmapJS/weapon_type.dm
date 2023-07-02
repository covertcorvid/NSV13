/// This is a holder for some weapons that fire together
/datum/weapon_group
	var/datum/overmap/holder
	/// The name must be unique within the parent ship so we can use it as a list index
	var/name = ""
	/// The references to the weapons associated with this group
	var/list/weapon_list = list()

/datum/weapon_group/New(datum/overmap/holder, name)
	. = ..()
	src.holder = holder
	while(!name || (name in holder.weapon_groups))
		// Look, picking a random number that's already used could happen, okay?
		name = "Group [rand(0, 999)]"
	src.name = name
	holder.weapon_groups[name] = src
	// TODO actual weapons, this is just for testing
	for(var/i = 0; i < rand(1,4); i++)
		weapon_list += "weapon [i]"

/datum/weapon_group/proc/get_ui_data()
	. = list()
	.["name"] = name
	.["weapons"] = weapon_list
	.["id"] = "\ref[src]"
