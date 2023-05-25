/obj/item/disk/design_disk/deck_gun_autoelevator
	name = "Naval Artillery Cannon Autoelevator Design"
	desc = "Design blueprints for a faster-loading naval artillery cannon."
	icon_state = "datadisk2"
	max_blueprints = 1

/obj/item/disk/design_disk/deck_gun_autoelevator/Initialize(mapload)
	. = ..()
	blueprints[1] = new /datum/design/board/deck_gun_autoelevator

/obj/item/disk/design_disk/deck_gun_autorepair
	name = "Naval Artillery Cannon Auto-repair Design"
	desc = "Design blueprints for a self-repairing naval artillery cannon."
	icon_state = "datadisk0"
	max_blueprints = 1

/obj/item/disk/design_disk/deck_gun_autorepair/Initialize(mapload)
	. = ..()
	blueprints[1] = new /datum/design/board/deck_gun_autorepair

/obj/item/disk/design_disk/overmap_shields
	name = "SolGov Experimental Shielding Technology Disk"
	desc = "This disk is the property of SolGov, unlawful use of the data contained on this disk is prohibited."
	icon_state = "datadisk2"
	max_blueprints = 5

/obj/item/disk/design_disk/overmap_shields/Initialize(mapload)
	. = ..()
	var/datum/design/shield_fan/A = new
	var/datum/design/shield_capacitor/B = new
	var/datum/design/shield_modulator/C = new
	var/datum/design/shield_interface/D = new
	var/datum/design/shield_frame/E = new
	blueprints[1] = A
	blueprints[2] = B
	blueprints[3] = C
	blueprints[4] = D
	blueprints[5] = E

/obj/item/disk/design_disk/apnw_load
	name = "Experimental Nano-Repair Load Inhibitor Design"
	desc = "Design blueprints for an APNW overclock module."
	icon_state = "datadisk0"
	max_blueprints = 1

/obj/item/disk/design_disk/apnw_load/Initialize(mapload)
	. = ..()
	blueprints[1] = new /datum/design/apnw_oc_load

/obj/item/disk/design_disk/apnw_power
	name = "Experimental Nano-Repair Power Module Design"
	desc = "Design blueprints for an APNW overclock module."
	icon_state = "datadisk0"
	max_blueprints = 1

/obj/item/disk/design_disk/apnw_power/Initialize(mapload)
	. = ..()
	blueprints[1] = new /datum/design/apnw_oc_power

/obj/item/disk/design_disk/apnw_cooling
	name = "Experimental Nano-Repair Cooling Module Design"
	desc = "Design blueprints for an APNW overclock module."
	icon_state = "datadisk0"
	max_blueprints = 1

/obj/item/disk/design_disk/apnw_cooling/Initialize(mapload)
	. = ..()
	blueprints[1] = new /datum/design/apnw_oc_cooling
