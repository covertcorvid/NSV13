/// A mob on the main ship should have its get_overmap return the main ship
/datum/unit_test/basic_mob_overmap
	var/mob/living/carbon/human/dummy = null

/datum/unit_test/basic_mob_overmap/Run()
	var/turf/center = SSmapping.get_station_center()
	ASSERT(center)
	dummy = new(center)
	dummy.get_or_update_overmap()
	TEST_ASSERT_EQUAL(dummy.get_overmap(), SSstar_system.find_main_overmap(), "The mob's overmap was not the main ship")

/datum/unit_test/basic_mob_overmap/Destroy()
	QDEL_NULL(dummy)
	. = ..()

/// A mob inside a basic fighter should have its get_overmap return the fighter
/datum/unit_test/fighter_pilot_overmap
	var/obj/structure/overmap/small_craft/combat/light/fighter = null
	var/mob/living/carbon/human/dummy = null

/datum/unit_test/fighter_pilot_overmap/Run()
	for(var/obj/structure/overmap/small_craft/combat/light/OM as() in SSstar_system.find_main_overmap().overmaps_in_ship)
		fighter = OM
		break

	if(!fighter)
		var/turf/center = SSmapping.get_station_center()
		ASSERT(center)
		fighter = new (center)

	dummy = new()
	fighter.enter(dummy)
	fighter.start_piloting(dummy, OVERMAP_USER_ROLE_PILOT | OVERMAP_USER_ROLE_GUNNER)
	TEST_ASSERT_EQUAL(dummy.get_overmap(), fighter, "The mob's overmap was not the light fighter")
	fighter.stop_piloting(dummy)

/datum/unit_test/fighter_pilot_overmap/Destroy()
	QDEL_NULL(dummy)
	QDEL_NULL(fighter)
	. = ..()

/datum/unit_test/fighter_pilot_overmap/Destroy()
	QDEL_NULL(dummy)
	. = ..()

/// A fighter inside a larger ship should have its get_overmap return the ship
/datum/unit_test/fighter_on_ship
	var/obj/structure/overmap/small_craft/combat/light/fighter = null

/datum/unit_test/fighter_on_ship/Run()
	for(var/obj/structure/overmap/small_craft/combat/light/OM as() in SSstar_system.find_main_overmap().overmaps_in_ship)
		fighter = OM
		break

	if(!fighter)
		var/turf/center = SSmapping.get_station_center()
		ASSERT(center)
		fighter = new (center)

	TEST_ASSERT_EQUAL(fighter.get_overmap(), SSstar_system.find_main_overmap(), "The fighter's overmap was not the ship")

/datum/unit_test/fighter_on_ship/Destroy()
	QDEL_NULL(fighter)
	. = ..()

/// A fighter that leaves and re-enters a larger ship should have its get_overmap return null while in space, and the ship when back on the ship
/datum/unit_test/fighter_docking
	var/obj/structure/overmap/small_craft/combat/light/fighter = null

/datum/unit_test/fighter_docking/Run()
	for(var/obj/structure/overmap/small_craft/combat/light/OM as() in SSstar_system.find_main_overmap().overmaps_in_ship)
		fighter = OM
		break

	if(!fighter)
		var/turf/center = SSmapping.get_station_center()
		ASSERT(center)
		fighter = new (center)

	fighter.check_overmap_elegibility(ignore_position = TRUE, ignore_cooldown = TRUE)
	TEST_ASSERT_EQUAL(fighter.get_overmap(), null, "The fighter's overmap was not null after entering the overmap")
	fighter.transfer_from_overmap(SSstar_system.find_main_overmap())
	TEST_ASSERT_EQUAL(fighter.get_overmap(), SSstar_system.find_main_overmap(), "The fighter's overmap was not the ship after docking")

/datum/unit_test/fighter_docking/Destroy()
	QDEL_NULL(fighter)
	. = ..()
