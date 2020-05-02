/obj/item/ammo_box/magazine/pdc/flak
	name = "40mm flak rounds"
	icon_state = "flak"
	ammo_type = /obj/item/ammo_casing/flak
	caliber = "mm40"
	max_ammo = 100

/obj/item/ammo_box/magazine/pdc/update_icon()
	if(ammo_count() > 10)
		icon_state = initial(icon_state)
	else
		icon_state = "[initial(icon_state)]_empty"

/obj/item/ammo_casing/flak
	name = "mm40 flak round casing"
	desc = "A 30.12x82mm bullet casing."
	projectile_type = /obj/item/projectile/bullet/pdc_round