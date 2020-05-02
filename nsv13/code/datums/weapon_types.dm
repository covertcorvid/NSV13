/**
 * Common information used by both the hero ship and the fighters/AIs
 * Default values are for AI ships
 */
/datum/ship_weapon
	var/name = "Ship weapon"
	var/default_projectile_type
	var/burst_size = 1 // How many projectiles to fire at a time
	var/fire_delay = 1 SECONDS // How long the ship has to wait between shots
	var/range_modifier = 0 // Modification to the overmaps default range
	var/lateral = TRUE      // "Lateral" means that your ship doesnt have to face the target

	var/select_alert // Text to show when weapon is cycled to
	var/failure_alert // Text to show when weapon cannot fire
	var/list/overmap_firing_sounds
	var/overmap_select_sound

	var/gunner_controlled = TRUE // Can the weapon be controlled with the firing console?
								 // Set FALSE for automated or crewed weapons. AIs ignore this.
	var/requires_linked = FALSE // Does this weapon need an object to work?
								// Mapped weapons and fighter payloads
	var/obj/linked // Linked object if requires_linked is true

	// Using a firing zone will override facing_degrees and firing_arc_width
	var/firing_zone // Port (left), starboard (behind), ahead (front), astern (back), or omnidirectional
	var/facing_degrees // Center of the firing arc based on degrees from the nose of the ship, going clockwise
	var/firing_arc_width // Full width of the firing arc in degrees. 360 is omnidirectional

	var/ammo = -1 // How many bullets we have left. Updated externally, -1 means infinite
	var/next_sound = 0

/datum/ship_weapon/railgun
	name = "Electromagnetic railguns"
	default_projectile_type = /obj/item/projectile/bullet/railgun_slug
	burst_size = 1
	fire_delay = 1 SECONDS
	range_modifier = 30
	select_alert = "<span class='notice'>Charging railgun hardpoints...</span>"
	failure_alert = "<span class='warning'>DANGER: Launch failure! Railgun systems are not loaded.</span>"
	overmap_firing_sounds = list('nsv13/sound/effects/ship/railgun_fire.ogg')
	overmap_select_sound = 'nsv13/sound/effects/ship/railgun_ready.ogg'
	firing_zone = FIRE_ZONE_OMNIDIRECTIONAL

/datum/ship_weapon/torpedo_launcher
	name = "Torpedo tubes"
	default_projectile_type = /obj/item/projectile/guided_munition/torpedo
	burst_size = 1
	fire_delay = 0.5 SECONDS
	range_modifier = 30
	select_alert = "<span class='notice'>Torpedo target acquisition systems: online.</span>"
	failure_alert = "<span class='warning'>DANGER: Launch failure! Torpedo tubes are not loaded.</span>"
	overmap_firing_sounds = list(
		'nsv13/sound/effects/ship/torpedo.ogg',
		'nsv13/sound/effects/ship/freespace2/m_shrike.wav',
		'nsv13/sound/effects/ship/freespace2/m_stiletto.wav',
		'nsv13/sound/effects/ship/freespace2/m_tsunami.wav',
		'nsv13/sound/effects/ship/freespace2/m_wasp.wav')
	overmap_select_sound = 'nsv13/sound/effects/ship/reload.ogg'
	firing_zone = FIRE_ZONE_OMNIDIRECTIONAL
	var/torp_speed = 1

/datum/ship_weapon/torpedo_launcher/proc/set_torpedo_vars(obj/item/ship_weapon/ammunition/torpedo/T)
	default_projectile_type = T.projectile_type
	torp_speed = T.speed

/datum/ship_weapon/torpedo_launcher/fire_projectile(obj/structure/overmap/source, atom/target)
	if(istype(default_projectile_type, /obj/item/projectile/bullet/torpedo/dud)) //Some brainlet MAA loaded an incomplete torp
		source.fire_projectile(default_projectile_type, target, homing=FALSE, speed=torp_speed, explosive=TRUE)
	else
		source.fire_projectile(default_projectile_type, target, homing=TRUE, speed=torp_speed, explosive=TRUE)

/datum/ship_weapon/torpedo_launcher/on_map
	requires_linked = TRUE
	max_ammo = 1
	ammo = 0

/datum/ship_weapon/torpedo_launcher/on_map/fire_projectile(obj/structure/overmap/source, atom/target)
	message_admins("Animating a torpedo")
	if(linked && istype(linked, /obj/machinery/ship_weapon/torpedo_launcher))
		message_admins("Got the launcher")
		var/obj/machinery/ship_weapon/torpedo_launcher/TL = linked
		if(TL.chambered)
			message_admins("Got the chambered round")
			var/obj/item/ship_weapon/ammunition/torpedo/T = TL.chambered
			if(istype(T))
				message_admins("Firing a [T]")
				set_torpedo_vars(T)
	..()

/datum/ship_weapon/torpedo_launcher/fighter
	max_ammo = 6
	ammo = 6

