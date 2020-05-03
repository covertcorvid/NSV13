#define FIRE_ZONE_AHEAD				"ahead"
#define FIRE_ZONE_ASTERN			"astern"
#define FIRE_ZONE_PORT				"port"
#define FIRE_ZONE_STARBOARD			"starboard"
#define FIRE_ZONE_OMNIDIRECTIONAL	"omni"

/datum/ship_weapon/New(dest, proj_type=null, burst_size=null, fire_delay=null, \
		select_alert=null, failure_alert=null, firing_sounds=null, \
		select_sound=null, gunner_controlled=null, req_linked=null, linked=null, \
		firing_zone=null, facing_degrees=null, firing_arc_width=null, ammo=null)
	. = ..()
	if(!isnull(proj_type))
		src.default_projectile_type = proj_type
	if(!isnull(burst_size))
		src.burst_size = burst_size
	if(!isnull(fire_delay))
		src.fire_delay = fire_delay
	if(!isnull(select_alert))
		src.select_alert = select_alert
	if(!isnull(failure_alert))
		src.failure_alert = failure_alert
	if(!isnull(firing_sounds))
		src.overmap_firing_sounds = firing_sounds
	if(!isnull(select_sound))
		src.overmap_select_sound = select_sound
	if(!isnull(gunner_controlled))
		src.gunner_controlled = gunner_controlled
	if(!isnull(req_linked))
		src.requires_linked = req_linked
	if(!isnull(linked))
		src.linked = linked
	if(!isnull(facing_degrees))
		src.facing_degrees = SIMPLIFY_DEGREES(facing_degrees)
	if(!isnull(firing_arc_width))
		src.firing_arc_width = firing_arc_width
	if(!isnull(ammo))
		src.ammo = ammo

	message_admins("Initialized weapon on [dest]")
	calculate_firing_arc()

/datum/ship_weapon/proc/calculate_firing_arc()
	message_admins("Setting firing arc for [name]")
	if(!isnull(firing_zone))
		switch(firing_zone)
			if(FIRE_ZONE_AHEAD)
				facing_degrees = 0
				firing_arc_width = 40
			if(FIRE_ZONE_ASTERN)
				facing_degrees = 180
				firing_arc_width = 40
			if(FIRE_ZONE_PORT)
				facing_degrees = 270
				firing_arc_width = 140
			if(FIRE_ZONE_STARBOARD)
				facing_degrees = 90
				firing_arc_width = 140
			if(FIRE_ZONE_OMNIDIRECTIONAL)
				facing_degrees = 0
				firing_arc_width = 360
	if(isnull(facing_degrees))
		message_admins("Error: weapon [src] has no weapon facing information. Defaulting to front.")
		facing_degrees = 0
	if(isnull(firing_arc_width))
		message_admins("Error: weapon [src] has no firing arc information. Defaulting to omnidirectional.")
		facing_degrees = 360

/datum/ship_weapon/proc/can_select(obj/structure/overmap/OM)
	if(!istype(OM)) // Need an overmap to check stuff on
		message_admins("OM isn't an overmap")
		return FALSE
	if(!gunner_controlled) // Can't be automatic
		message_admins("Weapon is automatic")
		return FALSE
	if(requires_linked)
		if(!linked || QDELETED(linked)) // The thing has to exist
			message_admins("No linked object")
			return FALSE
		if(OM.role == NORMAL_OVERMAP)
			if(linked.loc != src) // Fighter parts must be in the fighter
				message_admins("Part isn't in a fighter")
				return FALSE
			else
				return TRUE
		else
			var/obj/machinery/ship_weapon/SW = linked
			if(SW.linked && (SW.linked == OM)) // Player ships have physical weapons sitting on their maps
				return TRUE
			else
				message_admins("ship weapon isn't linked to this overmap")

	if(OM.role != NORMAL_OVERMAP)
		return TRUE
	if((!istype(src, /datum/ship_weapon/torpedo_launcher)) || (OM.torpedoes > 0)) // AI ships and fighters have to have enough torps left
		return TRUE
	message_admins("Hit end of proc")
	return FALSE

/datum/ship_weapon/proc/select(obj/structure/overmap/OM)
	if(OM.gunner)
		to_chat(OM.gunner, select_alert)
	OM.tactical?.relay_sound(overmap_select_sound)

/datum/ship_weapon/proc/check_firing_arc(atom/source, atom/target)
	if(!istype(source, /obj/structure/overmap))
		return FALSE
	var/obj/structure/overmap/source_overmap = source
	// Edge case where target is on top of us
	if((target.x == source.x) && (target.y == source.y))
		return TRUE

	// Maximum field of view is 360, if it's bigger than that just assume we see ALL
	if (firing_arc_width >= 360)
		return TRUE

	var/true_angle_to_target = Get_Angle(source, target) // Bearing to target with "north" as 0
	var/relative_angle_to_target = SIMPLIFY_DEGREES(true_angle_to_target - source_overmap.angle) // Bearing to target with ship facing as 0

	// Bearing to target from the left edge of the weapon's field of view
	// If negative, target is too far left, if positive check against firing arc width
	var/target_angle_from_arc_edge = SIMPLIFY_DEGREES(relative_angle_to_target - (facing_degrees - (firing_arc_width/2)))

	return ISINRANGE(target_angle_from_arc_edge, 0, firing_arc_width)

/datum/ship_weapon/proc/can_fire(obj/structure/overmap/source, atom/target)
	if(!check_firing_arc(source, target))
		message_admins("Not in firing arc")
		return FALSE
	message_admins("Ammo [ammo] vs burst size [burst_size]")
	if(ammo < burst_size)
		return FALSE
	if(requires_linked)
		if(!linked || QDELETED(linked)) // The thing has to exist
			message_admins("No linked object")
			return FALSE
		if(source.role == NORMAL_OVERMAP)
			if(linked.loc != src) // Fighter parts must be in the fighter
				message_admins("Part isn't in a fighter")
				return FALSE
		else
			var/obj/machinery/ship_weapon/SW = linked
			if(!(SW.linked))
				message_admins("SW has no linked overmap")
				return FALSE
			if(SW.linked != source)
				message_admins("[source] can't fire weapon linked to [SW.linked]")
				return FALSE
			if(!(SW.can_fire(shots=burst_size)))
				message_admins("It can't fire")
				return FALSE
	return TRUE

/datum/ship_weapon/proc/try_fire(obj/structure/overmap/source, atom/target)
	if(!can_fire(source, target))
		return FALSE

	for(var/i; i < burst_size; i++)
		fire_projectile(source, target)
		ammo -= 1

		if(world.time >= next_sound) //Prevents ear destruction from soundspam
			var/sound/chosen = pick(overmap_firing_sounds)
			source.relay_to_nearby(chosen)
			next_sound = world.time + 1 SECONDS

		//if(overlay)
		//      overlay.do_animation()

		sleep(1)

	if(requires_linked && istype(linked, /obj/machinery/ship_weapon))
		var/obj/machinery/ship_weapon/SW = linked
		SW.fire(target, shots=burst_size)

	return TRUE

/datum/ship_weapon/proc/fire_projectile(obj/structure/overmap/source, atom/target)
	if(lateral)
		source.fire_lateral_projectile(default_projectile_type, target)
	else
		source.fire_projectile(default_projectile_type, target)
