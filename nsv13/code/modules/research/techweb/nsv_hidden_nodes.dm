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

/datum/techweb_node/missile_systems
	id = "missile_systems"
	display_name = "Missile Systems Technology"
	description = "Technology that can be used to build new missile and torpedo launchers"
	design_ids = list("ams_console", "vls_tube")
	research_costs = list(TECHWEB_POINT_TYPE_GENERIC = 1000)
	export_price = 5000
	hidden = TRUE
