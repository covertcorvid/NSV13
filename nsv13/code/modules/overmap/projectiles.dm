/obj/item/projectile/bullet/pdc_round
	icon_state = "pdc"
	name = "teflon coated tungsten round"
	damage = 5

/obj/item/projectile/bullet/railgun_slug
	icon_state = "railgun"
	name = "hyper accelerated tungsten slug"
	damage = 80
	movement_type = FLYING | UNSTOPPABLE //Railguns punch straight through your ship
	impact_effect_type = /obj/effect/temp_visual/impact_effect/torpedo

/obj/item/projectile/bullet/gauss_slug
	icon_state = "gaussgun"
	name = "tungsten round"
	damage = 20
	impact_effect_type = /obj/effect/temp_visual/impact_effect/torpedo

/obj/item/projectile/bullet/light_cannon_round
	icon_state = "pdc"
	name = "light cannon round"
	damage = 10
//	flag = "overmap_light"

/obj/item/projectile/bullet/heavy_cannon_round
	icon_state = "pdc"
	name = "heavy cannon round"
	damage = 20
//	flag = "overmap_heavy"

/obj/item/projectile/guided_munition/missile
	icon_state = "torpedo"
	name = "conventional missile"
	speed = 3
	damage = 50
	valid_angle = 90
	homing_turn_speed = 5
	range = 250
//	flag = "overmap_light"
	impact_effect_type = /obj/effect/temp_visual/impact_effect/torpedo

/obj/item/projectile/guided_munition/torpedo
	icon_state = "torpedo"
	name = "plasma torpedo"
	speed = 1
	valid_angle = 120
	homing_turn_speed = 5
	damage = 100
	range = 250
//	flag = "overmap_heavy"
	impact_effect_type = /obj/effect/temp_visual/impact_effect/torpedo

/obj/item/projectile/guided_munition/torpedo/on_hit(atom/target, blocked = FALSE)
	..()
	if(isovermap(target))
		var/obj/structure/overmap/OM = target
		OM.torpedoes_to_target -= src
	else
		explosion(target, 2, 4, 4)
	return BULLET_ACT_HIT

/obj/item/projectile/guided_munition/torpedo/ex_act(severity)
	explode()

// FLAK
/obj/item/projectile/bullet/flak
	icon_state = "flak"
	name = "flak round"
	damage = 2
	alpha = 0
	var/steps_left = 0 //Flak range, AKA how many tiles can we move before we go kaboom

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
