//Ship console for using the big guns
/obj/machinery/computer/ship/tactical
	name = "Seegson model TAC tactical systems control console"
	desc = "In ship-to-ship combat, most ship systems are digitalized. This console is networked with every weapon system that its ship has to offer, allowing for easy control. There's a section on the screen showing an exterior gun camera view with a rangefinder."
	icon_screen = "tactical"
	position_type = /datum/component/overmap_piloting/gunner
	circuit = /obj/item/circuitboard/computer/ship/tactical_computer
	ui_type = "JSTacticalConsole"

//For use in ghost ships
/obj/machinery/computer/ship/tactical/internal
	name = "integrated tactical console"
	use_power = 0

/obj/machinery/computer/ship/tactical/internal/attack_hand(mob/user)
	. = ..()
	if(.)
		ui_interact(user)


/obj/machinery/computer/ship/tactical/internal/can_interact(mob/user) //Override this code to allow people to use consoles when flying the ship.
	if(locate(user) in linked?.operators)
		return TRUE
	if(!user.can_interact_with(src)) //Theyre too far away and not flying the ship
		return FALSE
	return TRUE

/obj/machinery/computer/ship/tactical/internal/ui_interact(mob/user, datum/tgui/ui)
	ui = SStgui.try_update_ui(user, src, ui)
	if(!ui)
		ui = new(user, src, "GhostTacticalConsole")
		ui.open()
		ui.set_autoupdate(TRUE)

/obj/machinery/computer/ship/tactical/internal/ui_state(mob/user)
	return GLOB.always_state

/obj/machinery/computer/ship/tactical/internal/ui_data(mob/user)
	if(!linked)
		return
	var/list/data = list()
	data["flakrange"] = linked.get_flak_range(linked.last_target)
	data["integrity"] = linked.obj_integrity
	data["max_integrity"] = linked.max_integrity
	if(istype(linked, /obj/structure/overmap/small_craft))
		var/obj/structure/overmap/small_craft/small_ship = linked
		var/obj/item/fighter_component/armour_plating/A = small_ship.loadout.get_slot(HARDPOINT_SLOT_ARMOUR)
		data["has_quadrant"] = FALSE
		data["armour_integrity"] = (A) ? A.obj_integrity : 0
		data["max_armour_integrity"] = (A) ? A.max_integrity : 100
	else
		data["has_quadrant"] = TRUE // I'm uncertain about whether or not we have ANY small crafts that have armor quadrants so I'm making it like this instead.
	data["quadrant_fs_armour_current"] = linked.armour_quadrants["forward_starboard"]["current_armour"]
	data["quadrant_fs_armour_max"] = linked.armour_quadrants["forward_starboard"]["max_armour"]
	data["quadrant_as_armour_current"] = linked.armour_quadrants["aft_starboard"]["current_armour"]
	data["quadrant_as_armour_max"] = linked.armour_quadrants["aft_starboard"]["max_armour"]
	data["quadrant_ap_armour_current"] = linked.armour_quadrants["aft_port"]["current_armour"]
	data["quadrant_ap_armour_max"] = linked.armour_quadrants["aft_port"]["max_armour"]
	data["quadrant_fp_armour_current"] = linked.armour_quadrants["forward_port"]["current_armour"]
	data["quadrant_fp_armour_max"] = linked.armour_quadrants["forward_port"]["max_armour"]

	data["heavy_ammo"] = linked.shots_left
	data["light_ammo"] = linked.light_shots_left
	data["missile_ammo"] = linked.missiles
	data["torpedo_ammo"] = linked.torpedoes

 	//Logic to read 0% if not available
	if(initial(linked.shots_left))
		data["heavy_ammo_max"] = initial(linked.shots_left)
	else
		data["heavy_ammo_max"] = 1
	if(initial(linked.light_shots_left))
		data["light_ammo_max"] = initial(linked.light_shots_left)
	else
		data["light_ammo_max"] = 1
	if(initial(linked.missiles))
		data["missile_ammo_max"] = initial(linked.missiles)
	else
		data["missile_ammo_max"] = 1
	if(initial(linked.torpedoes))
		data["torpedo_ammo_max"] = initial(linked.torpedoes)
	else
		data["torpedo_ammo_max"] = 1

	data["target_name"] = (linked.target_lock) ? linked.target_lock.name : "none"
	data["painted_targets"] = list()
	data["no_gun_cam"] = linked.no_gun_cam
	if(!linked?.current_system)
		return data
	for(var/obj/structure/overmap/OM in linked.target_painted)
		if(OM.current_system != linked.current_system)
			continue
		data["painted_targets"] += list(list("name" = OM.name, "integrity" = OM.obj_integrity, "max_integrity" = OM.max_integrity, "faction" = OM.faction, \
			"quadrant_fs_armour_current" = OM.armour_quadrants["forward_starboard"]["current_armour"], \
			"quadrant_fs_armour_max" = OM.armour_quadrants["forward_starboard"]["max_armour"], \
			"quadrant_as_armour_current" = OM.armour_quadrants["aft_starboard"]["current_armour"], \
			"quadrant_as_armour_max" = OM.armour_quadrants["aft_starboard"]["max_armour"], \
			"quadrant_ap_armour_current" = OM.armour_quadrants["aft_port"]["current_armour"], \
			"quadrant_ap_armour_max" = OM.armour_quadrants["aft_port"]["max_armour"], \
			"quadrant_fp_armour_current" = OM.armour_quadrants["forward_port"]["current_armour"], \
			"quadrant_fp_armour_max" = OM.armour_quadrants["forward_port"]["max_armour"]))
	return data
