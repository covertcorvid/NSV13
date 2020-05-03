/obj/structure/overmap/proc/add_weapon(datum/ship_weapon/W)
	message_admins("adding [W:type] to [src]")
	if(!istype(W, /datum/ship_weapon))
		message_admins("wrong type")
		return
	if(!weapons)
		message_admins("initializing weapons list")
		weapons = list(W.name=list(W))
		weapon_types += W.name
	else if(!(weapons[W.name]))
		message_admins("initializing weapon typelist")
		weapons[W.name] = list(W)
		weapon_types += W.name
	else if(!(W in weapons[W.name]))
		message_admins("adding weapon to typelist")
		weapons[W.name] += W

/obj/structure/overmap/proc/remove_weapon(datum/ship_weapon/W)
	if(!istype(W, /datum/ship_weapon))
		message_admins("wrong type")
		return
	if(!weapons)
		message_admins("no weapons list")
		return
	else if(!(weapons[W.name]))
		message_admins("no weapons of this type")
		return
	else if(W in weapons[W.name])
		message_admins("adding weapon to typelist")
		weapons[W.name] -= W

/obj/structure/overmap/proc/fire(atom/target)
	if(weapon_safety)
		if(gunner)
			to_chat(gunner, "<span class='warning'>Weapon safety interlocks are active! Use the ship verbs tab to disable them!</span>")
		return
	if(ai_controlled) //Let the AI switch weapons according to range
		if(istype(target, /obj/structure/overmap))
			var/obj/structure/overmap/OT = target
			var/target_range = get_dist(OT,src)
			if(target_range > max_range) //Our max range is the maximum possible range we can engage in. This is to stop you getting hunted from outside of your view range.
				last_target = null
			if(target_range > 30) //In other words, theyre out of PDC range - Magic number pulled from the aether
				if(OT.mass >= MASS_MEDIUM) //Torps for capitals
					if(torpedoes > 0) //If we have torpedoes loaded, let's use them
						swap_to(FIRE_MODE_TORPEDO)
					else if(mass < MASS_LARGE) //Big ships don't use their PDCs like this, and instead let them automatically shoot at the enemy.
						swap_to(FIRE_MODE_PDC)
					else
						swap_to(FIRE_MODE_RAILGUN)
				if(OT.mass < MASS_MEDIUM) //Missiles for subcapitals
					if(missiles > 0) //If we have torpedoes loaded, let's use them
						swap_to(FIRE_MODE_MISSILE)
					else if(mass < MASS_LARGE) //Big ships don't use their PDCs like this, and instead let them automatically shoot at the enemy.
						swap_to(FIRE_MODE_PDC)
					else
						swap_to(FIRE_MODE_RAILGUN)
	//end if(ai_controlled)
	last_target = target
	if(next_firetime > world.time)
		to_chat(pilot, "<span class='warning'>WARNING: Weapons cooldown in effect to prevent overheat.</span>")
		return
	if(istype(target, /obj/structure/overmap))
		var/obj/structure/overmap/ship = target
		ship.add_enemy(src)
	next_firetime = world.time + fire_delay
	fire_weapon(target)

/obj/structure/overmap/verb/cycle_firemode()
	set name = "Switch firemode"
	set category = "Ship"
	set src = usr.loc
	if(usr != gunner)
		return

	var/stop = fire_mode
	if(!(weapons.len))
		return FALSE
	var/mode = WRAP_AROUND_VALUE(fire_mode + 1, 1, weapons.len + 1)

	for(mode; mode != stop; mode = WRAP_AROUND_VALUE(mode + 1, 1, weapons.len + 1))
		message_admins("Trying to switch to mode [mode]")
		stoplag()
		if(swap_to(mode))
			return

/obj/structure/overmap/proc/get_max_firemode()
	if(mass < MASS_MEDIUM) //Small craft dont get a railgun
		return FIRE_MODE_TORPEDO
	return FIRE_MODE_RAILGUN

