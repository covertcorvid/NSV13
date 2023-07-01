/**
	5-D vector for holding information about ship state.
	We can most definitely simplify this...
*/
/datum/vec5
	var/x = 0
	var/y = 0
	var/z = 0
	var/angle = 0
	var/datum/vector2d/velocity = null

/datum/vec5/New(x,y,z,angle,velocity_x, velocity_y)
	src.x = x
	src.y = y
	src.z = z
	src.angle = angle
	src.velocity = new /datum/vector2d(velocity_x, velocity_y)

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
	/// The level that this overmap object is attached to.
	/// All interactions are contained within this container.
	/// This can be null in the case that we do not belong to any map. This
	/// will represent an isolated ship instance with no external interactions.
	var/datum/overmap_level/map
	/// Position of the othermap object within the level.
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
	var/datum/component/overmap_ai_agent/ai_skynet3 = null
	var/ai_type = null
	var/list/damage_resistances = list()
	var/ai_controlled = FALSE
	var/interior_type = null///datum/component/overmap_interior
	var/datum/component/overmap_interior/interior = null
	var/integrity = 100
	var/max_integrity = 100
	var/list/armour_quadrants = null
	var/role = OVERMAP_ROLE_SECONDARY
	var/starting_system = "Staging"
	var/datum/star_system/current_system = null
	var/restitution = 1 //"bounciness", as used for collisions. 1 = boingy boingy, 0 = no boingy
	//Can this object be collided with?
	var/density = TRUE
	//All the keys the user is currently pressing.
	var/list/keys = list()
	var/last_combat_entered = 0
	var/inertial_dampeners = TRUE

	var/list/weapon_groups = list()


/**
	Constructor for overmap objects. Pre-bakes some maths for you and initialises processing.
*/
/datum/overmap/New(datum/overmap_level/map, x,y,z,angle,velocity_x, velocity_y)
	position = new /datum/vec5(x,y,z,angle,velocity_x, velocity_y)
	src.map = map
	if (map)
		map.register(src)
	if(collision_positions == null)
		collision_positions = GLOB.projectile_hitbox
	//If the overmap JS subsystem does not contain our type's icon, add it.
	var/icon/I = icon(icon,icon_state,SOUTH, frame=1)
	if(!SSJSOvermap.overmap_icons["[src.type]"])
		SSJSOvermap.overmap_icons["[src.type]"] = icon2base64(I)
		SEND_SIGNAL(SSJSOvermap, COMSIG_JS_OVERMAP_STATIC_DATA_UPDATE)

	//icon_base64 = SSJSOvermap.overmap_icons["[src.type]"]
	collision_radius = I.Width()
	//TODO this should inversely scale!
	//thruster_power = (mass / 10)
	//rotation_power = (mass / 10)

	thruster_power = 6 * (1 / (mass))
	rotation_power = thruster_power

	//todo maths shit to make the shit work.
	cos_r = cos(position.angle)
	sin_r = sin(position.angle)
	//TODO: Tie this into sensors subsystem!
	base_sensor_range = 2*(mass * 1000)
	physics2d = AddComponent(/datum/component/physics2d)
	if(ai_type)
		ai_skynet3 = AddComponent(ai_type)
	if(interior_type)
		interior = AddComponent(interior_type)
	physics2d.setup(collision_positions, angle, faction)
	//TODO: replace this.
	START_PROCESSING(SSJSOvermap, src)
	setup_armour()
	for(var/i = 0; i < 2; i++)
		new /datum/weapon_group(src)

//Stick any operations that require the starsystem to have instanced us here...
//Used by the grids system.
/datum/overmap/proc/PostInitialize()
	return

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


/datum/overmap/proc/fire_projectile(proj_angle = src.position.angle, datum/overmap/projectile/projectile_type=/datum/overmap/projectile/shell, burst_size=1)
	if (!map)
		CRASH("Overmap object with no map cannot fire projectiles.")
	//TODO: magic number "10".
	//We scromble the position so it originates from the centre of the ship.
	for(var/i = 1; i <= burst_size; i++)
		var/new_velocity_x = position.velocity.x + initial(projectile_type.speed) * cos(proj_angle)
		var/new_velocity_y = position.velocity.y + initial(projectile_type.speed) * sin(proj_angle)
		var/datum/overmap/projectile/O = new projectile_type(src.map, position.x + (collision_radius/2), position.y + (collision_radius/2), position.z, proj_angle, new_velocity_x, new_velocity_y)
		O.faction = faction
	//to_chat(world, "Fire missile.")

/datum/overmap/Destroy()
	QDEL_NULL(physics2d)
	map = null
	if (map)
		map.unregister(src)
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
		if(8)
			position.velocity.y -= thruster_power;
		if(2)
			position.velocity.y += thruster_power;
		if(4)
			position.velocity.x -= thruster_power;
		if(6)
			position.velocity.x += thruster_power;
		if(1)
			position.velocity.x += thruster_power * cos_r
			position.velocity.y += thruster_power * sin_r
		if(-1)
			//TODO: unrealistic, OK for now
			position.velocity.x *= 0.5
			position.velocity.y *= 0.5
			//position.velocity.x -= thruster_power * cos_r
			//position.velocity.y -= thruster_power * sin_r

			if(position.velocity.ln() < 0)
				position.velocity.x = 0
				position.velocity.y = 0
	//TODO: Mark everything dirty when we rotate, as we change heading.
	SEND_SIGNAL(SSJSOvermap, COMSIG_JS_OVERMAP_UPDATE, src)

/datum/overmap/proc/on_move()
	//TODO: Check translation for system layers if they exceed the tacmap bounds?
	return

//TODO: game coords to canvas coords! major desync issues, here.
/datum/overmap/process()
	handle_input()
	position.x += position.velocity.x //y is down but x points right as usual, so these have to be, er, this way.
	position.y += position.velocity.y
	physics2d.update()
	on_move()
	/*
	//TODO: broken!
	if(inertial_dampeners) //An optional toggle to make capital ships more "fly by wire" and help you steer in only the direction you want to go.
		var/fx = cos(90 - position.angle)
		var/fy = sin(90 - position.angle) //This appears to be a vector.
		var/sx = fy
		var/sy = -fx
		var/side_movement = (sx*position.velocity.x) + (sy*position.velocity.y)
		var/friction_impulse = (thruster_power)//((mass / 10) + thruster_power) //Weighty ships generate more space friction
		var/clamped_side_movement = CLAMP(side_movement, -friction_impulse, friction_impulse)
		position.velocity.x -= clamped_side_movement * sx
		position.velocity.y -= clamped_side_movement * sy
	*/

/datum/overmap/proc/handle_input()
	//Arrow keys..
	//Up
	if(keys["[38]"])
		thrust(8)
		return
	//Down
	if(keys["[40]"])
		thrust(2)
		return
	//Right
	if(keys["[39]"])
		thrust(6)
		return
	//Left
	if(keys["[37]"])
		thrust(4)
		return
	//W key (TODO: also arrow keys)
	if(keys["[87]"])
		thrust(1)
		return
	//ALT key
	if(keys["[18]"])
		thrust(-1)
		return
	//A
	if(keys["[68]"])
		rotate(1)
		return
	//D
	if(keys["[65]"])
		rotate(-1)
		return


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
