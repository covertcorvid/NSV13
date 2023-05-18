#define COMSIG_JS_OVERMAP_UPDATE "js_overmap_mark_dirty"
/**
	The overmap JS subsystem. Not to be confused with overmap!
	Why? because it's WIP!, experimental, WIPPPP
*/
PROCESSING_SUBSYSTEM_DEF(JSOvermap)
	name = "JS Overmap"
	wait = 0.2 SECONDS
	stat_tag = "JS"
	var/list/physics_world = list()

/datum/controller/subsystem/processing/JSOvermap/proc/register(datum/overmap/target)
	SEND_SIGNAL(src, COMSIG_JS_OVERMAP_UPDATE, target)
	physics_world += target
	return target

/datum/controller/subsystem/processing/JSOvermap/proc/unregister(datum/overmap/target)
	SEND_SIGNAL(src, COMSIG_JS_OVERMAP_UPDATE, target)
	physics_world -= target
	return

/datum/controller/subsystem/processing/JSOvermap/proc/ui_data_for(mob/user, datum/overmap/target)
	. = list()
	.["physics_world"] = list()
	for(var/datum/overmap/O in physics_world)
		var/list/data = list(
			icon = O.icon_base64,
			active = (target == O),
			thruster_power = O.thruster_power,
			rotation_power = O.rotation_power,
			sensor_range = O.get_sensor_range(),
			position = list(O.position.x, O.position.y, O.position.z, O.position.angle, O.position.velocity)
		)
		.["physics_world"] += list(data)

/**
	5-D vector for holding information about ship state.
	We can most definitely simplify this...
*/
/datum/vec5
	var/x = 0
	var/y = 0
	var/z = 0
	var/angle = 0
	var/velocity = 0

/datum/vec5/New(x,y,z,angle,velocity)
	src.x = x
	src.y = y
	src.z = z
	src.angle = angle
	src.velocity = velocity

/datum/overmap
	var/datum/vec5/position
	var/icon = null
	var/icon_state = ""
	var/icon_base64 = ""
	var/mass = MASS_SMALL
	//TODO, temp.
	var/thruster_power = 0.01
	var/rotation_power = 0.001
	//Maths optimisations...
	var/radians = 0
	var/cos_r = 0
	var/sin_r = 0
	var/base_sensor_range = 1000

/**
	Return the sensor range for an overmap.

	TODO: Tie this into sensors subsystem!
*/
/datum/overmap/proc/get_sensor_range()
	return base_sensor_range

/**
	Constructor for overmap objects. Pre-bakes some maths for you and initialises processing.
*/
/datum/overmap/New(x,y,z,angle,velocity)
	position = new /datum/vec5(x,y,z,angle,velocity)
	icon_base64 = icon2base64(icon(icon, icon_state, frame=1))
	//TODO this should inversely scale!
	thruster_power = (mass / 10)
	rotation_power = (mass / 10)
	//TODO: Tie this into sensors subsystem!
	base_sensor_range = 2*(mass * 1000)
	//TODO: replace this.
	START_PROCESSING(SSJSOvermap, src)

/datum/overmap/Destroy()
	STOP_PROCESSING(SSJSOvermap, src)
	. = ..()
/**
	Rotate an overmap either left or right.
	dir: -1 = left, 1 = right.

	TODO: This should mark dirty. If a ship changes heading or speed that isn't yours.
	Maybe mark all UIs except the pilot's one dirty via the "target" property of the event?
*/
/datum/overmap/proc/rotate(dir)
	position.angle += rotation_power * dir
		//Maths optimisations...
	//radians = TORADIANS(position.angle)
	//Okay.. BYOND cos uses degrees, not radians. Good to know!
	cos_r = cos(position.angle)
	sin_r = sin(position.angle)

//TODO: game coords to canvas coords! major desync issues, here.
/datum/overmap/process()
	position.x -= cos_r * position.velocity
	position.y -= sin_r * position.velocity

/**
	Apply thrust to an overmap. TODO mostly.
	TODO: This should mark dirty. If a ship changes heading or speed that isn't yours.
	Maybe mark all UIs except the pilot's one dirty via the "target" property of the event?
*/
/datum/overmap/proc/thrust(dir)
	switch(dir)
		if(1)
			position.velocity += thruster_power
		if(-1)
			//TODO: unrealistic, OK for now
			position.velocity *= 0.99

/**
	Component to give the pilot a view of the overmap, and steer a ship.
	TODO: Observer and gunner subtypes.
*/
/datum/component/overmap_piloting
	var/zoom_distance = 0
	var/datum/overmap/target = null
	var/datum/tgui/ui = null
	dupe_mode = COMPONENT_DUPE_HIGHLANDER

/datum/component/overmap_piloting/Initialize(target, ui)
	src.target = target
	src.ui = ui
	RegisterSignal(SSJSOvermap, COMSIG_JS_OVERMAP_UPDATE, PROC_REF(mark_dirty)) //Don't do this for turfs, because we don't care

/datum/component/overmap_piloting/Destroy()
	UnregisterSignal(SSJSOvermap, COMSIG_JS_OVERMAP_UPDATE)
	. = ..()
/**
Mark our linked TGUI as requiring update.
The server will send the new positions and state of the physics world.
Usually called when anything is added to the overmap, removed from it, or a collision occurs.
*/
/datum/component/overmap_piloting/proc/mark_dirty()
	SIGNAL_HANDLER
	to_chat(world, "Overmap UI marked dirty.")
	src.ui.needs_update = TRUE

/**
	Zoom the client's view by a delta value.
*/
/datum/component/overmap_piloting/proc/zoom(delta_y)
	var/zoom_level = zoom_distance + (delta_y * 50)
	if(zoom_level <= 100)
		zoom_level = 100
	src.zoom_distance = zoom_level
	//to_chat(world, zoom_distance)

/datum/component/overmap_piloting/proc/process_input(key)
	if(!target)
		return
	switch(key)
		//W key (TODO: also arrow keys)
		if(87)
			target.thrust(1)
			return
		//ALT key
		if(18)
			target.thrust(-1)
			return
		//A
		if(68)
			target.rotate(1)
			return
		//D
		if(65)
			target.rotate(-1)
			return


/**
	Anything that's considered a "ship".
	This will have functionality for subsystems, weapons, etc.
*/
/datum/overmap/ship
	icon = 'nsv13/icons/overmap/nanotrasen/light_cruiser.dmi'
	icon_state = "cruiser-100"

/obj/machinery/computer/ship/js_overmap
	name = "HAHA"
	var/datum/overmap/ship/active_ship

//obj/machinery/computer/ship/js_overmap/process()

/obj/machinery/computer/ship/js_overmap/Initialize(mapload)
	. = ..()
	active_ship = SSJSOvermap.register(new /datum/overmap/ship(500,100, 1, 0, 0))

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

	to_chat(world, "Overmap: UI update...")
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
		if("keyup")
			return;
		if("keydown")
			C.process_input(params["key"])
			return;
	//active_ship.position.x += 0.1;
