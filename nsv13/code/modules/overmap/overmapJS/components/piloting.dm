
/**
	Component to give the pilot a view of the overmap, and steer a ship.
	TODO: Observer and gunner subtypes.
*/
/datum/component/overmap_piloting
	var/zoom_distance = 0
	var/datum/overmap/target = null
	var/datum/tgui/ui = null
	dupe_mode = COMPONENT_DUPE_HIGHLANDER
	var/rights = OVERMAP_CONTROL_RIGHTS_FULL
	var/fps_capability = -1
	// Testing - remove later
	var/firing_arc_center = 0 // Dead center
	var/firing_arc_width = 100 // In percentage - Omnidirectional


/datum/component/overmap_piloting/Initialize(target, ui)
	src.target = target
	src.ui = ui
	RegisterSignal(SSJSOvermap, COMSIG_JS_OVERMAP_UPDATE, PROC_REF(mark_dirty)) //Don't do this for turfs, because we don't care
	RegisterSignal(SSJSOvermap, COMSIG_JS_OVERMAP_STATIC_DATA_UPDATE, PROC_REF(force_update_static_data)) //Don't do this for turfs, because we don't care

/datum/component/overmap_piloting/proc/process_fire(datum/weapon_group/WG, proj_angle)
	if(!(rights & OVERMAP_CONTROL_RIGHTS_GUNNER))
		return
	//TODO hack to test the rest of this
	if(!istype(WG))
		var/key = target.weapon_groups[1]
		WG = target.weapon_groups[key]
	for(var/W in WG.weapon_list)
		var/datum/overmap_weapon/weap = W
		weap.fire(target, proj_angle)

/datum/component/overmap_piloting/Destroy()
	UnregisterSignal(SSJSOvermap, COMSIG_JS_OVERMAP_UPDATE)
	UnregisterSignal(SSJSOvermap, COMSIG_JS_OVERMAP_STATIC_DATA_UPDATE)

	//Bye bye mr UI, took my chevvy to the levy but the levy was dry..
	ui?.close()
	. = ..()
/**
Mark our linked TGUI as requiring update.
The server will send the new positions and state of the physics world.
Usually called when anything is added to the overmap, removed from it, or a collision occurs.
*/
/datum/component/overmap_piloting/proc/mark_dirty(datum/source, datum/overmap/target, fps=-1)
	SIGNAL_HANDLER
	//If they're not on our Z, ignore..
	if(target.map != src.target.map)
		return
	//If the client is reporting its FPS capability to us, set ours to match.
	if(fps != -1)
		fps_capability = round(fps)
	//to_chat(world, "Overmap UI marked dirty.")
	//src.ui.needs_update = TRUE
	//HACK: instant UI update. Take your delay and get out.
	//src.ui.src_object.ui_interact(ui.user, ui)
	src.ui.needs_update = TRUE

/datum/component/overmap_piloting/proc/force_update_static_data(datum/source)
	src.ui.src_object.update_static_data(ui.user)

/**
	Zoom the client's view by a delta value.
*/
/datum/component/overmap_piloting/proc/zoom(delta_y)
	var/zoom_level = zoom_distance + (delta_y * 100)
	if(zoom_level <= 100)
		zoom_level = 100
	src.zoom_distance = zoom_level

/datum/component/overmap_piloting/proc/set_zoom(zoom_level)
	src.zoom_distance = zoom_level

/datum/component/overmap_piloting/proc/process_input(key, state)
	if(!target)
		return
	//TODO: Mirror me in JS!!
	//Helm controls.
	if(rights & OVERMAP_CONTROL_RIGHTS_HELM)
		target.process_input(key, state)
	//Gunner controls (TODO)
	if(rights & OVERMAP_CONTROL_RIGHTS_GUNNER)
		return

/datum/component/overmap_piloting/proc/set_firing_arc_center(center)
	to_chat(world, "Setting firing_arc_center to [center]")
	firing_arc_center = SIMPLIFY_DEGREES(center)

/datum/component/overmap_piloting/proc/set_firing_arc_width(width)
	to_chat(world, "Setting firing_arc_width to [width]")
	firing_arc_width = width

/datum/component/overmap_piloting/observer
	rights = OVERMAP_CONTROL_RIGHTS_NONE

/datum/overmap/proc/process_input(key, state)
	keys["[key]"] = state