/datum/ship_weapon/torpedo_launcher/fighter/fire_projectile(obj/structure/overmap/fighter/source, atom/target)
	if(istype(source) && (source.munitions.len))
		var/obj/item/ship_weapon/ammunition/torpedo/T = pick(source.munitions)
		message_admins("Firing a [T]")
		set_torpedo_vars(T)
		source.munitions -= T
		qdel(T)
	..()

/datum/ship_weapon/pdc_mount
	name = "Point defense guns"
	default_projectile_type = /obj/item/projectile/bullet/pdc_round
	burst_size = 3
	fire_delay = 0
	range_modifier = 0
	overmap_select_sound = 'nsv13/sound/effects/ship/pdc_start.ogg'
	overmap_firing_sounds = list('nsv13/sound/effects/ship/pdc.ogg',
		'nsv13/sound/effects/ship/pdc2.ogg',
		'nsv13/sound/effects/ship/pdc3.ogg')
	select_alert = "<span class='notice'>Activating point defense emplacements..</span>"
	failure_alert = "<span class='warning'>DANGER: Point defense emplacements are unable to fire due to lack of ammunition.</span>"
	firing_zone = FIRE_ZONE_OMNIDIRECTIONAL

/datum/ship_weapon/pdc_mount/on_map
	gunner_controlled = TRUE // TODO: make false
	requires_linked = TRUE
+	select_alert = "<span class='notice'>Activating point defense emplacements..</span>"
+	failure_alert = "<span class='warning'>DANGER: Point defense emplacements are unable to fire due to lack of ammunition.</span>"

/datum/ship_weapon/pdc_mount/fighter
	lateral = FALSE

/datum/ship_weapon/missile_launcher
	default_projectile_type = /obj/item/projectile/guided_munition/missile
	burst_size = 1
	fire_delay = 5
	range_modifier = 30
	select_alert = "<span class='notice'>Missile target acquisition systems: online.</span>"
	failure_alert = "<span class='warning'>DANGER: Launch failure! Missile racks are not loaded.</span>"
	overmap_firing_sounds = list(
		'nsv13/sound/effects/ship/torpedo.ogg',
		'nsv13/sound/effects/ship/freespace2/m_shrike.wav',
		'nsv13/sound/effects/ship/freespace2/m_stiletto.wav',
		'nsv13/sound/effects/ship/freespace2/m_tsunami.wav',
		'nsv13/sound/effects/ship/freespace2/m_wasp.wav')
	overmap_select_sound = 'nsv13/sound/effects/ship/reload.ogg'

/datum/ship_weapon/light_cannon
	default_projectile_type = /obj/item/projectile/bullet/light_cannon_round
	burst_size = 3
	fire_delay = 0
	range_modifier = 0
	overmap_select_sound = 'nsv13/sound/effects/ship/pdc_start.ogg'
	overmap_firing_sounds = list('nsv13/sound/effects/ship/pdc.ogg',
		'nsv13/sound/effects/ship/pdc2.ogg',
		'nsv13/sound/effects/ship/pdc3.ogg')
	select_alert = "<span class='notice'>Cannon selected. DRADIS assisted targeting: online.</span>"
	failure_alert = "<span class='warning'>DANGER: Cannon ammunition reserves are depleted.</span>"

/datum/ship_weapon/heavy_cannon
	default_projectile_type = /obj/item/projectile/bullet/heavy_cannon_round
	burst_size = 3
	fire_delay = 0
	range_modifier = 0
	overmap_select_sound = 'nsv13/sound/effects/ship/pdc_start.ogg'
	overmap_firing_sounds = list('nsv13/sound/effects/ship/pdc.ogg',
		'nsv13/sound/effects/ship/pdc2.ogg',
		'nsv13/sound/effects/ship/pdc3.ogg')
	select_alert = "<span class='notice'>Cannon selected. DRADIS assisted targeting: online..</span>"
	failure_alert = "<span class='warning'>DANGER: Cannon ammunition reserves are depleted.</span>"

/datum/ship_weapon/search_rescue_scoop //not currently enabled
	default_projectile_type = /obj/item/projectile/bullet/pdc_round
	burst_size = 0
	fire_delay = 0
	range_modifier = 0
	overmap_select_sound = 'nsv13/sound/effects/ship/pdc_start.ogg'
	overmap_firing_sounds = list('nsv13/sound/effects/ship/pdc.ogg',
		'nsv13/sound/effects/ship/pdc2.ogg',
		'nsv13/sound/effects/ship/pdc3.ogg')
	select_alert = "<span class='warning'>Feature Not Currently Enabled.</span>"
	failure_alert = "<span class='warning'>Feature Not Currently Enabled.</span>"

/datum/ship_weapon/search_rescue_extractor //not currently enabled
	default_projectile_type = /obj/item/projectile/bullet/pdc_round
	burst_size = 0
	fire_delay = 0
	range_modifier = 0
	overmap_select_sound = 'nsv13/sound/effects/ship/pdc_start.ogg'
	overmap_firing_sounds = list('nsv13/sound/effects/ship/pdc.ogg',
		'nsv13/sound/effects/ship/pdc2.ogg',
		'nsv13/sound/effects/ship/pdc3.ogg')
	select_alert = "<span class='warning'>Feature Not Currently Enabled.</span>"
	failure_alert = "<span class='warning'>Feature Not Currently Enabled.</span>"

