/datum/techweb_node/ship_shield_tech
	id = "ship_shield_tech"
	display_name = "Experimental Shield Technology"
	description = "Highly experimental shield technology to vastly increase survivability in ships. Although Nanotrasen researchers have had access to this technology for quite some time, the incredible amount of power required to maintain shields has proven to be the greatest challenge in implementing them."
	design_ids = list("shield_fan", "shield_capacitor", "shield_modulator", "shield_interface", "shield_frame")
	research_costs = list(TECHWEB_POINT_TYPE_GENERIC = 1000)
	export_price = 5000
	hidden = TRUE

/datum/techweb_node/ship_armour_tech
	id = "ship_armour_tech"
	display_name = "Experimental Nano-Repair Technology"
	description = "Devices that alter the operational parameters of the APNW. May void the warranty."
	design_ids = list("apnw_oc_power", "apnw_oc_load", "apnw_oc_cooling")
	research_costs = list(TECHWEB_POINT_TYPE_GENERIC = 1000)
	export_price = 5000
	hidden = TRUE

/obj/item/circuitboard/computer/ams
/obj/item/circuitboard/computer/anti_air
/obj/item/circuitboard/machine/anti_air
/obj/item/circuitboard/machine/pdc_mount
/obj/item/circuitboard/machine/deck_turret
/obj/item/circuitboard/computer/deckgun
/obj/item/circuitboard/machine/deck_gun
/obj/item/circuitboard/machine/deck_gun/powder
/obj/item/circuitboard/machine/deck_gun/payload
/obj/item/circuitboard/machine/vls
/obj/item/circuitboard/machine/gauss_turret
/obj/item/circuitboard/machine/gauss_dispenser
/obj/item/circuitboard/machine/broadside
/obj/item/ship_weapon/parts
/obj/item/ship_weapon/parts/firing_electronics
/obj/item/ship_weapon/parts/loading_tray
/obj/item/ship_weapon/parts/railgun_rail
/obj/item/ship_weapon/parts/mac_barrel
/obj/item/ship_weapon/parts/broadside_casing
/obj/item/ship_weapon/parts/broadside_load
