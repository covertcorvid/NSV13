
/**
	The overmap JS subsystem. Not to be confused with overmap!
	Why? because it's WIP!, experimental, WIPPPP
*/
PROCESSING_SUBSYSTEM_DEF(JSOvermap)
	name = "JS Overmap"
	wait = 0.2 SECONDS
	stat_tag = "JS"
	var/list/physics_world = list()

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

/obj/machinery/computer/ship/js_overmap
	name = "HAHA"
	var/datum/overmap/ship/active_ship

//obj/machinery/computer/ship/js_overmap/process()

/obj/machinery/computer/ship/js_overmap/Initialize(mapload)
	. = ..()
	active_ship = SSJSOvermap.register(new /datum/overmap/ship/player(600,200, 1, 0, 0))
	SSJSOvermap.register(new /datum/overmap/ship/syndicate(450,100, 1, 180, 0))
	SSJSOvermap.register(new /datum/overmap/ship/syndicate/frigate(800,100, 1, 180, 0.05))
	SSJSOvermap.register(new /datum/overmap/ship/syndicate/cruiser(1500,1000, 1, 90, 0))

/obj/machinery/computer/ship/js_overmap/attack_hand(mob/user)
	. = ..()
	if(.)
		ui_interact(user)

/obj/machinery/computer/ship/js_overmap/can_interact(mob/user) //Override this code to allow people to use consoles when flying the ship.
	if(!user.can_interact_with(src)) //Theyre too far away and not flying the ship
		return FALSE
	if((interaction_flags_atom & INTERACT_ATOM_REQUIRES_DEXTERITY) && !user.IsAdvancedToolUser())
		to_chat(user, "<span class='warning'>You don't have the dexterity to do this!</span>")
		return FALSE
	if(!(interaction_flags_atom & INTERACT_ATOM_IGNORE_INCAPACITATED) && user.incapacitated((interaction_flags_atom & INTERACT_ATOM_IGNORE_RESTRAINED), !(interaction_flags_atom & INTERACT_ATOM_CHECK_GRAB)))
		return FALSE
	return TRUE

/obj/machinery/computer/ship/js_overmap/ui_state(mob/user)
	return GLOB.always_state

/obj/machinery/computer/ship/js_overmap/ui_interact(mob/user, datum/tgui/ui)
	//TODO: need a UI handler for this to REMOVE their piloting component!

	//to_chat(world, "Overmap: UI update...")
	ui = SStgui.try_update_ui(user, src, ui)
	if(!ui)
		ui = new(user, src, "JSOvermap")
		ui.open()
		user.AddComponent(/datum/component/overmap_piloting, active_ship, ui)
		//TODO: Do we actually _NEED_ autoupdate?
		//We can guarantee a certain degree of precision between the client and server..
		//When the list of overmap ships changes, or a collision occurs etc, we can always update the clients.
		//ui.set_autoupdate(TRUE) // Contact positions

/obj/machinery/computer/ship/js_overmap/ui_data(mob/user)
	. = SSJSOvermap.ui_data_for(user, active_ship)
	var/datum/component/overmap_piloting/OP = user.GetComponent(/datum/component/overmap_piloting)
	//Broadcast this particular client's cached overmap Zoom level.
	var/zoom = 1000
	if(OP != null)
		zoom = OP.zoom_distance
	.["client_zoom"] = zoom

/obj/machinery/computer/ship/js_overmap/ui_act(action, list/params)
	. = ..()
	if (.)
		return
	var/datum/component/overmap_piloting/C = usr.GetComponent(/datum/component/overmap_piloting)
	//to_chat(world, action)
	//to_chat(world, params)
	//to_chat(world, params["key"])
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
	//active_ship.position.x += 0.1;
