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

/datum/armour_quadrant
	var/integrity = 100
	var/max_integrity = 100
	var/datum/overmap/holder = null

/datum/armour_quadrant/New(integrity)
	. = ..()
	src.max_integrity = integrity
	src.integrity = src.max_integrity

/**
	Take a hit to a specified armour quadrant.
	Returns TRUE if the armour absorbed the projectile fully.
*/
/datum/armour_quadrant/proc/take_damage(amount)
	integrity -= amount
	if(integrity <= 0)
		integrity = 0
	return integrity > 0

/datum/overmap
	var/datum/vec5/position
	var/icon = null
	var/icon_state = ""
	var/icon_base64 = ""
	var/mass = MASS_SMALL
	var/name = "Overmap Object"
	//TODO, temp.
	var/thruster_power = 0.01
	var/rotation_power = 0.001
	//Maths optimisations...
	var/radians = 0
	var/cos_r = 0
	var/sin_r = 0
	var/base_sensor_range = 1000
	var/collision_radius = 96
	var/faction = null
	var/list/collision_positions = null
	var/datum/component/physics2d/physics2d = null
	var/list/damage_resistances = list()
	var/ai_controlled = FALSE
	var/interior_type = null///datum/component/overmap_interior
	var/datum/component/overmap_interior/interior = null
	var/integrity = 100
	var/max_integrity = 100
	var/list/armour_quadrants = null
	var/role = OVERMAP_ROLE_SECONDARY


/**
	Constructor for overmap objects. Pre-bakes some maths for you and initialises processing.
*/
/datum/overmap/New(x,y,z,angle,velocity)
	if(collision_positions == null)
		collision_positions = GLOB.projectile_hitbox
	position = new /datum/vec5(x,y,z,angle,velocity)
	//If the overmap JS subsystem does not contain our type's icon, add it.
	var/icon/I = icon(icon,icon_state,SOUTH, frame=1)
	if(!SSJSOvermap.overmap_icons["[src.type]"])
		SSJSOvermap.overmap_icons["[src.type]"] = icon2base64(I)
	icon_base64 = SSJSOvermap.overmap_icons["[src.type]"]
	collision_radius = I.Width()
	//TODO this should inversely scale!
	//thruster_power = (mass / 10)
	//rotation_power = (mass / 10)

	thruster_power = 1 / (mass)
	rotation_power = 1 / (mass)

	//todo maths shit to make the shit work.
	cos_r = cos(position.angle)
	sin_r = sin(position.angle)
	//TODO: Tie this into sensors subsystem!
	base_sensor_range = 2*(mass * 1000)
	physics2d = AddComponent(/datum/component/physics2d)
	if(interior_type)
		interior = AddComponent(interior_type)
	physics2d.setup(collision_positions, angle, faction)
	//TODO: replace this.
	START_PROCESSING(SSJSOvermap, src)
	setup_armour()

