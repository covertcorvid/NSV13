//All credit goes to Goonstation's 2020 release for these explosion sprites, thanks goons!//

/obj/effect/temp_visual/impact_effect/torpedo
	icon = 'nsv13/goonstation/icons/effects/explosions/60x60.dmi'
	icon_state = "explosion"
	duration = 2 SECONDS

/obj/effect/temp_visual/impact_effect/torpedo/Initialize()
	var/states = list("explosion", "explosion2")
	icon_state = pick(states)
	. = ..()

/obj/effect/temp_visual/overmap_explosion
	icon = 'nsv13/goonstation/icons/hugeexplosion.dmi'
	icon_state = "explosion"
	duration = 10

/obj/effect/temp_visual/overmap_explosion/alt
	icon = 'nsv13/goonstation/icons/hugeexplosion2.dmi'
	icon_state = "explosion"
	duration = 10

/obj/effect/temp_visual/nuke_impact
	icon = 'nsv13/goonstation/icons/effects/explosions/224x224.dmi'
	icon_state = "explosion"
	duration = 5 SECONDS
	pixel_x = -96
	pixel_y = -96

/obj/effect/temp_visual/flak
	icon = 'nsv13/goonstation/icons/effects/explosions/80x80.dmi'
	icon_state = "explosion"
	duration = 2 SECONDS
	pixel_x = -32
	pixel_y = -32
	var/flak_range = 2 //AOE where flak hits torpedoes. May need to buff this a bit.

//Small object to make flak "flicker" a bit. Kills itself after spawning flak
/obj/effect/flak_handler/Initialize()
	. = ..()
	for(var/I = 0, I < rand(2,5), I++)
		var/edir = pick(GLOB.alldirs)
		new /obj/effect/temp_visual/flak(get_turf(get_step(src, edir)))
		sleep(rand(0, 2))
	return INITIALIZE_HINT_QDEL

/obj/effect/temp_visual/flak/Initialize()
	if(prob(50))
		icon = 'nsv13/goonstation/icons/effects/explosions/96x96.dmi'
	for(var/obj/X in view(flak_range, src))
		var/severity = flak_range-get_dist(X, src)
		if(istype(X, /obj/structure))
			X.take_damage(severity*10, damage_type = BRUTE)
		else
			X.ex_act(severity)
	. = ..()

/obj/weapon_overlay
	name = "Weapon overlay"
	layer = 4
	mouse_opacity = FALSE
	layer = WALL_OBJ_LAYER
	var/angle = 0 //Debug

/obj/weapon_overlay/proc/do_animation()
	return

/obj/weapon_overlay/railgun //Railgun sits on top of the ship and swivels to face its target
	name = "Railgun"
	icon_state = "railgun"

/obj/weapon_overlay/railgun_overlay/do_animation()
	flick("railgun_charge",src)

/obj/weapon_overlay/laser
	name = "Laser cannon"
	icon = 'icons/obj/hand_of_god_structures.dmi'
	icon_state = "conduit-red"

/obj/weapon_overlay/laser/do_animation()
	flick("laser",src)