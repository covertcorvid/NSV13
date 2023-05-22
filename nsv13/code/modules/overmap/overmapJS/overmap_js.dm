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

/**
	Constructor for overmap objects. Pre-bakes some maths for you and initialises processing.
*/
/datum/overmap/New(x,y,z,angle,velocity)
	position = new /datum/vec5(x,y,z,angle,velocity)
	icon_base64 = icon2base64(icon(icon, icon_state, frame=1))
	//TODO this should inversely scale!
	thruster_power = (mass / 10)
	rotation_power = (mass / 10)
	//todo maths shit to make the shit work.
	cos_r = cos(position.angle)
	sin_r = sin(position.angle)
	//TODO: Tie this into sensors subsystem!
	base_sensor_range = 2*(mass * 1000)
	//TODO: replace this.
	START_PROCESSING(SSJSOvermap, src)

/datum/overmap/proc/fire_projectile(angle = src.position.angle)
	//TODO: magic number "10".
	//We scromble the position so it originates from the centre of the ship.
	SSJSOvermap.register(new /datum/overmap/projectile(position.x + (collision_radius/2),position.y + (collision_radius/2), position.z, angle, position.velocity+10))
	//to_chat(world, "Fire missile.")

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
			position.velocity *= 0.99
	//TODO: Mark everything dirty when we rotate, as we change heading.
	SEND_SIGNAL(src, COMSIG_JS_OVERMAP_UPDATE, src)

//TODO: game coords to canvas coords! major desync issues, here.
/datum/overmap/process()
	position.x -= cos_r * position.velocity
	position.y -= sin_r * position.velocity