/obj/structure/overmap/proc/swap_to(what=1)
	if(weapon_types.len < what)
		message_admins("No weapon types listed")
		return FALSE
	var/weap_type = weapon_types[what]
	var/list/weapon_candidates = weapons[weap_type]
	if(!weapons)
		message_admins("no weapons list")
	if(!weapon_candidates)
		message_admins("no candidates")
	if(!(weapon_candidates.len))
		message_admins("length is 0")
	if(weapons && weapon_candidates && weapon_candidates.len)
		// Keep checking
		for(var/datum/ship_weapon/W in weapon_candidates)
			if(W.can_select(src))
				W.select(src)
				message_admins("Got one")
				fire_delay = initial(fire_delay) + W.fire_delay
				fire_mode = what
				fire_mode = what
				if(ai_controlled)
					fire_delay += 1 SECONDS //Make it fair on the humans who have to actually reload and stuff.
				return TRUE
	message_admins("nope")
	return FALSE

/obj/structure/overmap/proc/firemode2text(mode)
	if(!weapons[mode][1])
		return "Weapon type not found"
	var/list/selected = weapons[mode] //Clunky, but dreamchecker wanted it this way.
	var/atom/found = selected[1]
	return "[found.name]"

/obj/structure/overmap/proc/fire_weapon(atom/target, mode=fire_mode)
	var/typename = weapon_types[mode]
	message_admins("firing a [typename]")

	for(var/datum/ship_weapon/W in (weapons[typename]))
		message_admins("Trying a [W.name]")
		if(W && istype(W))
			message_admins("It exists")
			if(W.try_fire(src, target))
				message_admins("We did it")
				return TRUE
	if(gunner && (weapons[typename]) && (weapons[typename][1])) //Tell them we failed
		var/datum/ship_weapon/SW = weapons[typename][1]
		to_chat(gunner, SW.failure_alert)

/obj/structure/overmap/proc/fire_ordnance(atom/target)
	if(fire_mode == FIRE_MODE_TORPEDO)
		return fire_torpedo(target)
	if(fire_mode == FIRE_MODE_MISSILE)
		return fire_missile(target)
	return FALSE

/obj/structure/overmap/proc/fire_torpedo(atom/target)
	if(!linked_areas.len && role != MAIN_OVERMAP) //AI ships and fighters don't have interiors
		if(torpedoes <= 0)
			if(ai_controlled)
				addtimer(VARSET_CALLBACK(src, torpedoes, initial(src.torpedoes)), 60 SECONDS)
			return
		fire_projectile(/obj/item/projectile/guided_munition/torpedo, target, homing = TRUE, speed=1, explosive = TRUE)
		torpedoes --
		var/obj/structure/overmap/OM = target
		if(istype(OM, /obj/structure/overmap) && OM.dradis)
			OM.dradis?.relay_sound('nsv13/sound/effects/fighters/launchwarning.ogg')
		return TRUE

/obj/structure/overmap/proc/fire_missile(atom/target)
	if(!linked_areas.len && role != MAIN_OVERMAP) //AI ships and fighters don't have interiors
		if(missiles <= 0)
			if(ai_controlled)
				addtimer(VARSET_CALLBACK(src, missiles, initial(src.missiles)), 60 SECONDS)
			return
		fire_projectile(/obj/item/projectile/guided_munition/missile, target, homing = TRUE, speed=3, explosive = TRUE)
		missiles --
		var/obj/structure/overmap/OM = target
		if(istype(OM, /obj/structure/overmap) && OM.dradis)
			OM.dradis?.relay_sound('nsv13/sound/effects/fighters/launchwarning.ogg')
		return TRUE

/obj/structure/overmap/proc/shake_everyone(severity)
	for(var/mob/M in mobs_in_ship)
		if(M.client)
			shake_camera(M, severity, 1)

/obj/structure/overmap/bullet_act(obj/item/projectile/P)
	if(istype(P, /obj/item/projectile/beam/overmap/aiming_beam))
		return
	relay_damage(P?.type)
	. = ..()

/obj/structure/overmap/proc/relay_damage(proj_type)
	if(role != MAIN_OVERMAP)
		return
	var/turf/pickedstart
	var/turf/pickedgoal
	var/max_i = 10//number of tries to spawn bullet.
	while(!isspaceturf(pickedstart))
		var/startSide = pick(GLOB.cardinals)
		var/startZ = pick(SSmapping.levels_by_trait(ZTRAIT_STATION))
		pickedstart = spaceDebrisStartLoc(startSide, startZ)
		pickedgoal = spaceDebrisFinishLoc(startSide, startZ)
		max_i--
		if(max_i<=0)
			return
	var/obj/item/projectile/proj = new proj_type(pickedstart)
	proj.starting = pickedstart
	proj.firer = null
	proj.def_zone = "chest"
	proj.original = pickedgoal
	spawn()
		proj.fire(Get_Angle(pickedstart,pickedgoal))
		proj.set_pixel_speed(4)

