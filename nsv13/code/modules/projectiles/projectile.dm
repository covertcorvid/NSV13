/obj/item/projectile
	var/datum/shape/collider2d = null //Our box collider. See the collision module for explanation
	var/datum/vector2d/position = null //Positional vector, used exclusively for collisions with overmaps
	var/list/collision_positions = null //The bounding box of this projectile.

/obj/item/projectile/proc/setup_collider()
	collision_positions = list(new /datum/vector2d(-2,16),\
										new /datum/vector2d(2,16),\
										new /datum/vector2d(2,-15),\
										new /datum/vector2d(-2,-15))
	position = new /datum/vector2d(x*32,y*32)
	collider2d = new /datum/shape(position, collision_positions, Angle) // -TORADIANS(src.angle-90)

/**

Method to check for whether this bullet should be colliding with an overmap object.


*/

/obj/item/projectile/proc/check_overmap_collisions()
	collider2d.set_angle(Angle) //Turn the box collider
	position._set(x * 32 + pixel_x, y * 32 + pixel_y)
	collider2d._set(position.x, position.y)
	for(var/obj/structure/overmap/OM in GLOB.overmap_objects)
		if(OM.z == z && OM.collider2d)
			if(src.collider2d.collides(OM.collider2d))
				if(!faction || faction != OM.faction) //Allow bullets to pass through friendlies
					Bump(OM) //Bang.

/obj/item/projectile/bullet/flak/Initialize(mapload, range=10)
	. = ..()
	steps_left = range
	RegisterSignal(src, COMSIG_MOVABLE_MOVED, .proc/check_range)

/obj/item/projectile/bullet/flak/proc/explode()
	new /obj/effect/flak_handler(get_turf(src))
	qdel(src)

/obj/item/projectile/bullet/flak/on_hit(atom/target, blocked = 0)
	explode()
	. = ..()

/obj/item/projectile/bullet/flak/proc/check_range()
	steps_left --
	if(steps_left <= 0)
		explode()

/obj/item/projectile/guided_munition/Crossed(atom/movable/AM) //Here, we check if the bullet that hit us is from a friendly ship. If it's from an enemy ship, we explode as we've been flak'd down.
	. = ..()
	if(istype(AM, /obj/item/projectile/))
		var/obj/item/projectile/proj = AM
		if(!ismob(firer) || !ismob(proj.firer)) //Unlikely to ever happen but if it does, ignore.
			return
		var/mob/checking = firer
		var/mob/enemy = proj.firer
		if(checking.overmap_ship && enemy.overmap_ship) //Firer is a mob, so check the faction of their ship
			var/obj/structure/overmap/OM = checking.overmap_ship
			var/obj/structure/overmap/our_ship = enemy.overmap_ship
			if(OM.faction != our_ship.faction)
				explode()
				return FALSE

/obj/item/projectile/guided_munition/ex_act(severity)
	explode()

/obj/item/projectile/guided_munition/proc/explode()
	if(firer)
		var/mob/checking = firer
		var/obj/structure/overmap/OM = checking.overmap_ship
		var/sound/chosen = pick('nsv13/sound/effects/ship/torpedo_detonate.ogg','nsv13/sound/effects/ship/freespace2/impacts/boom_2.wav','nsv13/sound/effects/ship/freespace2/impacts/boom_3.wav','nsv13/sound/effects/ship/freespace2/impacts/subhit.wav','nsv13/sound/effects/ship/freespace2/impacts/subhit2.wav','nsv13/sound/effects/ship/freespace2/impacts/m_hit.wav','nsv13/sound/effects/ship/freespace2/impacts/hit_1.wav')
		OM.relay_to_nearby(chosen)
	new shotdown_effect_type(get_turf(src)) //Exploding effect
	qdel(src)
	return FALSE