
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


/datum/component/overmap_piloting/Initialize(target, ui)
	src.target = target
	src.ui = ui
	RegisterSignal(SSJSOvermap, COMSIG_JS_OVERMAP_UPDATE, PROC_REF(mark_dirty)) //Don't do this for turfs, because we don't care

/datum/component/overmap_piloting/proc/process_fire(weapon_type, angle)
	if(!(rights & OVERMAP_CONTROL_RIGHTS_GUNNER))
		return
	//TODO: Check if theyre the gunner. Roles... I don't care for now!
	target.fire_projectile(angle=angle)

/datum/component/overmap_piloting/Destroy()
	UnregisterSignal(SSJSOvermap, COMSIG_JS_OVERMAP_UPDATE)
	. = ..()
/**
Mark our linked TGUI as requiring update.
The server will send the new positions and state of the physics world.
Usually called when anything is added to the overmap, removed from it, or a collision occurs.
*/
/datum/component/overmap_piloting/proc/mark_dirty(datum/source, datum/overmap/target)
	SIGNAL_HANDLER
	//If they're not on our Z, ignore..
	if(target.position.z != src.target.position.z)
		return
	//to_chat(world, "Overmap UI marked dirty.")
	//src.ui.needs_update = TRUE
	//HACK: instant UI update. Take your delay and get out.
	src.ui.src_object.ui_interact(ui.user, ui)

/**
	Zoom the client's view by a delta value.
*/
/datum/component/overmap_piloting/proc/zoom(delta_y)
	var/zoom_level = zoom_distance + (delta_y * 100)
	if(zoom_level <= 100)
		zoom_level = 100
	src.zoom_distance = zoom_level
	//to_chat(world, zoom_distance)

/datum/component/overmap_piloting/proc/process_input(key)
	if(!target)
		return
	//TODO: Mirror me in JS!!
	//Helm controls.
	if(rights & OVERMAP_CONTROL_RIGHTS_HELM)
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
	//Gunner controls (TODO)
	if(rights & OVERMAP_CONTROL_RIGHTS_GUNNER)
		return

/datum/component/overmap_piloting/observer
	rights = OVERMAP_CONTROL_RIGHTS_NONE

