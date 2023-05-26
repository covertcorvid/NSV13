/* MESSAGE FOR THE NEXT POOR SOD TO STUMBLE UPON THIS SAD LITTLE THING WE CALL A SUBSYSTEM
--------------------------------------------------------------------------------------------
 * Collision detection hasn't been used in this subsystem for a while, expect to encounter unexpected behavior when re-implementing this
 * collission detection currently relies on deprecated C++ hooks in shape.dm, you'll need to either replace the hook with DM or use Rust to hook it with auxtools
 * godspeed o7.
*/

/// Max amount of objects we can have in a quadtree node before subdividing
#define MAX_OBJECTS_PER_NODE 15

PROCESSING_SUBSYSTEM_DEF(physics_processing)
	name = "Physics"
	wait = 1.5
	priority = FIRE_PRIORITY_PHYSICS
	stat_tag = "PHYS"
	var/list/physics_levels = list() // key = (string) z_level, value = list()
	var/datum/collision_response/c_response = new()

	var/list/tracked = list()
	var/RBcounter = 0
	var/rebuild_frequency = 10 // How many physics ticks between rebuilds

/datum/controller/subsystem/processing/physics_processing/proc/AddToChunk(datum/component/physics2d/P, list/chunk)
	var/_x = 1 + round((P.holder.collision_radius + P.holder.position.x) / 2000)
	var/_y = 1 + round((P.holder.collision_radius + P.holder.position.y) / 2000)
	to_chat(world, "Added to chunk: [_x], [_y]")
	P.last_chunk = chunk[_x][_y]
	P.last_chunk.Add(P)
	/*
	var/start_x = round(P.holder.position.x / JS_OVERMAP_TACMAP_TILE_SIZE)
	var/end_x = round((P.holder.collision_radius + P.holder.position.x) / JS_OVERMAP_TACMAP_TILE_SIZE)

	var/start_y = round(P.holder.position.y / JS_OVERMAP_TACMAP_TILE_SIZE)
	var/end_y = round((P.holder.collision_radius + P.holder.position.y) / JS_OVERMAP_TACMAP_TILE_SIZE)
	for(var/Y = start_y; Y <= end_y; Y++)
		var/list/row = chunk[Y]
		for(var/X = start_x; X <= end_x; X++)
			var/list/col = row[X]
			col += P
			P.last_chunk = col
			break;
	*/

//TODO: BROKEN!..?
/datum/controller/subsystem/processing/physics_processing/proc/AddToLevel(datum/component/physics2d/P, z)
	var/z_str = "[z]"
	if(!physics_levels[z_str])
		//Set up this grid.

		to_chat(world, "New physics level.")
		var/rows = (JS_OVERMAP_TACMAP_TOTAL_SQUARES)
		var/cols = (JS_OVERMAP_TACMAP_TOTAL_SQUARES)
		physics_levels[z_str] = new(cols)
		//TODO: test me
		for(var/y = 1; y <= rows; y++)
			var/list/row = new(rows)
			//L[y][x] = list()
			for(var/x = 1; x <= cols; x++)
				row[x] = list()
			physics_levels[z_str][y] = row
	AddToChunk(P, physics_levels[z_str])

/datum/controller/subsystem/processing/physics_processing/proc/RemoveFromLevel(datum/component/physics2d/P, z)
	if(P.last_chunk)
		P.last_chunk -= P
	//TODO: can free up the memory here, if we want?? assuming nothing else lives here.

/datum/controller/subsystem/processing/physics_processing/proc/UpdateChunk(datum/component/physics2d/P, z)
	var/z_str = "[z]"
	var/list/chunk = physics_levels[z_str]
	var/_x = 1 + round((P.holder.collision_radius + P.holder.position.x) / 2000)
	var/_y = 1 + round((P.holder.collision_radius + P.holder.position.y) / 2000)
	var/next_chunk = chunk[_x][_y]
	if(next_chunk != P.last_chunk)
		to_chat(world, "New chunk: [_x],[_y]")
		if(P.last_chunk)
			P.last_chunk -= P
		AddToChunk(P, chunk)