/obj/structure/overmap/take_damage(damage_amount, damage_type = BRUTE, damage_flag = 0, sound_effect = 1)
	SEND_SIGNAL(src, COMSIG_DAMAGE_TAKEN, damage_amount) //Trigger to update our list of armour plates without making the server cry.
	if(is_player_ship()) //Code for handling "superstructure crit" only applies to the player ship, nothing else.
		if(obj_integrity <= damage_amount || structure_crit) //Superstructure crit! They would explode otherwise, unable to withstand the hit.
			obj_integrity = 10 //Automatically set them to 10 HP, so that the hit isn't totally ignored. Say if we have a nuke dealing 1800 DMG (the ship's full health) this stops them from not taking damage from it, as it's more DMG than we can handle.
			handle_crit(damage_amount)
			return FALSE
	. = ..()

/obj/structure/overmap/proc/is_player_ship() //Should this ship be considered a player ship? This doesnt count fighters because they need to actually die.
	if(linked_areas.len || role == MAIN_OVERMAP)
		return TRUE
	return FALSE

/obj/structure/overmap
	var/structure_crit = FALSE
	var/explosion_cooldown = FALSE

/obj/structure/overmap/proc/handle_crit(damage_amount) //A proc to allow ships to enter superstructure crit, this means the player ship can't die, but its insides can get torn to shreds.
	if(!structure_crit)
		relay('nsv13/sound/effects/ship/crit_alarm.ogg', message=null, loop=TRUE, channel=CHANNEL_SHIP_FX)
		priority_announce("DANGER. Ship superstructure failing. Structural integrity failure imminent. Immediate repairs are required to avoid total structural failure.","Automated announcement ([src])") //TEMP! Remove this shit when we move ruin spawns off-z
		structure_crit = TRUE
	if(explosion_cooldown)
		return
	explosion_cooldown = TRUE
	addtimer(VARSET_CALLBACK(src, explosion_cooldown, FALSE), 5 SECONDS)
	var/area/target = null
	if(role == MAIN_OVERMAP)
		var/name = pick(GLOB.teleportlocs) //Time to kill everyone
		target = GLOB.teleportlocs[name]
	else
		target = pick(linked_areas)
	var/turf/T = pick(get_area_turfs(target))
	new /obj/effect/temp_visual/explosion_telegraph(T)

/obj/structure/overmap/proc/try_repair(amount)
	var/withrepair = obj_integrity+amount
	if(withrepair > max_integrity) //No overheal
		obj_integrity = max_integrity
	else
		obj_integrity += amount
	if(structure_crit)
		if(obj_integrity >= max_integrity/3) //You need to repair a good chunk of her HP before you're getting outta this fucko.
			stop_relay(channel=CHANNEL_SHIP_FX)
			priority_announce("Ship structural integrity restored to acceptable levels. ","Automated announcement ([src])")
			structure_crit = FALSE

/obj/effect/temp_visual/explosion_telegraph
	name = "Explosion imminent!"
	icon = 'nsv13/icons/overmap/effects.dmi'
	icon_state = "target"
	duration = 6 SECONDS
	randomdir = 0
	light_color = LIGHT_COLOR_ORANGE
	layer = ABOVE_MOB_LAYER

/obj/effect/temp_visual/explosion_telegraph/Initialize()
	. = ..()
	set_light(4)
	for(var/mob/M in orange(src, 3))
		if(isliving(M))
			to_chat(M, "<span class='userdanger'>You hear a loud creak coming from above you. Take cover!</span>")
			SEND_SOUND(M, pick('nsv13/sound/ambience/ship_damage/creak5.ogg','nsv13/sound/ambience/ship_damage/creak6.ogg'))

/obj/effect/temp_visual/explosion_telegraph/Destroy()
	var/turf/T = get_turf(src)
	explosion(T,3,4,4)
	. = ..()