/datum/ship_weapon/rapid_breach_sealing_welder //not currently enabled
	default_projectile_type = /obj/item/projectile/bullet/pdc_round
	burst_size = 0
	fire_delay = 0
	range_modifier = 0
	overmap_select_sound = 'nsv13/sound/effects/ship/pdc_start.ogg'
	overmap_firing_sounds = list('nsv13/sound/effects/ship/pdc.ogg',
		'nsv13/sound/effects/ship/pdc2.ogg',
		'nsv13/sound/effects/ship/pdc3.ogg')
	select_alert = "<span class='warning'>Feature Not Currently Enabled.</span>"
	failure_alert = "<span class='warning'>Feature Not Currently Enabled.</span>"

/datum/ship_weapon/rapid_breach_sealing_foam //not currently enabled
	default_projectile_type = /obj/item/projectile/bullet/pdc_round
	burst_size = 0
	fire_delay = 0
	range_modifier = 0
	overmap_select_sound = 'nsv13/sound/effects/ship/pdc_start.ogg'
	overmap_firing_sounds = list('nsv13/sound/effects/ship/pdc.ogg',
		'nsv13/sound/effects/ship/pdc2.ogg',
		'nsv13/sound/effects/ship/pdc3.ogg')
	select_alert = "<span class='warning'>Feature Not Currently Enabled.</span>"
	failure_alert = "<span class='warning'>Feature Not Currently Enabled.</span>"

/datum/ship_weapon/refueling_system //not currently enabled
	default_projectile_type = /obj/item/projectile/bullet/pdc_round
	burst_size = 0
	fire_delay = 0
	range_modifier = 0
	overmap_select_sound = 'nsv13/sound/effects/ship/pdc_start.ogg'
	overmap_firing_sounds = list('nsv13/sound/effects/ship/pdc.ogg',
		'nsv13/sound/effects/ship/pdc2.ogg',
		'nsv13/sound/effects/ship/pdc3.ogg')
	select_alert = "<span class='warning'>Feature Not Currently Enabled.</span>"
	failure_alert = "<span class='warning'>Feature Not Currently Enabled.</span>"

//You don't ever actually select this. Crew act as gunners.

/datum/ship_weapon/gauss
	name = "Gauss guns"
	default_projectile_type = /obj/item/projectile/bullet/gauss_slug
	burst_size = 2
	fire_delay = 20 SECONDS
	range_modifier = 20
	select_alert = "<span class='notice'>Activating gauss weapon systems...</span>"
	failure_alert = "<span class='warning'>DANGER: Gauss gun systems not loaded.</span>"
	overmap_firing_sounds = list('nsv13/sound/effects/ship/gauss.ogg')
	overmap_select_sound = 'nsv13/sound/effects/ship/railgun_ready.ogg'
	firing_zone = FIRE_ZONE_OMNIDIRECTIONAL

/datum/ship_weapon/gauss/on_map
	fire_delay = 1 SECONDS
	requires_linked = TRUE

/datum/ship_weapon/gauss/can_fire(obj/structure/overmap/OM)
	if(OM.mass <= MASS_MEDIUM) //This is for big boys only.
		return FALSE
	return ..()

/datum/ship_weapon/flak
	name = "Flak cannon"
	default_projectile_type = /obj/item/projectile/bullet/gauss_slug
	burst_size = 1
	fire_delay = 5 SECONDS
	range_modifier = 30
	overmap_select_sound = 'nsv13/sound/effects/ship/freespace2/computer/escape.wav'
	overmap_firing_sounds = list('nsv13/sound/effects/ship/flak/flakhit1.ogg','nsv13/sound/effects/ship/flak/flakhit2.ogg','nsv13/sound/effects/ship/flak/flakhit3.ogg')
	select_alert = "<span class='notice'>Defensive flak screens: <b>OFFLINE</b>. Activating manual flak control.</span>"
	failure_alert = "<span class='warning'>DANGER: flak guns unable to fire due to lack of ammunition.</span>"
	firing_zone = FIRE_ZONE_OMNIDIRECTIONAL

/datum/ship_weapon/flak/fire_projectile(obj/structure/overmap/source, atom/target, speed=null)
	if(!target)
		target = source
	var/flak_range = source.get_flak_range(target)

	var/turf/T = get_turf(source)
	var/obj/item/projectile/proj = new /obj/item/projectile/bullet/flak(T, flak_range)
	proj.starting = T
	if(source.gunner)
		proj.firer = source.gunner
	else
		proj.firer = source
	proj.def_zone = "chest"
	proj.original = target
	proj.pixel_x = round(source.pixel_x)
	proj.pixel_y = round(source.pixel_y)
	var/theangle = Get_Angle(source,target)
	spawn()
		proj.fire(theangle)
		ammo -= 1
		if(speed)
			proj.set_pixel_speed(speed)