/datum/controller/subsystem/processing/physics_processing/fire(resumed)
	for(var/datum/component/physics2d/body as() in tracked)
		for(var/datum/component/physics2d/neighbour as() in body.last_chunk)
			if(neighbour == body)
				continue
			if(body.collide(neighbour))
				SEND_SIGNAL(SSJSOvermap, COMSIG_JS_OVERMAP_UPDATE, body.holder)
				//to_chat(world, "BONK")
			//Okay, we can in theory collide. Perform the more expensive calculations and find out whether we do.
			//if(IS_OVERMAP_JS_COLLISION_RESPONSE_ELIGIBLE(body.holder) && IS_OVERMAP_JS_COLLISION_RESPONSE_ELIGIBLE(neighbour.holder))
			//	if(body.collide(neighbour, c_response))
			//		SEND_SIGNAL(SSJSOvermap, COMSIG_JS_OVERMAP_UPDATE, body.holder)
			//		to_chat(world, "BONK")


	//Do processing.
	if(!resumed)
		. = ..()
		if(MC_TICK_CHECK)
			return



/datum/component/physics2d
	var/datum/overmap/holder = null
	var/datum/shape/collider2d = null //Our box collider. See the collision module for explanation
	//var/matrix/vector/position = null //Positional vector, used exclusively for collisions with overmaps
	var/last_registered_z = 0
	var/faction = null
	var/list/last_chunk = null

	// rounded to multiple of JS_OVERMAP_TACMAP_TILE_SIZE (changes every tacmap tile)
	var/last_x_clamped
	var/last_y_clamped
	var/next_chunk_update = 0

/datum/component/physics2d/Initialize()
	. = ..()
	holder = parent
	SSphysics_processing.tracked += src
	if(!istype(holder))
		return COMPONENT_INCOMPATIBLE //Precondition: This is a subtype of atom/movable.
	last_registered_z = holder.position.z
	RegisterSignal(holder, COMSIG_MOVABLE_Z_CHANGED, PROC_REF(update_z))

/datum/component/physics2d/Destroy(force, silent)

	//Stop fucking referencing this I sweAR
	if(holder)
		UnregisterSignal(holder, COMSIG_MOVABLE_Z_CHANGED)
	if(last_chunk)
		last_chunk.Remove(src)
	//De-alloc references.
	//QDEL_NULL(collider2d)
	//QDEL_NULL(position)
	SSphysics_processing.tracked -= src
	return ..()

/datum/component/physics2d/proc/setup(list/hitbox, angle, faction)
	src.faction = faction
	last_registered_z = holder.position.z
	last_x_clamped = round(holder.position.x, JS_OVERMAP_TACMAP_TILE_SIZE)
	last_y_clamped = round(holder.position.y, JS_OVERMAP_TACMAP_TILE_SIZE)
	SSphysics_processing.AddToLevel(src, holder.position.z)

/// Uses pixel coordinates
/datum/component/physics2d/proc/update()
	if(world.time >= next_chunk_update)
		SSphysics_processing.UpdateChunk(src, holder.position.z)
		next_chunk_update = world.time + 0.5 SECONDS

/datum/component/physics2d/proc/update_z()
	if(holder.position.z != last_registered_z) //Z changed? Update this unit's processing chunk.
		if(!holder.position.z) // Something terrible has happened. Kill ourselves to prevent runtime spam
			qdel(src)
			message_admins("WARNING: [holder] has been moved out of bounds. Deleting physics component.")
			CRASH("Physics component holder located in nullspace.")
		SSphysics_processing.RemoveFromLevel(src, holder.position.z)
		last_registered_z = holder.position.z
		SSphysics_processing.AddToLevel(src, holder.position.z)

//If the angle delta between the holder overmap and its collider is less than this,
//we don't bother to do expensive recalc.
#define PHYSICS_PRECISION_IDGAF 5

//TODO: Center this?
//datum/component/physics2d/proc/test_aabb(/datum/component/physics2d/O)
//	return holder.position.x < O.holder.position.x + O.holder.collision_radius && holder.position.x + holder.collision_radius > O.holder.position.x && holder.position.y < O.holder.position.y + O.holder.collision_radius && holder.position.y + holder.collision_radius > O.holder.position.y
/datum/component/physics2d/proc/collides(datum/component/physics2d/P)
	var/dx = holder.position.x - P.holder.position.x;
	var/dy = holder.position.y - P.holder.position.y;
	var/distance = sqrt(dx * dx + dy * dy);

	return (distance < holder.collision_radius + P.holder.collision_radius)

