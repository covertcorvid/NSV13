/obj/item/apnw_oc_module
	name = "Armour Plating Nano-repair Well Overclocking Module (PARENT)"
	desc = "A small electronic device that alters operational parameters of the APNW. This will likely void the warranty."
	icon = 'nsv13/icons/obj/objects.dmi'
	icon_state = "oc_module"
	w_class = 3

/obj/item/apnw_oc_module/power //Changes power cap to 10MW
	name = "Armour Plating Nano-repair Well Overclocking Module (Overwattage)"

/obj/item/apnw_oc_module/power/examine(mob/user)
	. = ..()
	. += "<span class='notice'>Allows the allocation of additional power to the APNW - MAY CAUSE OVERHEATING</span>"

/obj/item/apnw_oc_module/load //Changes stress threshold to 200%
	name = "Armour Plating Nano-repair Well Overclocking Module (Overload)"

/obj/item/apnw_oc_module/load/examine(mob/user)
	. = ..()
	. += "<span class='notice'>Allows the allocation of additional system load to the APNW - MAY CAUSE VOLTAGE SPIKES</span>"

/obj/item/apnw_oc_module/cooling //Changes stress reduction to 2.5 per cycle
	name = "Armour Plating Nano-repair Well Overclocking Module (Cooling)"

/obj/item/apnw_oc_module/cooling/examine(mob/user)
	. = ..()
	. += "<span class='notice'>Allows the allocation of additional system load to the APNW - MAY CAUSE REALITY DISTORTIONS</span>" //It really doesn't
