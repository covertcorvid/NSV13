/**
	The overmap JS subsystem. Not to be confused with overmap!
	Why? because it's WIP!, experimental, WIPPPP
*/
PROCESSING_SUBSYSTEM_DEF(JSOvermap)
	name = "JS Overmap"
	wait = 0.2 SECONDS
	stat_tag = "JS"
	init_order = INIT_ORDER_STARSYSTEM
	var/list/physics_world = list()
	var/list/overmap_icons = list()

/datum/controller/subsystem/processing/JSOvermap/proc/batch_initial()
	instance(/datum/overmap/ship/player/cruiser, new /datum/vec5(200, 200, 1, 0, 0))
	instance(/datum/overmap/ship/syndicate, new /datum/vec5(1000, 400, 1, 0, 0))
	instance(/datum/overmap/ship/syndicate/cruiser, new /datum/vec5(400, 1000, 1, 90, 0))

/datum/controller/subsystem/processing/JSOvermap/proc/instance(type, datum/vec5/position)
	var/datum/overmap/OM = register(new type(position.x, position.y, position.z, position.angle, position.velocity))
	return OM

/datum/controller/subsystem/processing/JSOvermap/proc/get_overmap(z)
	var/datum/space_level/SL = SSmapping.z_list[z] // Overmaps linked to Zs, like the main ship
	if(SL?.occupying_overmap)
		return SL.occupying_overmap
/**
	Register "target" with the overmap.
	Pass in a newly created overmap object, and it will be tracked.
*/
/datum/controller/subsystem/processing/JSOvermap/proc/register(datum/overmap/target)
	SEND_SIGNAL(src, COMSIG_JS_OVERMAP_UPDATE, target)
	physics_world += target
	return target

/**
	Register a list of overmaps as one processing "batch".
	This means the UI is only marked dirty ONCE, as the ships are pushed in.
*/
/datum/controller/subsystem/processing/JSOvermap/proc/register_batch(list/targets)
	if(!targets)
		return
	for(var/datum/overmap/O in targets)
		physics_world += O
	SEND_SIGNAL(src, COMSIG_JS_OVERMAP_UPDATE, targets[1])

/datum/controller/subsystem/processing/JSOvermap/proc/unregister(datum/overmap/target)
	SEND_SIGNAL(src, COMSIG_JS_OVERMAP_UPDATE, target)
	physics_world -= target
	STOP_PROCESSING(SSJSOvermap, target)
	return

/datum/controller/subsystem/processing/JSOvermap/proc/ui_data_for(mob/user, datum/overmap/target)
	. = list()
	.["physics_world"] = list()
	var/datum/component/overmap_piloting/OP = user.GetComponent(/datum/component/overmap_piloting)
	//Broadcast this particular client's cached overmap Zoom level.
	var/zoom = 1000
	if(OP != null)
		zoom = OP.zoom_distance
	.["client_zoom"] = zoom
	.["can_pilot"] = OP.rights & OVERMAP_CONTROL_RIGHTS_HELM
	.["control_scheme"] = OP.rights
	for(var/datum/overmap/O in physics_world)
		var/list/quads = list()
		if(O.armour_quadrants)
			quads = new(4)
			for(var/I = 1; I <=4; I++)
				quads[I] = list(O.armour_quadrants[I].integrity, O.armour_quadrants[I].max_integrity)
		var/list/data = list(
			icon = O.icon_base64,
			active = (target == O),
			thruster_power = O.thruster_power,
			rotation_power = O.rotation_power,
			sensor_range = O.get_sensor_range(),
			armour_quadrants = quads,
			position = list(O.position.x, O.position.y, O.position.z, O.position.angle, O.position.velocity)
		)
		.["physics_world"] += list(data)

//datum/controller/subsystem/processing/JSOvermap/proc/start_piloting(mob/user, datum/overmap/OM)


/datum/overmap_js_panel
	var/datum/overmap/active_ship = null
	var/hide_bullets = TRUE
	var/spawn_type = /datum/overmap
	var/spawn_z = 1

/datum/overmap_js_panel/ui_data(mob/user)
	. = SSJSOvermap.ui_data_for(user, active_ship)
	var/list/ships = list()
	for(var/datum/overmap/OM in SSJSOvermap.physics_world)
		if(hide_bullets && IS_OVERMAP_JS_PROJECTILE(OM))
			continue
		var/list/ship_data = list()
		ship_data["active"] = OM == active_ship
		ship_data["name"] = OM.name
		ship_data["faction"] = OM.faction
		ship_data["icon"] = OM.icon_base64
		ship_data["datum"] = "\ref[OM]"
		ships[++ships.len] = ship_data
	.["ships"] = ships
	.["spawn_type"] = "[spawn_type]"
	.["spawn_z"] = spawn_z
	.["hide_bullets"] = hide_bullets

/datum/overmap_js_panel/ui_state(mob/user)
	return GLOB.admin_state

/datum/overmap_js_panel/ui_interact(mob/user, datum/tgui/ui)
	if(!check_rights(0))
		return
	if(!active_ship)
		active_ship = SSJSOvermap.physics_world[1]
	ui = SStgui.try_update_ui(user, src, ui)
	if(!ui)
		log_admin_private("[user.ckey] opened the JS overmap panel.")
		ui = new(user, src, "JSOvermapPanel", "JS Overmap Panel")
		user.AddComponent(/datum/component/overmap_piloting/observer, active_ship, ui)
		ui.open()

/datum/overmap_js_panel/ui_act(action, list/params)
	. = ..()
	if (.)
		return
	var/datum/component/overmap_piloting/C = usr.GetComponent(/datum/component/overmap_piloting)
	switch(action)
		if("scroll")
			C.zoom(params["key"])
			return;
		if("fire")
			C.process_fire(params["weapon"], params["coords"])
			return;
		if("keyup")
			return;
		if("keydown")
			C.process_input(params["key"])
			return;
		if("view_vars")
			usr.client.debug_variables(locate(params["target"]))
			return
		//Swap ship. TODO: Remote piloting is also doable here!
		if("track")
			active_ship = locate(params["target"])
			C.target = active_ship
			ui_interact(usr)
			return
		if("swap_control_scheme")
			C.rights = params["target"]
			ui_interact(usr)
		if("toggle_hide_bullets")
			hide_bullets = !hide_bullets
			ui_interact(usr)
	//TODO: spawney buttons to add enemies?
		if("set_spawn_type")
			spawn_type = params["target"]
			ui_interact(usr)
		if("set_spawn_z")
			spawn_z = params["target"]
			ui_interact(usr)
		if("spawn_ship")
			SSJSOvermap.instance(spawn_type, new /datum/vec5(rand(0, JS_OVERMAP_TACMAP_SIZE), rand(0, JS_OVERMAP_TACMAP_SIZE), spawn_z, 0))
			ui_interact(usr)

/client/proc/js_overmap_panel() //Admin Verb for the Overmap Gamemode controller
	set name = "JS Overmap Panel"
	set desc = "Manage the JS overmap"
	set category = "Adminbus"
	var/datum/overmap_js_panel/JS = new()
	JS.ui_interact(usr)
