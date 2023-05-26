


/datum/overmap/projectile
	mass = MASS_TINY
	name = "overmap projectile"
	icon = 'nsv13/icons/obj/projectiles_nsv.dmi'
	icon_state = "pdc"
	base_sensor_range = 0
	//Projectile specific bits...
	var/damage = 10
	/**
		Percentile chance for a bullet to ignore armour entirely and penetrate through.
	*/
	var/armour_penetration_factor = 0
	var/damage_type = OVERMAP_DAMAGE_TYPE_KINETIC_SUBCAPITAL
	var/unstoppable = FALSE
	///Distance this projectile may travel before it's auto-deleted / culled.
	var/range = 1 KM
	var/distance_travelled = 0

/datum/overmap/projectile/on_move()
	..()
	distance_travelled += position.velocity
	if(distance_travelled > range)
		qdel(src)

/datum/overmap/projectile/proc/on_hit(datum/overmap/target, angle)
	var/resistance = target.damage_resistances[damage_type]
	//If we have no resistance, OR the bullet rolls for full armour pen...
	//Yep this is definitely how AP works, stupid? I dunno! see take_quadrant_hit too!
	if(!resistance || prob(armour_penetration_factor))
		resistance = 0
	var/amount = abs(damage - (damage * (resistance / 100)))
	if(target.take_quadrant_hit(src, amount, angle))
		return
	//Do we have an interior? If so, let that handle the hit!
	if(target.interior)
		return target.interior.take_damage(src, angle)

	. = target.take_damage(amount, damage_type)
	//Unstoppable projectiles rip straight through everything. IE: railgun slugs. Line 'em up!
	if(!unstoppable)
		qdel(src)

/**
	Attempt to absorb a bullet's damage into the ship's armour quadrants.
	Returns TRUE if the shot was blocked.
*/
/datum/overmap/proc/take_quadrant_hit(datum/overmap/projectile/P, amount, angle)
	//The shot bypassed the armour entirely. This is totes how AP works ;)
	//@Karmic, todo definitely here.. this is stupid(?) I don't know!
	if(prob(P.armour_penetration_factor))
		return FALSE
	//TODO: Armour quadrants logic goes here!
	return FALSE

/**
	What happens when an overmap object physically takes damage, from any source.
*/
/datum/overmap/proc/take_damage(amount, damage_type)
	integrity -= amount
	if(integrity <= 0)
		explode()

/**
	What happens when an enemy ship explodes?
	Physically only possible for overmap vessels WITHOUT interiors.
*/
/datum/overmap/proc/explode()
	qdel(src)

/datum/overmap/proc/bullet_act(datum/overmap/projectile/P, angle)
	SEND_SIGNAL(src, COMSIG_ATOM_BULLET_ACT, P, angle)
	. = P.on_hit(src, angle)

/datum/overmap/proc/ex_act(severity)