/datum/overmap/proc/setup_armour()
	switch(mass)
		if(MASS_TINY)
			damage_resistances = list(OVERMAP_DAMAGE_TYPE_KINETIC_SUBCAPITAL = 5, \
			OVERMAP_DAMAGE_TYPE_KINETIC_CAPITAL = 0, \
			OVERMAP_DAMAGE_TYPE_ENERGY = 0, \
			OVERMAP_DAMAGE_TYPE_EXPLOSIVE = 20, \
			)
		if(MASS_SMALL)
			damage_resistances = list(OVERMAP_DAMAGE_TYPE_KINETIC_SUBCAPITAL = 20, \
			OVERMAP_DAMAGE_TYPE_KINETIC_CAPITAL = 10, \
			OVERMAP_DAMAGE_TYPE_ENERGY = 5, \
			OVERMAP_DAMAGE_TYPE_EXPLOSIVE = 20, \
			)
		if(MASS_MEDIUM)
			damage_resistances = list(OVERMAP_DAMAGE_TYPE_KINETIC_SUBCAPITAL = 90, \
			OVERMAP_DAMAGE_TYPE_KINETIC_CAPITAL = 20, \
			OVERMAP_DAMAGE_TYPE_ENERGY = 10, \
			OVERMAP_DAMAGE_TYPE_EXPLOSIVE = 30, \
			)
		if(MASS_MEDIUM_LARGE)
			damage_resistances = list(OVERMAP_DAMAGE_TYPE_KINETIC_SUBCAPITAL = 95, \
			OVERMAP_DAMAGE_TYPE_KINETIC_CAPITAL = 25, \
			OVERMAP_DAMAGE_TYPE_ENERGY = 15, \
			OVERMAP_DAMAGE_TYPE_EXPLOSIVE = 30, \
			)
		if(MASS_LARGE)
			damage_resistances = list(OVERMAP_DAMAGE_TYPE_KINETIC_SUBCAPITAL = 98, \
			OVERMAP_DAMAGE_TYPE_KINETIC_CAPITAL = 25, \
			OVERMAP_DAMAGE_TYPE_ENERGY = 15, \
			OVERMAP_DAMAGE_TYPE_EXPLOSIVE = 35, \
			)
		if(MASS_TITAN)
			damage_resistances = list(OVERMAP_DAMAGE_TYPE_KINETIC_SUBCAPITAL = 100, \
			OVERMAP_DAMAGE_TYPE_KINETIC_CAPITAL = 40, \
			OVERMAP_DAMAGE_TYPE_ENERGY = 30, \
			OVERMAP_DAMAGE_TYPE_EXPLOSIVE = 40, \
			)


/datum/overmap/proc/fire_projectile(angle = src.position.angle, projectile_type=/datum/overmap/projectile/shell, burst_size=1)
	//TODO: magic number "10".
	//We scromble the position so it originates from the centre of the ship.
	for(var/i = 1; i <= burst_size; i++)
		var/datum/overmap/projectile/O = new projectile_type(position.x + (collision_radius/2),position.y + (collision_radius/2), position.z, angle, position.velocity)
		O.position.velocity += O.speed
		O.faction = faction
		SSJSOvermap.register(O)
	//to_chat(world, "Fire missile.")

/datum/overmap/Destroy()
	QDEL_NULL(physics2d)
	SSJSOvermap.unregister(src)
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
	//TODO: Mark everything dirty when we rotate, as we change heading.
	SEND_SIGNAL(src, COMSIG_JS_OVERMAP_UPDATE, src)

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
			//position.velocity *= 0.99
			position.velocity -= thruster_power
			if(position.velocity < 0)
				position.velocity = 0
	//TODO: Mark everything dirty when we rotate, as we change heading.
	SEND_SIGNAL(src, COMSIG_JS_OVERMAP_UPDATE, src)

/datum/overmap/proc/on_move()
	//TODO: Check translation for system layers if they exceed the tacmap bounds?
	return

//TODO: game coords to canvas coords! major desync issues, here.
/datum/overmap/process()
	position.x -= cos_r * position.velocity
	position.y -= sin_r * position.velocity
	physics2d.update()
	on_move()

/**
	Test the faction of the other ship. TRUE if the factions are the same.
*/
/datum/overmap/proc/test_faction(datum/overmap/OM)
	//NT alligned with civvies and SolGov.
	if(src.faction & OVERMAP_FACTION_NANOTRASEN)
		return OM.faction & OVERMAP_FACTION_NANOTRASEN || OM.faction & OVERMAP_FACTION_SOLGOV || OM.faction & OVERMAP_FACTION_CIVILIAN
	//Syndies and pirates are friends.
	if(src.faction & OVERMAP_FACTION_SYNDICATE || src.faction & OVERMAP_FACTION_PIRATE)
		return OM.faction & OVERMAP_FACTION_SYNDICATE || OM.faction & OVERMAP_FACTION_PIRATE
	//No idea what you are, sorry!
	return FALSE
