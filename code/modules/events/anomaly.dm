/datum/round_event_control/anomaly
	name = "Anomaly: Energetic Flux"
	typepath = /datum/round_event/anomaly

	min_players = 1
	max_occurrences = 0 //This one probably shouldn't occur! It'd work, but it wouldn't be very fun.
	weight = 15

/datum/round_event/anomaly
	var/area/impact_area
	var/obj/effect/anomaly/anomaly_path = /obj/effect/anomaly/flux
	announceWhen	= 1


/datum/round_event/anomaly/proc/findEventArea(list/possible_areas)
	var/static/list/allowed_areas
	if(!allowed_areas)
		//Places that shouldn't explode
		var/list/safe_area_types = typecacheof(ANOMALY_AREA_BLACKLIST)

		//Subtypes from the above that actually should explode.
		var/list/unsafe_area_subtypes = typecacheof(ANOMALY_AREA_SUBTYPE_WHITELIST)

		allowed_areas = make_associative(possible_areas) - safe_area_types + unsafe_area_subtypes

	return safepick(typecache_filter_list(possible_areas,allowed_areas))

/datum/round_event/anomaly/setup()
	var/list/areas = list()
	if(length(target_Zs))  // NSV13 - added target_Zs list for event handling
		for(var/z_level in Zs)
			areas += SSmapping.areas_in_z["[z_level]"]
	impact_area = findEventArea(areas)
	if(!impact_area)
		CRASH("No valid areas for anomaly found.")
	var/list/turf_test = get_area_turfs(impact_area)
	if(!turf_test.len)
		CRASH("Anomaly : No valid turfs found for [impact_area] - [impact_area.type]")

/datum/round_event/anomaly/announce(fake)
	priority_announce("Localized energetic flux wave detected on long range scanners. Expected location of impact: [impact_area.name].", "Anomaly Alert", SSstation.announcer.get_rand_alert_sound())

/datum/round_event/anomaly/start()
	var/turf/T = safepick(get_area_turfs(impact_area))
	var/newAnomaly
	if(T)
		newAnomaly = new anomaly_path(T)
	if (newAnomaly)
		announce_to_ghosts(newAnomaly)