/datum/component/physics2d/proc/can_collide(datum/component/physics2d/P)
	//Is a collision even possible here?
	return !(P.holder.test_faction(holder)) && collides(P)


#undef PHYSICS_PRECISION_IDGAF

/datum/component/physics2d/proc/collide(datum/component/physics2d/other, datum/collision_response/c_response, collision_velocity)
	if(!can_collide(other))
		return FALSE


	var/src_vel_mag = holder.position.velocity
	var/other_vel_mag = other.holder.position.velocity
	//I mean, the angle between the two objects is very likely to be the angle of incidence innit
	var/col_angle = ATAN2((other.holder.position.x + other.holder.collision_radius / 2) - (src.holder.position.x + src.holder.collision_radius / 2), (other.holder.position.y + other.holder.collision_radius / 2) - (src.holder.position.y + holder.collision_radius / 2))
	//Bullets behave differently.
	if(IS_OVERMAP_JS_PROJECTILE(holder))
		other.holder.bullet_act(holder, col_angle)
		return TRUE
	//Debounce
	if(((cos(holder.position.angle - col_angle) * src_vel_mag) - (cos(other.holder.position.angle - col_angle) * other_vel_mag)) < 0)
		return

	// Elastic collision equations
	var/new_src_vel_x = ((																			\
		(src_vel_mag * cos(holder.position.angle - col_angle) * (src.holder.mass - other.holder.mass)) +			\
		(2 * other.holder.mass * other_vel_mag * cos(other.holder.position.angle - col_angle))					\
	) / (src.holder.mass + other.holder.mass)) * cos(col_angle) + (src_vel_mag * sin(holder.position.angle - col_angle) * cos(col_angle + 90))

	var/new_src_vel_y = ((																			\
		(src_vel_mag * cos(holder.position.angle - col_angle) * (src.holder.mass - other.holder.mass)) +			\
		(2 * other.holder.mass * other_vel_mag * cos(other.holder.position.angle - col_angle))					\
	) / (src.holder.mass + other.holder.mass)) * sin(col_angle) + (src_vel_mag * sin(holder.position.angle - col_angle) * sin(col_angle + 90))

	var/new_other_vel_x = ((																		\
		(other_vel_mag * cos(other.holder.position.angle - col_angle) * (other.holder.mass - src.holder.mass)) +		\
		(2 * src.holder.mass * src_vel_mag * cos(holder.position.angle - col_angle))						\
	) / (other.holder.mass + src.holder.mass)) * cos(col_angle) + (other_vel_mag * sin(other.holder.position.angle - col_angle) * cos(col_angle + 90))

	var/new_other_vel_y = ((																		\
		(other_vel_mag * cos(other.holder.position.angle - col_angle) * (other.holder.mass - src.holder.mass)) +		\
		(2 * src.holder.mass * src_vel_mag * cos(holder.position.angle - col_angle))						\
	) / (other.holder.mass + src.holder.mass)) * sin(col_angle) + (other_vel_mag * sin(other.holder.position.angle - col_angle) * sin(col_angle + 90))

	//TODO: NAIVE! I broke this with overmap JS
	//src.velocity._set(new_src_vel_x, new_src_vel_y)
	//other.velocity._set(new_other_vel_x, new_other_vel_y)
	holder.position.x += new_src_vel_x
	holder.position.y += new_src_vel_y
	other.holder.position.x += new_other_vel_x
	other.holder.position.y += new_other_vel_y
	//var/bonk = src_vel_mag//How much we got bonked
	//var/bonk2 = other_vel_mag //Vs how much they got bonked
	//Prevent ultra spam.
	//if(!impact_sound_cooldown && (bonk > 2 || bonk2 > 2))
		//bonk *= 5 //The rammer gets an innate penalty, to discourage ramming metas.
		//bonk2 *= 5
		//take_quadrant_hit(bonk, projectile_quadrant_impact(other)) //This looks horrible, but trust me, it isn't! Probably!. Armour_quadrant.dm for more info
		//other.take_quadrant_hit(bonk2, projectile_quadrant_impact(src)) //This looks horrible, but trust me, it isn't! Probably!. Armour_quadrant.dm for more info

		//log_game("[key_name(pilot)] has impacted an overmap ship into [other] with velocity [bonk]")

	return TRUE
