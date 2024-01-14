/// This is a holder for some weapons that fire together
/datum/weapon_group
	var/datum/overmap/ship/holder
	/// The name must be unique within the parent ship so we can use it as a list index
	var/name = ""
	/// The references to the weapons associated with this group
	var/list/weapon_list = list()

/datum/weapon_group/New(datum/overmap/ship/holder, name)
	. = ..()
	src.holder = holder
	if(!name)
		name = "Group [rand(0, 999)]"
	src.name = name
	holder.weapon_groups[name] = src

/datum/weapon_group/proc/add_weapon(datum/overmap_weapon/weap)
	weapon_list |= weap

/datum/weapon_group/proc/get_ui_data()
	. = list()
	.["name"] = name
	.["id"] = "\ref[src]"
	.["weapons"] = list()
	for(var/datum/overmap_weapon/W as() in weapon_list)
		.["weapons"] += list(list(name = W.name, id = "\ref[W]"))

// overmap_weapon does not have any children - it defines a template to be used for all
// other types that can be fired as a weapon. You can make them any type as long as
// they implement these variables and procs.
// In general trying to keep this to stuff that needs to be displayed and have no real
// implementation here to avoid the problems we had last time.
/datum/overmap_weapon
	// Weapons will be sorted into groups by name by default
	var/name
	// Ammo counters - use whatever format you want, bullets, bursts, percents, joules...
	var/ammo = 0
	var/max_ammo = 0
	// Testing - remove later
	var/firing_arc_center_rel_deg
	var/firing_arc_width_deg

// Must return true if the weapon fired one or more projectiles
/datum/overmap_weapon/proc/fire()
	return FALSE

// ai_weapon is a non-physical weapon that can be attached to a ship
/datum/ai_weapon
	var/name
	// Firing rate stuff
	var/time_between_projectiles = 0
	var/time_between_bursts = 0 // If this is a single-shot weapon, leave this at zero
	var/burst_size = 1 // TODO handle burst fire
	var/next_fire = 0
	// Resupply rate stuff. We'll just make it linear for now.
	var/max_time_between_resupplies = 0
	var/resupply_time_slope = 0.5 // 20 minute fight = 10 minutes between resupplies
	var/next_resupply = 0
	// Testing - remove later
	var/shell_type
	var/firing_arc_center_rel_deg = 0
	var/firing_arc_width_deg = 360 // Anything unspecified is omnidirectional

/datum/ai_weapon/proc/fire(datum/overmap/src_overmap, angle)
	var/proj_angle = angle
	if(!src_overmap)
		CRASH("Tried to fire [src] without a source overmap")
	if(!proj_angle)
		proj_angle = src_overmap.position.angle

	// Calculate the angle between the center of the firing arc and the requested angle, and compare it to the width of the firing arc
	// CC-BY-SA algorithm from StackOverflow https://stackoverflow.com/questions/12234574/calculating-if-an-angle-is-between-two-angles
	// Solution by Alnitak (https://stackoverflow.com/users/6782/alnitak) and hdante (https://stackoverflow.com/users/1797000/hdante)
	var/current_arc_center = src_overmap.position.angle + firing_arc_center_rel_deg
	var/adjusted_angle = arccos(cos(current_arc_center) * cos(proj_angle) + sin(current_arc_center) * sin(proj_angle))
	if(adjusted_angle > firing_arc_width_deg / 2)
		to_chat(world, "adjusted angle [adjusted_angle] was out of range")
		return FALSE

	if(next_fire > world.time)
		// Too soon
		return FALSE

	src_overmap.fire_projectile(proj_angle, shell_type)
	next_fire = world.time + time_between_bursts
	return TRUE
	//TODO: Check if theyre the gunner. Roles... I don't care for now!

/datum/overmap/proc/fire_projectile(proj_angle = src.position.angle, datum/overmap/projectile/projectile_type=/datum/overmap/projectile/shell, burst_size=1)
	if (!map)
		CRASH("Overmap object with no map cannot fire projectiles.")
	//We scromble the position so it originates from the centre of the ship.
	for(var/i = 1; i <= burst_size; i++)
		var/new_velocity_x = position.velocity.x + initial(projectile_type.speed) * cos(proj_angle)
		var/new_velocity_y = position.velocity.y + initial(projectile_type.speed) * sin(proj_angle)
		var/datum/overmap/projectile/O = new projectile_type(src.map, position.x + (collision_radius/2), position.y + (collision_radius/2), position.z, proj_angle, new_velocity_x, new_velocity_y)
		O.faction = faction
	//to_chat(world, "Fire missile.")
