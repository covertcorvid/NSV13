/obj/machinery/ship_weapon/pdc_mount/flak
	name = "Flak loading rack"
	icon = 'nsv13/icons/obj/munitions.dmi'
	icon_state = "pdc"
	desc = "Seegson's all-in-one PDC targeting computer, ammunition loader, and human interface has proven extremely popular in recent times. It's rare to see a ship without one of these."
	anchored = TRUE
	density = FALSE
	pixel_y = 26
	maintainable = FALSE
	bang = FALSE

//	circuit = /obj/item/circuitboard/machine/pdc_mount

	fire_mode = FIRE_MODE_FLAK
	weapon_type = new/datum/ship_weapon/flak/on_map
	magazine_type = /obj/item/ammo_box/magazine/pdc/flak

	auto_load = TRUE
	semi_auto = TRUE
	maintainable = FALSE
	max_ammo = 100

	// We're fully automatic, so just the loading sound is enough
	mag_load_sound = 'sound/weapons/autoguninsert.ogg'
	mag_unload_sound = 'sound/weapons/autoguninsert.ogg'
	feeding_sound = null
	fed_sound = null
	chamber_sound = null

	load_delay = 50
	unload_delay = 50

	// No added delay between shots or for feeding rounds
	feed_delay = 0
	chamber_delay_rapid = 0
	chamber_delay = 0
	bang = FALSE
