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
	for(var/type in subtypesof(/datum/ai_weapon))
		weapon_list += new type()

/datum/weapon_group/proc/get_ui_data()
	. = list()
	.["name"] = name
	.["weapons"] = weapon_list
	.["id"] = "\ref[src]"

/datum/overmap_weapon
	var/name
	// Testing - remove later
	var/firing_arc_center
	var/firing_arc_width

/datum/overmap_weapon/proc/fire()

/datum/ai_weapon
	var/name
	// Testing - remove later
	var/shell_type
	var/firing_arc_center
	var/firing_arc_width

/datum/ai_weapon/proc/fire(datum/overmap/src_overmap, angle)
	var/proj_angle = angle
	if(!src_overmap)
		CRASH("Tried to fire [src] without a source overmap")
	if(!proj_angle)
		proj_angle = src_overmap.position.angle

	// Calculate the angle between the center of the firing arc and the requested angle, and compare it to the width of the firing arc
	// CC-BY-SA algorithm from StackOverflow https://stackoverflow.com/questions/12234574/calculating-if-an-angle-is-between-two-angles
	// Solution by Alnitak (https://stackoverflow.com/users/6782/alnitak) and hdante (https://stackoverflow.com/users/1797000/hdante)
	var/current_arc_center = src_overmap.position.angle + firing_arc_center
	var/adjusted_angle = arccos(cos(current_arc_center) * cos(proj_angle) + sin(current_arc_center) * sin(proj_angle))
	if(adjusted_angle > (firing_arc_width/100)*180)
		to_chat(world, "adjusted angle [adjusted_angle] was out of range")
		return

	src_overmap.fire_projectile(proj_angle, shell_type)
	//TODO: Check if theyre the gunner. Roles... I don't care for now!


/datum/ai_weapon/pdc
	name = "Axial Cannon"
	// Testing - remove later
	shell_type = /datum/overmap/projectile/shell
	firing_arc_center = 0 // Dead center
	firing_arc_width = 50 // In percentage - Front side only

/datum/ai_weapon/torpedo
	name = "Torpedo"
	shell_type = /datum/overmap/projectile/slug
	firing_arc_center = 180 // Back
	firing_arc_width = 50

/datum/overmap/proc/fire_projectile(proj_angle = src.position.angle, datum/overmap/projectile/projectile_type=/datum/overmap/projectile/shell, burst_size=1)
	if (!map)
		CRASH("Overmap object with no map cannot fire projectiles.")
	//TODO: magic number "10".
	//We scromble the position so it originates from the centre of the ship.
	for(var/i = 1; i <= burst_size; i++)
		var/new_velocity_x = position.velocity.x + initial(projectile_type.speed) * cos(proj_angle)
		var/new_velocity_y = position.velocity.y + initial(projectile_type.speed) * sin(proj_angle)
		var/datum/overmap/projectile/O = new projectile_type(src.map, position.x + (collision_radius/2), position.y + (collision_radius/2), position.z, proj_angle, new_velocity_x, new_velocity_y)
		O.faction = faction
	//to_chat(world, "Fire missile.")
