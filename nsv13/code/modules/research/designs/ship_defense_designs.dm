/datum/design/shield_fan
	name = "Shield cooling fan"
	desc = "A component required for producing a shield generator."
	id = "shield_fan"
	build_type = PROTOLATHE
	materials = list(/datum/material/iron = 4000, /datum/material/titanium = 4000, /datum/material/glass = 1000)
	build_path = /obj/item/shield_component/fan
	category = list("Experimental Technology")
	departmental_flags = DEPARTMENTAL_FLAG_ENGINEERING | DEPARTMENTAL_FLAG_SCIENCE

/datum/design/shield_capacitor
	name = "Flux Capacitor"
	desc = "A component required for producing a shield generator."
	id = "shield_capacitor"
	build_type = PROTOLATHE
	materials = list(/datum/material/iron = 10000, /datum/material/uranium = 5000, /datum/material/diamond = 5000)
	build_path = /obj/item/shield_component/capacitor
	category = list("Experimental Technology")
	departmental_flags = DEPARTMENTAL_FLAG_ENGINEERING | DEPARTMENTAL_FLAG_SCIENCE

/datum/design/shield_modulator
	name = "Shield Modulator"
	desc = "A component required for producing a shield generator."
	id = "shield_modulator"
	build_type = PROTOLATHE
	materials = list(/datum/material/iron = 10000, /datum/material/uranium = 10000, /datum/material/diamond = 10000)
	build_path = /obj/item/shield_component/modulator
	category = list("Experimental Technology")
	departmental_flags = DEPARTMENTAL_FLAG_ENGINEERING | DEPARTMENTAL_FLAG_SCIENCE

/datum/design/shield_interface
	name = "Bluespace Crystal Interface"
	desc = "A component required for producing a shield generator."
	id = "shield_interface"
	build_type = PROTOLATHE
	materials = list(/datum/material/titanium = 10000, /datum/material/bluespace = MINERAL_MATERIAL_AMOUNT, /datum/material/diamond = 10000)
	build_path = /obj/item/shield_component/interface
	category = list("Experimental Technology")
	departmental_flags = DEPARTMENTAL_FLAG_ENGINEERING | DEPARTMENTAL_FLAG_SCIENCE

/datum/design/shield_frame
	name = "Shield Generator Frame"
	desc = "The basic frame of a shield generator. Assembly required, parts sold separately."
	id = "shield_frame"
	build_type = PROTOLATHE
	materials = list(/datum/material/titanium = 20000, /datum/material/iron = 20000)
	build_path = /obj/structure/shieldgen_frame
	category = list("Experimental Technology")
	departmental_flags = DEPARTMENTAL_FLAG_ENGINEERING | DEPARTMENTAL_FLAG_SCIENCE

/datum/design/apnw_oc_power
	name = "Armour Plating Nano-repair Well Overclocking Module (Overwattage)"
	desc = "Allows the allocation of additional power to the APNW - MAY CAUSE OVERHEATING"
	id = "apnw_oc_power"
	build_type = PROTOLATHE
	materials = list(/datum/material/iron = 5000, /datum/material/copper = 1000)
	build_path = /obj/item/apnw_oc_module/power
	category = list("Experimental Technology")
	departmental_flags = DEPARTMENTAL_FLAG_ENGINEERING | DEPARTMENTAL_FLAG_SCIENCE

/datum/design/apnw_oc_load
	name = "Armour Plating Nano-repair Well Overclocking Module (Overload)"
	desc = "Allows the allocation of additional system load to the APNW - MAY CAUSE VOLTAGE SPIKES"
	id = "apnw_oc_load"
	build_type = PROTOLATHE
	materials = list(/datum/material/iron = 5000, /datum/material/copper = 1000)
	build_path = /obj/item/apnw_oc_module/load
	category = list("Experimental Technology")
	departmental_flags = DEPARTMENTAL_FLAG_ENGINEERING | DEPARTMENTAL_FLAG_SCIENCE

/datum/design/apnw_oc_cooling
	name = "Armour Plating Nano-repair Well Overclocking Module (Cooling)"
	desc = "Allows the allocation of additional system load to the APNW - MAY CAUSE REALITY DISTORTIONS"
	id = "apnw_oc_cooling"
	build_type = PROTOLATHE
	materials = list(/datum/material/iron = 5000, /datum/material/copper = 1000)
	build_path = /obj/item/apnw_oc_module/cooling
	category = list("Experimental Technology")
	departmental_flags = DEPARTMENTAL_FLAG_ENGINEERING | DEPARTMENTAL_FLAG_SCIENCE
